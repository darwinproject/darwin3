.. include:: ../defs.hrst

.. _Bacteria:

Bacteria
^^^^^^^^

To enable heterotrophic uptake for plankton type j, set
:varlink:`bactType`\ (j) to a non-zero value and set one of
:varlink:`isAerobic`\ (j) and :varlink:`isDenit`\ (j) to 1.  The allowed values
and associated types are summarized in
:numref:`tab_phys_pkg_darwin_bacteria_types`.  Note that ammonia and nitrite
oxidizers must be aerobic.

.. csv-table:: Darwin bacteria types
   :delim: &
   :widths: auto
   :header: bacttype, isAerobic, isDenit, Description
   :name: tab_phys_pkg_darwin_bacteria_types

   1 & 1 & 0 & Aerobic particle-associated: POM :math:`\to` inorganic, DOM
   1 & 0 & 1 & Denitrifying particle-associated: POM :math:`\to` inorganic, DOM
   2 & 1 & 0 & Aerobic free-living: DOM :math:`\to` inorganic
   2 & 0 & 1 & Denitrifying free-living: DOM :math:`\to` inorganic

You may also set the corresponding group parameters,
:varlink:`grp_bacttype`, :varlink:`grp_aerobic` and :varlink:`grp_denit`.

To disable remineralization other than by bacteria, set the parameterized
remineralization rates :varlink:`KDOC`, ... to zero, see
:numref:`Remineralization`.  This is not done automatically.

Note that bacteria have fixed elemental ratios.  For now, no elemental quotas
may be turned on in DARWIN_OPTIONS.h.  In the future, elemental quotas will be
kept at fixed ratios if turned on.


Growth and energy sources
'''''''''''''''''''''''''

Bacterial growth is represented by a growth rate,

.. math:: \partial_t{c}_j = \mu_j {c}_j \;,

which is computed from various limiting resources.
Aerobic bacteria are limited by and take up oxygen,

.. math::

   \mu^{{\mathrm{O}}}_j = y^{\mathrm{O}_2}_j P^{\max}_{\mathrm{O}2} \mathrm{O}_2
   \;,

.. math::

   U^{{\mathrm{O}}2}_j = \frac{1}{{y^{{\mathrm{O}}_2}_j}} \mu_j {c}_j
   \;,

denitrifiers nitrate,

.. math::

   \mu^{{\mathrm{O}}}_j = y^{\op{NO}_3}_j V^{\max}_{\op{DIN}}
       \dfrac{\op{NO}_3}{\op{NO}_3 + k^{\op{DIN}}} f^{\op{remin}}(T)
   \;,

.. math::

   U^{\op{NO3}}_j = \frac{1}{{y^{\op{NO}_3}_j}} \mu_j {c}_j
   \;.

The nitrogen is released as N\ :sub:`2` which is not represented in the model.


