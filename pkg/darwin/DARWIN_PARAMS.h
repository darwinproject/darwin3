#ifdef ALLOW_DARWIN

CBOP
C     !ROUTINE: DARWIN_PARAMS.h
C     !INTERFACE:
C #include DARWIN_PARAMS.h

C     !DESCRIPTION:
C Contains run-time parameters for the darwin package
C
C Requires: DARWIN_SIZE.h

      _RL DARWIN_UNINIT_RL
      PARAMETER(DARWIN_UNINIT_RL=-999999999 _d 0)

C--   COMMON/darwin_forcing_params_l/ darwin parameters related to forcing
C     darwin_chlInitBalanced :: Initialize Chlorophyll to a balanced value following Geider
C     darwin_haveSurfPAR     :: whether PAR forcing fields/constant were given
C     darwin_haveVentHe3     :: whether hydrothermal vent forcing was given
C     darwin_useSEAICE       :: whether to use ice area from seaice pkg
C     darwin_useQsw          :: whether to use model shortwave radiation
C     darwin_useEXFwind      :: whether to use wind speed from exf package
      COMMON/darwin_forcing_params_l/
     &    darwin_chlInitBalanced,
     &    darwin_haveSurfPAR,
     &    darwin_haveVentHe3,
     &    darwin_useSEAICE,
     &    darwin_useQsw,
     &    darwin_useEXFwind
      LOGICAL darwin_chlInitBalanced
      LOGICAL darwin_haveSurfPAR
      LOGICAL darwin_haveVentHe3
      LOGICAL darwin_useSEAICE
      LOGICAL darwin_useQsw
      LOGICAL darwin_useEXFwind

C--   COMMON/darwin_forcing_params_i/ darwin parameters related to forcing
C     darwin_chlIter0 :: Iteration number when to initialize Chlorophyll
      COMMON/darwin_forcing_params_i/
     &    darwin_chlIter0
      INTEGER darwin_chlIter0

C--   COMMON /DARWIN_CONSTANTS_r/
C     rad2deg ::
      COMMON /DARWIN_CONSTANTS_r/
     &    rad2deg
      _RL rad2deg

#ifdef DARWIN_ALLOW_CARBON
C--   COMMON /CARBON_CONSTANTS_r/ Coefficients for DIC chemistry
C     Pa2Atm :: Convert pressure in Pascal to atm
C     ptr2mol :: convert ptracers (in mmol/m3) to mol/m3
C-
C     sca1 :: Schmidt no. coefficient for CO2
C     sca2 :: Schmidt no. coefficient for CO2
C     sca3 :: Schmidt no. coefficient for CO2
C     sca4 :: Schmidt no. coefficient for CO2
C-
C     sox1 :: [] Schmidt no. coefficient for O2 [Keeling et al, GBC, 12, 141, (1998)]
C     sox2 :: [] Schmidt no. coefficient for O2 [Keeling et al, GBC, 12, 141, (1998)]
C     sox3 :: [] Schmidt no. coefficient for O2 [Keeling et al, GBC, 12, 141, (1998)]
C     sox4 :: [] Schmidt no. coefficient for O2 [Keeling et al, GBC, 12, 141, (1998)]
C-
C     oA0 :: Coefficient for determining saturation O2
C     oA1 :: Coefficient for determining saturation O2
C     oA2 :: Coefficient for determining saturation O2
C     oA3 :: Coefficient for determining saturation O2
C     oA4 :: Coefficient for determining saturation O2
C     oA5 :: Coefficient for determining saturation O2
C     oB0 :: Coefficient for determining saturation O2
C     oB1 :: Coefficient for determining saturation O2
C     oB2 :: Coefficient for determining saturation O2
C     oB3 :: Coefficient for determining saturation O2
C     oC0 :: Coefficient for determining saturation O2
      COMMON /CARBON_CONSTANTS_r/
     &    Pa2Atm,
     &    ptr2mol,
     &    sca1,
     &    sca2,
     &    sca3,
     &    sca4,
     &    sox1,
     &    sox2,
     &    sox3,
     &    sox4,
     &    oA0,
     &    oA1,
     &    oA2,
     &    oA3,
     &    oA4,
     &    oA5,
     &    oB0,
     &    oB1,
     &    oB2,
     &    oB3,
     &    oC0
      _RL Pa2Atm
      _RL ptr2mol
      _RL sca1
      _RL sca2
      _RL sca3
      _RL sca4
      _RL sox1
      _RL sox2
      _RL sox3
      _RL sox4
      _RL oA0
      _RL oA1
      _RL oA2
      _RL oA3
      _RL oA4
      _RL oA5
      _RL oB0
      _RL oB1
      _RL oB2
      _RL oB3
      _RL oC0
