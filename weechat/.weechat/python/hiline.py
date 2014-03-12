# hiline.py -- highlight full line instead of just nick
# Copyright 2010, Aron Griffis <agriffis@n01se.net>
# Released under GNU GPL v2
#
# 2010-02-20, Aron Griffis <agriffis@n01se.net>
#     0.1: initial release

import weechat, string, sys, binascii, re, array

weechat.register("hiline", "agriffis", "0.1", "GPL", "extend highlighting to full line", "", "")

# struct t_hook
# *weechat_hook_modifier (const char *modifier,
#                         char *(*callback)(void *data,
#                                           const char *modifier,
#                                           const char *modifier_data,
#                                           const char *string),
#                         void *callback_data);
weechat.hook_modifier("weechat_print", "hiline_cb", "")

def tohex(matchobj):
    return hex(ord(matchobj.group(0)))

def hiline_cb(data, modifier, modifier_data, string):
    for c in string:
        if ord(c) >= 0x20:
            sys.stderr.write(str(c) + "\n")
        else:
            sys.stderr.write(hex(ord(c)) + "\n")
    #sys.stderr.write(re.sub(r'[^\040-\176]', tohex, string) + "\n")
    return string
