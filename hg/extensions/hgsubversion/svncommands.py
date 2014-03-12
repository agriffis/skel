import os
import posixpath
import cPickle as pickle
import sys
import traceback
import urlparse

from mercurial import commands
from mercurial import hg
from mercurial import node
from mercurial import util as hgutil
from mercurial import error

import maps
import svnwrap
import svnrepo
import util
import svnexternals
import verify


def updatemeta(ui, repo, args, **opts):
    """Do a partial rebuild of the subversion metadata.

    Assumes that the metadata that currently exists is valid, but that
    some is missing, e.g. because you have pulled some revisions via a
    native mercurial method.

    """

    return _buildmeta(ui, repo, args, partial=True)


def rebuildmeta(ui, repo, args, unsafe_skip_uuid_check=False, **opts):
    """rebuild hgsubversion metadata using values stored in revisions
    """
    return _buildmeta(ui, repo, args, partial=False,
                      skipuuid=unsafe_skip_uuid_check)

def _buildmeta(ui, repo, args, partial=False, skipuuid=False):

    if repo is None:
        raise error.RepoError("There is no Mercurial repository"
                              " here (.hg not found)")

    dest = None
    if len(args) == 1:
        dest = args[0]
    elif len(args) > 1:
        raise hgutil.Abort('rebuildmeta takes 1 or no arguments')
    uuid = None
    url = repo.ui.expandpath(dest or repo.ui.config('paths', 'default-push') or
                             repo.ui.config('paths', 'default') or '')
    svn = svnrepo.svnremoterepo(ui, url).svn
    subdir = svn.subdir
    svnmetadir = os.path.join(repo.path, 'svn')
    if not os.path.exists(svnmetadir):
        os.makedirs(svnmetadir)

    youngest = 0
    startrev = 0
    sofar = []
    branchinfo = {}
    if partial:
        try:
            youngestpath = os.path.join(svnmetadir, 'lastpulled')
            foundpartialinfo = False
            if os.path.exists(youngestpath):
                youngest = int(util.load_string(youngestpath).strip())
                sofar = list(maps.RevMap.readmapfile(repo))
                if sofar and len(sofar[-1].split(' ', 2)) > 1:
                    lasthash = sofar[-1].split(' ', 2)[1]
                    startrev = repo[lasthash].rev() + 1
                    branchinfo = pickle.load(open(os.path.join(svnmetadir,
                                                           'branch_info')))
                    foundpartialinfo = True
            if not foundpartialinfo:
                ui.status('missing some metadata -- doing a full rebuild\n')
                partial = False
        except IOError, err:
            if err.errno != errno.ENOENT:
                raise
            ui.status('missing some metadata -- doing a full rebuild')
        except AttributeError:
            ui.status('no metadata available -- doing a full rebuild')


    lastpulled = open(os.path.join(svnmetadir, 'lastpulled'), 'wb')
    revmap = open(os.path.join(svnmetadir, 'rev_map'), 'w')
    revmap.write('1\n')
    revmap.writelines(sofar)
    last_rev = -1
    tagfile = os.path.join(svnmetadir, 'tagmap')
    if not partial and os.path.exists(maps.Tags.filepath(repo)) :
        os.unlink(maps.Tags.filepath(repo))
    tags = maps.Tags(repo)

    layout = None

    skipped = set()
    closed = set()

    numrevs = len(repo) - startrev

    subdirfile = open(os.path.join(svnmetadir, 'subdir'), 'w')
    subdirfile.write(subdir.strip('/'))
    subdirfile.close()

    # ctx.children() visits all revisions in the repository after ctx. Calling
    # it would make us use O(revisions^2) time, so we perform an extra traversal
    # of the repository instead. During this traversal, we find all converted
    # changesets that close a branch, and store their first parent
    for rev in xrange(startrev, len(repo)):
        util.progress(ui, 'prepare', rev - startrev, total=numrevs)
        ctx = repo[rev]
        convinfo = util.getsvnrev(ctx, None)
        if not convinfo:
            continue
        svnrevnum = int(convinfo.rsplit('@', 1)[1])
        youngest = max(youngest, svnrevnum)

        if ctx.extra().get('close', None) is None:
            continue

        droprev = lambda x: x.rsplit('@', 1)[0]
        parentctx = ctx.parents()[0]
        parentinfo = util.getsvnrev(parentctx, '@')

        if droprev(parentinfo) == droprev(convinfo):
            if parentctx.rev() < startrev:
                parentbranch = parentctx.branch()
                if parentbranch == 'default':
                    parentbranch = None
                branchinfo.pop(parentbranch)
            else:
                closed.add(parentctx.rev())

    lastpulled.write(str(youngest) + '\n')
    util.progress(ui, 'prepare', None, total=numrevs)

    for rev in xrange(startrev, len(repo)):
        util.progress(ui, 'rebuild', rev-startrev, total=numrevs)
        ctx = repo[rev]
        convinfo = util.getsvnrev(ctx, None)
        if not convinfo:
            continue
        if '.hgtags' in ctx.files():
            parent = ctx.parents()[0]
            parentdata = ''
            if '.hgtags' in parent:
                parentdata = parent.filectx('.hgtags').data()
            newdata = ctx.filectx('.hgtags').data()
            for newtag in newdata[len(parentdata):-1].split('\n'):
                ha, tag = newtag.split(' ', 1)
                tagged = util.getsvnrev(repo[ha], None)
                if tagged is None:
                    tagged = -1
                else:
                    tagged = int(tagged[40:].split('@')[1])
                # This is max(tagged rev, tagging rev) because if it is a normal
                # tag, the tagging revision has the right rev number. However, if it
                # was an edited tag, then the tagged revision has the correct revision
                # number.
                tagging = int(convinfo[40:].split('@')[1])
                tagrev = max(tagged, tagging)
                tags[tag] = node.bin(ha), tagrev

        # check that the conversion metadata matches expectations
        assert convinfo.startswith('svn:')
        revpath, revision = convinfo[40:].split('@')
        if subdir and subdir[0] != '/':
            subdir = '/' + subdir
        if subdir and subdir[-1] == '/':
            subdir = subdir[:-1]
        assert revpath.startswith(subdir), ('That does not look like the '
                                            'right location in the repo.')

        if layout is None:
            if (subdir or '/') == revpath:
                layout = 'single'
            else:
                layout = 'standard'
            f = open(os.path.join(svnmetadir, 'layout'), 'w')
            f.write(layout)
            f.close()
        elif layout == 'single':
            assert (subdir or '/') == revpath, ('Possible layout detection'
                                                ' defect in replay')

        # write repository uuid if required
        if uuid is None:
            uuid = convinfo[4:40]
            if not skipuuid:
                if uuid != svn.uuid:
                    raise hgutil.Abort('remote svn repository identifier '
                                       'does not match')
            uuidfile = open(os.path.join(svnmetadir, 'uuid'), 'w')
            uuidfile.write(svn.uuid)
            uuidfile.close()

        # don't reflect closed branches
        if (ctx.extra().get('close') and not ctx.files() or
            ctx.parents()[0].node() in skipped):
            skipped.add(ctx.node())
            continue

        # find commitpath, write to revmap
        commitpath = revpath[len(subdir)+1:]
        if layout == 'standard':
            if commitpath.startswith('branches/'):
                commitpath = commitpath[len('branches/'):]
            elif commitpath == 'trunk':
                commitpath = ''
            else:
                if commitpath.startswith('tags/') and ctx.extra().get('close'):
                    continue
                commitpath = '../' + commitpath
        else:
            commitpath = ''
        revmap.write('%s %s %s\n' % (revision, ctx.hex(), commitpath))

        revision = int(revision)
        if revision > last_rev:
            last_rev = revision

        # deal with branches
        if not commitpath:
            branch = None
        elif not commitpath.startswith('../'):
            branch = commitpath
        elif ctx.parents()[0].node() != node.nullid:
            parent = ctx
            while parent.node() != node.nullid:
                parentextra = parent.extra()
                parentinfo = util.getsvnrev(parent)
                assert parentinfo
                parent = parent.parents()[0]

                parentpath = parentinfo[40:].split('@')[0][len(subdir) + 1:]

                if parentpath.startswith('tags/') and parentextra.get('close'):
                    continue
                elif parentpath.startswith('branches/'):
                    branch = parentpath[len('branches/'):]
                elif parentpath == 'trunk':
                    branch = None
                else:
                    branch = '../' + parentpath
                break
        else:
            branch = commitpath

        if rev in closed:
            # a direct child of this changeset closes the branch; drop it
            branchinfo.pop(branch, None)
        elif ctx.extra().get('close'):
            pass
        elif branch not in branchinfo:
            parent = ctx.parents()[0]
            if (parent.node() not in skipped
                and util.getsvnrev(parent, '').startswith('svn:')
                and parent.branch() != ctx.branch()):
                parentbranch = parent.branch()
                if parentbranch == 'default':
                    parentbranch = None
            else:
                parentbranch = None
            # branchinfo is a map from mercurial branch to a
            # (svn branch, svn parent revision, svn revision) tuple
            parentrev = util.getsvnrev(parent, '@').split('@')[1] or 0
            branchinfo[branch] = (parentbranch,
                                  int(parentrev),
                                  revision)

    util.progress(ui, 'rebuild', None, total=numrevs)

    # save off branch info
    branchinfofile = open(os.path.join(svnmetadir, 'branch_info'), 'w')
    pickle.dump(branchinfo, branchinfofile)
    branchinfofile.close()