#endif

C     COMMON /DARWIN_PARAMS_c/ General parameters (same for all plankton)
C     darwin_pickupSuff :: pickup suffix for darwin; set to ' ' to disable reading at PTRACERS_Iter0
      COMMON /DARWIN_PARAMS_c/ darwin_pickupSuff
      CHARACTER*10 darwin_pickupSuff
C     darwin_strict_check  :: stop instead of issuing warnings
C     darwin_linFSConserve :: correct non-conservation due to linear free surface (globally)
C     darwin_read_phos     :: initial conditions for plankton biomass are in mmol P/m3
C--   COMMON /DARWIN_PARAMS_l/ General parameters (same for all plankton)
      COMMON /DARWIN_PARAMS_l/
     &    darwin_strict_check,
     &    darwin_linFSConserve,
     &    darwin_read_phos
      LOGICAL darwin_strict_check
      LOGICAL darwin_linFSConserve
      LOGICAL darwin_read_phos

C--   COMMON /DARWIN_PARAMS_i/ General parameters (same for all plankton)
C     darwin_seed :: seed for random number generator (for DARWIN_RANDOM_TRAITS)
C     iDEBUG      :: index in x dimension for debug prints
C     jDEBUG      :: index in y dimension for debug prints
C     kDEBUG      :: index in z dimension for debug prints
      COMMON /DARWIN_PARAMS_i/
     &    darwin_seed,
     &    iDEBUG,
     &    jDEBUG,
     &    kDEBUG
      INTEGER darwin_seed
      INTEGER iDEBUG
      INTEGER jDEBUG
      INTEGER kDEBUG

