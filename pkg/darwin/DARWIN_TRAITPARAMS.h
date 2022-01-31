#ifdef ALLOW_DARWIN

CBOP
C     !ROUTINE: DARWIN_TRAITPARAMS.h
C     !INTERFACE:
C #include DARWIN_TRAITPARAMS.h

C     !DESCRIPTION:
C Contains run-time parameters for the darwin package
C the parameters in this file are used to generate traits
C
C Requires: DARWIN_SIZE.h

C--   COMMON /DARWIN_RANDOM_PARAMS_l/ For darwin_allometric_random
C     oldTwoGrazers :: old defaults for 2 grazers
      COMMON /DARWIN_RANDOM_PARAMS_l/
     &    oldTwoGrazers
      LOGICAL oldTwoGrazers

C--   COMMON /DARWIN_RANDOM_PARAMS_r/ For darwin_allometric_random
      COMMON /DARWIN_RANDOM_PARAMS_r/
     &    phymin,
     &    Smallgrow,
     &    Biggrow,
     &    Smallgrowrange,
     &    Biggrowrange,
     &    diaz_growfac,
     &    cocco_growfac,
     &    diatom_growfac,
     &    Smallmort,
     &    Bigmort,
     &    Smallmortrange,
     &    Bigmortrange,
     &    Smallexport,
     &    Bigexport,
     &    tempcoeff1,
     &    tempcoeff2_small,
     &    tempcoeff2_big,
     &    tempcoeff3,
     &    tempmax,
     &    temprange,
     &    tempdecay,
     &    val_R_NC,
     &    val_R_NC_diaz,
     &    val_R_PC,
     &    val_R_SiC_diatom,
     &    val_R_FeC,
     &    val_R_FeC_diaz,
     &    val_R_PICPOC,
     &    val_R_ChlC,
     &    val_R_NC_zoo,
     &    val_R_PC_zoo,
     &    val_R_SiC_zoo,
     &    val_R_FeC_zoo,
     &    val_R_PICPOC_zoo,
     &    val_R_ChlC_zoo,
     &    SmallSink,
     &    BigSink,
     &    SmallPsat,
     &    BigPsat,
     &    ProcPsat,
     &    UniDzPsat,
     &    CoccoPsat,
     &    SmallPsatrange,
     &    BigPsatrange,
     &    ProcPsatrange,
     &    UniDzPsatrange,
     &    CoccoPsatrange,
     &    ksatNH4fac,
     &    ksatNO2fac,
     &    val_amminhib,
     &    val_ksatsio2,
     &    smallksatpar,
     &    smallksatparstd,
     &    smallkinhpar,
     &    smallkinhparstd,
     &    Bigksatpar,
     &    Bigksatparstd,
     &    Bigkinhpar,
     &    Bigkinhparstd,
     &    LLProkinhpar,
     &    Coccokinhpar,
     &    inhibcoef_geid_val,
     &    smallmQyield,
     &    smallmQyieldrange,
     &    BigmQyield,
     &    BigmQyieldrange,
     &    smallchl2cmax,
     &    smallchl2cmaxrange,
     &    Bigchl2cmax,
     &    Bigchl2cmaxrange,
     &    val_acclimtimescl,
     &    GrazeFast,
     &    GrazeSlow,
     &    ZooexfacSmall,
     &    ZooexfacBig,
     &    ZoomortSmall,
     &    ZoomortBig,
     &    ZoomortSmall2,
     &    ZoomortBig2,
     &    ExGrazfracbig,
     &    ExGrazfracsmall,
     &    palathi,
     &    palatlo,
     &    diatomgraz,
     &    coccograz,
     &    olargegraz,
     &    GrazeEfflow,
     &    GrazeEffmod,
     &    GrazeEffhi,
     &    GrazeRate,
     &    ExGrazfrac,
     &    val_palat,
     &    val_ass_eff,
     &    kgrazesat_val,
     &    Zoomort,
     &    Zoomort2,
     &    Zooexfac,
     &    ZooDM
      _RL phymin
      _RL Smallgrow
      _RL Biggrow
      _RL Smallgrowrange
      _RL Biggrowrange
      _RL diaz_growfac
      _RL cocco_growfac
      _RL diatom_growfac
      _RL Smallmort
      _RL Bigmort
      _RL Smallmortrange
      _RL Bigmortrange
      _RL Smallexport
      _RL Bigexport
      _RL tempcoeff1
      _RL tempcoeff2_small
      _RL tempcoeff2_big
      _RL tempcoeff3
      _RL tempmax
      _RL temprange
      _RL tempdecay
      _RL val_R_NC
      _RL val_R_NC_diaz
      _RL val_R_PC
      _RL val_R_SiC_diatom
      _RL val_R_FeC
      _RL val_R_FeC_diaz
      _RL val_R_PICPOC
      _RL val_R_ChlC
      _RL val_R_NC_zoo
      _RL val_R_PC_zoo
      _RL val_R_SiC_zoo
      _RL val_R_FeC_zoo
      _RL val_R_PICPOC_zoo
      _RL val_R_ChlC_zoo
      _RL SmallSink
      _RL BigSink
      _RL SmallPsat
      _RL BigPsat
      _RL ProcPsat
      _RL UniDzPsat
      _RL CoccoPsat
      _RL SmallPsatrange
      _RL BigPsatrange
      _RL ProcPsatrange
      _RL UniDzPsatrange
      _RL CoccoPsatrange
      _RL ksatNH4fac
      _RL ksatNO2fac
      _RL val_amminhib
      _RL val_ksatsio2
      _RL smallksatpar
      _RL smallksatparstd
      _RL smallkinhpar
      _RL smallkinhparstd
      _RL Bigksatpar
      _RL Bigksatparstd
      _RL Bigkinhpar
      _RL Bigkinhparstd
      _RL LLProkinhpar
      _RL Coccokinhpar
      _RL inhibcoef_geid_val
      _RL smallmQyield
      _RL smallmQyieldrange
      _RL BigmQyield
      _RL BigmQyieldrange
      _RL smallchl2cmax
      _RL smallchl2cmaxrange
      _RL Bigchl2cmax
      _RL Bigchl2cmaxrange
      _RL val_acclimtimescl
      _RL GrazeFast
      _RL GrazeSlow
      _RL ZooexfacSmall
      _RL ZooexfacBig
      _RL ZoomortSmall
      _RL ZoomortBig
      _RL ZoomortSmall2
      _RL ZoomortBig2
      _RL ExGrazfracbig
      _RL ExGrazfracsmall
      _RL palathi
      _RL palatlo
      _RL diatomgraz
      _RL coccograz
      _RL olargegraz
      _RL GrazeEfflow
      _RL GrazeEffmod
      _RL GrazeEffhi
      _RL GrazeRate
      _RL ExGrazfrac
      _RL val_palat
      _RL val_ass_eff
      _RL kgrazesat_val
      _RL Zoomort
      _RL Zoomort2
      _RL Zooexfac
      _RL ZooDM

