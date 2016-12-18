Um, hi. These are my dotfiles. Feel free to browse and grab anything that works
for you. Licenses vary by whatever seemed to make sense at the time of writing.
If you'd like to use something but the license worries you, file an issue and
I'll probably be happy to change it
to [CC0](https://wiki.creativecommons.org/wiki/CC0) or whatever.

I use [GNU stow](https://www.gnu.org/software/stow/) to install these into my
home directory. It works like this:

    git clone git@github.com:agriffis/skel.git .skel
    cd .skel
    stow/bin/stow -S */

Stow's special feature is its ability to merge symlinks from
[multiple source directories](https://www.gnu.org/software/stow/manual/stow.html#Multiple-Stow-Directories),
so I have a second set of dotfiles (credentials and other personal
stuff) that I manage with [Syncthing](https://syncthing.net/):

    cd Sync/.skel
    stow -S */

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