def help_(ui, args=None, **opts):
    """show help for a given subcommands or a help overview
    """
    if args:
        subcommand = args[0]
        if subcommand not in table:
            candidates = []
            for c in table:
                if c.startswith(subcommand):
                    candidates.append(c)
            if len(candidates) == 1:
                subcommand = candidates[0]
            elif len(candidates) > 1:
                raise error.AmbiguousCommand(subcommand, candidates)
                return
        doc = table[subcommand].__doc__
        if doc is None:
            doc = "No documentation available for %s." % subcommand
        ui.status(doc.strip(), '\n')
        return
    commands.help_(ui, 'svn')


def update(ui, args, repo, clean=False, **opts):
    """update to a specified Subversion revision number
    """

    try:
        rev = int(args[0])
    except IndexError:
        raise error.CommandError('svn',
                                 "no revision number specified for 'update'")
    except ValueError:
        raise error.Abort("'%s' is not a valid Subversion revision number"
                          % args[0])

    meta = repo.svnmeta()

    answers = []
    for k, v in meta.revmap.iteritems():
        if k[0] == rev:
            answers.append((v, k[1]))

    if len(answers) == 1:
        if clean:
            return hg.clean(repo, answers[0][0])
        return hg.update(repo, answers[0][0])
    elif len(answers) == 0:
        ui.status('revision %s did not produce an hg revision\n' % rev)
        return 1
    else:
        ui.status('ambiguous revision!\n')
        revs = ['%s on %s' % (node.hex(a[0]), a[1]) for a in answers] + ['']
        ui.status('\n'.join(revs))
    return 1


