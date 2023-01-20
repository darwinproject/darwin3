.. include:: ../defs.hrst

.. _CarbonChemistry:

Carbon chemistry
^^^^^^^^^^^^^^^^

Carbon chemistry options
''''''''''''''''''''''''

The following preprocessor options affect the computation of pH, 
:math:`[\mathrm{CO}_2^*]` and :math:`[\mathrm{CO}_3^{2-}]`:

.. tabularcolumns:: |l|l|

.. csv-table:: CPP options for carbon chemistry
   :delim: &
   :widths: auto
   :class: longtable
   :header: CPP option, description

   :varlink:`DARWIN_ALLOW_CARBON` & enable air-sea carbon exchange and ALK and O\ :sub:`2` tracers
   :varlink:`DARWIN_SOLVESAPHE`   & compile Munhoven "Solvesaphe" pH/pCO\ :sub:`2` solver package
   :varlink:`DARWIN_TOTALPHSCALE` & consistently use the total pH scale for carbon chemistry coefficients
   :varlink:`DARWIN_ALLOW_RADI`   & enable RADI sediment model

:varlink:`DARWIN_ALLOW_CARBON` is required to enable the computation
of pH, :math:`[\mathrm{CO}_2^*]` and :math:`[\mathrm{CO}_3^{2-}]` values.  If
:varlink:`DARWIN_SOLVESAPHE` is defined, the coefficients for the carbon solver
are computed following to Munhoven (2013) :cite:`munhoven:13`, otherwise
according to Follows et al. (2006) :cite:`follows:06`.  In this case,
:varlink:`DARWIN_TOTALPHSCALE` can be defined to ensure all computations
consistently use the total pH scale.  :varlink:`DARWIN_ALLOW_RADI` activates
the RADI sediment model following :cite:`sulpis:22`.

The run-time parameter :varlink:`selectPHsolver` decides which pH solver to use:

.. table::

   +----------------+----------------------------------+
   | selectPHsolver | meaning                          |
   +================+==================================+
   | 0 (default)    | use Follows et al. (2006) solver |
   +----------------+----------------------------------+
   | 1              | use the GENERAL solver           |
   +----------------+----------------------------------+
   | 2              | use SEC solver                   |
   +----------------+----------------------------------+
   | 3              | use FAST solver routine          |
   +----------------+----------------------------------+

All options except '0' require :varlink:`DARWIN_SOLVESAPHE` to be defined.
Note that if the Follows et al. solver is selected with
:varlink:`DARWIN_SOLVESAPHE`, the dissociation coefficients from Solvesaphe
will be used.  More Solvesaphe parameters:

.. csv-table::
   :delim: &
   :widths: auto
   :header: selectBTconst, estimates borate concentration from salinity

   1 (default)     & use default formulation of Uppström (1974) :cite:`uppstrom:74` (same as S/R CARBON_COEFFS)
   2               & use new formulation from Lee et al (2010) :cite:`lee:10`

.. csv-table::
   :delim: &
   :widths: auto
   :header: selectFTconst, estimates fluoride concentration from salinity

   1 (default)     & use default formulation of Riley (1965) :cite:`riley:65` (same as S/R CARBON_COEFFS)
   2               & use new formulation from Culkin (1965) :cite:`culkin:65`

.. csv-table::
   :delim: &
   :widths: auto
   :header: selectHFconst, sets the first dissociation constant for hydrogen fluoride

   1 (default)     & use default  Dickson and Riley (1979) :cite:`dickson:79` (same as S/R CARBON_COEFFS)
   2               & use new formulation of Perez and Fraga (1987) :cite:`perez:87`

.. csv-table::
   :delim: &
   :widths: auto
   :header: selectK1K2const, sets the 1rst and 2nd dissociation constants of carbonic acid

   1 (default)     & use default formulation of Millero (1995) :cite:`millero:95` with data from Mehrbach et al. (1973) :cite:`mehrbach:73` (same as S/R CARBON_COEFFS)
   2               & use formulation of Roy et al. (1993) :cite:`roy:93`
   3               & use "combination" formulation of Millero (1995) :cite:`millero:95`
   4               & use formulation of Luecker et al. (2000) :cite:`lueker:00`
   5               & use formulation of Millero (2010) :cite:`millero:10b`
   6               & use formulation of Waters, Millero, Woosley (2014) :cite:`waters:13,waters:14`