C--   COMMON /DARWIN_TRAIT_PARAMS_l/ Used in darwin_generate_allometric
C     darwin_sort_biovol    :: whether to sort type by volume rather than group first
C     darwin_effective_ksat :: compute effective half-saturation for non-quota elements
      COMMON /DARWIN_TRAIT_PARAMS_l/
     &    darwin_sort_biovol,
     &    darwin_effective_ksat
      LOGICAL darwin_sort_biovol
      LOGICAL darwin_effective_ksat

C--   COMMON /DARWIN_TRAIT_PARAMS_c/ Used in darwin_generate_allometric
C     grp_names :: names of functional groups
      COMMON /DARWIN_TRAIT_PARAMS_c/
     &    grp_names
      CHARACTER*80 grp_names(nGroup)

C--   COMMON /DARWIN_TRAIT_PARAMS_i/ Used in darwin_generate_allometric
C     darwin_select_kn_allom :: 1: use Ward et al formulation, 2: use Follett et al
C     logvol0ind             :: first index in volume list used by this group
C     grp_nplank             :: number of plankton types in this group
C     grp_photo              :: -> isPhoto
C     grp_bacttype           :: -> bactType
C     grp_aerobic            :: -> isAerobic
C     grp_denit              :: -> isDenit
C     grp_pred               :: -> isPred
C     grp_prey               :: -> isPrey
C     grp_hasSi              :: -> hasSi
C     grp_hasPIC             :: -> hasPIC
C     grp_diazo              :: -> diazo
C     grp_useNH4             :: -> useNH4
C     grp_useNO2             :: -> useNO2
C     grp_useNO3             :: -> useNO3
C     grp_combNO             :: -> combNO
C     grp_aptype             :: -> aptype
C     grp_tempMort           :: -> tempMort
C     grp_tempMort2          :: -> tempMort2
C     grp_tempGraz           :: -> tempGraz
      COMMON /DARWIN_TRAIT_PARAMS_i/
     &    darwin_select_kn_allom,
     &    logvol0ind,
     &    grp_nplank,
     &    grp_photo,
     &    grp_bacttype,
     &    grp_aerobic,
     &    grp_denit,
     &    grp_pred,
     &    grp_prey,
     &    grp_hasSi,
     &    grp_hasPIC,
     &    grp_diazo,
     &    grp_useNH4,
     &    grp_useNO2,
     &    grp_useNO3,
     &    grp_combNO,
     &    grp_aptype,
     &    grp_tempMort,
     &    grp_tempMort2,
     &    grp_tempGraz
      INTEGER darwin_select_kn_allom
      INTEGER logvol0ind(nGroup)
      INTEGER grp_nplank(nGroup)
      INTEGER grp_photo(nGroup)
      INTEGER grp_bacttype(nGroup)
      INTEGER grp_aerobic(nGroup)
      INTEGER grp_denit(nGroup)
      INTEGER grp_pred(nGroup)
      INTEGER grp_prey(nGroup)
      INTEGER grp_hasSi(nGroup)
      INTEGER grp_hasPIC(nGroup)
      INTEGER grp_diazo(nGroup)
      INTEGER grp_useNH4(nGroup)
      INTEGER grp_useNO2(nGroup)
      INTEGER grp_useNO3(nGroup)
      INTEGER grp_combNO(nGroup)
      INTEGER grp_aptype(nGroup)
      INTEGER grp_tempMort(nGroup)
      INTEGER grp_tempMort2(nGroup)
      INTEGER grp_tempGraz(nGroup)