def genignore(ui, repo, force=False, **opts):
    """generate .hgignore from svn:ignore properties.
    """

    if repo is None:
        raise error.RepoError("There is no Mercurial repository"
                              " here (.hg not found)")

    ignpath = repo.wjoin('.hgignore')
    if not force and os.path.exists(ignpath):
        raise hgutil.Abort('not overwriting existing .hgignore, try --force?')
    svn = svnrepo.svnremoterepo(repo.ui).svn
    meta = repo.svnmeta()
    hashes = meta.revmap.hashes()
    parent = util.parentrev(ui, repo, meta, hashes)
    r, br = hashes[parent.node()]
    if meta.layout == 'single':
        branchpath = ''
    else:
        branchpath = br and ('branches/%s/' % br) or 'trunk/'
    ignorelines = ['.hgignore', 'syntax:glob']
    dirs = [''] + [d[0] for d in svn.list_files(branchpath, r)
                   if d[1] == 'd']
    for dir in dirs:
        path = '%s%s' % (branchpath, dir)
        props = svn.list_props(path, r)
        if 'svn:ignore' not in props:
            continue
        lines = props['svn:ignore'].strip().split('\n')
        ignorelines += [dir and (dir + '/' + prop) or prop for prop in lines]

    repo.wopener('.hgignore', 'w').write('\n'.join(ignorelines) + '\n')


