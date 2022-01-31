.. include:: ../defs.hrst

.. _Denitrification:

Denitrification
^^^^^^^^^^^^^^^

When :varlink:`DARWIN_ALLOW_DENIT` is defined in DARWIN_OPTIONS.h,
denitrification occurs, provided
:math:`{\mathrm{O}}_2<{\mathrm{O}}_2^{{\text{crit}}}`,

.. math::

     D_{\op{NH4}} &= R_{\op{DON}} + [R_{\op{PON}}]

     D_{\op{NO3}} &= R^{\mathrm{NO3}:\mathrm{P}}_{\op{denit}} \cdot \bigl(
                         R_{\op{DOP}} + [R_{\op{POP}}] \bigr)

(the particulate organic terms are not present with :varlink:`DARWIN_ALLOW_CDOM`).

The diagnostic 'Denit' is this:

.. math::

     \op{Denit} = R^{\mathrm{N}:\mathrm{P}}_{\op{denit}} \bigl(
                      R_{\op{DOP}} + [R_{\op{POP}}] \bigr)


Also, when :math:`{\mathrm{O}}_2<{\mathrm{O}}_2^{{\text{crit}}}` and
:math:`\op{NO}_3<\op{NO}_3^{{\text{crit}}}`, all remineralization,
denitrification and CDOM degradation (except bleaching) stops.
Bacteria are not affected.

.. csv-table:: Denitrification parameters
   :delim: &
   :widths: 16,12,12,15,45
   :class: longtable
   :header: Param, Symbol, Default, Units, Description

   :varlink:`denit_NP`  & :math:`R^{\mathrm{N}:\mathrm{P}}_{\op{denit}}`   & 120.0 & mmol N / mmol P               & ratio of n to p in denitrification process
   :varlink:`denit_NO3` & :math:`R^{\mathrm{NO3}:\mathrm{P}}_{\op{denit}}` & 104.0 & mmol N / mmol P               & ratio of NO3 uptake to phos remineralization in denitrification
   :varlink:`O2crit`    & :math:`\mathrm{O}_2^{\op{crit}}`                 & 6.0   & mmol O\ :sub:`2` m\ :sup:`-3` & critical oxygen for O2/NO3 remineralization
   :varlink:`NO3crit`   & :math:`\op{NO}_3^{\op{crit}}`                    & 0.01  & mmol N m\ :sup:`-3`           & critical nitrate below which no denit (or remin) happens
