.. include:: ../defs.hrst

.. _CarbonChemistry:

Carbon chemistry
^^^^^^^^^^^^^^^^

.. math::

     \partial_t\op{ALK} &= -\biggl( P_{\op{NO3}} - \sum_j U^{\op{NO3}}_j \biggr)
       - 2\biggl( \sum_j P^{\mathrm{C}}_j {c}_j R^{{\text{PIC:POC}}}_j - \kappa^{{\text{diss}}}_{\mathrm{C}}\op{PIC}\biggr)
       + D_{\op{NO3}}

     \partial_t{\mathrm{O}}_2 &= R_{{\mathrm{O}}:{\mathrm{P}}} \biggl( \sum_j U^{\op{PO4}}_j
              - r_{\op{DOP}} \op{DOP}- (r_{\op{POP}} \op{POP})
            \biggr)

The POP term is not present with :varlink:`DARWIN_ALLOW_CDOM`.

…surface forcing …

