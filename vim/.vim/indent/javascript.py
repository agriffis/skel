import vim, re, sys
from jslex import JsLexer

def quote(s):
    return "'" + s.replace("'", "''") + "'"

def echom(s):
    if vim.eval('g:js_indent_wip'):
        vim.command("echom %s" % quote(s))

def get_js_indent(lnum):
    # Collect the lines prior to and excluding this one.
    # Note that vim's lnum is 1-based.
    lines_before = vim.current.buffer[0:lnum-1]
    js = '\n'.join(lines_before)

    # Kill everything up to the script tag
    js = re.sub(r'(?s)^.*<script[^>]*>', '', js, count=1)

    # Find the initial whitespace on the first line of code.
    # This is hokey and should be moved into the loop below, especially when we
    # implement a heuristic for finding a "good" place to start parsing.
    initial = re.match(r'\s*', js).group(0).rsplit('\n', 1)[-1]

    stack = [('root', initial)]
    for name, tok in JsLexer().lex(js):
        if name == 'ws' and '\n' in tok:
            if stack[-1][0] == 'if' and stack[-1][1] is not None:
                stack.pop()
            elif stack[-1][1] is None:
                ws = tok.rsplit('\n', 1)[1]
                stack[-1] = (stack[-1][0], ws)
        elif name == 'punct':
            if tok in ['{', '(', '[']:
                stack.append((tok, None))
            elif tok in ['}', ')', ']']:
                stack.pop()
            elif tok == ';' and stack[-1][0] == 'if':
                stack.pop()
#       elif name == 'keyword' and tok == 'if':
#           stack.append((tok, None))

    if re.match(r'\s*[])}]', vim.current.buffer[lnum-1]):
        stack.pop()

    if stack[-1][1] is None:
        prevind = next(s[1] for s in reversed(stack) if s[1] is not None)
        sw = int(vim.eval('&sw'))
        ind = len(prevind) + sw
    else:
        ind = len(stack[-1][1])

    echom("stack=%r" % stack)
    return ind
