#!/usr/bin/perl
# $XFree86: xc/programs/xterm/vttests/88colors.pl,v 1.1 1999/09/25 14:38:51 dawes Exp $
# Made from 256colors.pl

for ($fg = 0; $fg < 88; $fg++) {
    print "\x1b[38;5;${fg}m";
    printf "%03.3d ", $fg;
}
print "\n";