def info(ui, repo, **opts):
    """show Subversion details similar to `svn info'
    """

    if repo is None:
        raise error.RepoError("There is no Mercurial repository"
                              " here (.hg not found)")

    meta = repo.svnmeta()
    hashes = meta.revmap.hashes()

    if opts.get('rev'):
        parent = repo[opts['rev']]
    else:
        parent = util.parentrev(ui, repo, meta, hashes)

    pn = parent.node()
    if pn not in hashes:
        ui.status('Not a child of an svn revision.\n')
        return 0
    r, br = hashes[pn]
    subdir = util.getsvnrev(parent)[40:].split('@')[0]
    if meta.layout == 'single':
        branchpath = ''
    elif br == None:
        branchpath = '/trunk'
    elif br.startswith('../'):
        branchpath = '/%s' % br[3:]
        subdir = subdir.replace('branches/../', '')
    else:
        branchpath = '/branches/%s' % br
    remoterepo = svnrepo.svnremoterepo(repo.ui)
    url = '%s%s' % (remoterepo.svnurl, branchpath)
    author = meta.authors.reverselookup(parent.user())
    # cleverly figure out repo root w/o actually contacting the server
    reporoot = url[:len(url)-len(subdir)]
    ui.write('''URL: %(url)s
Repository Root: %(reporoot)s
Repository UUID: %(uuid)s
Revision: %(revision)s
Node Kind: directory
Last Changed Author: %(author)s
Last Changed Rev: %(revision)s
Last Changed Date: %(date)s\n''' %
              {'reporoot': reporoot,
               'uuid': meta.uuid,
               'url': url,
               'author': author,
               'revision': r,
               # TODO I'd like to format this to the user's local TZ if possible
               'date': hgutil.datestr(parent.date(),
                                      '%Y-%m-%d %H:%M:%S %1%2 (%a, %d %b %Y)')
              })


def listauthors(ui, args, authors=None, **opts):
    """list all authors in a Subversion repository
    """
    if not len(args):
        ui.status('No repository specified.\n')
        return
    svn = svnrepo.svnremoterepo(ui, args[0]).svn
    author_set = set()
    for rev in svn.revisions():
        if rev.author is None:
            author_set.add('(no author)')
        else:
            author_set.add(rev.author)
    if authors:
        authorfile = open(authors, 'w')
        authorfile.write('%s=\n' % '=\n'.join(sorted(author_set)))
        authorfile.close()
    else:
        ui.write('%s\n' % '\n'.join(sorted(author_set)))


def _helpgen():
    ret = ['subcommands for Subversion integration', '',
           'list of subcommands:', '']
    for name, func in sorted(table.items()):
        if func.__doc__:
            short_description = func.__doc__.splitlines()[0]
        else:
            short_description = ''
        ret.append(" :%s: %s" % (name, short_description))
    return '\n'.join(ret) + '\n'

def svn(ui, repo, subcommand, *args, **opts):
    '''see detailed help for list of subcommands'''

    # guess command if prefix
    if subcommand not in table:
        candidates = []
        for c in table:
            if c.startswith(subcommand):
                candidates.append(c)
        if len(candidates) == 1:
            subcommand = candidates[0]
        elif not candidates:
            raise error.CommandError('svn',
                                     "unknown subcommand '%s'" % subcommand)
        else:
            raise error.AmbiguousCommand(subcommand, candidates)

    # override subversion credentials
    for key in ('username', 'password'):
        if key in opts:
            ui.setconfig('hgsubversion', key, opts[key])

    try:
        commandfunc = table[subcommand]
        return commandfunc(ui, args=args, repo=repo, **opts)
    except svnwrap.SubversionConnectionException, e:
        raise hgutil.Abort(*e.args)
    except TypeError:
        tb = traceback.extract_tb(sys.exc_info()[2])
        if len(tb) == 1:
            ui.status('Bad arguments for subcommand %s\n' % subcommand)
        else:
            raise
    except KeyError, e:
        tb = traceback.extract_tb(sys.exc_info()[2])
        if len(tb) == 1:
            ui.status('Unknown subcommand %s\n' % subcommand)
        else:
            raise

table = {
    'genignore': genignore,
    'info': info,
    'listauthors': listauthors,
    'update': update,
    'help': help_,
    'updatemeta': updatemeta,
    'rebuildmeta': rebuildmeta,
    'updateexternals': svnexternals.updateexternals,
    'verify': verify.verify,
}
svn.__doc__ = _helpgen()