Generic particle-associated
'''''''''''''''''''''''''''

BactType 1 consume POC, PON, POP, POFe and produce DIN, NH\ :sub:`4`, PO\
:sub:`4` and FeT and, by hydrolysis, DOC, DON, DOP, DOFe.  The growth rate is
limited by the presence of particulate organic matter and oxygen or nitrate,
see above,

.. math:: \mu_j = \min(\mu^{\op{PON}}_j, \mu^{\op{POC}}_j, \mu^{\op{POP}}_j, \mu^{\op{POFe}}_j, \mu^{{\mathrm{O}}}_j)

.. math:: \mu^{\op{PON}}_j = y_j {P^{\op{max}}_{{\mathrm{C}},j}} \frac{\op{PON}}{\op{PON}+ k^{\op{PON}}_j} f^{\op{remin}}(T)

.. math:: \mu^{\op{POC}}_j = y_j {P^{\op{max}}_{{\mathrm{C}},j}} \frac{\op{POC}}{\op{POC}+ k^{\op{POC}}_j} f^{\op{remin}}(T)

.. math:: \mu^{\op{POP}}_j = y_j {P^{\op{max}}_{{\mathrm{C}},j}} \frac{\op{POP}}{\op{POP}+ k^{\op{POP}}_j} f^{\op{remin}}(T)

.. math:: \mu^{\op{POFe}}_j = y_j {P^{\op{max}}_{{\mathrm{C}},j}} \frac{\op{POFe}}{\op{POFe}+ {k^{\op{POFe}}}_j} f^{\op{remin}}(T)

The update rates for organic matter are

.. math:: U^{\op{POC}}_j = \frac{{\alpha^{\op{hydrol}}}}{y_j} \mu_j {c}_j

.. math:: U^{\op{POX}}_j = U^{\op{POC}}_j R^{X{\mathrm{C}}}_j  \qquad X={\mathrm{N}},{\mathrm{P}},\op{Fe}

Part of POM is hydrolized to DOM:

.. math:: H^{\op{POC}}_j = \frac{{\alpha^{\op{hydrol}}}- 1}{y_j} \mu_j {c}_j

.. math:: H^{\op{POX}}_j = H^{\op{POC}}_j R^{X:\mathrm{C}}_j  \qquad X=\mathrm{N},\mathrm{P},\op{Fe}

Part is respired back to inorganics:

.. math:: R^{\op{DIC}}_j = \left( \frac{1}{y_j} - 1 \right) \mu_j {c}_j

.. math::

   R^{\op{NH4}}_j &= R^{\op{DIC}}_j R^{\mathrm{N:C}}_j

   R^{\op{PO4}}_j &= R^{\op{DIC}}_j R^{\mathrm{P:C}}_j

   R^{\op{FeT}}_j &= R^{\op{DIC}}_j R^{\mathrm{Fe:C}}_j
   \;.


Generic free-living
'''''''''''''''''''

BactType 2 consume DOC, DON, DOP, DOFe and produce DIN, NH\ :sub:`4`, PO\
:sub:`4` and FeT.  The growth rate is limited by the presence of dissolved
organic matter and oxygen or nitrogen,

.. math:: \mu_j = \min(\mu^{\op{DON}}_j, \mu^{\op{DOC}}_j, \mu^{\op{DOP}}_j, \mu^{\op{DOFe}}_j, \mu^{{\mathrm{O}}}_j)

.. math:: \mu^{\op{DON}}_j = y_j {P^{\op{max}}_{{\mathrm{C}},j}} \frac{\op{DON}}{\op{DON}+ k^{\op{DON}}_j} f^{\op{remin}}(T)

.. math:: \mu^{\op{DOC}}_j = y_j {P^{\op{max}}_{{\mathrm{C}},j}} \frac{\op{DOC}}{\op{DOC}+ k^{\op{DOC}}_j} f^{\op{remin}}(T)

.. math:: \mu^{\op{DOP}}_j = y_j {P^{\op{max}}_{{\mathrm{C}},j}} \frac{\op{DOP}}{\op{DOP}+ k^{\op{DOP}}_j} f^{\op{remin}}(T)

.. math:: \mu^{\op{DOFe}}_j = y_j {P^{\op{max}}_{{\mathrm{C}},j}} \frac{\op{DOFe}}{\op{DOFe}+ {k^{\op{DOFe}}}_j} f^{\op{remin}}(T)

The uptake rates for organic matter are

.. math:: U^{\op{DOC}}_j = \frac{1}{y_j} \mu_j {c}_j

.. math:: U^{\op{DOX}}_j = U^{\op{DOC}}_j R^{X{\mathrm{C}}}_j  \qquad X={\mathrm{N}},{\mathrm{P}},\op{Fe}

Part of it is respired back to inorganics:

.. math:: R^{\op{DIC}}_j = \left( \frac{1}{y_j} - 1 \right) \mu_j {c}_j

.. math::

   R^{\op{NH4}}_j &= R^{\op{DIC}}_j R^{\mathrm{N:C}}_j

   R^{\op{PO4}}_j &= R^{\op{DIC}}_j R^{\mathrm{P:C}}_j

   R^{\op{FeT}}_j &= R^{\op{DIC}}_j R^{\mathrm{Fe:C}}_j
   \;.


Bacteria parameters
'''''''''''''''''''

.. csv-table:: Bacteria parameters
   :delim: &
   :widths: 13,17,8,15,18,29
   :class: longtable
   :header: Trait, Param, Symbol, Default, Units, Description

   :varlink:`bactType`  & :varlink:`grp_bacttype` &                                 & 0                        &  & 1: particle associated, 2: free living bacteria, 0: not bacteria
   :varlink:`isAerobic` & :varlink:`grp_aerobic`  &                                 & 0                        &  & 1: is aerobic, 0: not
   :varlink:`isDenit`   & :varlink:`grp_denit`    &                                 & 0                        &  & 1: is dentrifying, 0: not
                        & :varlink:`pcoefO2`      & :math:`P^{\max}_{\mathrm{O}2}`  & 290.82 / 86400           & s\ :sup:`--1`         & max O2-specific O2 uptake rate for aerobic bacteria
                        & :varlink:`pmaxDIN`      & :math:`V^{\max}_{\op{DIN}}`     & 20/86400 & mmol N mmol C\ :sup:`--1` s\ :sup:`--1` & max C-specific DIN uptake rate for denitrifying bacteria
                        & :varlink:`ksatDIN`      & :math:`k^{\op{DIN}}`            & 0.01                     & mmol N m\ :sup:`--3`  & half-saturation conc of dissolved inorganic nitrogen
                        & :varlink:`alpha_hydrol` & :math:`\alpha^{\op{hydrol}}`    & 2.0                      & 1                     & increase in POM needed due to hydrolysis
   :varlink:`PCmax`     & :varlink:`a <a_PCmax>`,\ :varlink:`b_PCmax`  & :math:`P^{\op{max}}_{\op{C},j}` & (1/day) · V\ :sup:`--0.15`, see [#pcmax]_ & s\ :sup:`--1`       & maximum carbon-specific growth rate
   :varlink:`yield`     & :varlink:`yod` (aerobic) :varlink:`ynd` (denit) & :math:`y_j` & 0.2 (aerobic) 0.16 (denit) & 1               & bacterial growth yield for all organic matter
   :varlink:`yieldO2`   & :varlink:`yoe`          & :math:`y^{{\mathrm{O}}_2}_j`    & 0.2/467*4/ (1-0.2)*106   & mmol C / mmol O\ :sub:`2` & bacterial growth yield for oxygen
   :varlink:`yieldNO3`  & :varlink:`yne`          & :math:`y^{\op{NO}_3}_j`         & 0.16/467*5/ (1-0.16)*106 & mmol C / mmol N       & bacterial growth yield for nitrate
   :varlink:`ksatPON`   & :varlink:`a_ksatPON`    & :math:`k^{\op{PON}}_j`          & 1                        & mmol N m\ :sup:`--3`  & half-saturation of PON for bacterial growth
   :varlink:`ksatPOC`   &                         & :math:`k^{\op{POC}}_j`          & see below                & mmol C m\ :sup:`--3`  & half-saturation of POC for bacterial growth
   :varlink:`ksatPOP`   &                         & :math:`k^{\op{POP}}_j`          & see below                & mmol P m\ :sup:`--3`  & half-saturation of POP for bacterial growth
   :varlink:`ksatPOFe`  &                         & :math:`k^{\op{POFe}}_j`         & see below                & mmol Fe m\ :sup:`--3` & half-saturation of POFe for bacterial growth
   :varlink:`ksatDON`   & :varlink:`a_ksatDON`    & :math:`k^{\op{DON}}_j`          & 1                        & mmol N m\ :sup:`--3`  & half-saturation of DON for bacterial growth
   :varlink:`ksatDOC`   &                         & :math:`k^{\op{DOC}}_j`          & see below                & mmol C m\ :sup:`--3`  & half-saturation of DOC for bacterial growth
   :varlink:`ksatDOP`   &                         & :math:`k^{\op{DOP}}_j`          & see below                & mmol P m\ :sup:`--3`  & half-saturation of DOP for bacterial growth
   :varlink:`ksatDOFe`  &                         & :math:`k^{\op{DOFe}}_j`         & see below                & mmol Fe m\ :sup:`--3` & half-saturation of DOFe for bacterial growth

.. [#pcmax] A more appropriate value for the maximum growth rate of bacteria is 5/day
   which was used in previous versions of the code.

The organic nitrogen half-saturation constant, ksatPON and ksatDON, are set
from trait parameters.  Others are computed from nitrogen ones using
elemental ratios,

.. math::

   k^{\op{POC}}_j &= \frac{1}{R^{\mathrm{N}:\mathrm{C}}_j} k^{\op{PON}}_j &
   k^{\op{DOC}}_j &= \frac{1}{R^{\mathrm{N}:\mathrm{C}}_j} k^{\op{DON}}_j

   k^{\op{POP}}_j &= \frac{R^{\mathrm{P}:\mathrm{C}}_j}{R^{\mathrm{N}:\mathrm{C}}_j} k^{\op{PON}}_j &
   k^{\op{DOP}}_j &= \frac{R^{\mathrm{P}:\mathrm{C}}_j}{R^{\mathrm{N}:\mathrm{C}}_j} k^{\op{DON}}_j

   k^{\op{POFe}}_j &= \frac{R^{\mathrm{Fe}:\mathrm{C}}_j}{R^{\mathrm{N}:\mathrm{C}}_j} k^{\op{PON}}_j &
   k^{\op{DOFe}}_j &= \frac{R^{\mathrm{Fe}:\mathrm{C}}_j}{R^{\mathrm{N}:\mathrm{C}}_j} k^{\op{DON}}_j

