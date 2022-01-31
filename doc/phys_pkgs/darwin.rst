.. include:: ../defs.hrst

.. _sub_phys_pkg_darwin:

DARWIN package
--------------

The :filelink:`darwin package <pkg/darwin>` models the dynamics of a flexible
number of phyto- and zooplankton and bacteria types, and the nutrient cycles of
carbon, nitrogen, phosphorus, iron and silica.  The description of the
ecosystem model is split over a number of pages:

.. toctree::
   :maxdepth: 1

   darwin_equations
   darwin_growth
   darwin_light
   darwin_spectral
   darwin_uptake
   darwin_chl
   darwin_remin
   darwin_denit
   darwin_cdom
   darwin_carbon
   darwin_iron
   darwin_mort
   darwin_exude
   darwin_grazing
   darwin_bacteria
   darwin_temperature
   darwin_sink
   darwin_cons
   darwin_changes

Plankton and nutrients are represented by their concentration in the ocean,
using the :ref:`sub_phys_pkg_ptracers`.  The darwin package uses the following
tracers (or a subset, depending on the configuration):

.. table::
   :widths: auto

   =============  ==============================  =================================================
   Name           Units                           Description
   =============  ==============================  =================================================
   DIC            mmol C  m\ :sup:`--3`           concentration of dissolved inorganic carbon
   NO3            mmol N  m\ :sup:`--3`           concentration of nitrate
   NO2            mmol N  m\ :sup:`--3`           concentration of nitrite
   NH4            mmol N  m\ :sup:`--3`           concentration of ammonia
   PO4            mmol P  m\ :sup:`--3`           concentration of phosphate
   FeT            mmol Fe m\ :sup:`--3`           concentration of total dissolved iron
   SiO2           mmol Si m\ :sup:`--3`           concentration of inorganic silica
   DOC            mmol C  m\ :sup:`--3`           concentration of dissolved organic carbon
   DON            mmol N  m\ :sup:`--3`           concentration of dissolved organic nitrogen
   DOP            mmol P  m\ :sup:`--3`           concentration of dissolved organic phosphorus
   DOFe           mmol Fe m\ :sup:`--3`           concentration of dissolved organic iron
   POC            mmol C  m\ :sup:`--3`           concentration of particulate organic carbon
   PON            mmol N  m\ :sup:`--3`           concentration of particulate organic nitrogen
   POP            mmol P  m\ :sup:`--3`           concentration of particulate organic phosphorus
   POFe           mmol Fe m\ :sup:`--3`           concentration of particulate organic iron
   POSi           mmol Si m\ :sup:`--3`           concentration of particulate organic silica
   PIC            mmol C  m\ :sup:`--3`           concentration of particulate inorganic carbon
   ALK            meq m\ :sup:`--3`               alkalinity
   O2             mmol O\ :sub:`2` m\ :sup:`--3`  concentration of oxygen
   CDOM           | mmol P  m\ :sup:`--3`         | concentration of colored dissolved organic matter
                  | mmol C  m\ :sup:`--3`         | - if #define DARWIN_CDOM_UNITS_CARBON
   c\ :sub:`j`    mmol C  m\ :sup:`--3`           concentration of carbon in plankton type j
   n\ :sub:`j`    mmol N  m\ :sup:`--3`           concentration of nitrogen in plankton type j
   p\ :sub:`j`    mmol P  m\ :sup:`--3`           concentration of phosphorus in plankton type j
   fe\ :sub:`j`   mmol Fe m\ :sup:`--3`           concentration of iron in plankton type j
   si\ :sub:`j`   mmol Si m\ :sup:`--3`           concentration of silica in plankton type j
   Chl\ :sub:`j`  mg Chl a m\ :sup:`--3`          concentration of Chlorophyll-a in plankton type j
   =============  ==============================  =================================================

Phyto- and zooplankton are not distinguished except that certain source terms
will not be active, dependening on whether a plankton type can engage in
photosynthesis, grazing, etc.  This makes it very simple to include, for
instance, mixotrophy in the model.


Compiling and Running
~~~~~~~~~~~~~~~~~~~~~

Compiling
^^^^^^^^^

Include the word ``darwin`` in ``packages.conf`` in your code directory.
This will automatically turn on gchem, ptracers and exf.

Set compile-time options for darwin in file
:filelink:`~pkg/darwin/DARWIN_OPTIONS.h` (see table below).

Adjust the number of plankton types, functional groups, autotrophs,
grazers, prey and optical types in :filelink:`~pkg/darwin/DARWIN_SIZE.h`.

You will also have to adjust the number of passive tracers in
:filelink:`~pkg/ptracers/PTRACERS_SIZE.h`. You can run
:filelink:`tools/darwin/mkdarwintracers` in your code
directory (after adjusting :filelink:`~pkg/darwin/DARWIN_OPTIONS.h` and
:filelink:`~pkg/darwin/DARWIN_SIZE.h`)
to find out how many ptracers you will need and what they are.

In :filelink:`~pkg/gchem/GCHEM_OPTIONS.h` you need to define
:varlink:`GCHEM_SEPARATE_FORCING`.

In :filelink:`~pkg/exf/EXF_OPTIONS.h` you may want to undef
:varlink:`ALLOW_CLIMSST_RELAXATION` and :varlink:`ALLOW_CLIMSSS_RELAXATION`.

To use spectral light, compile the radtrans package, see
:numref:`sub_phys_pkg_radtrans`.

.. tabularcolumns:: |l|l|

.. csv-table:: Darwin package CPP options
   :delim: &
   :widths: auto
   :class: longtable
   :header: CPP option, description

   :varlink:`DARWIN_ALLOW_NQUOTA`               & enable nitrogen quotas for all plankton
   :varlink:`DARWIN_ALLOW_PQUOTA`               & enable phosphorus quotas for all plankton
   :varlink:`DARWIN_ALLOW_FEQUOTA`              & enable iron quotas for all plankton
   :varlink:`DARWIN_ALLOW_SIQUOTA`              & enable silica quotas for all plankton
   :varlink:`DARWIN_ALLOW_CHLQUOTA`             & enable chlorophyll quotas for all *phototrophs*
   :varlink:`DARWIN_ALLOW_CDOM`                 & enable a dynamic CDOM tracer
   :varlink:`DARWIN_CDOM_UNITS_CARBON`          & measure CDOM in units of mmol C/m\ :sup:`3` and follow organic carbon instead of phosphorus
   :varlink:`DARWIN_ALLOW_CARBON`               & enable air-sea carbon exchange and ALK and O\ :math:`_2` tracers
   :varlink:`DARWIN_TOTALPHSCALE`               & consistently use the total pH scale for carbon chemistry coefficients
   :varlink:`DARWIN_ALLOW_DENIT`                & enable denitrification code
   :varlink:`DARWIN_ALLOW_EXUDE`                & enable exudation of individual quotas
   :varlink:`ALLOW_OLD_VIRTUALFLUX`             & enable old virtualflux code for DIC and ALK
   :varlink:`DARWIN_NITRATE_FELIMIT`            & reduce nitrate uptake by iron limitation factor
   :varlink:`DARWIN_BOTTOM_SINK`                & allow organic matter to sink into bottom (sedimentize)
   :varlink:`DARWIN_AVPAR`                      & compute average PAR in layer, assuming exponential decay (%)
   :varlink:`DARWIN_ALLOW_GEIDER`               & enable GEIDER light code (required for radtrans)
   :varlink:`DARWIN_GEIDER_RHO_SYNTH`           & use ρ instead of acclimated Chl:C for chlorophyll synthesis
   :varlink:`DARWIN_CHL_INIT_LEGACY`            & initialize chlorophyll as in darwin2
   :varlink:`DARWIN_SCATTER_CHL`                & scattering coefficients are per Chlorophyll
   :varlink:`DARWIN_DIAG_IOP`                   & make diagnostics for instrinsic optical properties available
   :varlink:`DARWIN_GRAZING_SWITCH`             & enable quadratic grazing as in darwin2+quota
   :varlink:`DARWIN_ALLOMETRIC_PALAT`           & compute palatability from size ratios
   :varlink:`DARWIN_NOZOOTEMP`                  & turn off grazing temperature dependence
   :varlink:`DARWIN_NOTEMP`                     & turn off all temperature dependence
   :varlink:`DARWIN_TEMP_VERSION`               & select temperature version: 1, 2 or 3
   :varlink:`DARWIN_TEMP_RANGE`                 & restrict phytoplankton growth to a temperature range
   :varlink:`DARWIN_MINFE`                      & restrict maximum free iron (sic)
   :varlink:`DARWIN_PART_SCAV`                  & enable particle scavenging code
   :varlink:`DARWIN_IRON_SED_SOURCE_VARIABLE`   & enable variable iron sediment source
   :varlink:`DARWIN_DIAG_PERTYPE`               & enable per-type diagnostics PP####, GR####, GrGn####
   :varlink:`DARWIN_DEBUG`                      & turn on debugging output
   :varlink:`DARWIN_ALLOW_CONS`                 & compute and print global element totals
   :varlink:`DARWIN_UNUSED`                     & value for unused traits

The following options are used for random trait generation (as in darwin2):

.. tabularcolumns:: |l|L|

.. csv-table::
   :delim: &
   :widths: auto
   :header: CPP option, description

   :varlink:`DARWIN_RANDOM_TRAITS`              & assign traits based on random numbers as in darwin2
   :varlink:`DARWIN_TWO_SPECIES_SETUP`          & set traits for darwin2 2-species setup (requires :varlink:`DARWIN_RANDOM_TRAITS`)
   :varlink:`DARWIN_NINE_SPECIES_SETUP`         & set traits for darwin2 9-species setup (requires :varlink:`DARWIN_RANDOM_TRAITS`)
   :varlink:`DARWIN_ALLOW_DIAZ`                 & enable diazotrophy when using :varlink:`DARWIN_RANDOM_TRAITS`

Random trait generation is supported mainly for backwards compatibility.

Running
^^^^^^^

You will need to set ``useDARWIN=.TRUE.`` in ``data.gchem`` (and turn on
gchem, ptracers, exf, etc. in ``data.pkg``).

Runtime Parameters
''''''''''''''''''

Runtime parameters are set in ``data.darwin`` in these namelists:

