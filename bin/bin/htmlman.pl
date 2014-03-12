#!/usr/bin/perl
# $Id: htmlman.pl 4036 2010-04-13 23:16:41Z agriffis $
# 
# htmlman.pl -- generate simple HTML output for manual pages
# Written by Aron Griffis as a response to
# http://rwmj.wordpress.com/2009/10/12/ocaml-autoconf-macros-1-1/
#
# Copyright Aron Griffis <agriffis@n01se.net>, 2009
# Released under the GNU Affero General Public License v3

$^W = 1;
use HTML::Tiny;
use strict;

# LC_ALL=C prevents multibyte characters in the man output, because Perl's open
# doesn't respect locale environment settings unless perl executes with -C, and
# then "." doesn't match the multibyte characters in the text.
# Since the resulting html is likely to be posted on the web, and we don't want
# to deal with encodings of the output, forcing ASCII is probably good enough.
open F, "env LC_ALL=C MANWIDTH=72 MAN_KEEP_FORMATTING=1 man -P cat --no-hyphenation $ARGV[0]|" or die;
my $txt = do { local $/=undef; scalar <F> };
my $html = HTML::Tiny->new(mode => 'html')->entity_encode($txt);

# _^H_ is ambiguous:
# In context of a bolded string, it's a bolded underscore.
# In context of an underlined string, it's an underlined underscore.
# Furthermore bold/underline strings might be directly adjacent.
# We loop to find word starts and resolve the ambiguity.

my $ent = '&[^;]+;';

LOOP: {
    $html =~ s{
        (?<!\010.)                # don't start mid-word
        (?:_\010_)*               # leading ambiguous underscores
        _\010(?:$ent|[^_])        # unambiguous underlined character
        (?:_\010(?:$ent|.))*      # underlined characters
    }{
        (my $s = $&) =~ s/_\010//g;
        "<u>$s</u>"
    }gxeo;

    redo LOOP if $html =~ s{
        (?<!\010.)                # don't start mid-word
        (?:_\010_)*               # leading ambiguous underscores
        ($ent|[^_])\010\g{-1}     # unambiguous bolded character
        (?:($ent|.)\010\g{-1})*   # bolded characters
    }{
        (my $s = $&) =~ s/(?:$ent|.)\010//g;
        "<b>$s</b>"
    }gxeo;

    # assume bold for standalone underscores
    $html =~ s{
        (?:_\010_)+
    }{
        (my $s = $&) =~ s/_\010//g;
        "<b>$s</b>"
    }gxe;
}

if ($html =~ /.*\010.*/) {
    open FAIL, "|cat -v >&2";
    print FAIL "failed to resolve: $&\n";
    exit 1;
}

# Simplify formatted chains, 
#       <b>one</b> <b>two</b>
# becomes
#       <b>one two</b>
$html =~ s#</([bu])>( +)<\1>#$2#g;

print "<pre>\n";
print $html;
print "</pre>\n";
