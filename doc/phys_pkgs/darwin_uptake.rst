.. include:: ../defs.hrst

.. _Uptake:

Nutrient uptake and limitation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The uptake rate of dissolved inorganic carbon is

.. math::

   U^{\op{DIC}}_j = P^{\mathrm{C}}_j {c}_j
         - \op{synthcost}\cdot U^{\mathrm{N}}_j

where the carbon specific growth rate, :math:`P^{\op{C}}_j`, is discussed in
:numref:`Growth`, and the second term is only present with both N and Chl quotas
and the Geider formulation of photosynthesis.

Nutrient limitation is computed following Liebig's law of the minimum,

.. math::
   :label: eq_darwin_limitnut

   \gamma^{\op{nut}}_j = \min(\gamma^{\mathrm{P}}_j, \gamma^{\mathrm{N}}_j, \gamma^{\op{Si}}_j,
                              \gamma^{\op{Fe}}_j)

We will discuss the limitation terms for each element together with the
uptake rate of that element for the cases with and without a corresponding
elemental quota in plankton.

Without P quota:
''''''''''''''''

Monod limitation

.. math:: \gamma^{\mathrm{P}}_j = \frac{\mathrm{PO}_4}{\mathrm{PO}_4 + k^{\op{PO4}}_j}

.. math:: U^{\mathrm{P}}_j = R^{{\mathrm{P}}:{\mathrm{C}}}_j U^{\op{DIC}}_j

With P quota:
'''''''''''''

normalized Droop limitation

.. math::

   \gamma^{\mathrm{P}}_j = \left[ \frac{1 - Q^{{\mathrm{P}}\min}_j/Q^{{\mathrm{P}}}_j}
                               {1 - Q^{{\mathrm{P}}\min}_j/Q^{{\mathrm{P}}\max}_j}
                   \right]_0^1

.. math::

   U^{\mathrm{P}}_j = V^{{\mathrm{P}}\max}_j \frac{\mathrm{PO}_4}{\mathrm{PO}_4 + k^{\op{PO4}}_j}
              {{\text{reg}}}^{Q{\mathrm{P}}}_j \cdot f^{{\text{up}}}_j(T) \cdot {c}_j

where

.. math::

     {{\text{reg}}}^{Q{\mathrm{P}}}_j = \left( \left[ \frac{Q^{{\mathrm{P}}\max}_j - Q^{{\mathrm{P}}}_j}
                                {Q^{{\mathrm{P}}\max}_j - Q^{{\mathrm{P}}\min}_j}
                    \right]_0^1 \right)^{h_{\op{U}}}

and the exponent, :math:`h_{\op{U}}`, is the Hill number for uptake (default 1).

Si:
'''

Diatoms (trait :varlink:`hasSi` = 1) have linear limitation when using a Si quota,

.. math::

   \gamma^{\op{Si}}_j = \left[ \frac{Q^{\op{Si}}_j - Q^{\op{Si}\min}_j}
                              {Q^{\op{Si}\max}_j - Q^{\op{Si}\min}_j}
                      \right]_0^1

Otherwise Si is analogous to P.

