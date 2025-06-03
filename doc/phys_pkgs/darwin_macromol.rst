.. include:: ../defs.hrst

.. _Macromolecular:

Macromolecular parameterization of growth
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To enable the macromolecular parameterization of phototrophic growth, define
:varlink:`DARWIN_MACROMOLECULAR_GROWTH` in DARWIN_OPTIONS.h.  Phytoplankton
need to have flexible nitrogen, phosphorus and iron quotas, so also define
:varlink:`DARWIN_ALLOW_NQUOTA`, :varlink:`DARWIN_ALLOW_PQUOTA` and
:varlink:`DARWIN_ALLOW_FEQUOTA`.

The macromolecular growth parameterization is based on :cite:`sharoni:2026`.
In order to parameterize the growth rate as a function of elemental quotas, we
assume that the available carbon, nitrogen, phosphorus and iron in the organism
are allocated optimally to macromolecular pools to achieve maximum growth rate,
:math:`P_{\mathrm{C}}`, at every instant.  To determine this growth rate, the
macromolecular requirements are expressed as a function of growth rate.  The
available quota of each element then provides a constraint on the achievable
growth rate which can be obtained by solving for :math:`P_{\mathrm{C}}` as a
function of the required quota.  The realized growth rate is the smallest of
these solutions, the one obtained from the most limiting quota.

The assumed macromolecular pools and fluxes between them are shown in
:numref:`fig_phys_pkgs_darwin_macromol_fluxes`.

.. figure:: figs/fluxes.*
   :align: center
   :alt: Elemental fluxes of macromolecular growth model
   :name: fig_phys_pkgs_darwin_macromol_fluxes

   Macromolecular pools and fluxes

They imply the following elemental quota requirements:

.. math::
   :label: eq_ess

   Q_{\mathrm{C}}^{\mathrm{ess}} &= Q_{\mathrm{C}}^{\mathrm{Chl}}
                                  + Q_{\mathrm{C}}^{\mathrm{Pro}}
                                  + Q_{\mathrm{C}}^{\mathrm{RNA}}
                                  + Q_{\mathrm{C}}^{\mathrm{DNA}}
                                  + Q_{\mathrm{C}}^{\mathrm{Thy}}
                                  + Q_{\mathrm{C}}^{\mathrm{Other}}

   Q_{\mathrm{N}}^{\mathrm{ess}} &= Q_{\mathrm{N}}^{\mathrm{Chl}}
                                  + Q_{\mathrm{N}}^{\mathrm{Pro}}
                                  + Q_{\mathrm{N}}^{\mathrm{RNA}}
                                  + Q_{\mathrm{N}}^{\mathrm{DNA}}

   Q_{\mathrm{P}}^{\mathrm{ess}} &= Q_{\mathrm{P}}^{\mathrm{Thy}}
                                  + Q_{\mathrm{P}}^{\mathrm{RNA}}
                                  + Q_{\mathrm{P}}^{\mathrm{DNA}}
                                  + Q_{\mathrm{P}}^{\mathrm{Other}}

   Q_{\mathrm{Fe}}^{\mathrm{ess}} &= Q_{\mathrm{Fe}}^{\mathrm{Pro\_Pho}}

Any quotas beyonds these essential values will be distributed between a store
and an excess that is used to regulate uptake,

.. math::
   :label: eq_macromol_balance

   Q_{\mathrm{C}} &= Q_{\mathrm{C}}^{\mathrm{ess}} + Q_{\mathrm{C}}^{\mathrm{Stor}}
                   + Q_{\mathrm{N}}^{\mathrm{Stor}} Y^{\mathrm{C}:\mathrm{N}}_{\mathrm{Nsto}}
                   + Q_{\mathrm{C}}^{\mathrm{exc}}

   Q_{\mathrm{N}} &= Q_{\mathrm{N}}^{\mathrm{ess}} + Q_{\mathrm{N}}^{\mathrm{Stor}}
                   + Q_{\mathrm{N}}^{\mathrm{exc}}

   Q_{\mathrm{P}} &= Q_{\mathrm{P}}^{\mathrm{ess}} + Q_{\mathrm{P}}^{\mathrm{Stor}}
                   + Q_{\mathrm{P}}^{\mathrm{exc}}

   Q_{\mathrm{Fe}} &= Q_{\mathrm{Fe}}^{\mathrm{ess}} + Q_{\mathrm{Fe}}^{\mathrm{Stor}}
                    + Q_{\mathrm{Fe}}^{\mathrm{exc}}