C--   COMMON /DARWIN_TRAIT_PARAMS_r/ Used in darwin_generate_allometric
C     logvolbase             :: []    log-10 base for list of volumes
C     logvolinc              :: []    log-10 increment for list of volumes
C     biovol0                :: [um3] volume of smallest type in group
C     biovolfac              :: []    factor by which each type is bigger than previous
C     grp_logvolind          :: []    indices into volume list for type in this group
C     grp_biovol             :: [um3] volumes of types in each group
C
C- Allometric parameters
C     a_* b_* :: param = a_param*V^b_param
C
C- Predator prey preference distribution parameters
C     a_pp_sig               :: standard deviation of predator-prey volume ratio for palatability
C     a_pp_opt               :: a for optimal predator-prey volume ratio
C     b_pp_opt               :: b for optimal predator-prey volume ratio
C     palat_min              :: min non-zero palatability, smaller palat are set to 0 (was 1D-4 in quota)
C
C     a_respRate_c           :: Note function of cellular C --> aC^b
C     a_respRate_c_denom     :: Note function of cellular C --> aC^b
C     b_respRate_c           :: Note function of cellular C --> aC^b
C
C     a_ksatNO2fac           :: only used for darwin_effective_ksat
C     a_ksatNH4fac           :: only used for darwin_effective_ksat
C
      COMMON /DARWIN_TRAIT_PARAMS_r/
     &    logvolbase,
     &    logvolinc,
     &    biovol0,
     &    biovolfac,
     &    grp_logvolind,
     &    grp_biovol,
     &    a_Xmin,
     &    a_R_NC,
     &    a_R_PC,
     &    a_R_SiC,
     &    a_R_FeC,
     &    a_R_ChlC,
     &    a_R_PICPOC,
     &    a_ExportFracMort,
     &    a_ExportFracMort2,
     &    a_ExportFracExude,
     &    a_mort,
     &    a_mort2,
     &    a_phytoTempCoeff,
     &    a_phytoTempExp2,
     &    a_phytoTempExp1,
     &    a_phytoTempAe,
     &    a_phytoTempOptimum,
     &    a_phytoDecayPower,
     &    a_hetTempAe,
     &    a_hetTempExp2,
     &    a_hetTempOptimum,
     &    a_hetDecayPower,
     &    a_grazTempAe,
     &    a_grazTempExp2,
     &    a_grazTempOptimum,
     &    a_grazDecayPower,
#ifdef DARWIN_ALLOW_GEIDER
     &    a_mQyield,
     &    a_chl2cmax,
     &    a_inhibGeider,
#else
     &    a_ksatPAR,
     &    a_kinhPAR,
