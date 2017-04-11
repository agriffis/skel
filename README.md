If you're reading this, then you're either a future me trying to make sense of
past cleverness, or you've stumbled in here by accident. Or both.

If you're not me
----------------

These are my dotfiles. Feel free to browse and grab anything that works
for you. Licenses vary by whatever seemed to make sense at the time of writing.
If you'd like to use something but the license worries you, file an issue and
I'll probably be happy to change it
to [CC0](https://wiki.creativecommons.org/wiki/CC0) or whatever.

Installing in a new homedir
---------------------------

Clone from github, then use [GNU stow](https://www.gnu.org/software/stow/) to
install these into a new home directory.

    cd Sync  # syncthing
    git clone --recursive git@github.com:agriffis/skel.git skel
    cd skel
    stow -S */

What makes stow special is its ability to merge symlinks from
[multiple source directories](https://www.gnu.org/software/stow/manual/stow.html#Multiple-Stow-Directories),
so I have a second set of dotfiles (credentials and other personal
stuff) that I manage with [Syncthing](https://syncthing.net/):

    cd Sync/skel2
    stow -S */
    
Git submodules
--------------

This repo uses git submodules for emacs (spacemacs) and vim pathogen modules,
that's why the initial clone uses `--recursive`.

To update an individual module, change to the dir and pull, then commit the
result in this repo. For example:

    cd emacs/.emacs.d
    git -C emacs/.emacs.d pull
    git commit -am "update spacemacs"

To update all the modules to what's available upstream:

    git submodule update --remote
    git commit -am "update submodules"

To update to the revs specified by another checkout of this repo:

    git submodule sync
    git submodule update

Or something like that. GIYF.

Stow folding hack
-----------------

Just one more detail:
[tree folding](https://www.gnu.org/software/stow/manual/stow.html#Installing-Packages).
Stow does this awesome thing where it uses as few symlinks as possible, by
symlinking to a dir rather than to individual files. However occasionally there
are situations where I'd like to control the level at which this is done.

For example I want `.vim/swap` to be a proper directory on my home filesystem,
so `.vim` shouldn't be a symlink into `.skel`. To make that work, there are
two files in this tree:

    vim/.vim/swap/.stow-unfold-hack
    vim-/.vim/swap/.stow-unfold-hack-

Since these are separate top-level packages (`vim` and `vim-`) which install
files into the same directory (`.vim/swap`), stow will create the actual dir on
the filesystem with individual symlinks for the two files.