.. csv-table::
   :delim: &
   :widths: auto
   :header: Namelist, Description

   :varlink:`DARWIN_FORCING_PARAMS`  & parameters related to forcing and initialization
   :varlink:`DARWIN_INTERP_PARAMS`   & parameters for interpolation of forcing fields (only used if :varlink:`USE_EXF_INTERPOLATION` is defined)
   :varlink:`DARWIN_PARAMS`          & general parameters (not per-plankton traits)
   :varlink:`DARWIN_CDOM_PARAMS`     & parameters for dynamic CDOM
   :varlink:`DARWIN_RADTRANS_PARAMS` & parameters for radiative transer
   :varlink:`DARWIN_RANDOM_PARAMS`   & parameters for randomly generated traits (deprecated)
   :varlink:`DARWIN_TRAIT_PARAMS`    & parameters for trait generation (allometric and functional groups)

Set initial values/files for the tracers in ``data.ptracers``. You can
generate a template by running :filelink:`tools/darwin/mkdarwintracers` in your
code directory (get help with the ‘-h’ option).

You may generate a minimal file ``data.diagnostics`` with all the darwin
tracers by running :filelink:`tools/darwin/mkdiagnosticsdata` in your input/run
directory.

Forcing fields are read in using the exf package.  File names and forcing
parameters are given in namelist :varlink:`DARWIN_FORCING_PARAMS` in
``data.darwin``.  For light, ice area and wind speed, the following
alternative sources can be given:

.. csv-table:: Namelist DARWIN_FORCING_PARAMS
   :delim: &
   :widths: auto
   :header:  Name, Default, Description

   :varlink:`darwin_useQsw`     & .FALSE. & whether to use model shortwave radiation for light
   :varlink:`darwin_useSEAICE`  & .FALSE. & whether to use ice area from the seaice package
   :varlink:`darwin_useEXFwind` & .FALSE. & whether to use wind speed from the exf package

The forcing fields are:

.. tabularcolumns:: |\Y{.09}|\Y{.09}|\Y{.17}|\Y{.65}|

.. csv-table:: Darwin forcing fields
   :delim: &
   :widths: auto
   :class: longtable
   :header: Name, Default, Units, Description

   iron & 0.0    & mmol Fe m\ :sup:`--2` s\ :sup:`--1` & iron input through sea surface, will be multiplied by solubility :varlink:`alpfe`
   PAR  & 0.0    & μEin m\ :sup:`--2` s\ :sup:`--1`    & Photosynthetically active radiation below sea surface; not used with the radtrans package
   ice  & 0.0    & m\ :sup:`2`\ /m\ :sup:`2`           & fraction of surface covered by ice; used to reduce non-spectral light and for carbon and oxygen surface forcing; for spectral light, ice fraction has to be given in ``data.radtrans``
   wind & 5.0    & m/s                                 & wind speed; used for carbon and oxygen surface forcing
   pCO2 & 278E-6 & atm                                 & partial pressure of atmospheric CO\ :sub:`2`; used for carbon and oxygen surface forcing

The parameters darwin_inscal\_«Name» can be used to convert units.  Some examples
are given in :numref:`tab_phys_pkgs_darwin_inscal`.

.. csv-table:: Example unit conversions
   :delim: &
   :widths: auto
   :class: longtable
   :header: Field, File units, Scaling factor
   :name: tab_phys_pkgs_darwin_inscal

   iron & mol Fe m\ :sup:`--2` s\ :sup:`--1` & darwin_inscal_iron = 1000
        & kg Fe m\ :sup:`--2`                & darwin_inscal_iron = 17906.7
   PAR  & Ein m\ :sup:`--2` day\ :sup:`--1`  & darwin_inscal_PAR = 11.574074074074

Each forcing field has a set of parameters in :varlink:`DARWIN_FORCING_PARAMS`.
These work as in the exf package, see
:numref:`tab_phys_pkg_exf_runtime_attributes`.  For instance, for PAR they are:

.. csv-table:: Namelist DARWIN_FORCING_PARAMS, cont’d
   :delim: &
   :widths: auto
   :header:  Name, Default, Description

   :varlink:`PARfile`               & ' '                     & filename; if left empty no file will be read; PARconst will be used instead
   :varlink:`PARconst`              & 0.0                     & constant that will be used if no file is read
   :varlink:`PARperiod`             & 0.0                     & interval in seconds between two records
   :varlink:`PARRepCycle`           & :varlink:`repeatPeriod` & repeat cycle in seconds; only available if :varlink:`useExfYearlyFields` is .FALSE.
   :varlink:`PARStartTime`          & UNSET_RL                & time in seconds of first record from the beginning of the model integration or, if useExfYearlyFields, from the beginning of year; computed from PARstartdate* if not given
   :varlink:`PARstartdate1`         & 0                       & date/time of first record when using the cal package; format: YYYYMMDD; start year (YYYY), month (MM), day (YY)
   :varlink:`PARstartdate2`         & 0                       & format: HHMMSS; start hour (HH), minute (MM), second(SS)
   :varlink:`PAR_exfremo_intercept` & 0.0                     & can be used to remove global mean
   :varlink:`PAR_exfremo_slope`     & 0.0                     & can be used to remove global trend
   :varlink:`PARmask`               & 'c'                     & grid point for masking: ' ' = no masking; 'c' = centered mask; 'w' = western mask; 's' = southern
   :varlink:`darwin_inscal_PAR`     & 1.0                     & optional rescaling of input fields to adjust units

Interpolation parameters for all forcing fields are set in namelist
:varlink:`DARWIN_INTERP_PARAMS`.  See the exf package for how to set them.


General parameters are set in namelist :varlink:`DARWIN_PARAMS`:

.. tabularcolumns:: |\Y{.235}|\Y{.135}|\Y{.14}|\Y{.49}|

