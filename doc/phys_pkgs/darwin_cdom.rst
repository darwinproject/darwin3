.. include:: ../defs.hrst

.. _CDOM:

Dynamic CDOM
^^^^^^^^^^^^

To enable dynamic CDOM, define :varlink:`DARWIN_ALLOW_CDOM` in DARWIN_OPTIONS.h.
Remineralization of particulate organic matter to inorganic matter is then
replaced by

.. math::

     \partial_t\op{CDOM} &= f_{\op{CDOM}} (r_{\op{POP}} \op{POP}+ g^{\op{DOP}}) - D_{\op{CDOM}}

     \partial_t\op{DOP} &= \dots + D_{\op{CDOM}} - f_{\op{CDOM}} (r_{\op{POP}} \op{POP}+ g^{\op{DOP}})

     \partial_t\op{DOC} &= \dots + R^{{\mathrm{C}}:{\mathrm{P}}}_{\op{CDOM}} (D_{\op{CDOM}} - f_{\op{CDOM}} (r_{\op{POP}} \op{POP}+ g^{\op{DOP}}))

     \partial_t\op{DON} &= \dots + R^{{\mathrm{N}}:{\mathrm{P}}}_{\op{CDOM}} (D_{\op{CDOM}} - f_{\op{CDOM}} (r_{\op{POP}} \op{POP}+ g^{\op{DOP}}))

     \partial_t\op{DOFe} &= \dots + R^{\op{Fe}:{\mathrm{P}}}_{\op{CDOM}}(D_{\op{CDOM}} - f_{\op{CDOM}} (r_{\op{POP}} \op{POP}+ g^{\op{DOP}}))

where

.. math::

     D_{\op{CDOM}} = \left( r^{\op{degrad}}_{\op{CDOM}}
                     + r^{\op{bleach}}_{\op{CDOM}} \min(1, I/I_{\op{CDOM}}) \right)
                f^{{{\text{remin}}}}(T) \cdot \op{CDOM}

(CDOM is still in P units.)

