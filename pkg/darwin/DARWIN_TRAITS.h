#ifdef ALLOW_DARWIN

CBOP
C     !ROUTINE: DARWIN_TRAITS.h
C     !INTERFACE:
C #include DARWIN_TRAITS.h

C     !DESCRIPTION:
C Contains run-time parameters for the darwin package
C the parameters in this file are traits
C
C Requires: DARWIN_SIZE.h

C--   COMMON /DARWIN_TRAITS_i/ Per-plankton traits (generated, maybe overwritten by data.traits)
C     isPhoto   :: 1: does photosynthesis, 0: not
C     bactType  :: 1: particle associated, 2: free living bacteria, 0: not bacteria
C     isAerobic :: 1: is aerobic bacteria (also set bactType), 0: not
C     isDenit   :: 1: is dentrifying bacteria (also set (bactType), 0: not
C     hasSi     :: 1: uses silica (Diatom), 0: not
C     hasPIC    :: 1: calcifying, 0: set R_PICPOC to zero
C     diazo     :: 1: use molecular instead of mineral nitrogen, 0: not
C     useNH4    :: 1: can use ammonia, 0: not
C     useNO2    :: 1: can use nitrite, 0: not
C     useNO3    :: 1: can use nitrate, 0: not
C     combNO    :: 1: combined nitrite/nitrate limitation, 0: not
C     isPrey    :: 1: can be grazed, 0: not
C     isPred    :: 1: can graze, 0: not
C     tempMort  :: 1: mortality is temperature dependent, 0: turn dependence off
C     tempMort2 :: 1: quadratic mortality is temperature dependent, 0: turn dependence off
C     tempGraz  :: 1: grazing is temperature dependent, 0: turn dependence off
      COMMON /DARWIN_TRAITS_i/
     &    isPhoto,
     &    bactType,
     &    isAerobic,
     &    isDenit,
     &    hasSi,
     &    hasPIC,
     &    diazo,
     &    useNH4,
     &    useNO2,
     &    useNO3,
     &    combNO,
     &    isPrey,
     &    isPred,
     &    tempMort,
     &    tempMort2,
     &    tempGraz
      INTEGER isPhoto(nplank)
      INTEGER bactType(nplank)
      INTEGER isAerobic(nplank)
      INTEGER isDenit(nplank)
      INTEGER hasSi(nplank)
      INTEGER hasPIC(nplank)
      INTEGER diazo(nplank)
      INTEGER useNH4(nplank)
      INTEGER useNO2(nplank)
      INTEGER useNO3(nplank)
      INTEGER combNO(nplank)
      INTEGER isPrey(nplank)
      INTEGER isPred(nplank)
      INTEGER tempMort(nplank)
      INTEGER tempMort2(nplank)
      INTEGER tempGraz(nplank)

C--   COMMON /DARWIN_TRAITS_r/ Per-plankton traits (generated, maybe overwritten by data.traits)
C     Xmin               :: [mmol C m^-3]              minimum abundance for mortality, respiration and exudation
C     amminhib           :: [(mmol N m^-3)^-1]         coefficient for NH4 inhibition of NO uptake
C     acclimtimescl      :: [s^-1]                     rate of chlorophyll acclimation
C
C     mort               :: [s^-1]                     linear mortality rate
C     mort2              :: [(mmol C m^-3)^-1 s^-1]    quadratic mortality coefficient
C     ExportFracMort     :: []                         fraction of linear mortality to POM
C     ExportFracMort2    :: []                         fraction of quadratic mortality to POM
C     ExportFracExude    :: []                         fraction of exudation to POM
C     FracExudeC         :: []                         fraction of excess C exuded
C
C- temperature dependence:
C     phytoTempCoeff     :: []                         see :numref:`pkg_darwin_temperature_params`
C     phytoTempExp1      :: [exp(1/degrees C)]         see :numref:`pkg_darwin_temperature_params`
C     phytoTempAe        :: [1/degrees C]              see :numref:`pkg_darwin_temperature_params`
C     phytoTempExp2      :: []                         see :numref:`pkg_darwin_temperature_params`
C     phytoTempOptimum   :: [degrees C]                see :numref:`pkg_darwin_temperature_params`
C     phytoDecayPower    :: []                         see :numref:`pkg_darwin_temperature_params`
C     hetTempAe          :: [1/degrees C]              see :numref:`pkg_darwin_temperature_params`
C     hetTempExp2        :: []                         see :numref:`pkg_darwin_temperature_params`
C     hetTempOptimum     :: [degrees C]                see :numref:`pkg_darwin_temperature_params`
C     hetDecayPower      :: []                         see :numref:`pkg_darwin_temperature_params`
C     grazTempAe         :: [1/degrees C]              see :numref:`pkg_darwin_temperature_params`
C     grazTempExp2       :: []                         see :numref:`pkg_darwin_temperature_params`
C     grazTempOptimum    :: [degrees C]                see :numref:`pkg_darwin_temperature_params`
C     grazDecayPower     :: []                         see :numref:`pkg_darwin_temperature_params`
C
C     R_NC               :: [mmol N (mmol C)^-1]       nitrogen-carbon ratio (not used with DARWIN_ALLOW_NQUOTA)
C     R_PC               :: [mmol P (mmol C)^-1]       phosphorus-carbon ratio (not used with DARWIN_ALLOW_PQUOTA)
C     R_SiC              :: [mmol Si (mmol C)^-1]      silica-carbon ratio (not used with DARWIN_ALLOW_SIQUOTA)
C     R_FeC              :: [mmol Fe (mmol C)^-1]      iron-carbon ratio (not used with DARWIN_ALLOW_FEQUOTA)
C     R_ChlC             :: [mg Chl (mmol C)^-1]       chlorophyll-carbon ratio (not used with DARWIN_ALLOW_CHLQUOTA)
C     R_PICPOC           :: [mmol PIC (mmol POC)^-1]   inorganic-organic carbon ratio
C
C     biosink            :: [m s^-1]                   sinking velocity (positive downwards)
C     bioswim            :: [m s^-1]                   upward swimming velocity (positive upwards)
C     bioswimDVM         :: [m s^-1]                   swimming speed for diel vertically migrating plankton (pos. upwards)
C
C     respRate           :: [s^-1]                     respiration rate
C     PCmax              :: [s^-1]                     maximum carbon-specific growth rate
C
C     Qnmax              :: [mmol N (mmol C)^-1]       maximum nitrogen quota (only with DARWIN_ALLOW_NQUOTA)
C     Qnmin              :: [mmol N (mmol C)^-1]       minimum nitrogen quota (only with DARWIN_ALLOW_NQUOTA)
C     Qpmax              :: [mmol P (mmol C)^-1]       maximum phosphorus quota (only with DARWIN_ALLOW_PQUOTA)
C     Qpmin              :: [mmol P (mmol C)^-1]       minimum phosphorus quota (only with DARWIN_ALLOW_PQUOTA)
C     Qsimax             :: [mmol Si (mmol C)^-1]      maximum silica quota (only with DARWIN_ALLOW_SIQUOTA)
C     Qsimin             :: [mmol Si (mmol C)^-1]      minimum silica quota (only with DARWIN_ALLOW_SIQUOTA)
C     Qfemax             :: [mmol Fe (mmol C)^-1]      maximum iron quota (only with DARWIN_ALLOW_FEQUOTA)
C     Qfemin             :: [mmol Fe (mmol C)^-1]      minimum iron quota (only with DARWIN_ALLOW_FEQUOTA)
C
C     VmaxNH4            :: [mmol N (mmol C)^-1 s^-1]  maximum ammonia uptake rate (only with DARWIN_ALLOW_NQUOTA)
C     VmaxNO2            :: [mmol N (mmol C)^-1 s^-1]  maximum nitrite uptake rate (only with DARWIN_ALLOW_NQUOTA)
C     VmaxNO3            :: [mmol N (mmol C)^-1 s^-1]  maximum nitrate uptake rate (only with DARWIN_ALLOW_NQUOTA)
C     VmaxN              :: [mmol N (mmol C)^-1 s^-1]  maximum nitrogen uptake rate for diazotrophs (only with DARWIN_ALLOW_NQUOTA)
C                        ::                            has to be >= vmaxNO3 + vmaxNO2 + vmaxNH4
C     VmaxPO4            :: [mmol P (mmol C)^-1 s^-1]  maximum phosphate uptake rate (only with DARWIN_ALLOW_PQUOTA)
C     VmaxSiO2           :: [mmol Si (mmol C)^-1 s^-1] maximum silica uptake rate (only with DARWIN_ALLOW_SIQUOTA)
C     VmaxFeT            :: [mmol Fe (mmol C)^-1 s^-1] maximum iron uptake rate (only with DARWIN_ALLOW_FEQUOTA)
C
C     ksatNH4            :: [mmol N m^-3]              half-saturation conc. for ammonia uptake/limitation
C     ksatNO2            :: [mmol N m^-3]              half-saturation conc. for nitrite uptake/limitation
C     ksatNO3            :: [mmol N m^-3]              half-saturation conc. for nitrate uptake/limitation
C     ksatPO4            :: [mmol P m^-3]              half-saturation conc. for phosphate uptake/limitation
C     ksatSiO2           :: [mmol Si m^-3]             half-saturation conc. for silica uptake/limitation
C     ksatFeT            :: [mmol Fe m^-3]             half-saturation conc. for iron uptake/limitation
C
C     kexcc              :: [s^-1]                 exudation rate for carbon
C     kexcn              :: [s^-1]                 exudation rate for nitrogen
C     kexcp              :: [s^-1]                 exudation rate for phosphorus
C     kexcsi             :: [s^-1]                 exudation rate for silica
C     kexcfe             :: [s^-1]                 exudation rate for iron
C
C- Geider
C     inhibGeider        :: []                     photo-inhibition coefficient for Geider growth
C- not Geider
C     ksatPAR            :: [(uEin m^-2 s^-1)^-1]  saturation coefficient for PAR (w/o GEIDER)
C     kinhPAR            :: [(uEin m^-2 s^-1)^-1]  inhibition coefficient for PAR (w/o GEIDER)
C- always defined
C     mQyield            :: [mmol C (uEin)^-1]     maximum quantum yield
C     chl2cmax           :: [mg Chl (mmol C)^-1]   maximum Chlorophyll-carbon ratio
C
C- Grazing
C     grazemax           :: [s^-1]          maximum grazing rate
C     kgrazesat          :: [mmol C m^-3]   grazing half-saturation concentration
C     palat              :: []              palatability matrix
C     asseff             :: []              assimilation efficiency matrix
C     ExportFracPreyPred :: []              fraction of unassimilated prey becoming particulate organic matter
C
C- Bacteria
C     yield              :: []              bacterial growth yield for all organic matter
C     yieldO2            :: []              bacterial growth yield for oxygen
C     yieldNO3           :: []              bacterial growth yield for nitrate
C     ksatPON            :: [mmol N m^-3]   half-saturation of PON for bacterial growth
C     ksatPOC            :: [mmol C m^-3]   half-saturation of POC for bacterial growth
C     ksatPOP            :: [mmol P m^-3]   half-saturation of POP for bacterial growth
C     ksatPOFe           :: [mmol Fe m^-3]  half-saturation of POFe for bacterial growth
C     ksatDON            :: [mmol N m^-3]   half-saturation of DON for bacterial growth
C     ksatDOC            :: [mmol C m^-3]   half-saturation of DOC for bacterial growth
C     ksatDOP            :: [mmol P m^-3]   half-saturation of DOP for bacterial growth
C     ksatDOFe           :: [mmol Fe m^-3]  half-saturation of DOFe for bacterial growth
C- PAR preference
C     PARpref            :: [uEin m^-2 s^-1] preferred PAR isolume for determining DVM
C- Light-mediated mortality for DVM
C     mortmaxDVM         :: [s^-1]           maximum mortality rate related to PAR for DVM
C     ksatDVM            :: [mmol C m^-3]    half saturation for DVM mortality
C     ksatPARDVM         :: [uEin m^-2 s^-1] half sat for light limitation for DVM
C     fracPARmort        :: []               fraction of mortality from light-dependent mortality
C     ExportFracDVM      :: []               fraction of light-dep mortality from DVM to POM
C
C- MACROMOLECULAR_GROWTH parameters
C     Y_CP_Plip          :: [molC molP^-1]   C/P molar ratio of thylacoid membrane
C     Y_CN_protein       :: [molC molN^-1]   C/N molar ratio in protein
C     Y_NC_chl           :: [molN molC^-1]   N/C molar ratio in chlorophyll
C     Y_CN_cyano         :: [molC molN^-1]   C/N molar ratio of cyanophycin
C     Y_PN_nucacid       :: [molP molN^-1]   P/N molar ratio of RNA
C     Y_CN_DNA           :: [molC molN^-1]   C/N molar ratio of DNA
C     Y_CN_RNA           :: [molC molN^-1]   C/N molar ratio of RNA
C     Y_THY_P            :: [(molP)/(molC in chl)^-1] the stoichiometric ratio for cell phosphorus in thylakoid membrane to chlorophyll
C     Y_FeN_photo        :: [molFe mol N^-1] Fe/N ratio in photosystem iron
C     ECo2Prod           :: [dimensionless]  CO2 production ratio
C     maintConsum        :: [s^-1]           maintenance carbohydrate consumption
C     VI_max             :: [molC (molC in Chl)^-1 s^-1] carbon fixing rate
C     A_I                :: [umol^-1 m2 s]   coefficient characterizing the absorption cross section
C     QC_other           :: [molC molC^-1]   essential carbon (lipid membrane, etc.)
C     QC_pro_other       :: [molC molC^-1]
C     QP_other           :: [molP molC^-1]   constant part of phosphorus
C     QP_RNA_min         :: [molP molC^-1]
C     QC_DNA             :: [molC molC^-1]   constant part of DNA in carbon
C     QN_pro_other       :: [molN molC^-1]
C     QN_RNA_min         :: [molN molC^-1]   constant part of RNA in nitrogen
C     QC_RNA_min         :: [molN molC^-1]   constant part of RNA in carbon
C     QN_DNA             :: [molN molC^-1]   DNA in nitrogen
C     QP_DNA             :: [molP molC^-1]   DNA in phosphorous
C     QN_sto_max         :: [molN molC^-1]   maximum nitrogen storage
C     Qp_max             :: [molP molC^-1]   maximum phosphorus quota
C     Qfe_max            :: [molFe molC^-1]  maximum iron quota
C     A_pho              :: [(molC)/(molC in chl)^-1] A constant of proportionalty
C     A_bio              :: [molC molC^-1 s] constant for variable part of biosynthesis protein
C     AP_RNA             :: [molP molC^-1 s] constant for Variable part of RNA
C     AN_RNA             :: [molN molN^-1 s] constant for Variable part of RNA
C     A_thy              :: [molC (molC in chl)^-1]
C     Sf                 :: [unitless]       enhancement of photosynthesis due to size
C     QC_const           :: [molC molC^-1]   constant portion of the cell
C     VI_min             :: [molC (molC in Chl)^-1 s^-1] minimum photosynthesis rate
C     QC_chlMax          :: [molC molC^-1]   maximum chlorophyll concentration at minimum light
C     QnNoChl            :: [molN molC^-1]   minimum QN at zero growth rate
C     QpNoChl            :: [molP molC^-1]   minimum QP at zero growth rate
C     QfeNoChl           :: [molFe molC^-1]  minimum QFe at zero growth rate
      COMMON /DARWIN_TRAITS_r/
     &    Xmin,
     &    amminhib,
     &    acclimtimescl,
     &    mort,
     &    mort2,
     &    ExportFracMort,
     &    ExportFracMort2,
     &    ExportFracExude,
     &    FracExudeC,
     &    phytoTempCoeff,
     &    phytoTempExp1,
     &    phytoTempAe,
     &    phytoTempExp2,
     &    phytoTempOptimum,
     &    phytoDecayPower,
     &    hetTempAe,
     &    hetTempExp2,
     &    hetTempOptimum,
     &    hetDecayPower,
     &    grazTempAe,
     &    grazTempExp2,
     &    grazTempOptimum,
     &    grazDecayPower,
     &    R_NC,
     &    R_PC,
     &    R_SiC,
     &    R_FeC,
     &    R_ChlC,
     &    R_PICPOC,
     &    biosink,
     &    bioswim,
     &    bioswimDVM,
     &    respRate,
     &    PCmax,
     &    Qnmax,
     &    Qnmin,
     &    Qpmax,
     &    Qpmin,
     &    Qsimax,
     &    Qsimin,
     &    Qfemax,
     &    Qfemin,
     &    VmaxNH4,
     &    VmaxNO2,
     &    VmaxNO3,
     &    VmaxN,
     &    VmaxPO4,
     &    VmaxSiO2,
     &    VmaxFeT,
     &    ksatNH4,
     &    ksatNO2,
     &    ksatNO3,
     &    ksatPO4,
     &    ksatSiO2,
     &    ksatFeT,
     &    hillnumDIN,
     &    hillnumPO4,
     &    hillnumFeT,
     &    hillnumSiO2,
     &    kexcc,
     &    kexcn,
     &    kexcp,
     &    kexcsi,
     &    kexcfe,
#ifdef DARWIN_ALLOW_GEIDER
     &    inhibGeider,
#else
     &    ksatPAR,
     &    kinhPAR,
#endif
     &    mQyield,
     &    chl2cmax,
     &    grazemax,
     &    kgrazesat,
     &    palat,
     &    asseff,
     &    ExportFracPreyPred,
     &    yield,
     &    yieldO2,
     &    yieldNO3,
     &    ksatPON,
     &    ksatPOC,
     &    ksatPOP,
     &    ksatPOFe,
     &    ksatDON,
     &    ksatDOC,
     &    ksatDOP,
     &    ksatDOFe,
     &    PARpref,
     &    mortmaxDVM,
     &    ksatDVM,
     &    ksatPARDVM,
     &    fracPARmort,
     &    ExportFracDVM
#ifdef DARWIN_MACROMOLECULAR_GROWTH
     &   ,Y_CN_protein,
     &    Y_CP_Plip,
     &    Y_NC_chl,
     &    Y_CN_cyano,
     &    Y_PN_nucacid,
     &    Y_CN_DNA,
     &    Y_CN_RNA,
     &    Y_THY_P,
     &    Y_FeN_photo,
     &    ECo2Prod,
     &    maintConsum,
     &    VI_max,
     &    A_I,
     &    QC_other,
     &    QC_pro_other,
     &    QP_other,
     &    QP_RNA_min,
     &    QC_DNA,
     &    QN_pro_other,
     &    QN_RNA_min,
     &    QC_RNA_min,
     &    QN_DNA,
     &    QP_DNA,
     &    QN_sto_max,
     &    Qp_max,
     &    Qfe_max,
     &    A_pho,
     &    A_bio,
     &    AP_RNA,
     &    AN_RNA,
     &    A_thy,
     &    Sf,
     &    VI_min,
     &    QC_chlMax,
     &    QnNoChl,
     &    QpNoChl,
     &    QfeNoChl,
     &    QC_const
#endif
      _RL Xmin(nplank)
      _RL amminhib(nplank)
      _RL acclimtimescl(nplank)
      _RL mort(nplank)
      _RL mort2(nplank)
      _RL ExportFracMort(nplank)
      _RL ExportFracMort2(nplank)
      _RL ExportFracExude(nplank)
      _RL FracExudeC(nplank)
      _RL phytoTempCoeff(nplank)
      _RL phytoTempExp1(nplank)
      _RL phytoTempAe(nplank)
      _RL phytoTempExp2(nplank)
      _RL phytoTempOptimum(nplank)
      _RL phytoDecayPower(nplank)
      _RL hetTempAe(nplank)
      _RL hetTempExp2(nplank)
      _RL hetTempOptimum(nplank)
      _RL hetDecayPower(nplank)
      _RL grazTempAe(nplank)
      _RL grazTempExp2(nplank)
      _RL grazTempOptimum(nplank)
      _RL grazDecayPower(nplank)
      _RL R_NC(nplank)
      _RL R_PC(nplank)
      _RL R_SiC(nplank)
      _RL R_FeC(nplank)
      _RL R_ChlC(nplank)
      _RL R_PICPOC(nplank)
      _RL biosink(nplank)
      _RL bioswim(nplank)
      _RL bioswimDVM(nplank)
      _RL respRate(nplank)
      _RL PCmax(nplank)
      _RL Qnmax(nplank)
      _RL Qnmin(nplank)
      _RL Qpmax(nplank)
      _RL Qpmin(nplank)
      _RL Qsimax(nplank)
      _RL Qsimin(nplank)
      _RL Qfemax(nplank)
      _RL Qfemin(nplank)
      _RL VmaxNH4(nplank)
      _RL VmaxNO2(nplank)
      _RL VmaxNO3(nplank)
      _RL VmaxN(nplank)
      _RL VmaxPO4(nplank)
      _RL VmaxSiO2(nplank)
      _RL VmaxFeT(nplank)
      _RL ksatNH4(nplank)
      _RL ksatNO2(nplank)
      _RL ksatNO3(nplank)
      _RL ksatPO4(nplank)
      _RL ksatSiO2(nplank)
      _RL ksatFeT(nplank)
      _RL hillnumDIN(nplank)
      _RL hillnumPO4(nplank)
      _RL hillnumFeT(nplank)
      _RL hillnumSiO2(nplank)
      _RL kexcc(nplank)
      _RL kexcn(nplank)
      _RL kexcp(nplank)
      _RL kexcsi(nplank)
      _RL kexcfe(nplank)
#ifdef DARWIN_ALLOW_GEIDER
      _RL inhibGeider(nplank)
#else
      _RL ksatPAR(nplank)
      _RL kinhPAR(nplank)
#endif
      _RL mQyield(nplank)
      _RL chl2cmax(nplank)
      _RL grazemax(nplank)
      _RL kgrazesat(nplank)
      _RL palat(nplank,nplank)
      _RL asseff(nplank,nplank)
      _RL ExportFracPreyPred(nplank,nplank)
      _RL yield(nplank)
      _RL yieldO2(nplank)
      _RL yieldNO3(nplank)
      _RL ksatPON(nplank)
      _RL ksatPOC(nplank)
      _RL ksatPOP(nplank)
      _RL ksatPOFe(nplank)
      _RL ksatDON(nplank)
      _RL ksatDOC(nplank)
      _RL ksatDOP(nplank)
      _RL ksatDOFe(nplank)
      _RL PARpref(nplank)
      _RL mortmaxDVM(nplank)
      _RL ksatDVM(nplank)
      _RL ksatPARDVM(nplank)
      _RL fracPARmort(nplank)
      _RL ExportFracDVM(nplank)
#ifdef DARWIN_MACROMOLECULAR_GROWTH
      _RL Y_CN_protein(nplank)
      _RL Y_CP_Plip(nplank)
      _RL Y_NC_chl(nplank)
      _RL Y_CN_cyano(nplank)
      _RL Y_PN_nucacid(nplank)
      _RL Y_CN_DNA(nplank)
      _RL Y_CN_RNA(nplank)
      _RL Y_THY_P(nplank)
      _RL Y_FeN_photo(nplank)
      _RL ECo2Prod(nplank)
      _RL maintConsum(nplank)
      _RL VI_max(nplank)
      _RL A_I(nplank)
      _RL QC_other(nplank)
      _RL QC_pro_other(nplank)
      _RL QP_other(nplank)
      _RL QP_RNA_min(nplank)
      _RL QC_DNA(nplank)
      _RL QN_pro_other(nplank)
      _RL QN_RNA_min(nplank)
      _RL QC_RNA_min(nplank)
      _RL QN_DNA(nplank)
      _RL QP_DNA(nplank)
      _RL QN_sto_max(nplank)
      _RL Qp_max(nplank)
      _RL Qfe_max(nplank)
      _RL A_pho(nplank)
      _RL A_bio(nplank)
      _RL AP_RNA(nplank)
      _RL AN_RNA(nplank)
      _RL A_thy(nplank)
      _RL Sf(nplank)
      _RL VI_min(nplank)
      _RL QC_chlMax(nplank)
      _RL QnNoChl(nplank)
      _RL QpNoChl(nplank)
      _RL QfeNoChl(nplank)
      _RL QC_const(nplank)
#endif

C--   COMMON /DARWIN_DEPENDENT_TRAITS_i/ Dependent and constant (not read-in) parameters
C     group  :: which group this type belongs to
C     igroup :: index within group
C
C- Radtrans only:
C     aptype :: optical type (for absorption/scattering spectra)
      COMMON /DARWIN_DEPENDENT_TRAITS_i/
#ifdef ALLOW_RADTRANS
     &    aptype,
#endif
     &    group,
     &    igroup
#ifdef ALLOW_RADTRANS
      INTEGER aptype(nplank)
#endif
      INTEGER group(nplank)
      INTEGER igroup(nplank)

C--   COMMON /DARWIN_DEPENDENT_TRAITS_r/ Dependent and constant (not read-in) parameters
C     normI            :: []                    normalization factor for non-Geider light curve
C     biovol           :: [um^3]                volume
C     qcarbon          :: [mmol C/cell]         cellular carbon content
C     biovol_bygroup   :: [um^3]                volume of types in each group
C     chl2cmin         :: [mg Chl (mmol C)^-1]  minimum Chl:C ratio (function of chl2cmax and alpha_mean)
C     alpha_mean       :: [mmol C s-1 (uEin m^-2 s^-1)^-1 (mg Chl)^-1]  mean initial slope of light curve (over wavebands)
      COMMON /DARWIN_DEPENDENT_TRAITS_r/
#ifndef DARWIN_ALLOW_GEIDER
     &    normI,
#endif
     &    biovol,
     &    qcarbon,
     &    biovol_bygroup,
     &    alpha_mean,
     &    chl2cmin
#ifndef DARWIN_ALLOW_GEIDER
      _RL normI(nplank)
#endif
      _RL biovol(nplank)
      _RL qcarbon(nplank)
      _RL biovol_bygroup(nplank,ngroup)
      _RL alpha_mean(nplank)
      _RL chl2cmin(nplank)


#endif /* ALLOW_DARWIN */