C--   COMMON /DARWIN_PARAMS_r/ General parameters (same for all plankton)
C     katten_w          :: [1/m]            atten coefficient water
C     katten_chl        :: [m2/mg Chl]      atten coefficient chl
C
C     parfrac           :: []               fraction Qsw that is PAR
C     parconv           :: [uEin/s/W]       conversion from W/m2 to uEin/m2/s
C     tempnorm          :: []               set temperature function (was 1.0)
C     TempAeArr         :: [K]              slope for pseudo-Arrhenius (TEMP_VERSION 2)
C     TemprefArr        :: [K]              reference temp for pseudo-Arrhenius (TEMP_VERSION 2)
C     TempCoeffArr      :: []               pre-factor for pseudo-Arrhenius (TEMP_VERSION 2)
C     reminTempAe       :: [1/K]            temperature coefficient for remineralization (TEMP_VERSION 4)
C     mortTempAe        :: [1/K]            temperature coefficient for linear mortality (TEMP_VERSION 4)
C     mort2TempAe       :: [1/K]            temperature coefficient for quadr. mortality (TEMP_VERSION 4)
C     uptakeTempAe      :: [1/K]            temperature coefficient for uptake (TEMP_VERSION 4)
C
C- Iron parameters
C     alpfe             :: []                  solubility of Fe dust
C     scav              :: [1/s]               fixed iron scavenging rate
C     ligand_tot        :: [mol/m3]            total ligand concentration
C     ligand_stab       :: [m3/mol]            ligand stability rate ratio
C     freefemax         :: [mol/m3]            max concentration of free iron
C     scav_rat          :: [1/s]               rate of POM-based iron scavenging
C     scav_inter        :: []                  intercept of scavenging power law
C     scav_exp          :: []                  exponent of scavenging power law
C     scav_R_POPPOC     :: [mmol P / mmol C]   POP:POC ratio for DARWIN_PART_SCAV_POP
C     depthfesed        :: [m]                 depth above which to add sediment source (was -1000)
C     fesedflux         :: [mmol Fe /m2/s]     fixed iron flux from sediment
C     fesedflux_pcm     :: [mmol Fe / mmol C]  iron input per POC sinking into bottom for DARWIN_IRON_SED_SOURCE_VARIABLE
C     fesedflux_min     :: [mmol Fe /s]        min iron input rate subtracted from fesedflux_pcm*wc_sink*POC
C     R_CP_fesed        :: [mmol C / mmol P]   POC:POP conversion for DARWIN_IRON_SED_SOURCE_POP
C     depthFeVent       :: [m]                 depth below which iron from hydrothermal vents is added
C     solFeVent         :: []                  solubility of iron from hydrothermal vents
C     R_FeHe3_vent      :: [mmol Fe / mmol He3]  Fe:He3 ratio for hydrothermal vents
C
C     Knita             :: [1/s]               ammonia oxidation rate
C     Knitb             :: [1/s]               nitrite oxidation rate
C     PAR_oxi           :: [uEin/m2/s]         critical light level after which oxidation starts
C
C     Kdoc              :: [1/s]  DOC remineralization rate
C     Kdop              :: [1/s]  DON remineralization rate
C     Kdon              :: [1/s]  DOP remineralization rate
C     KdoFe             :: [1/s]  DOFe remineralization rate
C     KPOC              :: [1/s]  POC remineralization rate
C     KPON              :: [1/s]  PON remineralization rate
C     KPOP              :: [1/s]  POP remineralization rate
C     KPOFe             :: [1/s]  POFe remineralization rate
C     KPOSi             :: [1/s]  POSi remineralization rate
C
C     wC_sink           :: [m/s]  sinking velocity for POC
C     wN_sink           :: [m/s]  sinking velocity for PON
C     wP_sink           :: [m/s]  sinking velocity for POP
C     wFe_sink          :: [m/s]  sinking velocity for POFe
C     wSi_sink          :: [m/s]  sinking velocity for POSi
C     wPIC_sink         :: [m/s]  sinking velocity for PIC
C     Kdissc            :: [1/s]  dissolution rate for PIC
C
C- Carbon chemistry parameters
C     R_OP              :: [mmol O2 / mmol P]  O:P ratio for respiration and consumption
C     R_OC              :: [mmol O2 / mmol C]  NOT USED
C     m3perkg           :: [m3/kg]         constant for converting per kg to per m^3
C     surfSaltMinInit   :: [ppt]           minimum salt for carbon solver at initialization
C     surfSaltMaxInit   :: [ppt]           maximum salt for carbon solver at initialization
C     surfTempMinInit   :: [degrees C]     minimum temp for carbon solver at initialization
C     surfTempMaxInit   :: [degrees C]     maximum temp for carbon solver at initialization
C     surfDICMinInit    :: [mmol C m^-3]   minimum DIC for carbon solver at initialization
C     surfDICMaxInit    :: [mmol C m^-3]   maximum DIC for carbon solver at initialization
C     surfALKMinInit    :: [meq m^-3]      minimum alkalinity for carbon solver at initialization
C     surfALKMaxInit    :: [meq m^-3]      maximum alkalinity for carbon solver at initialization
C     surfPO4MinInit    :: [mmol P m^-3]   minimum PO4 for carbon solver at initialization
C     surfPO4MaxInit    :: [mmol P m^-3]   maximum PO4 for carbon solver at initialization
C     surfSiMinInit     :: [mmol Si m^-3]  minimum SiO2 for carbon solver at initialization
C     surfSiMaxInit     :: [mmol Si m^-3]  maximum SiO2 for carbon solver at initialization
C     surfSaltMin       :: [ppt]           minimum salt for carbon solver during run
C     surfSaltMax       :: [ppt]           maximum salt for carbon solver during run
C     surfTempMin       :: [degrees C]     minimum temp for carbon solver during run
C     surfTempMax       :: [degrees C]     maximum temp for carbon solver during run
C     surfDICMin        :: [mmol C m^-3]   minimum DIC for carbon solver during run
C     surfDICMax        :: [mmol C m^-3]   maximum DIC for carbon solver during run
C     surfALKMin        :: [meq m^-3]      minimum alkalinity for carbon solver during run
C     surfALKMax        :: [meq m^-3]      maximum alkalinity for carbon solver during run
C     surfPO4Min        :: [mmol P m^-3]   minimum PO4 for carbon solver during run
C     surfPO4Max        :: [mmol P m^-3]   maximum PO4 for carbon solver during run
C     surfSiMin         :: [mmol Si m^-3]  minimum SiO2 for carbon solver during run
C     surfSiMax         :: [mmol Si m^-3]  maximum SiO2 for carbon solver during run
C
C     diaz_ini_fac      :: reduce tracer concentrations by this factor on initialization
C
C- Denitrification
C     O2crit            :: [mmol O2 m-3]      critical oxygen for O2/NO3 remineralization
C     denit_NP          :: [mmol N / mmol P]  ratio of n to p in denitrification process
C     denit_NO3         :: [mmol N / mmol P]  ratio of NO3 uptake to phos remineralization in denitrification
C     NO3crit           :: [mmol N m-3]       critical nitrate below which no denit (or remin) happens
C
C- These should probably be traits
C     PARmin            :: [uEin/m2/s]        minimum light for photosynthesis; for non-Geider: 1.0
C     aphy_chl_ave      :: [m2/mg Chl]        Chl-specific absorption coefficient
C     chl2nmax          :: [mg Chl / mmol N]  max Chl:N ratio for Chl synthesis following Moore 2002
C     synthcost         :: [mmol C / mmol N]  cost of biosynthesis
C     inhib_graz        :: [(mmol C m-3)-1]   inverse decay scale for grazing inhibition
C     inhib_graz_exp    :: []                 exponent for grazing inhibition (0 to turn off inhibition)
C     hillnumUptake     :: []                 exponent for limiting quota uptake in nutrient uptake
C     hillnumGraz       :: []                 exponent for limiting quota uptake in grazing
C     hollexp           :: []                 grazing exponential 1= "Holling 2", 2= "Holling 3"
C     phygrazmin        :: [mmol C m-3]       minimum total prey conc for grazing to occur
C
C- Bacteria
C     pmaxDIN           :: [1/s]           max DIN uptake rate for denitrifying bacteria
C     pcoefO2           :: [m3/mmol O2/s]  max O2-specific O2 uptake rate for aerobic bacteria
C     ksatDIN           :: [mmol N m-3]    half-saturation conc of dissolved inorganic nitrogen
C     alpha_hydrol      :: []              increase in POM needed due to hydrolysis
C     yod               :: []              organic matter yield of aerobic bacteria
C     yoe               :: []              energy yield of aerobic bacteria
C     ynd               :: []              organic matter yield of denitrifying bacteria
C     yne               :: []              energy yield of denitrifying bacteria
C     fnh4              :: []              not implemented (for ammonia-oxidizing bacteria)
C     ynh4              :: []              not implemented (for ammonia-oxidizing bacteria)
C     yonh4             :: []              not implemented (for ammonia-oxidizing bacteria)
C     fno2              :: []              not implemented (for nitrite-oxidizing bacteria)
C     yno2              :: []              not implemented (for nitrite-oxidizing bacteria)
C     yono2             :: []              not implemented (for nitrite-oxidizing bacteria)
C
C- To be implemented
C     depthdenit        :: [m]             not implemented (depth for denitrification relaxation to start)
      COMMON /DARWIN_PARAMS_r/
     &    katten_w,
     &    katten_chl,
     &    parfrac,
     &    parconv,
     &    tempnorm,
     &    TempAeArr,
     &    TemprefArr,
     &    TempCoeffArr,
     &    reminTempAe,
     &    mortTempAe,
     &    mort2TempAe,
     &    uptakeTempAe,
     &    alpfe,
     &    scav,
     &    ligand_tot,
     &    ligand_stab,
     &    freefemax,
     &    scav_rat,
     &    scav_inter,
     &    scav_exp,
     &    scav_R_POPPOC,
     &    depthfesed,
     &    fesedflux,
     &    fesedflux_pcm,
     &    fesedflux_min,
     &    R_CP_fesed,
     &    depthFeVent,
     &    solFeVent,
     &    R_FeHe3_vent,
     &    Knita,
     &    Knitb,
     &    PAR_oxi,
     &    Kdoc,
     &    Kdop,
     &    Kdon,
     &    KdoFe,
     &    KPOC,
     &    KPON,
     &    KPOP,
     &    KPOFe,
     &    KPOSi,
     &    wC_sink,
     &    wN_sink,
     &    wP_sink,
     &    wFe_sink,
     &    wSi_sink,
     &    wPIC_sink,
     &    Kdissc,