The input parameters for the carbon solver are salinity, temperature, DIC,
alkalinity, phosphate and silica.  Limits are applied to all these quantities
to ensure convergence.  The corresponsing parameters are shown in
:numref:`phys_pkg_darwin_carbon_parameters`.  There is a separate set of
parameters for the initialization phase which is treated differently from calls
to the solver during the run: the Follows et al. solver is called 10 times in
order to allow the solution to converge.  The Munhoven solvers have a special
initialization routine.

.. csv-table:: Carbon parameters
   :delim: &
   :widths: 20,11,11,17,41
   :header: Name, Symbol, Default, Units, Description
   :name: phys_pkg_darwin_carbon_parameters

   :varlink:`surfSaltMinInit` & & 4.0                   & g/kg                             & limits for carbon solver input at initialization
   :varlink:`surfSaltMaxInit` & & 50.0                  & g/kg                             & ...
   :varlink:`surfTempMinInit` & & --4.0                 & °C                               &
   :varlink:`surfTempMaxInit` & & 39.0                  & °C                               &
   :varlink:`surfDICMinInit`  & & 10.0                  & mmol C m\ :sup:`-3`              &
   :varlink:`surfDICMaxInit`  & & 4000.0                & mmol C m\ :sup:`-3`              &
   :varlink:`surfALKMinInit`  & & 10.0                  & meq m\ :sup:`-3`                 &
   :varlink:`surfALKMaxInit`  & & 4000.0                & meq m\ :sup:`-3`                 &
   :varlink:`surfPO4MinInit`  & & 1D-10                 & mmol P m\ :sup:`-3`              &
   :varlink:`surfPO4MaxInit`  & & 10.0                  & mmol P m\ :sup:`-3`              &
   :varlink:`surfSiMinInit`   & & 1D-8                  & mmol Si m\ :sup:`-3`             &
   :varlink:`surfSiMaxInit`   & & 500.0                 & mmol Si m\ :sup:`-3`             &
   :varlink:`surfSaltMin`     & & 4.0                   & g/kg                             & limits for carbon solver input during run
   :varlink:`surfSaltMax`     & & 50.0                  & g/kg                             & ...
   :varlink:`surfTempMin`     & & --4.0                 & °C                               &
   :varlink:`surfTempMax`     & & 39.0                  & °C                               &
   :varlink:`surfDICMin`      & & 400.0                 & mmol C m\ :sup:`-3`              &
   :varlink:`surfDICMax`      & & 4000.0                & mmol C m\ :sup:`-3`              &
   :varlink:`surfALKMin`      & & 400.0                 & meq m\ :sup:`-3`                 &
   :varlink:`surfALKMax`      & & 4000.0                & meq m\ :sup:`-3`                 &
   :varlink:`surfPO4Min`      & & 1D-10                 & mmol P m\ :sup:`-3`              &
   :varlink:`surfPO4Max`      & & 10.0                  & mmol P m\ :sup:`-3`              &
   :varlink:`surfSiMin`       & & 1D-8                  & mmol Si m\ :sup:`-3`             &
   :varlink:`surfSiMax`       & & 500.0                 & mmol Si m\ :sup:`-3`             &


Calcite dissolution
'''''''''''''''''''

The parameter :varlink:`darwin_disscSelect` determines the calcite dissolution
rate law.  A value of ‘0’ gives a constant dissolution rate,

.. math::

   D_{\mathrm{PIC}} = \kappa^{\mathrm{diss}}_{\mathrm{C}} \cdot \op{PIC}
   \;.

A value of ‘1’ gives the power law of Keir (1980) :cite:`keir:80`,

.. math::

   D_{\mathrm{PIC}} = \kappa_{\text{Keir}} (1 - \Omega_{\mathrm{C}})^{e_{\text{Keir}}} \cdot \op{PIC}
   \;,

