.. include:: ../defs.hrst

.. _Denitrification:

Denitrification
^^^^^^^^^^^^^^^

When :varlink:`DARWIN_ALLOW_DENIT` is defined in DARWIN_OPTIONS.h,
denitrification occurs, provided
:math:`{\mathrm{O}}_2<{\mathrm{O}}_2^{{\text{crit}}}`,

.. math::

     D_{\op{NH4}} &= r_{\op{DON}} \op{DON} + (r_{\op{PON}} \op{PON})

     D_{\op{NO3}} &= \op{denit\_NO3} \cdot \bigl(r_{\op{DOP}} \op{DOP} +
                     (r_{\op{POP}} \op{POP}) \bigr)

(the particulate organic terms are not present with :varlink:`DARWIN_ALLOW_CDOM`).

The diagnostic 'Denit' is this:

.. math::

     \op{Denit} = \op{denit\_NP} \cdot  \bigl(r_{\op{DOP}} \op{DOP} +
                     (r_{\op{POP}} \op{POP}) \bigr)


Also, provided :math:`{\mathrm{O}}_2<{\mathrm{O}}_2^{{\text{crit}}}` and
:math:`\op{NO}_3<\op{NO}_3^{{\text{crit}}}`, all remineralization,
denitrification and CDOM degradation (except bleaching) stops.