#ifdef DARWIN_ALLOW_CARBON
     &    R_OP,
     &    R_OC,
     &    m3perkg,
     &    surfSaltMinInit,
     &    surfSaltMaxInit,
     &    surfTempMinInit,
     &    surfTempMaxInit,
     &    surfDICMinInit,
     &    surfDICMaxInit,
     &    surfALKMinInit,
     &    surfALKMaxInit,
     &    surfPO4MinInit,
     &    surfPO4MaxInit,
     &    surfSiMinInit,
     &    surfSiMaxInit,
     &    surfSaltMin,
     &    surfSaltMax,
     &    surfTempMin,
     &    surfTempMax,
     &    surfDICMin,
     &    surfDICMax,
     &    surfALKMin,
     &    surfALKMax,
     &    surfPO4Min,
     &    surfPO4Max,
     &    surfSiMin,
     &    surfSiMax,
#endif
     &    diaz_ini_fac,
     &    O2crit,
     &    denit_NP,
     &    denit_NO3,
     &    NO3crit,
     &    PARmin,
     &    aphy_chl_ave,
     &    chl2nmax,
     &    synthcost,
     &    inhib_graz,
     &    inhib_graz_exp,
     &    hillnumUptake,
     &    hillnumGraz,
     &    hollexp,
     &    phygrazmin,
     &    pcoefO2,
     &    pmaxDIN,
     &    ksatDIN,
     &    alpha_hydrol,
     &    yod,
     &    yoe,
     &    ynd,
     &    yne,