The molar fractions of the macromolecules are a function of light, temperature,
and nutrient uptake.  To find the required chlorophyll quota, :math:`{Q_{\mathrm{C}}^{\mathrm{Chl}}}` ,
consider the net change of cellular carbon quota from photosynthesis, growth
and maintainance:

.. math::

   Q_{\mathrm{C}}^{\mathrm{Chl}} P_{\mathrm{Chl}}(I) - (1 + E) P_{\mathrm{C}} - m
   \;.

The chlorophyll-specific photosynthesis rate is a function of the
photosynthetically active radiation, :math:`I`,

.. math::

   P_{\mathrm{Chl}}(I) = S_{\mathrm{f}} V^{\max}_{\mathrm{I}} f_{\mathrm{I}}(I)
   \quad\text{with}\quad
   f_{\mathrm{I}}(I) = 1 - e^{-A_{\mathrm{I}}I}
   \;,

By assuming fixed carbon quota, the chlorophyll quota required for growth rate
:math:`P_{\mathrm{C}}` at given light is:

.. math::
   :label: eq_CChl

   Q_{\mathrm{C}}^{\mathrm{Chl}} = \frac{m + (1+E) P_{\mathrm{C}}}{P_{\mathrm{Chl}}(I)}
   \;.

The photosynthetic protein pool is assumed to be proportional to chlorophyll,

.. math::

   Q_{\mathrm{C}}^{\mathrm{Pro\_Pho}} = A_{\mathrm{Pho}} Q_{\mathrm{C}}^{\mathrm{Chl}}
   \;.

The biosynthetic protein pool to growth rate, with a temperature dependence
(only :ref:`darwin-temp-version-2` is supported)

.. math::

   Q_{\mathrm{C}}^{\mathrm{Pro\_Bio}} = A_{\mathrm{Bio}} P_{\mathrm{C}} / f^{\mathrm{mm}}(T)
   \;.

Total proteins also include a base pool of 'other' protein,

.. math::

   Q_{\mathrm{N}}^{\mathrm{Pro}} = Q_{\mathrm{N}}^{\mathrm{Pro\_Other}} + Q_{\mathrm{N}}^{\mathrm{Pro\_Pho}} + Q_{\mathrm{N}}^{\mathrm{Pro\_Bio}}
   \;.

Here, the elemental quotas of the pools are related as

.. math::

   Q_{\mathrm{N}}^{\mathrm{Pro\_Pho}} &= Q_{\mathrm{C}}^{\mathrm{Pro\_Pho}}/Y^{\mathrm{C}:\mathrm{N}}_{\mathrm{Pro}}

   Q_{\mathrm{N}}^{\mathrm{Pro\_Bio}} &= Q_{\mathrm{C}}^{\mathrm{Pro\_Bio}}/Y^{\mathrm{C}:\mathrm{N}}_{\mathrm{Pro}}
   \;.

RNA pools depend on protein pools and growth rate, again with a temperature dependence,

.. math::

   Q_{\mathrm{P}}^{\mathrm{RNA}} = A^{\mathrm{P}}_{\mathrm{RNA}} Q_{\mathrm{C}}^{\mathrm{Pro}} P_{\mathrm{C}} / f^{\mathrm{mm}}(T) + Q_{\mathrm{P,min}}^{\mathrm{RNA}}

with

.. math::

   Q_{\mathrm{C}}^{\mathrm{Pro}} = Y^{\mathrm{C}:\mathrm{N}}_{\mathrm{Pro}} Q_{\mathrm{N}}^{\mathrm{Pro}}
   \;.

We find the other cell component from the following  stoichiometric relations:

