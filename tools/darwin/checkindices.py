'''
Generates lists of the names of ptracers used by the darwin package.
Separate lists are created for numbered tracers (like biomasses of a sequence
of plankton types) and others.  These lists are used for code generation
in the darwin package.
'''

__all__ = ['checkflds', 'checklflds']

import fortran

p,conds = fortran.readparameters('DARWIN_SIZE.h', 'DARWIN_INDICES.h', conditions=True)
conditional = {}
for k,v in conds.items():
    v = [c for c in v if not c.endswith('ALLOW_DARWIN\n')]
    if k[0] == 'i' and len(v):
        conditional[k[1:]] = (''.join(v), len(v)*'#endif\n')

checkflds = []
checklflds = []
for k in p:
    if k[0] == 'i' and k[1:4] not in ['Min', 'Max']:
        name = k[1:]
        pre,suf = conditional.get(name.lower(), ('', ''))
        if 'e'+name in p:
            checklflds.append((name, '{0:<5s}'.format(name), pre, suf))
        else:
            checkflds.append((name, '{0:<6s}'.format(name), pre, suf))