C     &    fnh4,
C     &    ynh4,
C     &    yonh4,
C     &    fno2,
C     &    yno2,
C     &    yono2,
     &    depthdenit
      _RL katten_w
      _RL katten_chl
      _RL parfrac
      _RL parconv
      _RL tempnorm
      _RL TempAeArr
      _RL TemprefArr
      _RL TempCoeffArr
      _RL reminTempAe
      _RL mortTempAe
      _RL mort2TempAe
      _RL uptakeTempAe
      _RL alpfe
      _RL scav
      _RL ligand_tot
      _RL ligand_stab
      _RL freefemax
      _RL scav_rat
      _RL scav_inter
      _RL scav_exp
      _RL scav_R_POPPOC
      _RL depthfesed
      _RL fesedflux
      _RL fesedflux_pcm
      _RL fesedflux_min
      _RL R_CP_fesed
      _RL depthFeVent
      _RL solFeVent
      _RL R_FeHe3_vent
      _RL Knita
      _RL Knitb
      _RL PAR_oxi
      _RL Kdoc
      _RL Kdop
      _RL Kdon
      _RL KdoFe
      _RL KPOC
      _RL KPON
      _RL KPOP
      _RL KPOFe
      _RL KPOSi
      _RL wC_sink
      _RL wN_sink
      _RL wP_sink
      _RL wFe_sink
      _RL wSi_sink
      _RL wPIC_sink
      _RL Kdissc
#ifdef DARWIN_ALLOW_CARBON
      _RL R_OP
      _RL R_OC
      _RL m3perkg
      _RL surfSaltMinInit
      _RL surfSaltMaxInit
      _RL surfTempMinInit
      _RL surfTempMaxInit
      _RL surfDICMinInit
      _RL surfDICMaxInit
      _RL surfALKMinInit
      _RL surfALKMaxInit
      _RL surfPO4MinInit
      _RL surfPO4MaxInit
      _RL surfSiMinInit
      _RL surfSiMaxInit
      _RL surfSaltMin
      _RL surfSaltMax
      _RL surfTempMin
      _RL surfTempMax
      _RL surfDICMin
      _RL surfDICMax
      _RL surfALKMin
      _RL surfALKMax
      _RL surfPO4Min
      _RL surfPO4Max
      _RL surfSiMin
      _RL surfSiMax