.. math::

   Q_{\mathrm{N}}^{\mathrm{Chl}}        &= Y^{\mathrm{N}:\mathrm{C}}_{\mathrm{Chl}} Q_{\mathrm{C}}^{\mathrm{Chl}}

   Q_{\mathrm{P}}^{\mathrm{Thy}}        &= Y^{\mathrm{P}}_{\mathrm{Thy}} Q_{\mathrm{C}}^{\mathrm{Chl}}

   Q_{\mathrm{N}}^{\mathrm{RNA}}        &= Q_{\mathrm{P}}^{\mathrm{RNA}}/Y^{\mathrm{P}:\mathrm{N}}_{\mathrm{RNA}}

   Q_{\mathrm{C}}^{\mathrm{RNA}}        &= Y^{\mathrm{C}:\mathrm{N}}_{\mathrm{RNA}} Q_{\mathrm{N}}^{\mathrm{RNA}}

   Q_{\mathrm{C}}^{\mathrm{Thy}}        &= Y^{\mathrm{C}:\mathrm{P}}_{\mathrm{Plip}} Q_{\mathrm{P}}^{\mathrm{Thy}}

   Q_{\mathrm{Fe}}^{\mathrm{Pro\_Pho}}  &= Y^{\mathrm{Fe}:\mathrm{N}}_{\mathrm{Pho}} Q_{\mathrm{N}}^{\mathrm{Pro\_Pho}}

   Q_{\mathrm{N}}^{\mathrm{Pro\_Other}} &= Q_{\mathrm{C}}^{\mathrm{Pro\_Other}}/Y^{\mathrm{C}:\mathrm{N}}_{\mathrm{Pro}}

   Q_{\mathrm{N,min}}^{\mathrm{RNA}}    &= Q_{\mathrm{P,min}}^{\mathrm{RNA}}/ Y^{\mathrm{P}:\mathrm{N}}_{\mathrm{RNA}}

   Q_{\mathrm{C,min}}^{\mathrm{RNA}}    &= Y^{\mathrm{C}:\mathrm{N}}_{\mathrm{RNA}} Q_{\mathrm{N,min}}^{\mathrm{RNA}}

   Q_{\mathrm{N}}^{\mathrm{DNA}}        &= Q_{\mathrm{C}}^{\mathrm{DNA}}/Y^{\mathrm{C}:\mathrm{N}}_{\mathrm{DNA}}

   Q_{\mathrm{P}}^{\mathrm{DNA}}        &= Y^{\mathrm{P}:\mathrm{N}}_{\mathrm{RNA}} Q_{\mathrm{N}}^{\mathrm{DNA}}
   \;,

These cellular balances for each element, without the storage component,
yield trinomial equation for growth rate, which solve numerically

.. math::

   Q_{X}^{\mathrm{ess}} = Q_{X}^{(0)} + Q_{X}^{(1)} P_{\mathrm{C}} + Q_{X}^{(2)} P_{\mathrm{C}}^2
   \;.

By equating these to the actually available quotas, we obtain maximum growth
rates for each quota limitation, :math:`P_{\mathrm{C}}^X`.  The realized growth
rate is the smallest,

.. math::

   P_{\mathrm{C}} = \min\left(
       P_{\mathrm{C}}^{\mathrm{N}},
       P_{\mathrm{C}}^{\mathrm{P}},
       P_{\mathrm{C}}^{\mathrm{Fe}},
       P_{\mathrm{C}}^{\mathrm{C}}
       \right)
   \;.


No-growth, non-zero chlorophyll case
''''''''''''''''''''''''''''''''''''

When one of the nutrient-limited growth-rate equations does not have a positive
solution, the growth rate is zero.  In this case, it is assumed that
the macromolecular requirements for Chlorophyll in the first part of this
section are still valid (but for :math:`P_{\mathrm{C}}=0`).  We can then compute the maximum
amount of chlorophyll possible for each limiting nutrient,

