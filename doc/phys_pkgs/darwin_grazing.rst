.. include:: ../defs.hrst

.. _Grazing:

Grazing
^^^^^^^

Grazing loss of plankton :math:`j`:

.. math:: G_j = \sum_{z\in\op{pred}} G_{j,z}

where

.. math::

   G_{j,z} = g^{\max}_z
          \frac{({p}_{j,z} {c}_j)^s}{A_z}
          \frac{p_z^h}{p_z^h + {k^{{{\text{graz}}}}_z}^h}
          (1 - {\mathrm{e}}^{-i_{{{\text{graz}}}} p_z})^{e_{\op{inhib}}}
          f^{{{\text{graz}}}}_z(T)^{e^{\op{graz}}_j}
          {c}_z

with

.. math:: A_z = \biggl[ \sum_j ({p}_{j,z} {c}_j)^s \biggr]_{\ge c^{\min}_{\op{graz}}}

.. math:: p_z = \biggl[ \sum_j {p}_{j,z} {c}_j - c^{\min}_{\op{graz}} \biggr]_{\ge 0}

:math:`s` is 1 for non-switching and 2 for switching grazers
(#define :varlink:`DARWIN_GRAZING_SWITCH`). The exponent :math:`h` defaults to
1.

**Note:** For non-switching grazers (:math:`s=1`), Ben has an additional
factor

.. math:: \frac{S^{[j]}_z}{S^{{{\text{phy}}}}_z + S^{{\text{zoo}}}_z}

in :math:`G_{j,z}` where

.. math::

     S^{{{\text{phy}}}}_z &= \sum_{j\in{{\text{phy}}}} {p}_{j,z} {c}_j

     S^{{\text{zoo}}}_z &= \sum_{j\in{{\text{zoo}}}} {p}_{j,z} {c}_j

and :math:`S^{[j]}_z` is the sum for the class plankton :math:`j`
belongs to. **This is not implemented yet!**

Gains from grazing:

.. math::

       g^{{\mathrm{C}}}_z &= \sum_j G_{j,z} a_{j,z} {{\text{reg}}}^{Q{\mathrm{C}}}_z

       g^{{\mathrm{P}}}_z &= \sum_j G_{j,z} a_{j,z} {{\text{reg}}}^{Q{\mathrm{P}}}_z Q^{\mathrm{P}}_j
       \qquad\text{if }\op{DARWIN\_ALLOW\_PQUOTA}

       &\dots

       g^{\op{DOC}} &= \sum_{j,z} G_{j,z} (1 - a_{j,z} {{\text{reg}}}^{Q{\mathrm{C}}}_z) (1 - f^{\text{exp graz}}_{j,z})

       g^{\op{DOP}} &= \sum_{j,z} \begin{cases}
         G_{j,z} (1 - a_{j,z} {{\text{reg}}}^{Q{\mathrm{P}}}_z) (1 - f^{\text{exp graz}}_{j,z}) Q^{\mathrm{P}}_j
         &\text{if }\op{DARWIN\_ALLOW\_PQUOTA}

         G_{j,z} (R^{{\mathrm{P}}:{\mathrm{C}}}_j - a_{j,z} R^{{\mathrm{P}}:{\mathrm{C}}}_z) (1 - f^{\text{exp graz}}_{j,z})
         &\text{else}
       \end{cases}

       &\dots

       g^{\op{POC}} &= \sum_{j,z} G_{j,z} (1 - a_{j,z} {{\text{reg}}}^{Q{\mathrm{C}}}_z) f^{\text{exp graz}}_{j,z}

       g^{\op{POP}} &= \sum_{j,z} \begin{cases}
         G_{j,z} (1 - a_{j,z} {{\text{reg}}}^{Q{\mathrm{P}}}_z) f^{\text{exp graz}}_{j,z} Q^{\mathrm{P}}_j
         &\text{if }\op{DARWIN\_ALLOW\_PQUOTA}

         G_{j,z} (R^{{\mathrm{P}}:{\mathrm{C}}}_j - a_{j,z} R^{{\mathrm{P}}:{\mathrm{C}}}_z) f^{\text{exp graz}}_{j,z}
         &\text{else}
         \end{cases}

       &\dots

       g^{\op{POSi}} &= \sum_{j,z} \begin{cases}
         G_{j,z} Q^{\op{Si}}_j &\text{if }\op{DARWIN\_ALLOW\_SIQUOTA}

         G_{j,z} R^{{\op{Si}}:{\mathrm{C}}}_j &\text{else}
         \end{cases}

       g^{\op{PIC}} &= \sum_{j} G_{j} R^{{\text{PIC:POC}}}_j

where

.. math::

       {{\text{reg}}}^{Q{\mathrm{P}}}_z &= \left( \left[ \frac{Q^{{\mathrm{P}}\max}_z - Q^{{\mathrm{P}}}_z}
                                   {Q^{{\mathrm{P}}\max}_z - Q^{{\mathrm{P}}\min}_z}
                       \right]_0^1 \right)^{h_{\op{G}}}

       &\dots

       {{\text{reg}}}^{Q{\mathrm{C}}}_z &= \left( \min\left\{
             \frac{Q^{{\mathrm{P}}}_z - Q^{{\mathrm{P}}\min}_z}{Q^{{\mathrm{P}}\max}_z - Q^{{\mathrm{P}}\min}_z},
             \frac{Q^{{\mathrm{N}}}_z - Q^{{\mathrm{N}}\min}_z}{Q^{{\mathrm{N}}\max}_z - Q^{{\mathrm{N}}\min}_z},
             \frac{Q^{\op{Fe}}_z - Q^{\op{Fe}\min}_z}{Q^{\op{Fe}\max}_z - Q^{\op{Fe}\min}_z}
             \right\}_0^1 \right)^{h_{\op{G}}}

       & \qquad\text{(only quota elements)}

and :math:`h_{\op{G}}` is the Hill number for grazing (:varlink:`hillnumGraz`,
default 1).


Implementation
''''''''''''''

In order to reduce the number of double (predator-prey) sums as much as
possible while still maintaining some code readability, the above sums are
computed in :filelink:`~pkg/darwin/darwin_plankton.F` via :math:`G_j`,
:math:`g^{\mathrm{C}}_z` and the following auxiliary sums:

.. math::

   G^{\exp}_j &= \sum_z G_{j,z} f^{\text{exp graz}}_{j,z}
   \;,

   g^{\mathrm{C}\exp}_z &= \sum_j G_{j,z} a_{j,z}
              {{\text{reg}}}^{Q{\mathrm{C}}}_z f^{\text{exp graz}}_{j,z}
   \;,

and for quotas elements additionally :math:`g^{\mathrm{P}}_z`, ..., and

.. math::

   g^{\mathrm{P}\exp}_z &= \sum_j G_{j,z} a_{j,z}
       {{\text{reg}}}^{Q{\mathrm{P}}}_z Q^{\mathrm{P}}_j
       f^{\text{exp graz}}_{j,z}

   &\ldots

The remaining terms are then computed as

.. math::

   g^{\op{POC}} &= \sum_j G^{\exp}_j - \sum_z g^{\mathrm{C}\exp}_z

   g^{\op{DOC}} &= g^{\op{OC}} - g^{\op{POC}}

where

.. math::

   g^{\op{OC}} = \sum_j G_j - \sum_z g^{\mathrm{C}}_z
   \;.

For other non-quota elements:

.. math::

   g^{\op{POP}} &= \sum_j G^{\exp}_j R^{\mathrm{P}:\mathrm{C}}_j
                 - \sum_z g^{\mathrm{C}\exp}_z R^{\mathrm{P}:\mathrm{C}}_z

   g^{\op{DOP}} &= g^{\op{OP}} - g^{\op{POP}}

where

.. math::

   g^{\op{OP}} = \sum_j G_j R^{\mathrm{P}:\mathrm{C}}_j
                - \sum_z g^{\mathrm{C}}_z R^{\mathrm{P}:\mathrm{C}}_z
   \;.

For quota elements:

.. math::

   g^{\op{POP}} &= \sum_j G^{\exp}_j Q^{\mathrm{P}}_j
                 - \sum_z g^{\mathrm{P}\exp}_z

   g^{\op{DOP}} &= g^{\op{OP}} - g^{\op{POP}}

where

.. math::

   g^{\op{OP}} = \sum_j G_j Q^{\mathrm{P}}_j
                - \sum_z g^{\mathrm{P}}_z
   \;.


Runtime Parameters
''''''''''''''''''

Grazing parameters are given in :numref:`tab_phys_pkg_darwin_grazing_params`.

.. csv-table:: Grazing parameters
   :delim: &
   :widths: 15,19,10,20,13,23
   :class: longtable
   :header: Trait, Param, Sym, Default, Units, Description
   :name: tab_phys_pkg_darwin_grazing_params

   :varlink:`grazemax`  & :varlink:`a_grazemax`     & :math:`g^{\op{max}}_z`       & 21.9/day·V\ :sup:`-0.16` & s\ :sup:`-1`         & maximum grazing rate
   :varlink:`kgrazesat` & :varlink:`a_kgrazesat`    & :math:`k^{\op{graz}}_z`      & 1.0                      & mmol C m\ :sup:`-3`  & grazing half-saturation concentration
   :varlink:`tempGraz`  & :varlink:`grp_tempGraz`   & :math:`e^{\op{graz}}_j`      & 1                        &                      & 1: grazing is temperature dependent, 0: turn dependence off
                        & :varlink:`inhib_graz`     & :math:`i_{\op{graz}}`        & 1.0                      & m\ :sup:`3` / mmol C & inverse decay scale for grazing inhibition
                        & :varlink:`inhib_graz_exp` & :math:`e_{\op{inhib}}`       & 0.0                      &                      & exponent for grazing inhibition (0 to turn off inhibition)
                        & :varlink:`hillnumGraz`    & :math:`h_{\op{G}}`           & 1.0                      &                      & exponent for limiting quota uptake in grazing
                        & :varlink:`hollexp`        & :math:`h`                    & 1.0                      &                      & grazing exponential 1= "Holling 2", 2= "Holling 3"
                        & :varlink:`phygrazmin`     & :math:`c^{\min}_{\op{graz}}` & 120E-10                  & mmol C m\ :sup:`-3`  & minimum total prey conc for grazing to occur

See :numref:`tab_phys_pkg_darwin_uptake` for stochiometry and quota-related parameters.


.. csv-table:: Trait matrices for grazing; indices (prey, pred); unitless
   :delim: &
   :widths: auto
   :class: longtable
   :header: Trait, Param, Symbol, Default, Description

   :varlink:`palat`              & see below                         & :math:`p_{j,z}`                     & 0   & palatability matrix
   :varlink:`asseff`             & :varlink:`grp_ass_eff`            & :math:`a_{j,z}`                     & 0.7 & assimilation efficiency matrix
   :varlink:`ExportFracPreyPred` & :varlink:`grp_ExportFracPreyPred` & :math:`f^{\op{exp}\op{graz}}_{j,z}` & 0.5 & fraction of unassimilated prey becoming particulate organic matter

If :varlink:`DARWIN_ALLOMETRIC_PALAT` is defined, palatabilities are set
allometrically,

.. math::

   p_{j,z} = \left[ \frac{1}{2\sigma_{\op{pp}}}
                    \exp\left\{
                      -\frac{(\ln(V_z/V_j/r_{\op{opt}}))^2}{2\sigma_{\op{pp}}^2}
                    \right\}
             \right]_{\ge p_{\min}}

:varlink:`grp_pred` and :varlink:`grp_prey` should be set to select which
plankton groups can graze or be grazed.


.. csv-table:: Allometric palatability trait parameters (unitless)
   :delim: &
   :widths: 20,15,15,50
   :class: longtable
   :header: Param, Symbol, Default, Description

   :varlink:`a <a_ppOpt>`,\ :varlink:`b_ppOpt` & :math:`r_{\op{opt}}`     & 1024·V\ :sup:`0` & optimum predator-prey ratio
   :varlink:`a_ppSig`     & :math:`\sigma_{\op{pp}}` & 1                & width of predator-prey curve
   :varlink:`palat_min`   & :math:`p_{\min}`         & 0                & min non-zero palatability, smaller :varlink:`palat` are set to 0 (was 1D-4 in quota)
   :varlink:`grp_pred`    &                          & 0                & 1: can graze, 0: not
   :varlink:`grp_prey`    &                          & 1                & 1: can be grazed, 0: not