#endif
      _RL diaz_ini_fac
      _RL O2crit
      _RL denit_NP
      _RL denit_NO3
      _RL NO3crit
      _RL PARmin
      _RL aphy_chl_ave
      _RL chl2nmax
      _RL synthcost
      _RL inhib_graz
      _RL inhib_graz_exp
      _RL hillnumUptake
      _RL hillnumGraz
      _RL hollexp
      _RL phygrazmin
      _RL pcoefO2
      _RL pmaxDIN
      _RL ksatDIN
      _RL alpha_hydrol
      _RL yod
      _RL yoe
      _RL ynd
      _RL yne
C      _RL fnh4
C      _RL ynh4
C      _RL yonh4
C      _RL fno2
C      _RL yno2
C      _RL yono2
      _RL depthdenit

#ifdef DARWIN_ALLOW_CDOM
C--   COMMON /DARWIN_CDOM_PARAMS_r/
C     fracCDOM   :: []                  fraction of remineralized POP contributing to CDOM
C     CDOMdegrd  :: [1/s]               CDOM degradation rate
C     CDOMbleach :: [1/s]               CDOM bleaching rate
C     PARCDOM    :: [uEin/m2/s]         PAR where CDOM bleaching becomes maximal
C     R_NC_CDOM  :: [mmol N / mmol C]   CDOM N:C ratio
C     R_FeC_CDOM :: [mmol Fe / mmol C]  CDOM Fe:C ratio
C     R_PC_CDOM  :: [mmol P / mmol C]   CDOM P:C ratio
C     R_NP_CDOM  :: [mmol N / mmol P]   CDOM N:P ratio
C     R_FeP_CDOM :: [mmol Fe / mmol P]  CDOM Fe:P ratio
C     R_CP_CDOM  :: [mmol C / mmol P]   CDOM C:P ratio
C     CDOMcoeff  :: [m2 / mmol C]       C-specific absorption coefficient of CDOM
C                                       (with #define DARWIN_CDOM_UNITS_CARBON)
C     CDOMcoeff  :: [m2 / mmol P]       P-specific absorption coefficient of CDOM
C                                       (with #undef DARWIN_CDOM_UNITS_CARBON)
      COMMON /DARWIN_CDOM_PARAMS_r/
     &    fracCDOM,
     &    CDOMdegrd,
     &    CDOMbleach,
     &    PARCDOM,
# ifdef DARWIN_CDOM_UNITS_CARBON
     &    R_NC_CDOM,
     &    R_FeC_CDOM,
     &    R_PC_CDOM,
# else
     &    R_NP_CDOM,
     &    R_FeP_CDOM,
     &    R_CP_CDOM,
# endif
     &    CDOMcoeff
      _RL fracCDOM
      _RL CDOMdegrd
      _RL CDOMbleach
      _RL PARCDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
      _RL R_NC_CDOM
      _RL R_FeC_CDOM
      _RL R_PC_CDOM
# else
      _RL R_NP_CDOM
      _RL R_FeP_CDOM
      _RL R_CP_CDOM
# endif
      _RL CDOMcoeff
#endif

C--   COMMON /DARWIN_DEPENDENT_PARAMS_i/
C     laCDOM     :: index of reference waveband for CDOM absorption spectrum
C     kMinFeSed  :: minimum level index for iron sedimentation
C     kMaxFeSed  :: maximum level index for iron sedimentation
C     kMinFeVent :: minimum level index for hydrothermal vents
      COMMON /DARWIN_DEPENDENT_PARAMS_i/
     &    darwin_dependent_i_dummy,
#ifdef ALLOW_RADTRANS
#ifdef DARWIN_ALLOW_CDOM
#else
     &    laCDOM,
#endif
#endif
     &    kMinFeSed,
     &    kMaxFeSed,
     &    kMinFeVent
      INTEGER darwin_dependent_i_dummy
#ifdef ALLOW_RADTRANS
#ifdef DARWIN_ALLOW_CDOM
#else
      INTEGER laCDOM
#endif
#endif
      INTEGER kMinFeSed
      INTEGER kMaxFeSed
      INTEGER kMinFeVent


#endif /* ALLOW_DARWIN */