.. math::

   Q_{\mathrm{C}}^{\mathrm{Chl,N}} &= \frac{ Q_{\mathrm{N}} - Q_{\mathrm{N}}^{\text{no-Chl}} }
                                           { Y^{\mathrm{N}:\mathrm{C}}_{\mathrm{Chl}}
                                           + A_{\mathrm{Pho}}/Y^{\mathrm{C}:\mathrm{N}}_{\mathrm{Pro}} }

   Q_{\mathrm{C}}^{\mathrm{Chl,P}} &= \frac{ Q_{\mathrm{P}} - Q_{\mathrm{P}}^{\text{no-Chl}} }{ Y^{\mathrm{P}}_{\mathrm{Thy}} }

   Q_{\mathrm{C}}^{\mathrm{Chl,Fe}} &= \frac{ Q_{\mathrm{Fe}} }
                                            { A_{\mathrm{Pho}} Y^{\mathrm{Fe}:\mathrm{N}}_{\mathrm{Pho}}
                                              /Y^{\mathrm{C}:\mathrm{N}}_{\mathrm{Pro}} }

where

.. math::

   Q_{\mathrm{N}}^{\text{no-Chl}} &= Q_{\mathrm{N,min}}^{\mathrm{RNA}} + Q_{\mathrm{N}}^{\mathrm{DNA}}
                                   + Q_{\mathrm{N}}^{\mathrm{Pro\_Other}}

   Q_{\mathrm{P}}^{\text{no-Chl}} &= Q_{\mathrm{P,min}}^{\mathrm{RNA}} + Q_{\mathrm{P}}^{\mathrm{DNA}}
                                   + Q_{\mathrm{P}}^{\mathrm{Other}}

are the essential quotas for zero growth.  (Without growth, no iron is required).

The carbon requirements also imply a maximum chlorophyll value for the zero
growth case,

.. math::

   Q_{\mathrm{C,max}}^{\mathrm{Chl}} = \frac{m}{V^{\min}_{\mathrm{I}}}

where

.. math::

   V^{\min}_{\mathrm{I}} &= m \frac{ 1 + A_{\mathrm{Thy}} + A_{\mathrm{Pho}} }
                                   { 1-Q_{\mathrm{C}}^{\mathrm{const}} }

   Q_{\mathrm{C}}^{\mathrm{const}} &= Q_{\mathrm{C}}^{\mathrm{Pro\_Other}} + Q_{\mathrm{C,min}}^{\mathrm{RNA}}
                                    + Q_{\mathrm{C}}^{\mathrm{DNA}} + Q_{\mathrm{C}}^{\mathrm{Other}}
   \;.

The realized amount of chlorophyll is the one compatible with all these, and the
constraint from carbon requirement,

.. math::

   Q_{\mathrm{C}}^{\mathrm{Chl}} = \min\bigl(
      Q_{\mathrm{C}}^{\mathrm{Chl,N}},
      Q_{\mathrm{C}}^{\mathrm{Chl,P}},
      Q_{\mathrm{C}}^{\mathrm{Chl,Fe}},
      Q_{\mathrm{C}}^{\mathrm{Chl}\max}
      \bigr)
   \;.


No-chlorophyll case
'''''''''''''''''''

When even the minimum quota requirements for chlorophyll are not met, the
available quotas are divided evenly between the pools needed for chlorophyll,

.. math::

   Q_{\mathrm{N}}^{\mathrm{RNA}}       &= f \cdot Q_{\mathrm{N,min}}^{\mathrm{RNA}}

   Q_{\mathrm{N}}^{\mathrm{DNA\_actl}} &= f \cdot Q_{\mathrm{N}}^{\mathrm{DNA}}

   Q_{\mathrm{P}}^{\mathrm{RNA}}       &= f \cdot Q_{\mathrm{P,min}}^{\mathrm{RNA}}

   Q_{\mathrm{P}}^{\mathrm{DNA\_actl}} &= f \cdot Q_{\mathrm{P}}^{\mathrm{DNA}}

where

.. math::

   f = \min\left( \frac{Q_{\mathrm{N}}}{Q_{\mathrm{N}}^{\text{no-Chl}}},
                  \frac{Q_{\mathrm{P}}}{Q_{\mathrm{P}}^{\text{no-Chl}}} \right)
   \;.

Any excess (of the non-limiting element) goes to the nitrogen protein or
phosphorus ‘other’ pool,

