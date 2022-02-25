-- init.lua
--
-- Written in 2003-2022 by Aron Griffis <aron@arongriffis.com>
-- (originally as .vimrc)
--
-- To the extent possible under law, the author(s) have dedicated all copyright
-- and related and neighboring rights to this software to the public domain
-- worldwide. This software is distributed without any warranty.
--
-- CC0 Public Domain Dedication at
-- http://creativecommons.org/publicdomain/zero/1.0/
--------------------------------------------------------------------------------

-- Make my.* available everywhere
_G.my = require('my')

-- Default global settings
require('settings')

-- Plugins loaded via Packer
require('plugins')

-- Post-plugin stuff is in after/plugin/caboose.lua