Without N quota:
''''''''''''''''

diazotroph:
"""""""""""

No limitation, no consumption:

.. math:: \gamma^{\mathrm{N}}_j = 1

.. math:: U^{\op{NH4}}_j = U^{\op{NO2}}_j = U^{\op{NO3}}_j = 0

not diazotroph:
"""""""""""""""

Modified Monod limitation:

.. math:: \gamma^{\mathrm{N}}_j = \left[ \gamma^{\op{NH4}}_j + \gamma^{\op{NO2}}_j + \gamma^{\op{NO3}}_j \right]_0^1

.. math:: \gamma^{\op{NH4}}_j = \op{useNH4}_j \frac{\op{NH}_4}{\op{NH}_4 + k^{\op{NH4}}_j}

NO\ :sub:`2` and NO\ :sub:`3` limitations can be combined
(trait :varlink:`combNO` = 1),

.. math::

   \gamma^{\op{NO2}}_j = \op{useNO2}_j
     \dfrac{\op{NO}_2}{\op{NO}_2 + \op{NO}_3 + k^{\op{NO3}}_j}
     \op{e}^{-\sigma^{\op{amm}}_j \op{NH}_4}

.. math::

   \gamma^{\op{NO3}}_j = \op{useNO3}_j
     \dfrac{\op{NO}_3}{\op{NO}_2 + \op{NO}_3 + k^{\op{NO3}}_j}
     \op{e}^{-\sigma^{\op{amm}}_j \op{NH}_4}

or not (combNO = 0),

.. math::

   \gamma^{\op{NO2}}_j = \op{useNO2}_j
     \dfrac{\op{NO}_2}{\op{NO}_2 + k^{\op{NO2}}_j}
     \op{e}^{-\sigma^{\op{amm}}_j \op{NH}_4}

.. math::

   \gamma^{\op{NO3}}_j = \op{useNO3}_j
     \dfrac{\op{NO}_3}{\op{NO}_3 + k^{\op{NO3}}_j}
     \op{e}^{-\sigma^{\op{amm}}_j \op{NH}_4}

Uptake is then

.. math::
   :label: eq_uptakeN

     U^{\op{NH4}}_j &= \frac{\gamma^{\op{NH4}}_j}
                    {\gamma^{\op{NH4}}_j + \gamma^{\op{NO2}}_j + \gamma^{\op{NO3}}_j}
                    R^{{\mathrm{N}}:{\mathrm{C}}}_j U^{\op{DIC}}_j

     U^{\op{NO2}}_j &= \frac{\gamma^{\op{NO2}}_j}
                    {\gamma^{\op{NH4}}_j + \gamma^{\op{NO2}}_j + \gamma^{\op{NO3}}_j}
                    R^{{\mathrm{N}}:{\mathrm{C}}}_j U^{\op{DIC}}_j

     U^{\op{NO3}}_j &= \frac{\gamma^{\op{NO3}}_j}
                     {\gamma^{\op{NH4}}_j + \gamma^{\op{NO2}}_j + \gamma^{\op{NO3}}_j}
                     R^{{\mathrm{N}}:{\mathrm{C}}}_j U^{\op{DIC}}_j

With N quota:
'''''''''''''

linear limitation

.. math::

   \gamma^{\mathrm{N}}_j = \left[ \frac{Q^{{\mathrm{N}}}_j - Q^{{\mathrm{N}}\min}_j}
                           {Q^{{\mathrm{N}}\max}_j - Q^{{\mathrm{N}}\min}_j}
                   \right]_0^1

.. math::

     U^{\op{NH4}}_j &= V^{\op{NH4}\max}_j
                    \frac{\op{NH}_4}{\op{NH}_4 + k^{\op{NH4}}_j}
                    {{\text{reg}}}^{Q{\mathrm{N}}}_j \cdot
                    f^{{\text{up}}}_j(T) \cdot {c}_j

     U^{\op{NO2}}_j &= V^{\op{NO2}\max}_j \cdot
                    {\mathrm{e}}^{-\sigma^{\op{amm}}_j \op{NH}_4} \cdot
                    \frac{\op{NO}_2}{\op{NO}_2 + k^{\op{NO2}}_j}
                    {{\text{reg}}}^{Q{\mathrm{N}}}_j \cdot
                    f^{{\text{up}}}_j(T) \cdot {c}_j

     U^{\op{NO3}}_j &= V^{\op{NO3}\max}_j \cdot
                     {\mathrm{e}}^{-\sigma^{\op{amm}}_j \op{NH}_4} \cdot
                     \frac{\op{NO}_3}{\op{NO}_3 + k^{\op{NO3}}_j}
                     {{\text{reg}}}^{Q{\mathrm{N}}}_j \cdot
                     f^{{\text{up}}}_j(T) \cdot {c}_j
                     \cdot \gamma^{\op{QFe}}_j

where

.. math::

   {{\text{reg}}}^{Q{\mathrm{N}}}_j = \left( \left[ \frac{Q^{{\mathrm{N}}\max}_j - Q^{{\mathrm{N}}}_j}
                                {Q^{{\mathrm{N}}\max}_j - Q^{{\mathrm{N}}\min}_j}
                    \right]_0^1 \right)^{h_{\op{U}}}

diazotroph:
"""""""""""

consume what is available, fix what is missing (up to
:math:`V^{{\mathrm{N}}\max}_j`),

.. math::

   U^{{\mathrm{N}}}_j = \max\biggl( U^{\op{NH4}}_j + U^{\op{NO2}}_j + U^{\op{NO3}}_j,\;
                    V^{{\mathrm{N}}\max}_j
                    {{\text{reg}}}^{Q{\mathrm{N}}}_j \cdot
                    f^{{\text{up}}}_j(T) \cdot {c}_j
                \biggr) \\

Rate of nitrogen fixation is

.. math:: U^{{\mathrm{N}}}_j - U^{\op{NH4}}_j - U^{\op{NO2}}_j - U^{\op{NO3}}_j


not diazotroph:
"""""""""""""""

.. math:: U^{{\mathrm{N}}}_j = U^{\op{NH4}}_j + U^{\op{NO2}}_j + U^{\op{NO3}}_j


Without Fe quota:
'''''''''''''''''