#endif
     &    a_amminhib,
     &    a_acclimtimescl,
     &    a_acclimtimescl_denom,
     &    a_ksatPON,
     &    a_ksatDON,
     &    a_grazemax,
     &    a_grazemax_denom,
     &    b_grazemax,
     &    a_kgrazesat,
     &    b_kgrazesat,
     &    a_biosink,
     &    a_biosink_denom,
     &    b_biosink,
     &    a_bioswim,
     &    a_bioswim_denom,
     &    b_bioswim,
     &    a_ppSig,
     &    a_ppOpt,
     &    b_ppOpt,
     &    palat_min,
     &    a_PCmax,
     &    a_PCmax_denom,
     &    b_PCmax,
     &    a_qcarbon,
     &    b_qcarbon,
     &    a_respRate_c,
     &    a_respRate_c_denom,
     &    b_respRate_c,
     &    a_kexcC,
     &    b_kexcC,
     &    a_vmaxNO3,
     &    a_vmaxNO3_denom,
     &    b_vmaxNO3,
     &    a_ksatNO3,
     &    b_ksatNO3,
     &    a_Qnmin,
     &    b_Qnmin,
     &    a_Qnmax,
     &    b_Qnmax,
     &    a_kexcN,
     &    b_kexcN,
     &    a_vmaxNO2,
     &    a_vmaxNO2_denom,
     &    b_vmaxNO2,
     &    a_ksatNO2,
     &    b_ksatNO2,
     &    a_ksatNO2fac,
     &    a_vmaxNH4,
     &    a_vmaxNH4_denom,
     &    b_vmaxNH4,
     &    a_ksatNH4,
     &    b_ksatNH4,
     &    a_ksatNH4fac,
     &    a_vmaxN,
     &    a_vmaxN_denom,
     &    b_vmaxN,
     &    a_vmaxPO4,
     &    a_vmaxPO4_denom,
     &    b_vmaxPO4,
     &    a_ksatPO4,
     &    b_ksatPO4,
     &    a_Qpmin,
     &    b_Qpmin,
     &    a_Qpmax,
     &    b_Qpmax,
     &    a_kexcP,
     &    b_kexcP,
     &    a_vmaxSiO2,
     &    a_vmaxSiO2_denom,
     &    b_vmaxSiO2,
     &    a_ksatSiO2,
     &    b_ksatSiO2,
     &    a_Qsimin,
     &    b_Qsimin,
     &    a_Qsimax,
     &    b_Qsimax,
     &    a_kexcSi,
     &    b_kexcSi,
     &    a_vmaxFeT,
     &    a_vmaxFeT_denom,
     &    b_vmaxFeT,
     &    a_ksatFeT,
     &    b_ksatFeT,
     &    a_Qfemin,
     &    b_Qfemin,
     &    a_Qfemax,
     &    b_Qfemax,
     &    a_kexcFe,
     &    b_kexcFe,
     &    grp_ExportFracPreyPred,
     &    grp_ass_eff
      _RL logvolbase
      _RL logvolinc
      _RL biovol0(nGroup)
      _RL biovolfac(nGroup)
      _RL grp_logvolind(nPlank,nGroup)
      _RL grp_biovol(nPlank,nGroup)
      _RL a_Xmin(nGroup)
      _RL a_R_NC(nGroup)
      _RL a_R_PC(nGroup)
      _RL a_R_SiC(nGroup)
      _RL a_R_FeC(nGroup)
      _RL a_R_ChlC(nGroup)
      _RL a_R_PICPOC(nGroup)
      _RL a_ExportFracMort(nGroup)
      _RL a_ExportFracMort2(nGroup)
      _RL a_ExportFracExude(nGroup)
      _RL a_mort(nGroup)
      _RL a_mort2(nGroup)
      _RL a_phytoTempCoeff(nGroup)
      _RL a_phytoTempExp1(nGroup)
      _RL a_phytoTempAe(nGroup)
      _RL a_phytoTempExp2(nGroup)
      _RL a_phytoTempOptimum(nGroup)
      _RL a_phytoDecayPower(nGroup)
      _RL a_hetTempAe(nGroup)
      _RL a_hetTempExp2(nGroup)
      _RL a_hetTempOptimum(nGroup)
      _RL a_hetDecayPower(nGroup)
      _RL a_grazTempAe(nGroup)
      _RL a_grazTempExp2(nGroup)
      _RL a_grazTempOptimum(nGroup)
      _RL a_grazDecayPower(nGroup)
#ifdef DARWIN_ALLOW_GEIDER
      _RL a_mQyield(nGroup)
      _RL a_chl2cmax(nGroup)
      _RL a_inhibGeider(nGroup)