.. csv-table:: Namelist DARWIN_PARAMS
   :delim: &
   :widths: auto
   :class: longtable
   :header: Name, Default, Units, Description

   :varlink:`darwin_seed`            & 0                     &                                  & seed for random number generator (for :varlink:`DARWIN_RANDOM_TRAITS`)
   :varlink:`darwin_strict_check`    & .FALSE.               &                                  & stop instead of issuing warnings
   :varlink:`iDEBUG`                 & 1                     &                                  & index in x dimension for debug prints
   :varlink:`jDEBUG`                 & 1                     &                                  & index in y dimension for debug prints
   :varlink:`kDEBUG`                 & 1                     &                                  & index in z dimension for debug prints
   :varlink:`darwin_pickupSuff`      & :varlink:`pickupSuff` &                                  & pickup suffix for darwin; set to ' ' to disable reading at :varlink:`PTRACERS_Iter0`
   :varlink:`darwin_linFSConserve`   & .FALSE.               &                                  & correct non-conservation due to linear free surface (globally)
   :varlink:`darwin_read_phos`       & .FALSE.               &                                  & initial conditions for plankton biomass are in mmol P/m3
   :varlink:`darwin_chlInitBalanced` & .FALSE.               &                                  & Initialize Chlorophyll to a balanced value following Geider
   :varlink:`darwin_chlIter0`        & 0                     &                                  & Iteration number when to initialize Chlorophyll
   :varlink:`katten_w`               & 4D-2                  & 1/m                              & atten coefficient water
   :varlink:`katten_chl`             & 4D-2                  & m\ :sup:`2`/mg Chl               & atten coefficient chl
   :varlink:`parfrac`                & 0.4                   &                                  & fraction Qsw that is PAR
   :varlink:`parconv`                & 1/0.2174              & μEin/s/W                         & conversion from W/m2 to μEin/m2/s
   :varlink:`tempnorm`               & 0.3                   &                                  & set temperature function (was 1.0)
   :varlink:`TempAeArr`              & -4000.0               & K                                & slope for pseudo-Arrhenius (TEMP_VERSION 2)
   :varlink:`TemprefArr`             & 293.15                & K                                & reference temp for pseudo-Arrhenius (TEMP_VERSION 2)
   :varlink:`TempCoeffArr`           & 0.5882                &                                  & pre-factor for pseudo-Arrhenius (TEMP_VERSION 2)
   :varlink:`reminTempAe`            & 0.0438                & 1/K                              & temperature coefficient for remineralization (TEMP_VERSION 4)
   :varlink:`mortTempAe`             & 0.0438                & 1/K                              & temperature coefficient for linear mortality (TEMP_VERSION 4)
   :varlink:`mort2TempAe`            & 0.0438                & 1/K                              & temperature coefficient for quadr. mortality (TEMP_VERSION 4)
   :varlink:`uptakeTempAe`           & 0.0                   & 1/K                              & temperature coefficient for uptake (TEMP_VERSION 4)
   :varlink:`alpfe`                  & 0.04                  &                                  & solubility of Fe dust
   :varlink:`scav`                   & 0.4/year              & 1/s                              & fixed iron scavenging rate
   :varlink:`ligand_tot`             & 1D-3                  & mol/m\ :sup:`3`                  & total ligand concentration
   :varlink:`ligand_stab`            & 2D5                   & m\ :sup:`3`/mol                  & ligand stability rate ratio
   :varlink:`freefemax`              & 0.4D-3                & mol/m\ :sup:`3`                  & max concentration of free iron
   :varlink:`scav_rat`               & 0.005 / day           & 1/s                              & rate of POM-based iron scavenging
   :varlink:`scav_inter`             & 0.079                 &                                  & intercept of scavenging power law
   :varlink:`scav_exp`               & 0.58                  &                                  & exponent of scavenging power law
   :varlink:`scav_R_POPPOC`          & 1.1321D-4             & mmol P / mmol C                  & POP\:POC ratio for :varlink:`DARWIN_PART_SCAV_POP`
   :varlink:`depthfesed`             & -1.0                  & m                                & depth above which to add sediment source (was -1000)
   :varlink:`fesedflux`              & 1D-3 / day            & mmol Fe /m\ :sup:`2`/s           & fixed iron flux from sediment
   :varlink:`fesedflux_pcm`          & 0.68D-3               & mmol Fe / mmol C                 & iron input per POC sinking into bottom for :varlink:`DARWIN_IRON_SED_SOURCE_VARIABLE`
   :varlink:`fesedflux_min`          & 0.5D-3 / day          & mmol Fe /s                       & min iron input rate subtracted from fesedflux_pcm*wc_sink*POC
   :varlink:`R_CP_fesed`             & 106                   & mmol C / mmol P                  & POC:POP conversion for :varlink:`DARWIN_IRON_SED_SOURCE_POP`
   :varlink:`Knita`                  & 1/(0.5 days)          & 1/s                              & ammonia oxidation rate
   :varlink:`Knitb`                  & 1/(10 days)           & 1/s                              & nitrite oxidation rate
   :varlink:`PAR_oxi`                & 10                    & μEin/m\ :sup:`2`/s               & critical light level after which oxidation starts
   :varlink:`Kdoc`                   & 1/(100 days)          & 1/s                              & DOC remineralization rate
   :varlink:`Kdop`                   & 1/(100 days)          & 1/s                              & DON remineralization rate
   :varlink:`Kdon`                   & 1/(100 days)          & 1/s                              & DOP remineralization rate
   :varlink:`KdoFe`                  & 1/(100 days)          & 1/s                              & DOFe remineralization rate
   :varlink:`KPOC`                   & 1/(50 days)           & 1/s                              & POC remineralization rate
   :varlink:`KPOP`                   & :varlink:`KPOC`       & 1/s                              & POP remineralization rate
   :varlink:`KPON`                   & :varlink:`KPOC`       & 1/s                              & PON remineralization rate
   :varlink:`KPOFe`                  & :varlink:`KPOC`       & 1/s                              & POFe remineralization rate
   :varlink:`KPOSi`                  & 1/(300 days)          & 1/s                              & POSi remineralization rate
   :varlink:`wC_sink`                & 10/day                & m/s                              & sinking velocity for POC
   :varlink:`wP_sink`                & :varlink:`wC_sink`    & m/s                              & sinking velocity for POP
   :varlink:`wN_sink`                & :varlink:`wC_sink`    & m/s                              & sinking velocity for PON
   :varlink:`wFe_sink`               & :varlink:`wC_sink`    & m/s                              & sinking velocity for POFe
   :varlink:`wSi_sink`               & :varlink:`wC_sink`    & m/s                              & sinking velocity for POSi
   :varlink:`wPIC_sink`              & 15/day                & m/s                              & sinking velocity for PIC
   :varlink:`Kdissc`                 & 1/(300 days)          & 1/s                              & dissolution rate for PIC
   :varlink:`R_OP`                   & 170                   & mmol O\ :sub:`2` / mmol P        & O:P ratio for respiration and consumption
   :varlink:`R_OC`                   & 170/120.0             & mmol O\ :sub:`2` / mmol C        & NOT USED
   :varlink:`m3perkg`                & 1 / 1024.5            & m\ :sup:`3`/kg                   & constant for converting per kg to per m^3
   :varlink:`surfSaltMinInit`        & 4.0                   & ppt                              & limits for carbon solver input at initialization
   :varlink:`surfSaltMaxInit`        & 50.0                  & ppt                              & ...
   :varlink:`surfTempMinInit`        & -4.0                  & °C                               &
   :varlink:`surfTempMaxInit`        & 39.0                  & °C                               &
   :varlink:`surfDICMinInit`         & 10.0                  & mmol C m\ :sup:`-3`              &
   :varlink:`surfDICMaxInit`         & 4000.0                & mmol C m\ :sup:`-3`              &
   :varlink:`surfALKMinInit`         & 10.0                  & meq m\ :sup:`-3`                 &
   :varlink:`surfALKMaxInit`         & 4000.0                & meq m\ :sup:`-3`                 &
   :varlink:`surfPO4MinInit`         & 1D-10                 & mmol P m\ :sup:`-3`              &
   :varlink:`surfPO4MaxInit`         & 10.0                  & mmol P m\ :sup:`-3`              &
   :varlink:`surfSiMinInit`          & 1D-8                  & mmol Si m\ :sup:`-3`             &
   :varlink:`surfSiMaxInit`          & 500.0                 & mmol Si m\ :sup:`-3`             &
   :varlink:`surfSaltMin`            & 4.0                   & ppt                              & limits for carbon solver input during run
   :varlink:`surfSaltMax`            & 50.0                  & ppt                              & ...
   :varlink:`surfTempMin`            & -4.0                  & °C                               &
   :varlink:`surfTempMax`            & 39.0                  & °C                               &
   :varlink:`surfDICMin`             & 400.0                 & mmol C m\ :sup:`-3`              &
   :varlink:`surfDICMax`             & 4000.0                & mmol C m\ :sup:`-3`              &
   :varlink:`surfALKMin`             & 400.0                 & meq m\ :sup:`-3`                 &
   :varlink:`surfALKMax`             & 4000.0                & meq m\ :sup:`-3`                 &
   :varlink:`surfPO4Min`             & 1D-10                 & mmol P m\ :sup:`-3`              &
   :varlink:`surfPO4Max`             & 10.0                  & mmol P m\ :sup:`-3`              &
   :varlink:`surfSiMin`              & 1D-8                  & mmol Si m\ :sup:`-3`             &
   :varlink:`surfSiMax`              & 500.0                 & mmol Si m\ :sup:`-3`             &
   :varlink:`diaz_ini_fac`           & 1                     &                                  & reduce tracer concentrations by this factor on initialization
   :varlink:`O2crit`                 & 6.0                   & mmol O\ :sub:`2` m\ :sup:`-3`    & critical oxygen for O2/NO3 remineralization
   :varlink:`denit_NP`               & 120.0                 & mmol N / mmol P                  & ratio of n to p in denitrification process
   :varlink:`denit_NO3`              & 104.0                 & mmol N / mmol P                  & ratio of NO3 uptake to phos remineralization in denitrification
   :varlink:`NO3crit`                & 1D-2                  & mmol N m\ :sup:`-3`              & critical nitrate below which no denit (or remin) happens
   :varlink:`PARmin`                 & 0.1                   & μEin/m\ :sup:`2`/s               & minimum light for photosynthesis; for non-Geider: 1.0
   :varlink:`aphy_chl_ave`           & 0.02                  & m\ :sup:`2`/mg Chl               & Chl-specific absorption coefficient
   :varlink:`chl2nmax`               & 3.00                  & mg Chl / mmol N                  & max Chl:N ratio for Chl synthesis following Moore 2002
   :varlink:`synthcost`              & 0.0                   & mmol C / mmol N                  & cost of biosynthesis
   :varlink:`inhib_graz`             & 1.0                   & (mmol C m\ :sup:`-3`)\ :sup:`-1` & inverse decay scale for grazing inhibition
   :varlink:`inhib_graz_exp`         & 0.0                   &                                  & exponent for grazing inhibition (0 to turn off inhibition)
   :varlink:`hillnumUptake`          & 1.0                   &                                  & exponent for limiting quota uptake in nutrient uptake
   :varlink:`hillnumGraz`            & 1.0                   &                                  & exponent for limiting quota uptake in grazing
   :varlink:`hollexp`                & 1.0                   &                                  & grazing exponential 1= "Holling 2", 2= "Holling 3"
   :varlink:`phygrazmin`             & 120D-10               & mmol C m\ :sup:`-3`              & minimum total prey conc for grazing to occur
   :varlink:`pmaxDIN`                & 20/day                & 1/s                              & max DIN uptake rate for denitrifying bacteria
   :varlink:`pcoefO2`                & 290.82/day            & m\ :sup:`3`/mmol O\ :sub:`2`/s   & max O2-specific O2 uptake rate for aerobic bacteria
   :varlink:`ksatDIN`                & 0.01                  & mmol N m\ :sup:`-3`              & half-saturation conc of dissolved inorganic nitrogen
   :varlink:`alpha_hydrol`           & 2.0                   &                                  & increase in POM needed due to hydrolysis
   :varlink:`yod`                    & 0.2                   &                                  & organic matter yield of aerobic bacteria
   :varlink:`yoe`                    & yod/467*4/(1-yod)*106 &                                  & energy yield of aerobic bacteria
   :varlink:`ynd`                    & 0.16                  &                                  & organic matter yield of denitrifying bacteria
   :varlink:`yne`                    & ynd/467*5/(1-ynd)*106 &                                  & energy yield of denitrifying bacteria