.. math:: \gamma^{\op{Fe}}_j = \frac{\op{FeT}}{\op{FeT}+ k^{\op{Fe}}_j}

.. math:: \gamma^{\op{QFe}}_j = 1

.. math:: U^{\op{Fe}}_j = R^{\op{Fe}:{\mathrm{C}}}_j U^{\op{DIC}}_j


With Fe quota,
''''''''''''''

a low iron quota does not directly limit growth,

.. math:: \gamma^{\op{Fe}}_j = 1

It rather reduces the light available for photosynthesis (see
:numref:`Growth` above),

.. math::

   \gamma^{\op{QFe}}_j = \left[ \frac{1 - Q^{\op{Fe}\min}_j/Q^{\op{Fe}}_j}
                                   {1 - Q^{\op{Fe}\min}_j/Q^{\op{Fe}\max}_j}
                       \right]_0^1

Iron uptake depends on the available dissolved iron,

.. math::

   U^{\op{Fe}}_j = V^{\op{Fe}\max}_j \frac{\op{FeT}}{\op{FeT}+ k^{\op{Fe}}_j}
              {{\text{reg}}}^{Q\op{Fe}}_j \cdot
              f^{{\text{up}}}_j(T) \cdot {c}_j

where

.. math::

   {{\text{reg}}}^{Q\op{Fe}}_j = \left( \left[ \frac{Q^{\op{Fe}\max}_j - Q^{\op{Fe}}_j}
                                 {Q^{\op{Fe}\max}_j - Q^{\op{Fe}\min}_j}
                    \right]_0^1 \right)^{h_{\op{U}}}