a value of ‘2’ the double power law of Naviaux (2019) :cite:`naviaux:19`,

.. math::

   D_{\mathrm{PIC}} = \op{PIC} \cdot \begin{cases}
      5.22\cdot 10^{-9} (1 - \Omega_{\mathrm{C}})^{0.11}
      &\text{for } \Omega_{\mathrm{C}} > 0.8272 \;, \\
      1.65\cdot 10^{-5} (1 - \Omega_{\mathrm{C}})^{4.7}
      &\text{for } \Omega_{\mathrm{C}} \le 0.8272 \;.
   \end{cases}

Here,

.. math::

   \Omega_{\mathrm{C}} = \frac{[\op{Ca}^{2+}] [\op{CO}_3^{2-}]}{K_{\mathrm{sp}}^{\mathrm{calc}}}

and the concentration of calcium is parameterized as a function of salinity.
With :varlink:`DARWIN_SOLVESAPHE`,

.. math::

   [\op{Ca}^{2+}] = 0.010282\frac{S}{35}
   \;,

otherwise,

.. math::

   [\op{Ca}^{2+}] = 0.01028\frac{S}{35}
   \;.


.. csv-table:: Calcite dissolution parameters
   :delim: &
   :widths: 23,12,15,10,40
   :header: Name, Symbol, Default, Units, Description
   :name: phys_pkg_darwin_calcite_parameters

   :varlink:`darwin_disscSelect` &                                             & 0                          &     & choose calcite dissolution rate law
                                 &                                             &                            &     & 0: constant
                                 &                                             &                            &     & 1: Keir
                                 &                                             &                            &     & 2: Naviaux
   :varlink:`Kdissc`             & :math:`\kappa^{\mathrm{diss}}_{\mathrm{C}}` & 1/(300 days)               & 1/s & constant calcite dissolution rate
   :varlink:`darwin_KeirCoeff`   & :math:`\kappa_{\text{Keir}}`                & e\ :sup:`7.177` /100/86400 & 1/s & Keir rate factor
   :varlink:`darwin_KeirExp`     & :math:`e_{\text{Keir}}`                     & 4.54                       &     & Keir rate exponent


.. _CarbonChemistryDiagnostics:

Diagnostics
'''''''''''

Diagnostics available with :varlink:`DARWIN_ALLOW_CARBON`:

.. tabularcolumns:: |\Y{.16}|\Y{.16}|\Y{.18}|\Y{.5}|

.. csv-table:: Darwin package carbon diagnostic fields
   :delim: &
   :widths: auto
   :class: longtable
   :header: Name, Code, Units, Description

   apCO2      & ``SM_P____L1`` & atm                             & atmospheric pCO\ :sub:`2`
   apCO2sat   & ``SM_P____L1`` & atm                             & atmospheric pCO\ :sub:`2` sat
   pH         & ``SMR_____MR`` & 1                               & pH
   pCO2       & ``SMRP____MR`` & atm                             & Partial Pressure of CO\ :sub:`2` in the ocean
   CO3        & ``SMR_____MR`` & mol/kg                          & Concentration of carbonate
   KspTPClc   & ``SMR_____MR`` & mol\ :sup:`2`/kg\ :sup:`2`      & Solubility product for calcite
   OmegaC     & ``SMR_____MR`` & 1                               & Calcite saturation ratio
   fugfCO2    & ``SM_P____L1`` & 1                               & Fugacity factor of CO\ :sub:`2` at surface
   fCO2       & ``SM_P____L1`` & atm                             & Fugacity of CO\ :sub:`2` (atm)
   fluxCO2    & ``SM______L1`` & mmol C/m\ :sup:`2`/s            & Flux of CO\ :sub:`2` - air-sea exch
   fluxO2     & ``SM______L1`` & mmol O\ :sub:`2` /m\ :sup:`2`/s & Flux of O\ :sub:`2` - air-sea exch
   VfluxCO2   & ``SM______L1`` & mmol C/m\ :sup:`2`/s            & Virtual flux of CO\ :sub:`2`
   VfluxAlk   & ``SM______L1`` & meq/m\ :sup:`2`/s               & Virtual flux of alkalinity
   gDICsurf   & ``SM______L1`` & mmol C/m\ :sup:`3`/s            & Tendency of DIC due to air-sea exch + oldvirt.flux
   gALKsurf   & ``SM______L1`` & meq/m\ :sup:`3`/s               & Tendency of ALK due to oldvirt.flux
   gO2surf    & ``SM______L1`` & mmol O\ :sub:`2` /m\ :sup:`3`/s & Tendency of O\ :sub:`2` due to air-sea exch
   C_DIC      & ``SMR_____MR`` & mmol C/m\ :sup:`3`/s            & Consumption of DIC
   C_DICPIC   & ``SMR_____MR`` & mmol C/m\ :sup:`3`/s            & Consumption of DIC due to PIC
   respDIC    & ``SMR_____MR`` & mmol C/m\ :sup:`3`/s            & DIC due to respiration
   rDIC_DOC   & ``SMR_____MR`` & mmol C/m\ :sup:`3`/s            & DIC due to remineralization of DOC
   rDIC_POC   & ``SMR_____MR`` & mmol C/m\ :sup:`3`/s            & DIC due to remineralization of POC
   dDIC_PIC   & ``SMR_____MR`` & mmol C/m\ :sup:`3`/s            & DIC due to dissolution of PIC
   C_ALK      & ``SMR_____MR`` & meq/m\ :sup:`3`/s               & Consumption of alkalinity
   S_ALK      & ``SMR_____MR`` & meq/m\ :sup:`3`/s               & Non-transport source of alkalinity
   C_O2       & ``SMR_____MR`` & mmol O\ :sub:`2` /m\ :sup:`3`/s & Consumption of oxygen
   S_O2       & ``SMR_____MR`` & mmol O\ :sub:`2` /m\ :sup:`3`/s & Non-transport source of oxygen

The sign convention for the fluxCO2, gDICsurf, gALKsurf and gO2surf diagnostics
is such that positive values increase the concentration in the ocean.  Note
that the units vary: gDICsurf, gALKsurf and gO2surf are tracer tendencies,
i.e., change rates of concentration, while fluxCO2 is a flux per area of
sea surface.

Diagnostics available with :varlink:`DARWIN_ALLOW_RADI`:

.. tabularcolumns:: |\Y{.16}|\Y{.16}|\Y{.18}|\Y{.5}|

.. csv-table:: RADI sediment model diagnostic fields
   :delim: &
   :widths: auto
   :class: longtable
   :header: Name, Code, Units, Description

   DICFsed    & ``SM______U1`` & mmol C/m\ :sup:`2`/s            & DIC sediment flux
   ALKFsed    & ``SM______U1`` & meq/m\ :sup:`2`/s               & ALK sediment flux
   O2Fsed     & ``SM______U1`` & mmol O\ :sub:`2` /m\ :sup:`2`/s & O\ :sub:`2` sediment flux
   POCFbur    & ``SM______U1`` & mmol C/m\ :sup:`2`/s            & POC buried flux
   CALFbur    & ``SM______U1`` & mmol C/m\ :sup:`2`/s            & Calcite buried flux
   sedFlPOC   & ``SM_P____U1`` & mmol C/m\ :sup:`2`/s            & POC flux from water column to sediment
   sedFlPIC   & ``SM_P____U1`` & mmol C/m\ :sup:`2`/s            & PIC flux from water column to sediment
   TcorrO2    & ``SM_P____M1`` & 1                               & Temperature correction factor for diffusive O\ :sub:`2` flux
   TcorrALK   & ``SM_P____M1`` & 1                               & Temperature correction factor for diffusive ALK flux
   TcorrDIC   & ``SM_P____M1`` & 1                               & Temperature correction factor for diffusive DIC flux
   OmegCbot   & ``SM_P____M1`` & 1                               & Calcite saturation ratio above the seabed

