# hipchat_backlog.py -- fix Message from unknown participant junk
# Copyright 2012, Aron Griffis <aron@arongriffis.com>
# Released under GNU GPL v2
#
# 2012-08-01, Aron Griffis <aron@arongriffis.com>
#     0.1: initial release

import weechat, string, sys, binascii, re, array

weechat.register("hipchat_backlog", "agriffis", "0.1", "GPL", "fix hipchat backlog", "", "")

import pybuffer
debug = pybuffer.debugBuffer(globals(), "py")

# struct t_hook
# *weechat_hook_modifier (const char *modifier,
#                         char *(*callback)(void *data,
#                                           const char *modifier,
#                                           const char *modifier_data,
#                                           const char *string),
#                         void *callback_data);
weechat.hook_modifier("weechat_print", "hipchat_backlog", "")


def hipchat_backlog(data, modifier, modifier_data, string):
    plugin, buffer_name, tags = modifier_data.split(';', 2)
    tags = tags.split(',')

    if not buffer_name.startswith('bitlbee.'):
        return string

    if 'nick_root' in tags and 'unknown participant' in string:
        string, tags = resolve_unknown_participant(string, tags)

    if 'nick_assembla' in tags:
        string = highlight_assembla(string)

    if 'nick_deployment' in tags:
        string = highlight_deployment(string)

    return string


def resolve_unknown_participant(string, tags):
    matched = re.match(r'''(?x)
                       .*?root.*?(>.*?)
                       Message.from.unknown.participant.(\w+)
                       .*?:\s+(.*)
                       ''', string)
    if matched:
        author = matched.group(2).lower()
        string = ''.join(['<-',
                          author,
                          matched.group(1),
                          matched.group(3),
                         ])
        tags = list(tags)
        tags.remove('nick_root')
        tags.append('nick_%s' % author)
    return string, tags


seen = set()

def highlight_assembla(string):
    nick, msg = string.split('\t', 1)
    matched = re.match(r'''(?x)
        (.*?) \s+ (.*?): \s+
        <a \s+ href=" (.*?) [?#"] .*?>
        (?:Changeset|Re:)? \s* (.*?)
        </a>
        ''', msg)
    if matched:
        user, action, link, thing = matched.groups()
        if action == 'created' and thing in seen:
            action = 'updated'
        seen.add(thing)
        color = 'red' if action == 'committed' else 'yellow'
        string = '{color}{user} {action} {thing}  {blue}{link}'.format(
            color=weechat.color(color),
            user=user,
            action=action,
            thing=thing,
            blue=weechat.color('blue'),
            link=link)
    return string


def highlight_deployment(string):
    nick, msg = string.split('\t', 1)
    return (# weechat.color('chat_prefix_action') +
            # ' *\t' +
            weechat.color('*red') +
            msg)


def debug_log(s):
    with open('/home/aron/debug.log', 'a') as f:
        f.write(s)
        if not s[-1] == '\n':
            f.write('\n')