#else
      _RL a_ksatPAR(nGroup)
      _RL a_kinhPAR(nGroup)
#endif
      _RL a_amminhib(nGroup)
      _RL a_acclimtimescl(nGroup)
      _RL a_acclimtimescl_denom(nGroup)
      _RL a_ksatPON(nGroup)
      _RL a_ksatDON(nGroup)
      _RL a_grazemax(nGroup)
      _RL a_grazemax_denom(nGroup)
      _RL b_grazemax(nGroup)
      _RL a_kgrazesat(nGroup)
      _RL b_kgrazesat(nGroup)
      _RL a_biosink(nGroup)
      _RL a_biosink_denom(nGroup)
      _RL b_biosink(nGroup)
      _RL a_bioswim(nGroup)
      _RL a_bioswim_denom(nGroup)
      _RL b_bioswim(nGroup)
      _RL a_ppSig(nGroup)
      _RL a_ppOpt(nGroup)
      _RL b_ppOpt(nGroup)
      _RL palat_min
      _RL a_PCmax(nGroup)
      _RL a_PCmax_denom(nGroup)
      _RL b_PCmax(nGroup)
      _RL a_qcarbon(nGroup)
      _RL b_qcarbon(nGroup)
      _RL a_respRate_c(nGroup)
      _RL a_respRate_c_denom(nGroup)
      _RL b_respRate_c(nGroup)
      _RL a_kexcC(nGroup)
      _RL b_kexcC(nGroup)
      _RL a_vmaxNO3(nGroup)
      _RL a_vmaxNO3_denom(nGroup)
      _RL b_vmaxNO3(nGroup)
      _RL a_ksatNO3(nGroup)
      _RL b_ksatNO3(nGroup)
      _RL a_Qnmin(nGroup)
      _RL b_Qnmin(nGroup)
      _RL a_Qnmax(nGroup)
      _RL b_Qnmax(nGroup)
      _RL a_kexcN(nGroup)
      _RL b_kexcN(nGroup)
      _RL a_vmaxNO2(nGroup)
      _RL a_vmaxNO2_denom(nGroup)
      _RL b_vmaxNO2(nGroup)
      _RL a_ksatNO2(nGroup)
      _RL b_ksatNO2(nGroup)
      _RL a_ksatNO2fac(nGroup)
      _RL a_vmaxNH4(nGroup)
      _RL a_vmaxNH4_denom(nGroup)
      _RL b_vmaxNH4(nGroup)
      _RL a_ksatNH4(nGroup)
      _RL b_ksatNH4(nGroup)
      _RL a_ksatNH4fac(nGroup)
      _RL a_vmaxN(nGroup)
      _RL a_vmaxN_denom(nGroup)
      _RL b_vmaxN(nGroup)
      _RL a_vmaxPO4(nGroup)
      _RL a_vmaxPO4_denom(nGroup)
      _RL b_vmaxPO4(nGroup)
      _RL a_ksatPO4(nGroup)
      _RL b_ksatPO4(nGroup)
      _RL a_Qpmin(nGroup)
      _RL b_Qpmin(nGroup)
      _RL a_Qpmax(nGroup)
      _RL b_Qpmax(nGroup)
      _RL a_kexcP(nGroup)
      _RL b_kexcP(nGroup)
      _RL a_vmaxSiO2(nGroup)
      _RL a_vmaxSiO2_denom(nGroup)
      _RL b_vmaxSiO2(nGroup)
      _RL a_ksatSiO2(nGroup)
      _RL b_ksatSiO2(nGroup)
      _RL a_Qsimin(nGroup)
      _RL b_Qsimin(nGroup)
      _RL a_Qsimax(nGroup)
      _RL b_Qsimax(nGroup)
      _RL a_kexcSi(nGroup)
      _RL b_kexcSi(nGroup)
      _RL a_vmaxFeT(nGroup)
      _RL a_vmaxFeT_denom(nGroup)
      _RL b_vmaxFeT(nGroup)
      _RL a_ksatFeT(nGroup)
      _RL b_ksatFeT(nGroup)
      _RL a_Qfemin(nGroup)
      _RL b_Qfemin(nGroup)
      _RL a_Qfemax(nGroup)
      _RL b_Qfemax(nGroup)
      _RL a_kexcFe(nGroup)
      _RL b_kexcFe(nGroup)
      _RL grp_ExportFracPreyPred(nGroup,nGroup)
      _RL grp_ass_eff(nGroup,nGroup)

#endif /* ALLOW_DARWIN */

