" $Id$
" Vim plugin for working in a virtualenv

if ! exists('$VIRTUAL_ENV')
  finish
endif

if ! exists('g:virtualenv_augment_default')
  " Often a virtualenv is created with --no-site-packages.
  " That's great for project isolation, but vim python plugins might depend
  " on the system site-packages, so this is 1 by default.
  let g:virtualenv_augment_default = 1
endif

if has('python')
  let s:syspath = system('python -c "import sys; print repr(sys.path)"')
  if v:shell_error == 0
    let s:syspath = s:syspath[0:-2]  " trim newline
    exec "python virtualenv_syspath = " . s:syspath
    if g:virtualenv_augment_default
      python sys.path = virtualenv_syspath + sys.path
    else
      python sys.path = virtualenv_syspath
    endif
  endif
endif
