.. include:: ../defs.hrst

.. _CDOM:

Dynamic CDOM
^^^^^^^^^^^^

To enable dynamic CDOM, define :varlink:`DARWIN_ALLOW_CDOM` in DARWIN_OPTIONS.h.
Part of the dissolved organic matter produced by grazing and plankton mortality
and part of remineralized particulate organic matter then goes into a
fixed-stoichiometry CDOM pool.  The CDOM tracer is in units of mmol C m\
:sup:`-3` if :varlink:`DARWIN_CDOM_UNITS_CARBON` is defined and mmol P m\
:sup:`-3` otherwise.

If :varlink:`DARWIN_CDOM_UNITS_CARBON` is defined:

.. math::

     S_{\op{CDOM}} = f_{\op{CDOM}} \left(
         R_{\op{POC}} + g^{\op{DOC}} + \sum_j M^{\op{DOM}}_j
     \right) - D_{\op{CDOM}}

where :math:`R_{\op{POC}}` is remineralization of POC, :math:`g^{\op{DOC}}`
grazing loss to DOC, :math:`M^{\op{DOM}}_j` mortality loss to DOC and

.. math::

     D_{\op{CDOM}} = \left( r^{\op{degrad}}_{\op{CDOM}}
                     + r^{\op{bleach}}_{\op{CDOM}} \min(1, I/I_{\op{CDOM}}) \right)
                f^{{{\text{remin}}}}(T) \cdot \op{CDOM}

CDOM degradation that goes into dissolved organic matter pools.

If :varlink:`DARWIN_CDOM_UNITS_CARBON` is undefined:

.. math::

     S_{\op{CDOM}} = f_{\op{CDOM}} \left(
         R_{\op{POP}} + g^{\op{DOP}} + \sum_j M^{\op{DOM}}_j Q^{\mathrm{P}}_j
     \right) - D_{\op{CDOM}}

where :math:`R_{\op{POP}}` is remineralization of POP, :math:`g^{\op{DOP}}`
grazing loss to DOP, :math:`M^{\op{DOM}}_j` mortality loss to DOC and
:math:`D_{\op{CDOM}}` is defined as above.

Note that with :varlink:`DARWIN_ALLOW_DENIT` defined, CDOM degradation stops
when :math:`{\mathrm{O}}_2<{\mathrm{O}}_2^{{\text{crit}}}` and
:math:`\op{NO}_3<\op{NO}_3^{{\text{crit}}}` (but bleaching continues), see
:numref:`Denitrification`.


.. csv-table:: Parameters in namelist DARWIN_CDOM_PARAMS
   :delim: &
   :widths: 20,15,15,15,35
   :class: longtable
   :header: Param, Symbol, Default, Units, Description

   :varlink:`fracCDOM`   & :math:`f_{\op{CDOM}}`                          & 2/100     &                      & fraction of remineralized POP contributing to CDOM
   :varlink:`CDOMdegrd`  & :math:`r^{\op{degrad}}_{\op{CDOM}}`            & 1/200days & 1/s                  & CDOM degradation rate
   :varlink:`CDOMbleach` & :math:`r^{\op{bleach}}_{\op{CDOM}}`            & 1/15days  & 1/s                  & CDOM bleaching rate
   :varlink:`PARCDOM`    & :math:`I_{\op{CDOM}}`                          & 20        & μEin/m\ :sup:`2`/s   & PAR where CDOM bleaching becomes maximal
   :varlink:`R_NP_CDOM`  & :math:`R^{\mathrm{N}:\mathrm{P}}_{\op{CDOM}}`  & 16        & mmol N / mmol P      & CDOM N:P ratio (with #undef DARWIN_CDOM_UNITS_CARBON)
   :varlink:`R_FeP_CDOM` & :math:`R^{\mathrm{Fe}:\mathrm{P}}_{\op{CDOM}}` & 1D-3      & mmol Fe / mmol P     & CDOM Fe:P ratio (with #undef DARWIN_CDOM_UNITS_CARBON)
   :varlink:`R_CP_CDOM`  & :math:`R^{\mathrm{C}:\mathrm{P}}_{\op{CDOM}}`  & 120       & mmol C / mmol P      & CDOM C:P ratio (with #undef DARWIN_CDOM_UNITS_CARBON)
   :varlink:`R_NC_CDOM`  & :math:`R^{\mathrm{N}:\mathrm{C}}_{\op{CDOM}}`  & 16/120    & mmol N / mmol C      & CDOM N:C ratio (with #define DARWIN_CDOM_UNITS_CARBON)
   :varlink:`R_PC_CDOM`  & :math:`R^{\mathrm{P}:\mathrm{C}}_{\op{CDOM}}`  & 1/120     & mmol P / mmol C      & CDOM P:C ratio (with #define DARWIN_CDOM_UNITS_CARBON)
   :varlink:`R_FeC_CDOM` & :math:`R^{\mathrm{Fe}:\mathrm{C}}_{\op{CDOM}}` & 1D-3/120  & mmol Fe / mmol C     & CDOM Fe:C ratio (with #define DARWIN_CDOM_UNITS_CARBON)