Effective half saturation constants
'''''''''''''''''''''''''''''''''''

If :varlink:`DARWIN_effective_ksat` is true, half saturations for non-quota
elements are computed from quota traits. If :varlink:`darwin_select_kn_allom`\
=1 (now deprecated), the half saturation for :math:`\op{NO}_3` is computed
following Ward et al.,

.. math::

   k^{\op{NO3}}_j \rightarrow \frac{ k^{\op{NO3}}_j
                              P^{{\mathrm{C}}{\op{m}}}_j Q^{{\mathrm{N}}\min}_j
                              (Q^{{\mathrm{N}}\max}_j - Q^{{\mathrm{N}}\min}_j) }
                            { V^{\op{NO3}\max}_j Q^{{\mathrm{N}}\max}_j +
                              P^{{\mathrm{C}}{\op{m}}}_j Q^{{\mathrm{N}}\min}_j
                              (Q^{{\mathrm{N}}\max}_j - Q^{{\mathrm{N}}\min}_j) }

and those of the other elements are computed by scaling :math:`k^{\op{NO3}}_j`
with the type’s elemental ratios. Here, :math:`k^{\op{NO3}}_j` on the
right-hand side is computed from :varlink:`a_ksatNO3` and :varlink:`b_ksatNO3`.

If :varlink:`darwin_select_kn_allom`\ =2 (the default), the half saturation for
:math:`\op{NO}_3` is computed following Follett et al.,

.. math::

   k^{\op{NO3}}_j \rightarrow k^{\op{NO3}}_j \frac
                     { P^{{\mathrm{C}}{\op{m}}}_j Q^{{\mathrm{N}}\min}_j }
                     { V^{\op{NO3}\max}_j }

Those of the other elements are again computed by scaling
:math:`k^{\op{NO3}}_j` with the type’s elemental ratios.


Uptake and limitation parameters
''''''''''''''''''''''''''''''''

.. csv-table:: Uptake parameters
   :delim: &
   :widths: 13,20,17,15,15,20
   :class: longtable
   :header: Trait, Param, Symbol, Default, Units, Description
   :name: tab_phys_pkg_darwin_uptake

                       & :varlink:`synthcost`        & :varlink:`synthcost`            & 0.0                          & mmol C / mmol N      & cost of biosynthesis
   :varlink:`hasSi`    & :varlink:`grp_hasSi`        & hasSi\ :math:`_j`               & 0                            &                      & 1: uses silica (Diatom), 0: not
   :varlink:`diazo`    & :varlink:`grp_diazo`        & diazo\ :math:`_j`               & 0                            &                      & 1: use molecular instead of mineral nitrogen, 0: not
   :varlink:`useNH4`   & :varlink:`grp_useNH4`       & useNH4\ :math:`_j`              & 1                            &                      & 1: can use ammonia, 0: not
   :varlink:`useNO2`   & :varlink:`grp_useNO2`       & useNO2\ :math:`_j`              & 1                            &                      & 1: can use nitrite, 0: not
   :varlink:`useNO3`   & :varlink:`grp_useNO3`       & useNO3\ :math:`_j`              & 1                            &                      & 1: can use nitrate, 0: not
   :varlink:`combNO`   & :varlink:`grp_combNO`       & combNO\ :math:`_j`              & 1                            &                      & 1: combined nitrite/nitrate limitation, 0: not
   :varlink:`Qnmin`    & :varlink:`a <a_Qnmin>`,\ :varlink:`b_Qnmin`      & :math:`Q^{\op{N}\min}_j`        & 0.07 V\ :sup:`--0.17`        & mmol N / mmol C      & minimum nitrogen quota
   :varlink:`Qnmax`    & :varlink:`a <a_Qnmax>`,\ :varlink:`b_Qnmax`      & :math:`Q^{\op{N}\op{max}}_j`    & 0.25 V\ :sup:`--0.13`        & mmol N / mmol C      & maximum nitrogen quota
   :varlink:`Qpmin`    & :varlink:`a <a_Qpmin>`,\ :varlink:`b_Qpmin`      & :math:`Q^{\op{P}\min}_j`        & 0.002 V\ :sup:`0`            & mmol P / mmol C      & minimum phosphorus quota
   :varlink:`Qpmax`    & :varlink:`a <a_Qpmax>`,\ :varlink:`b_Qpmax`      & :math:`Q^{\op{P}\op{max}}_j`    & 0.01 V\ :sup:`0`             & mmol P / mmol C      & maximum phosphorus quota
   :varlink:`Qsimin`   & :varlink:`a <a_Qsimin>`,\ :varlink:`b_Qsimin`     & :math:`Q^{\op{Si}\min}_j`       & 0.002 V\ :sup:`0`            & mmol Si / mmol C     & minimum silica quota
   :varlink:`Qsimax`   & :varlink:`a <a_Qsimax>`,\ :varlink:`b_Qsimax`     & :math:`Q^{\op{Si}\op{max}}_j`   & 0.004 V\ :sup:`0`            & mmol Si / mmol C     & maximum silica quota
   :varlink:`Qfemin`   & :varlink:`a <a_Qfemin>`,\ :varlink:`b_Qfemin`     & :math:`Q^{\op{Fe}\min}_j`       & 15E-6 V\ :sup:`0`            & mmol Fe / mmol C     & minimum iron quota
   :varlink:`Qfemax`   & :varlink:`a <a_Qfemax>`,\ :varlink:`b_Qfemax`     & :math:`Q^{\op{Fe}\op{max}}_j`   & 80E-6 V\ :sup:`0`            & mmol Fe / mmol C     & maximum iron quota
   :varlink:`vmaxNO3`  & :varlink:`a <a_vmaxNO3>`,\ :varlink:`b_vmaxNO3`    & :math:`V^{\op{NO3}\op{max}}_j`  & (0.26/day)  V\ :sup:`--0.27` & mmol N / (mmol C s)  & maximum nitrate uptake rate
   :varlink:`vmaxNO2`  & :varlink:`a <a_vmaxNO2>`,\ :varlink:`b_vmaxNO2`    & :math:`V^{\op{NO2}\op{max}}_j`  & (0.51/day)  V\ :sup:`--0.27` & mmol N / (mmol C s)  & maximum nitrite uptake rate
   :varlink:`vmaxNH4`  & :varlink:`a <a_vmaxNH4>`,\ :varlink:`b_vmaxNH4`    & :math:`V^{\op{NH4}\op{max}}_j`  & (0.51/day)  V\ :sup:`--0.27` & mmol N / (mmol C s)  & maximum ammonia uptake rate
   :varlink:`vmaxN`    & :varlink:`a <a_vmaxN>`,\ :varlink:`b_vmaxN`      & :math:`V^{\op{N}\op{max}}_j`    & (1.28/day)  V\ :sup:`--0.27` & mmol N / (mmol C s)  & maximum nitrogen uptake rate for diazotrophs
   :varlink:`vmaxPO4`  & :varlink:`a <a_vmaxPO4>`,\ :varlink:`b_vmaxPO4`    & :math:`V^{\op{PO4}\op{max}}_j`  & (0.077/day) V\ :sup:`--0.27` & mmol P / (mmol C s)  & maximum phosphate uptake rate
   :varlink:`vmaxSiO2` & :varlink:`a <a_vmaxSiO2>`,\ :varlink:`b_vmaxSiO2`   & :math:`V^{\op{SiO2}\op{max}}_j` & (0.077/day) V\ :sup:`--0.27` & mmol Si / (mmol C s) & maximum silica uptake rate
   :varlink:`vmaxFeT`  & :varlink:`a <a_vmaxFeT>`,\ :varlink:`b_vmaxFeT`    & :math:`V^{\op{Fe}\op{max}}_j`   & (14E-6/day) V\ :sup:`--0.27` & mmol Fe / (mmol C s) & maximum iron uptake rate
   :varlink:`ksatNO3`  & :varlink:`a <a_ksatNO3>`,\ :varlink:`b_ksatNO3`    & :math:`k^{\op{NO3}}_j`          & 0.085 V\ :sup:`0.27`         & mmol N m\ :sup:`-3`  & half-saturation conc. for nitrate uptake/limitation
   :varlink:`ksatNO2`  & :varlink:`a <a_ksatNO2>`,\ :varlink:`b_ksatNO2`    & :math:`k^{\op{NO2}}_j`          & 0.17  V\ :sup:`0.27`         & mmol N m\ :sup:`-3`  & half-saturation conc. for nitrite uptake/limitation
   :varlink:`ksatNH4`  & :varlink:`a <a_ksatNH4>`,\ :varlink:`b_ksatNH4`    & :math:`k^{\op{NH4}}_j`          & 0.17  V\ :sup:`0.27`         & mmol N m\ :sup:`-3`  & half-saturation conc. for ammonia uptake/limitation
   :varlink:`ksatPO4`  & :varlink:`a <a_ksatPO4>`,\ :varlink:`b_ksatPO4`    & :math:`k^{\op{PO4}}_j`          & 0.026 V\ :sup:`0.27`         & mmol P m\ :sup:`-3`  & half-saturation conc. for phosphate uptake/limitation
   :varlink:`ksatSiO2` & :varlink:`a <a_ksatSiO2>`,\ :varlink:`b_ksatSiO2`   & :math:`k^{\op{SiO2}}_j`         & 0.024 V\ :sup:`0.27`         & mmol Si m\ :sup:`-3` & half-saturation conc. for silica uptake/limitation
   :varlink:`ksatFeT`  & :varlink:`a <a_ksatFeT>`,\ :varlink:`b_ksatFeT`    & :math:`k^{\op{Fe}}_j`           & 80E-6 V\ :sup:`0.27`         & mmol Fe m\ :sup:`-3` & half-saturation conc. for iron uptake/limitation
                       & :varlink:`a_ksatNO2fac`     &                                 & 1                            &                      & *used for eff.ksat*
                       & :varlink:`a_ksatNH4fac`     &                                 & 0.5                          &                      & *used for eff.ksat*
   :varlink:`R_NC`     & :varlink:`a_R_NC`           & :math:`R^{\op{N}:\op{C}}_j`     & 16/120                       & mmol N / mmol C      & nitrogen-carbon ratio
   :varlink:`R_PC`     & :varlink:`a_R_PC`           & :math:`R^{\op{P}:\op{C}}_j`     & 1/120                        & mmol P / mmol C      & phosphorus-carbon ratio
   :varlink:`R_SiC`    & :varlink:`a_R_SiC`          & :math:`R^{\op{Si}:\op{C}}_j`    & 0                            & mmol Si / mmol C     & silica-carbon ratio
   :varlink:`R_FeC`    & :varlink:`a_R_FeC`          & :math:`R^{\op{Fe}:\op{C}}_j`    & 1E-3/120                     & mmol Fe / mmol C     & iron-carbon ratio
   :varlink:`R_ChlC`   & :varlink:`a_R_ChlC`         & :math:`R^{\op{chl}c}_j`         & 16/120                       & mg Chl / mmol C      & chlorophyll-carbon ratio
   :varlink:`amminhib` & :varlink:`a_amminhib`       & :math:`\sigma^{\op{amm}}_j`     & 4.6                          & m\ :sup:`3` / mmol N & coefficient for NH4 inhibition of NO uptake
                       & :varlink:`hillnumUptake`    & :math:`h^{\op{U}}`              & 1.0                          &                      & exponent for limiting quota uptake in nutrient uptake