.. csv-table:: Namelist DARWIN_CDOM_PARAMS
   :delim: &
   :widths: auto
   :header: Name, Default, Units, Description

   :varlink:`fracCDOM`   & 2 / 100        &                      & fraction of remineralized POP contributing to CDOM
   :varlink:`CDOMdegrd`  & 1 / (200 days) & 1/s                  & CDOM degradation rate
   :varlink:`CDOMbleach` & 1 / (15 days)  & 1/s                  & CDOM bleaching rate
   :varlink:`PARCDOM`    & 20             & μEin/m\ :sup:`2`/s   & PAR where CDOM bleaching becomes maximal
   :varlink:`R_NP_CDOM`  & 16             & mmol N / mmol P      & CDOM N:P ratio (with #undef DARWIN_CDOM_UNITS_CARBON)
   :varlink:`R_FeP_CDOM` & 1D-3           & mmol Fe / mmol P     & CDOM Fe:P ratio (with #undef DARWIN_CDOM_UNITS_CARBON)
   :varlink:`R_CP_CDOM`  & 120            & mmol C / mmol P      & CDOM C:P ratio (with #undef DARWIN_CDOM_UNITS_CARBON)
   :varlink:`R_NC_CDOM`  & 16/120         & mmol N / mmol C      & CDOM N:C ratio (with #define DARWIN_CDOM_UNITS_CARBON)
   :varlink:`R_PC_CDOM`  & 1/120          & mmol P / mmol C      & CDOM P:C ratio (with #define DARWIN_CDOM_UNITS_CARBON)
   :varlink:`R_FeC_CDOM` & 1D-3/120       & mmol Fe / mmol C     & CDOM Fe:C ratio (with #define DARWIN_CDOM_UNITS_CARBON)
   :varlink:`CDOMcoeff`  & 100.0          & m\ :sup:`2` / mmol P & P-specific absorption coefficient of CDOM at :math:`\lambda_{\op{CDOM}}`
                         & 100/120        & m\ :sup:`2` / mmol C & - if #define DARWIN_CDOM_UNITS_CARBON


.. tabularcolumns:: |\Y{.255}|\Y{.115}|\Y{.13}|\Y{.5}|

.. csv-table:: Namelist DARWIN_RADTRANS_PARAMS
   :delim: &
   :widths: auto
   :header: Name, Default, Units, Description

   :varlink:`darwin_waterAbsorbFile`    & ' '      &                    & filename for reading water absorption and scattering spectra
   :varlink:`darwin_phytoAbsorbFile`    & ' '      &                    & filename for reading plankton absorption and scattering spectra
   :varlink:`darwin_particleAbsorbFile` & ' '      &                    & filename for reading particle absorption and scattering spectra
   :varlink:`darwin_part_size_P`        & 1D-15    & mmol P/particle    & conversion factor for particle absorption and scattering spectra
   :varlink:`darwin_bbmin`              & 0.0002   & 1/m                & minimum backscattering ratio
   :varlink:`darwin_bbw`                & 0.5      &                    & backscattering ratio of water
   :varlink:`darwin_lambda_aCDOM`       & 450.0    & nm                 & reference wavelength for CDOM absorption spectra
   :varlink:`darwin_Sdom`               & 0.014    & 1/nm               & coefficient for CDOM absorption spectra
   :varlink:`darwin_aCDOM_fac`          & 0.2      &                    & factor for computing aCDOM from water+Chlorophyll absorption
   :varlink:`darwin_rCDOM`              & 0.0      & mmol P/m\ :sup:`3` & recalcitrant CDOM concentration
                                        & 0.0      & mmol C/m\ :sup:`3` & - if #define DARWIN_CDOM_UNITS_CARBON
   :varlink:`darwin_RPOC`               & 0.0      & mmol C/m\ :sup:`3` & recalcitrant POC concentration
   :varlink:`darwin_allomSpectra`       & .FALSE.  &                    & enable/disable allometric scaling of plankton absorption and scattering spectra
   :varlink:`darwin_aCarCell`           & 0.109D-9 & mg C/cell          & coefficient coefficient for scaling plankton spectra
   :varlink:`darwin_bCarCell`           & 0.991    &                    & coefficient coefficient for scaling plankton spectra
   :varlink:`darwin_absorpSlope`        & -0.075   &                    & slope for scaled absorption spectra
   :varlink:`darwin_bbbSlope`           & -1.458   &                    & slope for scaled backscattering ratio spectra
   :varlink:`darwin_scatSwitchSizeLog`  & 0        & log(μm)            & log of size for switching slopes
   :varlink:`darwin_scatSlopeSmall`     & 1.5      &                    & slope for small plankton
   :varlink:`darwin_scatSlopeLarge`     & 1.5      &                    & slope for large plankton



Traits
''''''

Traits are generated from the parameters in ``&DARWIN_TRAIT_PARAMS``
(see next section) but can be overridden in ``data.traits``:

.. tabularcolumns:: |\Y{.2}|\Y{.12}|\Y{.2}|\Y{.48}|

.. csv-table:: Namelist DARWIN_TRAITS
   :delim: &
   :widths: auto
   :class: longtable
   :header: Trait, Symbol, Units, Description

   :varlink:`isPhoto`          & isPhoto\ :math:`_j`                    &                                               & 1: does photosynthesis, 0: not
   :varlink:`bactType`         & bactType\ :math:`_j`                   &                                               & 1: particle associated, 2: free living bacteria, 0: not bacteria
   :varlink:`isAerobic`        & isAerobic\ :math:`_j`                  &                                               & 1: is aerobic bacteria (also set bactType), 0: not
   :varlink:`isDenit`          & isDenit\ :math:`_j`                    &                                               & 1: is dentrifying bacteria (also set (bactType), 0: not
   :varlink:`hasSi`            & hasSi\ :math:`_j`                      &                                               & 1: uses silica (Diatom), 0: not
   :varlink:`hasPIC`           & hasPIC\ :math:`_j`                     &                                               & 1: calcifying, 0: set R_PICPOC to zero
   :varlink:`diazo`            & diazo\ :math:`_j`                      &                                               & 1: use molecular instead of mineral nitrogen, 0: not
   :varlink:`useNH4`           & useNH4\ :math:`_j`                     &                                               & 1: can use ammonia, 0: not
   :varlink:`useNO2`           & useNO2\ :math:`_j`                     &                                               & 1: can use nitrite, 0: not
   :varlink:`useNO3`           & useNO3\ :math:`_j`                     &                                               & 1: can use nitrate, 0: not
   :varlink:`combNO`           & combNO\ :math:`_j`                     &                                               & 1: combined nitrite/nitrate limitation, 0: not
   :varlink:`isPrey`           & isPrey\ :math:`_j`                     &                                               & 1: can be grazed, 0: not
   :varlink:`isPred`           & isPred\ :math:`_j`                     &                                               & 1: can graze, 0: not
   :varlink:`tempMort`         & :math:`e^{\op{mort}}_j`                &                                               & 1: mortality is temperature dependent, 0: turn dependence off
   :varlink:`tempMort2`        & :math:`e^{\op{mort2}}_j`               &                                               & 1: quadratic mortality is temperature dependent, 0: turn dependence off
   :varlink:`tempGraz`         & :math:`e^{\op{graz}}_j`                &                                               & 1: grazing is temperature dependent, 0: turn dependence off
   :varlink:`Xmin`             & :math:`c^{\min}_j`                     & mmol C m\ :sup:`-3`                           & minimum abundance for mortality, respiration and exudation
   :varlink:`amminhib`         & :math:`\sigma_1`                       & (mmol N m\ :sup:`-3`)\ :sup:`-1`              & coefficient for NH4 inhibition of NO uptake
   :varlink:`acclimtimescl`    & :math:`\tau^{\op{acclim}}`             & s\ :sup:`-1`                                  & rate of chlorophyll acclimation
   :varlink:`mort`             & :math:`m^{(1)}_j`                      & s\ :sup:`-1`                                  & linear mortality rate
   :varlink:`mort2`            & :math:`m^{(2)}_j`                      & (mmol C m\ :sup:`-3`)\ :sup:`-1` s\ :sup:`-1` & quadratic mortality coefficient
   :varlink:`ExportFracMort`   & :math:`f^{\op{exp}\op{mort}}_j`        &                                               & fraction of linear mortality to POM
   :varlink:`ExportFracMort2`  & :math:`f^{\op{exp}\op{mort2}}_j`       &                                               & fraction of quadratic mortality to POM
   :varlink:`ExportFracExude`  & :math:`f^{\op{exp}\op{exude}}_j`       &                                               & fraction of exudation to POM
   :varlink:`phytoTempCoeff`   & :math:`c_j`                            &                                               & see :numref:`pkg_darwin_temperature_params`
   :varlink:`phytoTempExp1`    & :math:`e_{1j}`                         & exp(1/°C)                                     & see :numref:`pkg_darwin_temperature_params`
   :varlink:`phytoTempAe`      & :math:`A^{\op{phy}}_{\op{e}j}`         & 1/°C                                          & see :numref:`pkg_darwin_temperature_params`
   :varlink:`phytoTempExp2`    & :math:`e_{2j}`                         &                                               & see :numref:`pkg_darwin_temperature_params`
   :varlink:`phytoTempOptimum` & :math:`T^{\op{opt}}_j`                 & °C                                            & see :numref:`pkg_darwin_temperature_params`
   :varlink:`phytoDecayPower`  & :math:`p_j`                            &                                               & see :numref:`pkg_darwin_temperature_params`
   :varlink:`hetTempAe`        & :math:`A^{\op{het}}_{\op{e}j}`         & 1/°C                                          & see :numref:`pkg_darwin_temperature_params`
   :varlink:`hetTempExp2`      & :math:`e^{\op{het}}_{2j}`              &                                               & see :numref:`pkg_darwin_temperature_params`
   :varlink:`hetTempOptimum`   & :math:`T^{\op{opt het}}_j`             & °C                                            & see :numref:`pkg_darwin_temperature_params`
   :varlink:`hetDecayPower`    & :math:`p^{\op{het}}_j`                 &                                               & see :numref:`pkg_darwin_temperature_params`
   :varlink:`grazTempAe`       & :math:`A^{\op{graz}}_{\op{e}j}`        & 1/°C                                          & see :numref:`pkg_darwin_temperature_params`
   :varlink:`grazTempExp2`     & :math:`e^{\op{graz}}_{2j}`             &                                               & see :numref:`pkg_darwin_temperature_params`
   :varlink:`grazTempOptimum`  & :math:`T^{\op{opt graz}}_j`            & °C                                            & see :numref:`pkg_darwin_temperature_params`
   :varlink:`grazDecayPower`   & :math:`p^{\op{graz}}_j`                &                                               & see :numref:`pkg_darwin_temperature_params`
   :varlink:`R_NC`             & :math:`R^{\op{N}:\op{C}}_j`            & mmol N (mmol C)\ :sup:`-1`                    & nitrogen-carbon ratio (not used with DARWIN_ALLOW_NQUOTA)
   :varlink:`R_PC`             & :math:`R^{\op{P}:\op{C}}_j`            & mmol P (mmol C)\ :sup:`-1`                    & phosphorus-carbon ratio (not used with DARWIN_ALLOW_PQUOTA)
   :varlink:`R_SiC`            & :math:`R^{\op{Si}:\op{C}}_j`           & mmol Si (mmol C)\ :sup:`-1`                   & silica-carbon ratio (not used with DARWIN_ALLOW_SIQUOTA)
   :varlink:`R_FeC`            & :math:`R^{\op{Fe}:\op{C}}_j`           & mmol Fe (mmol C)\ :sup:`-1`                   & iron-carbon ratio (not used with DARWIN_ALLOW_FEQUOTA)
   :varlink:`R_ChlC`           & :math:`R^{\op{chl}c}_j`                & mg Chl (mmol C)\ :sup:`-1`                    & chlorophyll-carbon ratio (not used with DARWIN_ALLOW_CHLQUOTA)
   :varlink:`R_PICPOC`         & :math:`R^{\op{PICPOC}}_j`              & mmol PIC (mmol POC)\ :sup:`-1`                & inorganic-organic carbon ratio
   :varlink:`biosink`          & :math:`w^{\op{sink}}_j`                & m s\ :sup:`-1`                                & sinking velocity (positive downwards)
   :varlink:`bioswim`          & :math:`w^{\op{swim}}_j`                & m s\ :sup:`-1`                                & upward swimming velocity (positive upwards)
   :varlink:`respRate`         & :math:`r^{\op{resp}}_j`                & s\ :sup:`-1`                                  & respiration rate
   :varlink:`PCmax`            & :math:`P^{\op{max}}_{\op{C},j}`        & s\ :sup:`-1`                                  & maximum carbon-specific growth rate
   :varlink:`Qnmax`            & :math:`Q^{\op{N}\op{max}}_j`           & mmol N (mmol C)\ :sup:`-1`                    & maximum nitrogen quota (only with DARWIN_ALLOW_NQUOTA)
   :varlink:`Qnmin`            & :math:`Q^{\op{N}\min}_j`               & mmol N (mmol C)\ :sup:`-1`                    & minimum nitrogen quota (only with DARWIN_ALLOW_NQUOTA)
   :varlink:`Qpmax`            & :math:`Q^{\op{P}\op{max}}_j`           & mmol P (mmol C)\ :sup:`-1`                    & maximum phosphorus quota (only with DARWIN_ALLOW_PQUOTA)
   :varlink:`Qpmin`            & :math:`Q^{\op{P}\min}_j`               & mmol P (mmol C)\ :sup:`-1`                    & minimum phosphorus quota (only with DARWIN_ALLOW_PQUOTA)
   :varlink:`Qsimax`           & :math:`Q^{\op{Si}\op{max}}_j`          & mmol Si (mmol C)\ :sup:`-1`                   & maximum silica quota (only with DARWIN_ALLOW_SIQUOTA)
   :varlink:`Qsimin`           & :math:`Q^{\op{Si}\min}_j`              & mmol Si (mmol C)\ :sup:`-1`                   & minimum silica quota (only with DARWIN_ALLOW_SIQUOTA)
   :varlink:`Qfemax`           & :math:`Q^{\op{Fe}\op{max}}_j`          & mmol Fe (mmol C)\ :sup:`-1`                   & maximum iron quota (only with DARWIN_ALLOW_FEQUOTA)
   :varlink:`Qfemin`           & :math:`Q^{\op{Fe}\min}_j`              & mmol Fe (mmol C)\ :sup:`-1`                   & minimum iron quota (only with DARWIN_ALLOW_FEQUOTA)
   :varlink:`VmaxNH4`          & :math:`V^{\op{NH4}\op{max}}_j`         & mmol N (mmol C)\ :sup:`-1` s\ :sup:`-1`       & maximum ammonia uptake rate (only with DARWIN_ALLOW_NQUOTA)
   :varlink:`VmaxNO2`          & :math:`V^{\op{NO2}\op{max}}_j`         & mmol N (mmol C)\ :sup:`-1` s\ :sup:`-1`       & maximum nitrite uptake rate (only with DARWIN_ALLOW_NQUOTA)
   :varlink:`VmaxNO3`          & :math:`V^{\op{NO3}\op{max}}_j`         & mmol N (mmol C)\ :sup:`-1` s\ :sup:`-1`       & maximum nitrate uptake rate (only with DARWIN_ALLOW_NQUOTA)
   :varlink:`VmaxN`            & :math:`V^{\op{N}\op{max}}_j`           & mmol N (mmol C)\ :sup:`-1` s\ :sup:`-1`       & maximum nitrogen uptake rate for diazotrophs (only with DARWIN_ALLOW_NQUOTA)
   :varlink:`VmaxPO4`          & :math:`V^{\op{PO4}\op{max}}_j`         & mmol P (mmol C)\ :sup:`-1` s\ :sup:`-1`       & maximum phosphate uptake rate (only with DARWIN_ALLOW_PQUOTA)
   :varlink:`VmaxSiO2`         & :math:`V^{\op{SiO2}\op{max}}_j`        & mmol Si (mmol C)\ :sup:`-1` s\ :sup:`-1`      & maximum silica uptake rate (only with DARWIN_ALLOW_SIQUOTA)
   :varlink:`VmaxFeT`          & :math:`V^{\op{Fe}\op{max}}_j`          & mmol Fe (mmol C)\ :sup:`-1` s\ :sup:`-1`      & maximum iron uptake rate (only with DARWIN_ALLOW_FEQUOTA)
   :varlink:`ksatNH4`          & :math:`k^{\op{NH4}}_j`                 & mmol N m\ :sup:`-3`                           & half-saturation conc. for ammonia uptake/limitation
   :varlink:`ksatNO2`          & :math:`k^{\op{NO2}}_j`                 & mmol N m\ :sup:`-3`                           & half-saturation conc. for nitrite uptake/limitation
   :varlink:`ksatNO3`          & :math:`k^{\op{NO3}}_ji`                & mmol N m\ :sup:`-3`                           & half-saturation conc. for nitrate uptake/limitation
   :varlink:`ksatPO4`          & :math:`k^{\op{PO4}}_j`                 & mmol P m\ :sup:`-3`                           & half-saturation conc. for phosphate uptake/limitation
   :varlink:`ksatSiO2`         & :math:`k^{\op{SiO2}}_j`                & mmol Si m\ :sup:`-3`                          & half-saturation conc. for silica uptake/limitation
   :varlink:`ksatFeT`          & :math:`k^{\op{Fe}}_j`                  & mmol Fe m\ :sup:`-3`                          & half-saturation conc. for iron uptake/limitation
   :varlink:`kexcc`            & :math:`\kappa^{\op{exc}}_{\op{C} j}`   & s\ :sup:`-1`                                  & exudation rate for carbon
   :varlink:`kexcn`            & :math:`\kappa^{\op{exc}}_{\op{N} j}`   & s\ :sup:`-1`                                  & exudation rate for nitrogen
   :varlink:`kexcp`            & :math:`\kappa^{\op{exc}}_{\op{P} j}`   & s\ :sup:`-1`                                  & exudation rate for phosphorus
   :varlink:`kexcsi`           & :math:`\kappa^{\op{exc}}_{\op{Si} j}`  & s\ :sup:`-1`                                  & exudation rate for silica
   :varlink:`kexcfe`           & :math:`\kappa^{\op{exc}}_{\op{Fe} j}`  & s\ :sup:`-1`                                  & exudation rate for iron
   :varlink:`inhibGeider`      & :math:`c^{\op{inhib}}_j`               &                                               & photo-inhibition coefficient for Geider growth
   :varlink:`ksatPAR`          & :math:`k^{\op{sat}}_{\op{PAR}}`        & (μEin m\ :sup:`-2` s\ :sup:`-1`)\ :sup:`-1`   & saturation coefficient for PAR (w/o GEIDER)
   :varlink:`kinhPAR`          & :math:`k^{\op{inh}}_{\op{PAR}}`        & (μEin m\ :sup:`-2` s\ :sup:`-1`)\ :sup:`-1`   & inhibition coefficient for PAR (w/o GEIDER)
   :varlink:`mQyield`          & :math:`\Phi_j`                         & mmol C (μEin)\ :sup:`-1`                      & maximum quantum yield
   :varlink:`chl2cmax`         & :math:`\op{Chl\text{:}C}^{\op{max}}_j` & mg Chl (mmol C)\ :sup:`-1`                    & maximum Chlorophyll-carbon ratio
   :varlink:`grazemax`         & :math:`g^{\op{max}}_z`                 & s\ :sup:`-1`                                  & maximum grazing rate
   :varlink:`kgrazesat`        & :math:`k^{\op{graz}}_z`                & mmol C m\ :sup:`-3`                           & grazing half-saturation concentration
   :varlink:`yield`            & :math:`{Y_j}`                          &                                               & bacterial growth yield for all organic matter
   :varlink:`yieldO2`          & :math:`{Y^{{\mathrm{O}}_2}_j}`         &                                               & bacterial growth yield for oxygen
   :varlink:`yieldNO3`         & :math:`{Y^{\op{NO}_3}_j}`              &                                               & bacterial growth yield for nitrate
   :varlink:`ksatPON`          & :math:`{k^{\op{PON}}}`                 & mmol N m\ :sup:`-3`                           & half-saturation of PON for bacterial growth
   :varlink:`ksatPOC`          & :math:`{k^{\op{POC}}}`                 & mmol C m\ :sup:`-3`                           & half-saturation of POC for bacterial growth
   :varlink:`ksatPOP`          & :math:`{k^{\op{POP}}}`                 & mmol P m\ :sup:`-3`                           & half-saturation of POP for bacterial growth
   :varlink:`ksatPOFe`         & :math:`{k^{\op{POFe}}}`                & mmol Fe m\ :sup:`-3`                          & half-saturation of POFe for bacterial growth
   :varlink:`ksatDON`          & :math:`{k^{\op{DON}}}`                 & mmol N m\ :sup:`-3`                           & half-saturation of DON for bacterial growth
   :varlink:`ksatDOC`          & :math:`{k^{\op{DOC}}}`                 & mmol C m\ :sup:`-3`                           & half-saturation of DOC for bacterial growth
   :varlink:`ksatDOP`          & :math:`{k^{\op{DOP}}}`                 & mmol P m\ :sup:`-3`                           & half-saturation of DOP for bacterial growth
   :varlink:`ksatDOFe`         & :math:`{k^{\op{DOFe}}}`                & mmol Fe m\ :sup:`-3`                          & half-saturation of DOFe for bacterial growth


.. csv-table:: Trait matrices for grazing; indices (prey, pred)
   :delim: &
   :widths: auto
   :class: longtable
   :header: Trait, Symbol, Units, Description

   :varlink:`palat`              & :math:`p_{j,z}`                     &   & palatability matrix
   :varlink:`asseff`             & :math:`a_{j,z}`                     &   & assimilation efficiency matrix
   :varlink:`ExportFracPreyPred` & :math:`f^{\op{exp}\op{graz}}_{j,z}` &   & fraction of unassimilated prey becoming particulate organic matter


.. csv-table:: Namelist DARWIN_RADTRANS_TRAITS; indices (plankton, waveband)
   :delim: &
   :widths: auto
   :header: Trait, Symbol, Units, Description

   :varlink:`aphy_chl`    & :math:`a^{\op{chl}}_{\op{phy}}`       & m\ :sup:`2` (mg Chl)\ :sup:`-1` & phytoplankton Chl-specific absorption coefficient
   :varlink:`aphy_chl_ps` & :math:`a^{\op{chl}}_{\op{ps}}`        & m\ :sup:`2` (mg Chl)\ :sup:`-1` & part of :varlink:`aphy_chl` that is used in photosynthesis
   :varlink:`aphy_mgC`    & :math:`a^{\op{mgC}}_{\op{phy}}`       & m\ :sup:`2` (mg C)\ :sup:`-1`   & plankton carbon-specific absorption coefficient
   :varlink:`bphy_mgC`    & :math:`b^{\op{mgC}}_{\op{phy}}`       & m\ :sup:`2` (mg C)\ :sup:`-1`   & carbon-specific total scattering coefficient
   :varlink:`bbphy_mgC`   & :math:`b^{\op{mgC}}_{\op{b}\op{phy}}` & m\ :sup:`2` (mg C)\ :sup:`-1`   & carbon-specific backscattering coefficient


The dependent trait alphachl(plankton,waveband) is computed from the other traits
(radtrans or not).

Allometric trait generation
'''''''''''''''''''''''''''

Plankton types are organized into functional groups. ``grp_nplank(g)``
sets the number of types in group ``g``. Traits may be set the same for
all types in a group, e.g., ``grp_diazo(g)``, or based on allometric
scaling relations,

.. math:: \mathrm{trait}_j = a_g \cdot V_j^{b_g}

with per-group scaling coefficients :math:`a_g` and :math:`b_g`.

The volumes :math:`V_j` of all types can be set in four ways (in order
or decreasing precedence),

.. math::

   V_j = \begin{cases}
       \op{grp\_biovol(i,g)} &  \\
       V_{\log}(\op{grp\_biovolind(i,g)}) \\
       V_{\log}(\op{logvol0ind(g)}+i-1) \\
       V_{0 g} f_g^{i-1}
     \end{cases}

where :math:`i` is the index of type :math:`j` within the functional
group. :math:`V_{\log}` is a series of volumes, evenly spaced in log
space and defined by parameters :math:`B=\op{logvolbase}` and
:math:`I=\op{logvolinc}`,

.. math:: V_{\log} = 10^B, 10^{B+I}, 10^{B+2I}, \dots

and :math:`V_{0 g}=\op{biovol0(g)}` and
:math:`f_g=\op{biovolfac(g)}`.

The scaling coefficients are read from namelist ``&darwin_trait_params``
in ``data.darwin``. The following table shows the correspondence between
traits and trait parameters. Where :math:`b` is not given, it is set to
0, i.e., all types in the group share the same trait value.  For some trait
parameters *x*, a divisor may be specified in *x*\ _denom.  This is
particularly useful for specifying a rate in ‘per-day’ units, i.e.,
*x*\ _denom=86400.

.. csv-table:: Namelist DARWIN_TRAIT_PARAMS
   :delim: &
   :widths: auto
   :header: Trait, a, Default, b, Default

   :varlink:`isPhoto`            & :varlink:`grp_photo`              & 1             &                                    &
   :varlink:`bactType`           & :varlink:`grp_bacttype`           & 0             &                                    &
   :varlink:`isAerobic`          & :varlink:`grp_aerobic`            & 0             &                                    &
   :varlink:`isDenit`            & :varlink:`grp_denit`              & 0             &                                    &
   :varlink:`isPred`             & :varlink:`grp_pred`               & 0             &                                    &
   :varlink:`isPrey`             & :varlink:`grp_prey`               & 1             &                                    &
   :varlink:`hasSi`              & :varlink:`grp_hasSi`              & 0             &                                    &
   :varlink:`hasPIC`             & :varlink:`grp_hasPIC`             & 0             &                                    &
   :varlink:`diazo`              & :varlink:`grp_diazo`              & 0             &                                    &
   :varlink:`useNH4`             & :varlink:`grp_useNH4`             & 1             &                                    &
   :varlink:`useNO2`             & :varlink:`grp_useNO2`             & 1             &                                    &
   :varlink:`useNO3`             & :varlink:`grp_useNO3`             & 1             &                                    &
   :varlink:`combNO`             & :varlink:`grp_combNO`             & 1             &                                    &
   :varlink:`aptype`             & :varlink:`grp_aptype`             & 0             &                                    &
   :varlink:`tempMort`           & :varlink:`grp_tempMort`           & 1             &                                    &
   :varlink:`tempMort2`          & :varlink:`grp_tempMort2`          & 1             &                                    &
   :varlink:`tempGraz`           & :varlink:`grp_tempGraz`           & 1             &                                    &
   :varlink:`Xmin`               & :varlink:`a_Xmin`                 & 0             &                                    &
   :varlink:`R_NC`               & :varlink:`a_R_NC`                 & 16/120        &                                    &
   :varlink:`R_PC`               & :varlink:`a_R_PC`                 & 1/120         &                                    &
   :varlink:`R_SiC`              & :varlink:`a_R_SiC`                & 0             &                                    &
   :varlink:`R_FeC`              & :varlink:`a_R_FeC`                & 1D-3/120      &                                    &
   :varlink:`R_ChlC`             & :varlink:`a_R_ChlC`               & 16/120        &                                    &
   :varlink:`R_PICPOC`           & :varlink:`a_R_PICPOC`             & 0.8           &                                    &
   :varlink:`ExportFracMort`     & :varlink:`a_ExportFracMort`       & 0.5           &                                    &
   :varlink:`ExportFracMort2`    & :varlink:`a_ExportFracMort2`      & 0.5           &                                    &
   :varlink:`ExportFracExude`    & :varlink:`a_ExportFracExude`      & UNINIT        &                                    &
   :varlink:`mort`               & :varlink:`a_mort`                 & 0.02 / day    &                                    &
   :varlink:`mort2`              & :varlink:`a_mort2`                & 0             &                                    &
   :varlink:`phytoTempCoeff`     & :varlink:`a_phytoTempCoeff`       & 1/3           &                                    &
   :varlink:`phytoTempExp1`      & :varlink:`a_phytoTempExp1`        & 1.04          &                                    &
   :varlink:`phytoTempAe`        & :varlink:`a_phytoTempAe`          & 0.0438        &                                    &
   :varlink:`phytoTempExp2`      & :varlink:`a_phytoTempExp2`        & 0.001         &                                    &
   :varlink:`phytoTempOptimum`   & :varlink:`a_phytoTempOptimum`     & 2             &                                    &
   :varlink:`phytoDecayPower`    & :varlink:`a_phytoDecayPower`      & 4             &                                    &
   :varlink:`hetTempAe`          & :varlink:`a_hetTempAe`            & 0.0438        &                                    &
   :varlink:`hetTempExp2`        & :varlink:`a_hetTempExp2`          & 0.001         &                                    &
   :varlink:`hetTempOptimum`     & :varlink:`a_hetTempOptimum`       & 2             &                                    &
   :varlink:`hetDecayPower`      & :varlink:`a_hetDecayPower`        & 4             &                                    &
   :varlink:`grazTempAe`         & :varlink:`a_grazTempAe`           & 0.0438        &                                    &
   :varlink:`grazTempExp2`       & :varlink:`a_grazTempExp2`         & 0.001         &                                    &
   :varlink:`grazTempOptimum`    & :varlink:`a_grazTempOptimum`      & 2             &                                    &
   :varlink:`grazDecayPower`     & :varlink:`a_grazDecayPower`       & 4             &                                    &
   :varlink:`mQyield`            & :varlink:`a_mQyield`              & 75D-6         &                                    &
   :varlink:`chl2cmax`           & :varlink:`a_chl2cmax`             & .3            &                                    &
   :varlink:`inhibGeider`        & :varlink:`a_inhibGeider`          & 0             &                                    &
   :varlink:`ksatPAR`            & :varlink:`a_ksatPAR`              & 0.012         &                                    &
   :varlink:`kinhPAR`            & :varlink:`a_kinhPAR`              & 6D-3          &                                    &
   :varlink:`amminhib`           & :varlink:`a_amminhib`             & 4.6           &                                    &
   :varlink:`acclimtimescl`      & :varlink:`a_acclimtimescl`        & 1/(20 days)   &                                    &
                                 & :varlink:`a_acclimtimescl_denom`  & 1             &                                    &
   :varlink:`ksatPON`            & :varlink:`a_ksatPON`              & 1             &                                    &
   :varlink:`ksatDON`            & :varlink:`a_ksatDON`              & 1             &                                    &
   :varlink:`grazemax`           & :varlink:`a_grazemax`             & 21.9 / day    & :varlink:`b_grazemax`              & -0.16
                                 & :varlink:`a_grazemax_denom`       & 1             &                                    &
   :varlink:`kgrazesat`          & :varlink:`a_kgrazesat`            & 1.00          & :varlink:`b_kgrazesat`             & 0.00
   :varlink:`biosink`            & :varlink:`a_biosink`              & 0.28D-1 / day & :varlink:`b_biosink`               & 0.39
                                 & :varlink:`a_biosink_denom`        & 1             &                                    &
   :varlink:`bioswim`            & :varlink:`a_bioswim`              & 0.00 / day    & :varlink:`b_bioswim`               & 0.18
                                 & :varlink:`a_bioswim_denom`        & 1             &                                    &
   :varlink:`palat`              & :varlink:`a_ppSig`                & 1             & *see note* [#palat]_
   :varlink:`palat`              & :varlink:`a_ppOpt`                & 1024          & :varlink:`b_ppOpt`                 & 0.00
   :varlink:`palat`              & :varlink:`palat_min`              & 0             &                                    &
   :varlink:`PCmax`              & :varlink:`a_PCmax`                & 1.00 / day    & :varlink:`b_PCmax`                 & -0.15
                                 & :varlink:`a_PCmax_denom`          & 1             &                                    &
   :varlink:`qcarbon`            & :varlink:`a_qcarbon`              & 1.80D-11      & :varlink:`b_qcarbon`               & 0.94
   :varlink:`respRate`           & :varlink:`a_respRate_c`           & 0.00          & :varlink:`b_respRate_c`            & 0.93
                                 & :varlink:`a_respRate_c_denom`     & 1             & *see note* [#resprate]_
   :varlink:`kexcc`              & :varlink:`a_kexcC`                & 0.00          & :varlink:`b_kexcC`                 & -0.33
   :varlink:`vmaxNO3`            & :varlink:`a_vmaxNO3`              & 0.51 / day    & :varlink:`b_vmaxNO3`               & -0.27
                                 & :varlink:`a_vmaxNO3_denom`        & 1             &                                    &
   :varlink:`ksatNO3`            & :varlink:`a_ksatNO3`              & 0.17          & :varlink:`b_ksatNO3`               & 0.27
   :varlink:`Qnmin`              & :varlink:`a_Qnmin`                & 0.07          & :varlink:`b_Qnmin`                 & -0.17
   :varlink:`Qnmax`              & :varlink:`a_Qnmax`                & 0.25          & :varlink:`b_Qnmax`                 & -0.13
   :varlink:`kexcn`              & :varlink:`a_kexcN`                & 0.00          & :varlink:`b_kexcN`                 & -0.33
   :varlink:`vmaxNO2`            & :varlink:`a_vmaxNO2`              & 0.51 / day    & :varlink:`b_vmaxNO2`               & -0.27
                                 & :varlink:`a_vmaxNO2_denom`        & 1             &                                    &
   :varlink:`ksatNO2`            & :varlink:`a_ksatNO2`              & 0.17          & :varlink:`b_ksatNO2`               & 0.27
                                 & :varlink:`a_ksatNO2fac`           & 1             & *used for eff.ksat*
   :varlink:`vmaxNH4`            & :varlink:`a_vmaxNH4`              & 0.26 / day    & :varlink:`b_vmaxNH4`               & -0.27
                                 & :varlink:`a_vmaxNH4_denom`        & 1             &                                    &
   :varlink:`ksatNH4`            & :varlink:`a_ksatNH4`              & 0.85D-1       & :varlink:`b_ksatNH4`               & 0.27
                                 & :varlink:`a_ksatNH4fac`           & 0.5           & *used for eff.ksat*
   :varlink:`vmaxN`              & :varlink:`a_vmaxN`                & 1.28 / day    & :varlink:`b_vmaxN`                 & -0.27
                                 & :varlink:`a_vmaxN_denom`          & 1             &                                    &
   :varlink:`vmaxPO4`            & :varlink:`a_vmaxPO4`              & 0.77D-1 / day & :varlink:`b_vmaxPO4`               & -0.27
                                 & :varlink:`a_vmaxPO4_denom`        & 1             &                                    &
   :varlink:`ksatPO4`            & :varlink:`a_ksatPO4`              & 0.26D-1       & :varlink:`b_ksatPO4`               & 0.27
   :varlink:`Qpmin`              & :varlink:`a_Qpmin`                & 2.00D-3       & :varlink:`b_Qpmin`                 & 0.00
   :varlink:`Qpmax`              & :varlink:`a_Qpmax`                & 0.01          & :varlink:`b_Qpmax`                 & 0.00
   :varlink:`kexcp`              & :varlink:`a_kexcP`                & 0.24D-1 / day & :varlink:`b_kexcP`                 & -0.33
   :varlink:`vmaxSiO2`           & :varlink:`a_vmaxSiO2`             & 0.77D-1 / day & :varlink:`b_vmaxSiO2`              & -0.27
                                 & :varlink:`a_vmaxSiO2_denom`       & 1             &                                    &
   :varlink:`ksatSiO2`           & :varlink:`a_ksatSiO2`             & 0.24D-1       & :varlink:`b_ksatSiO2`              & 0.27
   :varlink:`Qsimin`             & :varlink:`a_Qsimin`               & 2.00D-3       & :varlink:`b_Qsimin`                & 0.00
   :varlink:`Qsimax`             & :varlink:`a_Qsimax`               & 4.00D-3       & :varlink:`b_Qsimax`                & 0.00
   :varlink:`kexcsi`             & :varlink:`a_kexcSi`               & 0.00  / day   & :varlink:`b_kexcSi`                & 0.00
   :varlink:`vmaxFeT`            & :varlink:`a_vmaxFeT`              & 14D-6 / day   & :varlink:`b_vmaxFeT`               & -0.27
                                 & :varlink:`a_vmaxFeT_denom`        & 1             &                                    &
   :varlink:`ksatFeT`            & :varlink:`a_ksatFeT`              & 80D-6         & :varlink:`b_ksatFeT`               & 0.27
   :varlink:`Qfemin`             & :varlink:`a_Qfemin`               & 1.50D-6       & :varlink:`b_Qfemin`                & 0.00
   :varlink:`Qfemax`             & :varlink:`a_Qfemax`               & 80D-6         & :varlink:`b_Qfemax`                & 0.00
   :varlink:`kexcfe`             & :varlink:`a_kexcFe`               & 0.00  / day   & :varlink:`b_kexcFe`                & 0.00
   :varlink:`ExportFracPreyPred` & :varlink:`grp_ExportFracPreyPred` & 0.5           & *(nGroup* :math:`\times` *nGroup)*
   :varlink:`asseff`             & :varlink:`grp_ass_eff`            & 0.7           & *(nGroup* :math:`\times` *nGroup)*
   :varlink:`aphy_chl`           & :varlink:`aphy_chl_type`          & *read*        & *via* :varlink:`grp_aptype`
   :varlink:`aphy_chl_ps`        & :varlink:`aphy_chl_ps_type`       & *read*        & *via* :varlink:`grp_aptype`
   :varlink:`aphy_mgC`           & :varlink:`aphy_mgC_type`          & *read*        & *via* :varlink:`grp_aptype`
   :varlink:`bphy_mgC`           & :varlink:`bphy_mgC_type`          & *read*        & *via* :varlink:`grp_aptype`
   :varlink:`bbphy_mgC`          & :varlink:`bbphy_mgC_type`         & *read*        & *via* :varlink:`grp_aptype`

.. [#palat] Palatabilities are initialized to zero and have to be set in
   ``data.traits`` unless :varlink:`DARWIN_ALLOMETRIC_PALAT` is defined in
   which case they are computed from pp_opt, pp_sig and palat_min based on
   predator and prey sizes, see :numref:`Grazing`.

.. [#resprate] The respiration rate follows a different scaling law from other
   traits.  It scales in terms of cellular carbon content, see
   :numref:`Mortality`.


Diagnostics
~~~~~~~~~~~

.. tabularcolumns:: |\Y{.16}|\Y{.16}|\Y{.18}|\Y{.5}|

.. csv-table:: Darwin package diagnstic fields
   :delim: &
   :widths: auto
   :class: longtable
   :header: Name, Code, Units, Description

   plankC     & ``SMR_____MR`` & mmol C /m\ :sup:`3`             & Total plankton carbon biomass
   Chl        & ``SMR_____MR`` & mg Chl a /m\ :sup:`3`           & Total Chlorophyll a
   PP         & ``SMRP____MR`` & mmol C /m\ :sup:`3`/s           & Primary Production
   Nfix       & ``SMRP____MR`` & mmol N /m\ :sup:`3`/s           & N fixation
   Denit      & ``SMRP____MR`` & mmol N /m\ :sup:`3`/s           & Denitrification
   DenitN     & ``SMRP____MR`` & mmol N /m\ :sup:`3`/s           & Nitrogen loss due to denitrification
   PAR###     & ``SMRP____MR`` & µEin/m\ :sup:`2`/s              & PAR waveband ###
   PARF###    & ``SMRP____LR`` & µEin/m\ :sup:`2`/s              & PAR at W point, waveband ###
   a###       & ``SMRP____MR`` & 1/m                             & total absorption for waveband ###
   bt###      & ``SMRP____MR`` & 1/m                             & total scattering for waveband ###
   bb###      & ``SMRP____MR`` & 1/m                             & total backscattering for waveband ###
   aplk###    & ``SMRP____MR`` & 1/m                             & absorption by plankton for waveband ###
   btplk###   & ``SMRP____MR`` & 1/m                             & scattering by plankton for waveband ###
   bbplk###   & ``SMRP____MR`` & 1/m                             & backscattering by plankton for waveband ###
   aprt###    & ``SMRP____MR`` & 1/m                             & absorption by particles for waveband ###
   btprt###   & ``SMRP____MR`` & 1/m                             & scattering by particles for waveband ###
   bbprt###   & ``SMRP____MR`` & 1/m                             & backscattering by particles for waveband ###
   aCDOM###   & ``SMRP____MR`` & 1/m                             & absorption by CDOM for waveband ###
   atten      & ``SMRP____MR`` & 1                               & attenuation in layer
   PARF       & ``SMRP____LR`` & µEin/m\ :sup:`2`/s              & PAR at top of layer
   PAR        & ``SMRP____MR`` & µEin/m\ :sup:`2`/s              & total PAR at layer center
   C_DIN      & ``SMRP____MR`` & mmol N /m\ :sup:`3`/s           & consumption of DIN: :math:`\sum_j(U^{\op{NO3}}_j+U^{\op{NO2}}_j+U^{\op{NH4}}_j)`
   C_NO3      & ``SMRP____MR`` & mmol N /m\ :sup:`3`/s           & consumption of NO3: :math:`\sum_j U^{\op{NO3}}_j`
   C_NO2      & ``SMRP____MR`` & mmol N /m\ :sup:`3`/s           & consumption of NO2: :math:`\sum_j U^{\op{NO2}}_j`
   C_NH4      & ``SMRP____MR`` & mmol N /m\ :sup:`3`/s           & consumption of NH4: :math:`\sum_j U^{\op{NH4}}_j`
   C_PO4      & ``SMRP____MR`` & mmol P /m\ :sup:`3`/s           & consumption of PO4: :math:`\sum_j U^{\op{PO4}}_j`
   C_Si       & ``SMRP____MR`` & mmol Si /m\ :sup:`3`/s          & consumption of Si: :math:`\sum _j U^{\op{SiO2}}_j`
   C_Fe       & ``SMRP____MR`` & mmol Fe /m\ :sup:`3`/s          & consumption of Fe: :math:`\sum_j U^{\op{Fe}}_j`
   S_DIN      & ``SMR_____MR`` & mmol N /m\ :sup:`3`/s           & non-transport source of DIN: :math:`r_{\op{DON}}\op{DON}+[r_{\op{PON}}\op{PON}]-D_{\op{NH4}}-D_{\op{NO3}}`
   S_NO3      & ``SMR_____MR`` & mmol N /m\ :sup:`3`/s           & non-transport source of NO3
   S_NO2      & ``SMR_____MR`` & mmol N /m\ :sup:`3`/s           & non-transport source of NO2
   S_NH4      & ``SMR_____MR`` & mmol N /m\ :sup:`3`/s           & non-transport source of NH4
   S_PO4      & ``SMR_____MR`` & mmol P /m\ :sup:`3`/s           & non-transport source of PO4: :math:`r_{\op{DOP}}\op{DOP}+[r_{\op{POP}}\op{POP}]`
   S_Si       & ``SMR_____MR`` & mmol Si /m\ :sup:`3`/s          & non-transport source of Si: :math:`r_{\op{POSi}}\op{POSi}`
   S_Fe       & ``SMR_____MR`` & mmol Fe /m\ :sup:`3`/s          & non-transport source of Fe: :math:`r_{\op{DOFe}}\op{DOFe}+[r_{\op{POFe}}\op{POFe}]+S_{\op{Fe}}`
   gDAR##     & ``SMR_____MR`` & [TRAC##]/s                      & ptracer ## tendency from DARWIN [#a]_
   gECO##     & ``SMR_____MR`` & [TRAC##]/s                      & ptracer ## tendency from DARWIN w/o sink/swim [#a]_
   PP####     & ``SMRP____MR`` & mmol C /m\ :sup:`3`/s           & Primary Production plankton ####
   PC####     & ``SMRP____MR`` & 1/s                             & Carbon-specific growth rate plankton ####
   GR####     & ``SMRP____MR`` & mmol C /m\ :sup:`3`/s           & Grazing loss of plankton ####
   GrGn####   & ``SMRP____MR`` & mmol C /m\ :sup:`3`/s           & Grazing gain of plankton ####
   sfcSolFe   & ``SM_P____L1`` & mmol Fe /m\ :sup:`2`/s          & Soluble iron input at sea surface
   sedFe      & ``SM_P____MR`` & mmol Fe /m\ :sup:`2`/s          & Iron input from sediment
   freeFeLs   & ``SMRP____MR`` & mmol Fe /m\ :sup:`3`/s          & Iron loss due to free iron limit
   pH         & ``SMR_____MR`` & 1                               & pH
   pCO2       & ``SMRP____MR`` & atm                             & Partial Pressure of CO2
   fugfCO2    & ``SM_P____L1`` & 1                               & Fugacity factor of CO2 at surface
   fCO2       & ``SM_P____L1`` & atm                             & Fugacity of CO2 (atm)
   fluxCO2    & ``SM______L1`` & mmol C /m\ :sup:`2`/s           & Flux of CO2 - air-sea exch
   fluxO2     & ``SM______L1`` & mmol O2 /m\ :sup:`2`/s          & Flux of O2 - air-sea exch
   VfluxCO2   & ``SM______L1`` & mmol C /m\ :sup:`2`/s           & Virtual flux of CO2
   VfluxAlk   & ``SM______L1`` & meq/m\ :sup:`2`/s               & Virtual flux of alkalinity
   gDICsurf   & ``SM______L1`` & mmol C /m\ :sup:`3`/s           & Tendency of DIC due to air-sea exch + oldvirt.flux
   gDICEpr    & ``SM______L1`` & mmol C /m\ :sup:`3`/s           & Tendency of DIC due to E/P/runoff
   gALKEpr    & ``SM______L1`` & mmol eq./m\ :sup:`3`/s          & Tendency of ALK due to E/P/runoff
   gO2Epr     & ``SM______L1`` & mmol eq./m\ :sup:`3`/s          & Tendency of O2 due to E/P/runoff
   gNO3Epr    & ``SM______L1`` & mmol N /m\ :sup:`3`/s           & Tendency of DIC due to E/P/runoff
   gNO2Epr    & ``SM______L1`` & mmol N /m\ :sup:`3`/s           & Tendency of DIC due to E/P/runoff
   gNH4Epr    & ``SM______L1`` & mmol N /m\ :sup:`3`/s           & Tendency of DIC due to E/P/runoff
   gPO4Epr    & ``SM______L1`` & mmol P /m\ :sup:`3`/s           & Tendency of PO4 due to E/P/runoff
   gFeTEpr    & ``SM______L1`` & mmol C /m\ :sup:`3`/s           & Tendency of FeT due to E/P/runoff
   gSiO2Epr   & ``SM______L1`` & mmol Si /m\ :sup:`3`/s          & Tendency of SiO2 due to E/P/runoff
   gALKsurf   & ``SM______L1`` & meq/m\ :sup:`3`/s               & Tendency of ALK due to oldvirt.flux
   gO2surf    & ``SM______L1`` & mmol O2 /m\ :sup:`3`/s          & Tendency of O2 due to air-sea exch
   C_DIC      & ``SMR_____MR`` & mmol C /m\ :sup:`3`/s           & Consumption of DIC
   C_DICPIC   & ``SMR_____MR`` & mmol C /m\ :sup:`3`/s           & Consumption of DIC due to PIC
   respDIC    & ``SMR_____MR`` & mmol C /m\ :sup:`3`/s           & DIC due to respiration
   rDIC_DOC   & ``SMR_____MR`` & mmol C /m\ :sup:`3`/s           & DIC due to remineralization of DOC
   rDIC_POC   & ``SMR_____MR`` & mmol C /m\ :sup:`3`/s           & DIC due to remineralization of POC
   dDIC_PIC   & ``SMR_____MR`` & mmol C /m\ :sup:`3`/s           & DIC due to dissolution of PIC
   C_ALK      & ``SMR_____MR`` & mmol eq./m\ :sup:`3`/s          & Consumption of alkalinity
   S_ALK      & ``SMR_____MR`` & mmol eq./m\ :sup:`3`/s          & Non-transport source of alkalinity
   C_O2       & ``SMR_____MR`` & mmol O /m\ :sup:`3`/s           & Consumption of oxygen
   S_O2       & ``SMR_____MR`` & mmol O /m\ :sup:`3`/s           & Non-transport source of oxygen
   surfPAR    & ``SM_P____L1`` & µEin/m\ :sup:`2`/s              & PAR forcing at surface
   surfiron   & ``SM_P____L1`` & mmol Fe /m\ :sup:`2`/s          & iron forcing at surface
   DARice     & ``SM_P____L1`` & m\ :sup:`2`/m\ :sup:`2`         & ice area fraction
   DARwind    & ``SM_P____L1`` & m/s                             & wind speed used for carbon exchange
   surfpCO2   & ``SM_P____L1`` & mol/mol                         & atmospheric surface pCO2
   apCO2      & ``SM_P____L1`` & atm                             & atmospheric pCO2
   apCO2sat   & ``SM_P____L1`` & atm                             & atmospheric pCO2 sat

.. [#a] does not include free iron adjustment for FeT tracer

The sign convention for the fluxCO2, gDICsurf, gALKsurf and gO2surf diagnostics
is such that positive values increase the concentration in the ocean.  Note
that the units vary: gDICsurf, gALKsurf and gO2surf are tracer tendencies,
i.e., change rates of concentration, while fluxCO2 is a flux per area of
sea surface.

Also of interest are the following diagnostics from the ptracers and gchem packages:

.. csv-table::
   :delim: &
   :widths: auto
   :class: longtable
   :header: Name, Code, Units, Description

   Tp_g##  & ``SMR_____MR`` & [TRAC##]/s & ptracer ## total transport tendency (before gchem_forcing_sep)
   TRAC##  & ``SMR_____MR`` & [TRAC##]   & ptracer ## concentration before transport
   GC_Tr## & ``SMR_____MR`` & [TRAC##]   & ptracer ## concentration before GCHEM

The ptracer number ## here and in gDAR## is the one defined in the ptracers
package, see :numref:`ptracers_diagnostics` for value larger than 99.


Call Tree
~~~~~~~~~

::

    the_model_main
      initialise_fixed
        packages_readparms
          gchem_readparms
            darwin_readparms
              darwin_exf_readparms
              darwin_read_params
              darwin_read_traitparams
            gchem_tr_register
              darwin_tr_register
        packages_init_fixed
          gchem_init_fixed
            darwin_init_fixed
              darwin_exf_init_fixed
              darwin_diagnostics_init
              darwin_random_init
              darwin_generate_random
                darwin_random
                darwin_random_normal
              darwin_generate_allometric
              darwin_read_traits
        packages_check
          gchem_check
            darwin_check
      the_main_loop
        initialise_varia
          packages_init_variables
            gchem_init_vari
              darwin_init_varia
                darwin_exf_init_varia
                darwin_read_pickup
                darwin_init_chl
                  darwin_light_radtrans
                  darwin_light
                    darwin_insol
                darwin_surfforcing_init
                  darwin_carbon_coeffs
                  darwin_calc_pco2_approx
          do_the_model_io
            gchem_output
              darwin_diags
        main_do_loop
          forward_step
            load_fields_driver
              gchem_fields_load
                darwin_fields_load
                  darwin_exf_load
                  darwin_monitor
            gchem_forcing_sep
              darwin_conserve_surface
              darwin_cons
              darwin_nut_supply
              darwin_forcing
                darwin_light_radtrans
                darwin_light...
                darwin_surfforcing
                  darwin_carbon_coeffs
                  darwin_calc_pco2_approx
                darwin_fe_chem
                darwin_tempfunc
                darwin_plankton
                darwin_sinking
              darwin_atmos
            do_the_model_io...
            do_write_pickup
              packages_write_pickup
                gchem_write_pickup
                  darwin_write_pickup


Differences to darwin2
^^^^^^^^^^^^^^^^^^^^^^

Not up-to-date!

-  Particulate/dissolved split of plankton mortality products is not
   allometric or element-dependent as it was in quota.

-  grazing and mortality temperature dependent with TEMP_VERSION 2.

-  chl2cmin affects acclim.

Bug fixes:

-  1e-3 replaced by 1 _d -3 in conversion of tracers for pH solver.
