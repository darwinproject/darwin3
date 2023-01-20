.. include:: ../defs.hrst

.. _AirSea:

Air-sea exchanges
^^^^^^^^^^^^^^^^^

The preprocessor option :varlink:`DARWIN_ALLOW_CARBON` is required to enable
the computation of air-sea exchanges and the oxygen tracer.

The surface flux of DIC is

.. math::

   \mathcal{F}_{\mathrm{DIC}} = \rho_o K_{\text{g}}^{\mathrm{CO2}}
      \bigl(
      [\op{CO}_2^{\text{at}}] - [\op{CO}_2^*]
      \bigr)

with

.. math::

   K_{\text{g}}^{\mathrm{CO2}} = \frac{0.337\op{cm}\op{h}^{-1}}{\op{m}^2/\op{s}^2} w^2
   \left(\frac{\op{Sc}_{\mathrm{CO2}}}{660}\right)^{-1/2}
   (1-f_{\text{ice}})

.. math::

   [\op{CO}_2^*] = [\op{CO}_2] + [\mathrm{H_2CO_3}]

.. math::

   [\op{CO}_2^{\text{at}}] = F p_{\op{CO}_2}^{\text{at}}

.. math::

   p_{\op{CO}_2}^{\text{at}} = p^{\text{at}} \cdot x_{\op{CO}_2}^{\text{at}}

where :math:`w` is the wind speed and :math:`f_{\text{ice}}` is the surface
fraction covered by ice, read in from :varlink:`icefile` or taken from the
seaice package if :varlink:`useSEAICE` is set to true.  The Schmidt number for
CO\ :sub:`2`, Sc\ :sub:`CO2`, is parameterized according to Wanninkhof (1992)
:cite:`wannink:92`, with values below 0.01 cut.  :math:`F` is computed
following Weiss and Price (1980) :cite:`weiss:80`.  The reference density of
seawater, :math:`\rho_o`, is set via its inverse, :varlink:`m3perkg`.  The
units of CO\ :sub:`2` concentrations here are mol/kg.
:math:`[\mathrm{CO}_2^*]` is computed in :ref:`CarbonChemistry`.

The surface flux of oxygen is

.. math::

   \mathcal{F}_{\mathrm{O2}} = K_{\text{g}}^{\mathrm{O2}} \bigl(
      [\op{O}_2^{\text{sat}}] - [\op{O}_2]
      \bigr)

with

.. math::

   K_{\text{g}}^{\mathrm{O2}} = \frac{0.337\op{cm}\op{h}^{-1}}{\op{m}^2/\op{s}^2} w^2
   \left(\frac{\op{Sc}_{\mathrm{O2}}}{660}\right)^{-1/2}
   (1-f_{\text{ice}})

.. math::

   [\op{O}_2^{\text{sat}}] = p^{\text{at}} C_o^*

The saturated concentration of O\ :sub:`2` at 1 atm, :math:`C_o^*`, is computed
following Garcia and Gordon (1992) :cite:`garcia:92`.  The Schmidt number of
oxygen according to Keeling et al. (1998) :cite:`keeling:98`.  The units of
oxygen concentrations are mmol m\ :sup:`-3`.


.. csv-table:: Air-sea exchange parameters
   :delim: &
   :widths: auto
   :header: Name, Symbol, Default, Units, Description
   :name: phys_pkg_darwin_airsea_parameters

   :varlink:`m3perkg`  & :math:`1/\rho_o` & 1 / 1024.5            & m\ :sup:`3`/kg                   & constant for converting per kg to per m\ :sup:`3`
   :varlink:`darwin_useSEAICE` & & .FALSE. & & whether to use ice area from the seaice package