.. math::

   Q_{\mathrm{N}}^{\mathrm{Pro}} &= \min\left( Q_{\mathrm{N}} - Q_{\mathrm{N}}^{\mathrm{RNA}}
                                               - Q_{\mathrm{N}}^{\mathrm{DNA\_actl}},
                                               Q_{\mathrm{N}}^{\mathrm{Pro\_Other}} \right)

   Q_{\mathrm{P}}^{\mathrm{Other\_actl}} &= \min\left( Q_{\mathrm{P}} - Q_{\mathrm{P}}^{\mathrm{RNA}}
                                                       - Q_{\mathrm{P}}^{\mathrm{DNA\_actl}},
                                                       Q_{\mathrm{P}}^{\mathrm{Other}} \right)
   \;.

The essential quotas are then recomputed with these reduced pools.


Storage and uptake regulation
'''''''''''''''''''''''''''''

Nutrient storage is computed from excess quota beyond essential.
Nitrogen storage is limited by a fixed maximum and the required carbon quota for the store,

.. math::

   Q_{\mathrm{N}}^{\mathrm{Stor}} = \min\left(
                         Q_{\mathrm{N}} - Q_{\mathrm{N}}^{\mathrm{ess}},
                         Q_{\mathrm{N,max}}^{\mathrm{Sto}},
                         \frac{ Q_{\mathrm{C}} - Q_{\mathrm{C}}^{\mathrm{ess}} }
                              { Y^{\mathrm{C}:\mathrm{N}}_{\mathrm{Nsto}} }
                  \right)
   \;.

For phosphorus and iron, the quotas are limited rather than the store,

.. math::

   Q_{\mathrm{P}}^{\mathrm{Stor}}  &= \min\left( Q_{\mathrm{P}}, Q_{\mathrm{P}}^{\mathrm{max}} \right)
                                      - Q_{\mathrm{P}}^{\mathrm{ess}}

   Q_{\mathrm{Fe}}^{\mathrm{Stor}} &= \min\left( Q_{\mathrm{Fe}}, Q_{\mathrm{Fe}}^{\mathrm{max}} \right)
                                      - Q_{\mathrm{Fe}}^{\mathrm{ess}}
   \;.

Excess nitrogen quota that cannot be stored leads to a reduction in uptake via
an additional multiplicative regulation term in :math:`U^{\mathrm{NO3}}`,

.. math::

   \mathrm{reg}^{\mathrm{mm}}_{\mathrm{N}} =
       \frac{1.1 (Q_{\mathrm{N}}^{\mathrm{ess}} + Q_{\mathrm{N}}^{\mathrm{Stor}}) - Q_{\mathrm{N}}}
            {0.1 (Q_{\mathrm{N}}^{\mathrm{ess}} + Q_{\mathrm{N}}^{\mathrm{Stor}})}
   \;,

and similar for phosphorus and iron.

.. tabularcolumns:: |\Y{.12}|\Y{.16}|\Y{.18}|\Y{.14}|\Y{.1}|\Y{.3}|

.. csv-table:: Traits of the macromolecular growth model
   :delim: &
   :widths: 13,20,22,16,11,18
   :class: longtable
   :header: symbol, trait, param, default, units, description
   :name: tab_phys_pkg_darwin_macromol_traits

   :math:`E`                                         & :varlink:`ECo2Prod`     & :varlink:`a_ECo2Prod`     & 0.774       & dimensionless          & respiratory cost of biosynthesis
   :math:`m`                                         & :varlink:`maintConsum`  & :varlink:`a_maintConsum`  & 0.393/day   & 1/s                    & maintenance respiration rate
   :math:`V^{\max}_{\mathrm{I}}`                     & :varlink:`VI_max`       & :varlink:`a_VI_max`       & 277/day     & molC/s / (molC in Chl) & per-chlorophyll maximum photosynthesis rate
                                                     &                         & :varlink:`b_VI_max`       & 0           &                        &
   :math:`A_{\mathrm{I}}`                            & :varlink:`A_I`          & :varlink:`a_A_I`          & 0.008633641 & m\ :sup:`2`\ s/μmol    & coefficient characterizing the absorption cross section
   :math:`S_{\mathrm{f}}`                            & :varlink:`Sf`           &                           & 1.0         & unitless               & enhancement of photosynthesis due to size
   :math:`A_{\mathrm{Pho}}`                          & :varlink:`A_pho`        & :varlink:`a_A_pho`        & 16.0        & molC / (molC in Chl)   & A constant of proportionality
   :math:`A_{\mathrm{Bio}}`                          & :varlink:`A_bio`        & :varlink:`a_A_bio`        & 0.2711*day  & molC / (molC/s)        & constant for variable part of biosynthesis protein
   :math:`A^{\mathrm{P}}_{\mathrm{RNA}}`             & :varlink:`AP_RNA`       & :varlink:`a_AP_RNA`       & 0.00423*day & molP / (molC/s)        & constant for variable part of RNA
   :math:`Q_{\mathrm{C}}^{\mathrm{Other}}`           & :varlink:`QC_other`     & :varlink:`a_QC_other`     & 0.0182      & molC / molC            & constant pool of structural lipids and carbs
   :math:`Q_{\mathrm{C}}^{\mathrm{Pro\_Other}}`      & :varlink:`QC_pro_other` & :varlink:`a_QC_pro_other` & 0.24        & molC / molC            & constant pool of essential proteins
   :math:`Q_{\mathrm{P}}^{\mathrm{Other}}`           & :varlink:`QP_other`     & :varlink:`a_QP_other`     & 6.5344E-4   & molP / molC            & constant part of phosphorus
   :math:`Q_{\mathrm{P,min}}^{\mathrm{RNA}}`         & :varlink:`QP_RNA_min`   & :varlink:`a_QP_RNA_min`   & 2.23E-4     & molP / molC            & minimum RNA in the cell
   :math:`Q_{\mathrm{C}}^{\mathrm{DNA}}`             & :varlink:`QC_DNA`       & :varlink:`a_QC_DNA`       & 9.41E-4     & molC / molC            & constant part of DNA
   :math:`Q_{\mathrm{N,max}}^{\mathrm{Sto}}`         & :varlink:`QN_sto_max`   & :varlink:`a_QN_sto_max`   & 0.035       & molN / molC            & maximum nitrogen storage
                                                     &                         & :varlink:`b_QN_sto_max`   & 0           &                        &
   :math:`Q_{\mathrm{P}}^{\mathrm{max}}`             & :varlink:`Qp_max`       & :varlink:`a_Qp_max`       & 0.0052      & molP / molC            & maximum phosphorus quota
                                                     &                         & :varlink:`b_Qp_max`       & 0           &                        &
   :math:`Q_{\mathrm{Fe}}^{\mathrm{max}}`            & :varlink:`Qfe_max`      & :varlink:`a_Qfe_max`      & 2.436E-4    & molFe / molC           & maximum iron quota
                                                     &                         & :varlink:`b_Qfe_max`      & 0           &                        &
   :math:`Y^{\mathrm{C}:\mathrm{P}}_{\mathrm{Plip}}` & :varlink:`Y_CP_Plip`    & :varlink:`a_Y_CP_Plip`    & 40.0        & molC / molP            & C/P molar ratio of thylakoid membrane
   :math:`Y^{\mathrm{C}:\mathrm{N}}_{\mathrm{Pro}}`  & :varlink:`Y_CN_protein` & :varlink:`a_Y_CN_protein` & 5.3/1.4     & molC / molN            & C/N molar ratio in protein
   :math:`Y^{\mathrm{N}:\mathrm{C}}_{\mathrm{Chl}}`  & :varlink:`Y_NC_chl`     & :varlink:`a_Y_NC_chl`     & 4.0/55.0    & molN / molC            & N/C molar ratio in chlorophyll
   :math:`Y^{\mathrm{C}:\mathrm{N}}_{\mathrm{Nsto}}` & :varlink:`Y_CN_cyano`   & :varlink:`a_Y_CN_cyano`   & 2.0         & molC / molN            & C/N molar ratio of cyanophycin
   :math:`Y^{\mathrm{P}:\mathrm{N}}_{\mathrm{RNA}}`  & :varlink:`Y_PN_nucacid` & :varlink:`a_Y_PN_nucacid` & 1/3.75      & molP / molN            & P/N molar ratio of RNA
   :math:`Y^{\mathrm{C}:\mathrm{N}}_{\mathrm{DNA}}`  & :varlink:`Y_CN_DNA`     & :varlink:`a_Y_CN_DNA`     & 9.75/3.75   & molC / molN            & C/N molar ratio of DNA
   :math:`Y^{\mathrm{C}:\mathrm{N}}_{\mathrm{RNA}}`  & :varlink:`Y_CN_RNA`     & :varlink:`a_Y_CN_RNA`     & 9.50/3.75   & molC / molN            & C/N molar ratio of RNA
   :math:`Y^{\mathrm{P}}_{\mathrm{Thy}}`             & :varlink:`Y_THY_P`      & :varlink:`a_Y_THY_P`      & 0.028163    & molP / (molC in Chl)   & phosphorus in thylakoid membrane to chlorophyll
   :math:`Y^{\mathrm{Fe}:\mathrm{N}}_{\mathrm{Pho}}` & :varlink:`Y_FeN_photo`  & :varlink:`a_Y_FeN_photo`  & 0.00163     & molFe / molN           & Fe/N ratio in photosystem iron


.. csv-table:: Dependent traits of the macromolecular growth model
   :delim: &
   :widths: 15,18,25,42
   :header: symbol, trait, units, description
   :name: tab_phys_pkg_darwin_macromol_deptraits

   :math:`Q_{\mathrm{N}}^{\mathrm{Pro\_Other}}` & :varlink:`QN_pro_other` & molN / molC            & cellular nitrogen in essential proteins
   :math:`Q_{\mathrm{N,min}}^{\mathrm{RNA}}`    & :varlink:`QN_RNA_min`   & molN / molC            & constant part of RNA in nitrogen
   :math:`Q_{\mathrm{C,min}}^{\mathrm{RNA}}`    & :varlink:`QC_RNA_min`   & molN / molC            & constant part of RNA in carbon
   :math:`Q_{\mathrm{N}}^{\mathrm{DNA}}`        & :varlink:`QN_DNA`       & molN / molC            & DNA in nitrogen
   :math:`Q_{\mathrm{P}}^{\mathrm{DNA}}`        & :varlink:`QP_DNA`       & molP / molC            & DNA in phosphorous
   :math:`A_{\mathrm{Thy}}`                     & :varlink:`A_thy`        & molC / (molC in chl)   & ratio of carbon in thylakoid membrane to chlorophyll
   :math:`A^{\mathrm{N}}_{\mathrm{RNA}}`        & :varlink:`AN_RNA`       & s molN / molN          & constant for variable part of RNA
   :math:`V^{\min}_{\mathrm{I}}`                & :varlink:`VI_min`       & molC/s / (molC in Chl) & minimum photosynthesis rate
   :math:`Q_{\mathrm{C,max}}^{\mathrm{Chl}}`    & :varlink:`QC_chlMax`    & molC / molC            & maximum chlorophyll concentration at minimum light
   :math:`Q_{\mathrm{N}}^{\text{no-Chl}}`       & :varlink:`QnNoChl`      & molN / molC            & minimum QN at zero growth rate
   :math:`Q_{\mathrm{P}}^{\text{no-Chl}}`       & :varlink:`QpNoChl`      & molP / molC            & minimum QP at zero growth rate
   :math:`Q_{\mathrm{Fe}}^{\text{no-Chl}}`      & :varlink:`QfeNoChl`     & molFe / molC           & minimum QFe at zero growth rate
   :math:`Q_{\mathrm{C}}^{\mathrm{const}}`      & :varlink:`QC_const`     & molC / molC            & constant portion of the cell

.. csv-table:: Parameters of the macromolecular growth model
   :delim: &
   :widths: 25,11,9,55
   :header: param, default, units, description
   :name: tab_phys_pkg_darwin_macromol_params

   :varlink:`TempAeArrMacromol` & --8420 & K & slope for pseudo-Arrhenius for macromolecular (TEMP_VERSION 2)
