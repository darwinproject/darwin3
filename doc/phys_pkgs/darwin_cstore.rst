.. include:: ../defs.hrst

.. _CarbonStore:

Internal carbon store and exudation
'''''''''''''''''''''''''''''''''''

Note: the internal carbon store is currently only implemented for fixed
plankton elemental ratios (i.e., :varlink:`DARWIN_ALLOW_NQUOTA`,
:varlink:`DARWIN_ALLOW_PQUOTA`, :varlink:`DARWIN_ALLOW_FEQUOTA`,
:varlink:`DARWIN_ALLOW_SIQUOTA` all undefined).

With :varlink:`DARWIN_ALLOW_CSTORE` defined, nutrient availability limits
growth directly rather than via the photosynthesis rate.  The maximum
photosynthesis rate (and with it carbon uptake) becomes independent of
nutritient limitation,

.. math::

   P^{{\mathrm{C}}{\op{m}}}_j = P_{{\mathrm{C}},j}^{\max} f^{{{\text{phy}}}}_j(T) \gamma_{\op{pCO2}}

but the growth rate is limited by the availability of each nutrient,

.. math::

   \mu_j = \min(P^{\op{C}}_j, \mu^{\max\op{N}}_j, \mu^{\max\op{P}}_j,
           \mu^{\max\op{Fe}}_j, \mu^{\max\op{Si}}_j)

Each nutrient’s availability determines a maximum achievable growth rate. Its
form depends on whether variable quotas are enabled for the nutrient.
For instance for phosphorus, without P quota,

.. math::
   :label: eq_darwin_max_growth_p

   \mu^{\max\op{P}}_j = \frac{1}{R^{\op{P}:\op{C}}_j} V^{{\mathrm{P}}\max}_j
           \gamma^{\op{P}}_j f^{\op{up}}_j(T) ( 1 + r^{\op{resp}}_j )

and with P quota,

.. math::
   :label: eq_darwin_max_growth_p_noquota

   \mu^{\max\op{P}}_j = \frac{1}{R^{\op{P}:\op{C}}_j} u^{\mathrm{P}}_j
           ( 1 + r^{\op{resp}}_j )

where :math:`u^{\mathrm{P}}_j` is the carbon-specific uptake rate for phosphorus,

.. math::

   u^{\mathrm{P}}_j = V^{{\mathrm{P}}\max}_j \frac{\mathrm{PO}_4}{\mathrm{PO}_4 + k^{\op{PO4}}_j}
              {{\text{reg}}}^{Q{\mathrm{P}}}_j \cdot f^{{\text{up}}}_j(T)

and the respiration rate is

.. math::

   r^{\op{resp}}_j = r^{\op{resp}\max}_j f^{\op{remin}}(T) \frac{c_j - c_j^{\min}}{c_j}

Other elements work analogously, except that the maximum nitrogen uptake rate
for the case without nitrogen quotas is more complex,

.. math::

   \mu^{\max\op{N}}_j = \frac{1}{R^{\op{P}:\op{C}}_j} u^{{\mathrm{N}}\max}_j
           ( 1 + r^{\op{resp}}_j )

where

.. math::

   u^{{\mathrm{N}}\max}_j = \max( u^{{\mathrm{NO3}}\max}_j,
        u^{{\mathrm{NO2}}\max}_j, u^{{\mathrm{NH4}}\max}_j )

with

.. math::

   u^{{\mathrm{N..}}\max}_j = V^{{\mathrm{N..}}\max}_j \gamma^{\op{N..}}_j
            f^{\op{up}}_j(T)

Part of the excess carbon is exuded to become DOC,

.. math::

   E^{\op{C}}_j = (P^{\op{C}}_j - \mu_j) f^{\op{exude}}_j c_j

and part stored as fat,

.. math::

   U^{\op{fat}}_j = (P^{\op{C}}_j - \mu_j) (1 - f^{\op{exude}}_j) c_j \;.

The Chlorophyll synthesis rate is based on the growth rate (as before).

.. csv-table:: Exudation parameters
   :delim: &
   :widths: 13,20,17,15,15,20
   :class: longtable
   :header: Trait, Param, Symbol, Default, Units, Description

   :varlink:`FracExudeC` & :varlink:`a_FracExudeC` & :math:`f^{\op{exude}}_j` & 0.3 &  & fraction of excess carbon exuded
