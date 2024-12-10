import sys
import os
import re
from collections import OrderedDict

__all__ = ['readparameters']

def readparameters(*files, **kwargs):
    '''
    extracts fortran parameters from header files with CPP directives

    The arguments are file names or open files.

    Keyword arguments:

    dir        :: directory for include files
    conditions :: return a dictionary with CPP conditions for each parameter
    sloppy     :: ignore missing include files

    Returns a dictionary of parameter names and values and, if <conditions> is
    true, a dictionary of CPP conditions.
    '''
    sloppy = kwargs.pop('sloppy', False)
    returnconditions = kwargs.pop('conditions', False)

    dir = kwargs.pop('dir', '.')
    assert len(kwargs) == 0

    filestack = []
    for f in files:
        if not hasattr(f,'readlines'):
            f = open(f)
        filestack[:0] = [f]

    conds = {}

    code = ''
    cond = []
    varlist = []
    while len(filestack):
        file = filestack[-1]
        for line in file:
            m = re.match(r'^ *# *include *"([^"]*)"', line)
            if m:
                fname = os.path.join(dir, m.group(1))
                try:
                    file = open(fname)
                except IOError:
                    if not sloppy:
                        raise
                else:
                    filestack.append(file)
                continue

            m = re.match(r'^ *# *ifn?def  *(\S*)', line)
            if m:
                cond.append(line)
                continue

            m = re.match(r'^ *# *endif', line)
            if m:
                cond.pop()
                continue

            m = re.match(r'^ *parameter *\( *(.*) *\)', line, re.IGNORECASE)
            if m:
                codeline = m.group(1)
                codeline = re.sub(r',', ';', codeline)
                codeline = re.sub(r'\bin\b', 'IN', codeline)
                code += codeline + '\n'
                try:
                    name,val = m.group(1).split('=')
                except ValueError:
                    pass
                else:
                    conds[name.strip().lower()] = list(cond)
                    varlist.append(name.strip())
        filestack.remove(file)

#    d = OrderedDict()
    d = dict()
    exec(code, d)
    dnew = OrderedDict.fromkeys(varlist)
    for k,v in d.items():
        if k == 'IN':
            k = 'in'
        dnew[k] = v
    d = dnew

    try:
        del d['__builtins__']
    except:
        pass

    if returnconditions:
        return d, conds
    else:
        return d


if __name__ == '__main__':
    d = readparameters(*sys.argv[1:])
    wid = max(len(k) for k in d)
#    for k,v in d.items():
#        print '{0:{1}s} = {2}'.format(k, wid, v)

