#include "DARWIN_OPTIONS.h"

      SUBROUTINE DARWIN_READ_TRAITPARAMS(iUnit,oUnit,myThid)
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITPARAMS.h"

      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER iUnit,oUnit,myThid

#ifdef ALLOW_DARWIN

      NAMELIST/DARWIN_RANDOM_PARAMS/
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
     &    oldTwoGrazers,
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

      NAMELIST/DARWIN_TRAIT_PARAMS/
     &    darwin_sort_biovol,
     &    darwin_effective_ksat,
     &    darwin_select_kn_allom,
     &    logvolbase,
     &    logvolinc,
     &    biovol0,
     &    biovolfac,
     &    logvol0ind,
     &    grp_logvolind,
     &    grp_biovol,
     &    grp_names,
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
     &    grp_tempGraz,
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
     &    a_phytoTempExp1,
     &    a_phytoTempAe,
     &    a_phytoTempExp2,
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



      _RL pday

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     locals
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      pday = 86400.0 _d 0

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     DARWIN_RANDOM_PARAMS
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      phymin = 120 _d -20
      Smallgrow = .7 _d 0
      Biggrow = .4 _d 0
      Smallgrowrange = 0. _d 0
      Biggrowrange = 0. _d 0
      diaz_growfac = 2. _d 0
      cocco_growfac = 1.3 _d 0
      diatom_growfac = 0.95 _d 0
      Smallmort = 10. _d 0
      Bigmort = 10. _d 0
      Smallmortrange = 0. _d 0
      Bigmortrange = 0. _d 0
      Smallexport = 0.2 _d 0
      Bigexport = 0.5 _d 0
      tempcoeff1 = 1. _d 0/3. _d 0
      tempcoeff2_small = 0.001 _d 0
      tempcoeff2_big = 0.0003 _d 0
      tempcoeff3 = 1.04 _d 0
      tempmax = 30. _d 0
      temprange = 32. _d 0
      tempdecay = 4. _d 0
      val_R_NC = 16.0 _d 0/120.0 _d 0
      val_R_NC_diaz = 40.0 _d 0/120.0 _d 0
      val_R_PC = 1.0 _d 0/120.0 _d 0
      val_R_SiC_diatom = 16.0 _d 0/120.0 _d 0
      val_R_FeC = 1.0 _d -3/120.0 _d 0
      val_R_FeC_diaz = 30.0 _d 0 * val_R_FeC
      val_R_PICPOC = 0.8 _d 0
      val_R_ChlC = 16.0 _d 0/120 _d 0
      val_R_NC_zoo = 16.0 _d 0/120.0 _d 0
      val_R_PC_zoo = 1 _d 0/120.0 _d 0
      val_R_SiC_zoo = 0.0 _d 0
      val_R_FeC_zoo = 1.0 _d -3/120.0 _d 0
      val_R_PICPOC_zoo = 0.0 _d 0
      val_R_ChlC_zoo = 0 _d 0/120 _d 0
      SmallSink = 0.0 _d 0/pday
      BigSink = 0.5 _d 0/pday
      SmallPsat = 0.015 _d 0
      BigPsat = 0.035 _d 0
      ProcPsat = 0.01 _d 0
      UniDzPsat = 0.012 _d 0
      CoccoPsat = 0.035 _d 0
      SmallPsatrange = 0.02 _d 0
      BigPsatrange = 0.02 _d 0
      ProcPsatrange = 0.005 _d 0
      UniDzPsatrange = 0.02 _d 0
      CoccoPsatrange = 0.02 _d 0
      ksatNH4fac = .50 _d 0
      ksatNO2fac = 1.0 _d 0
      val_amminhib = 4.6 _d 0
      val_ksatsio2 = 1. _d 0
      smallksatpar = 0.12 _d -1
      smallksatparstd = 0.20 _d -1
      smallkinhpar = 6.0 _d -3
      smallkinhparstd = 0.10 _d -3
      Bigksatpar = 0.12 _d -1
      Bigksatparstd = 0.06 _d -1
      Bigkinhpar = 1.0 _d -3
      Bigkinhparstd = 0.05 _d -3
      LLProkinhpar = 6.0 _d -3
      Coccokinhpar = 0.5 _d -3
      inhibcoef_geid_val = 0 _d 0
      smallmQyield = 5. _d -5
      smallmQyieldrange = 1. _d -4
      BigmQyield = 3. _d -5
      BigmQyieldrange = 4. _d -5
      smallchl2cmax = 0.2 _d 0
      smallchl2cmaxrange = 0.3 _d 0
      Bigchl2cmax = 0.5 _d 0
      Bigchl2cmaxrange = 0.3 _d 0
      val_acclimtimescl = 1./(60. _d 0*60. _d 0*24. _d 0*20. _d 0)
      oldTwoGrazers = .FALSE.
      GrazeFast = 1.0 _d 0/(2.0 _d 0*pday)
      GrazeSlow = 1.0 _d 0/(7.0 _d 0*pday)
      ZooexfacSmall = 0.2 _d 0
      ZooexfacBig = 0.7 _d 0
      ZoomortSmall = 1.0 _d 0/(30.0 _d 0*pday)
      ZoomortBig = 1.0 _d 0/(30.0 _d 0*pday)
      ZoomortSmall2 = 0. _d 0
      ZoomortBig2 = 0. _d 0
      ExGrazfracbig = 0.8 _d 0
      ExGrazfracsmall = 0.8 _d 0
      palathi = 1.0 _d 0
      palatlo = 0.2 _d 0
      diatomgraz = 0.7 _d 0
      coccograz = 0.6 _d 0
      olargegraz = 1.0 _d 0
      GrazeEfflow = 0.2 _d 0
      GrazeEffmod = 0.5 _d 0
      GrazeEffhi = 0.7 _d 0
      GrazeRate = 1.0 _d 0/(2.0 _d 0*pday)
      ExGrazfrac = 0.8 _d 0
      val_palat = 0.0 _d 0
      val_ass_eff = 0.70 _d 0
      kgrazesat_val = 12 _d 0
      Zoomort = 1.0 _d 0/(30.0 _d 0*pday)
      Zoomort2 = 0. _d 0
      Zooexfac = 0.7 _d 0
      ZooDM = 100 _d 0

      READ(UNIT=iUnit, NML=DARWIN_RANDOM_PARAMS)

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     DARWIN_TRAIT_PARAMS
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      darwin_sort_biovol = .FALSE.
      darwin_effective_ksat = .FALSE.
      darwin_select_kn_allom = 2
      logvolbase = 0.0 _d 0
      logvolinc = 0.0 _d 0
      biovol0 = 0.0 _d 0
      biovolfac = 1.0 _d 0
      logvol0ind = 0
      grp_logvolind = 0 _d 0
      grp_biovol = 0 _d 0
      grp_names = ''
      grp_nplank = 0
      grp_photo = 1
      grp_bacttype = 0
      grp_aerobic = 0
      grp_denit = 0
      grp_pred = 0
      grp_prey = 1
      grp_hasSi = 0
      grp_hasPIC = 0
      grp_diazo = 0
      grp_useNH4 = 1
      grp_useNO2 = 1
      grp_useNO3 = 1
      grp_combNO = 1
      grp_aptype = 0
      grp_tempMort = 1
      grp_tempMort2 = 1
      grp_tempGraz = 1
C     used to be 120D-20 for phyto
      a_Xmin = 0 _d 0
      a_R_NC = 16.0 _d 0/120.0 _d 0
      a_R_PC = 1 _d 0/120.0 _d 0
      a_R_SiC = 0 _d 0
      a_R_FeC = 1.0 _d -3/120.0 _d 0
      a_R_ChlC = 16 _d 0/120 _d 0
      a_R_PICPOC = 0.8 _d 0
      a_ExportFracMort = 0.5 _d 0
      a_ExportFracMort2 = 0.5 _d 0
      a_ExportFracExude = DARWIN_UNINIT_RL
      a_mort = 0.02 _d 0 / pday
      a_mort2 = 0.0 _d 0
      a_phytoTempCoeff = 1. _d 0/3. _d 0
      a_phytoTempExp1 = 1.04 _d 0
      a_phytoTempAe = 0.0438 _d 0
      a_phytoTempExp2 = 0.001 _d 0
      a_phytoTempOptimum = 2. _d 0
      a_phytoDecayPower = 4. _d 0
      a_hetTempAe = 0.0438 _d 0
      a_hetTempExp2 = 0.001 _d 0
      a_hetTempOptimum = 2. _d 0
      a_hetDecayPower = 4. _d 0
      a_grazTempAe = 0.0438 _d 0
      a_grazTempExp2 = 0.001 _d 0
      a_grazTempOptimum = 2. _d 0
      a_grazDecayPower = 4. _d 0
#ifdef DARWIN_ALLOW_GEIDER
      a_mQyield = 75 _d -6
      a_chl2cmax = .3 _d 0
      a_inhibGeider = 0 _d 0
#else
      a_ksatPAR = 0.012 _d 0
      a_kinhPAR = 6.0 _d -3
#endif
      a_amminhib = 4.6 _d 0
      a_acclimtimescl = 1 _d 0/(20*pday)
      a_acclimtimescl_denom = 1 _d 0
      a_ksatPON = 1 _d 0
      a_ksatDON = 1 _d 0
      a_grazemax = 21.9 _d 0 / pday
      a_grazemax_denom = 1. _d 0
      b_grazemax = -0.16 _d 0
C     used to be 22.4
      a_kgrazesat = 1.00 _d 0
      b_kgrazesat = 0.00 _d 0
      a_biosink = 0.28 _d -1 / pday
      a_biosink_denom = 1. _d 0
      b_biosink = 0.39 _d 0
      a_bioswim = 0.00 _d 0 / pday
      a_bioswim_denom = 1. _d 0
      b_bioswim = 0.18 _d 0
      a_ppSig = 1.0 _d 0
      a_ppOpt = 1024. _d 0
      b_ppOpt = 0.00 _d 0
      palat_min = 0 _d 0
      a_PCmax = 1.00 _d 0 / pday
      a_PCmax_denom = 1. _d 0
      b_PCmax = -0.15 _d 0
      a_qcarbon = 1.80 _d -11
      b_qcarbon = 0.94 _d 0
C     was 3.21 _d -11 / pday
      a_respRate_c = 0.00 _d 0
      a_respRate_c_denom = 1. _d 0
      b_respRate_c = 0.93 _d 0
C     was 0.32 _d -1 / pday
      a_kexcC = 0.00 _d 0
      b_kexcC = -0.33 _d 0
      a_vmaxNO3 = 0.51 _d 0 / pday
      a_vmaxNO3_denom = 1. _d 0
      b_vmaxNO3 = -0.27 _d 0
      a_ksatNO3 = 0.17 _d 0
      b_ksatNO3 = 0.27 _d 0
      a_Qnmin = 0.07 _d 0
      b_Qnmin = -0.17 _d 0
      a_Qnmax = 0.25 _d 0
      b_Qnmax = -0.13 _d 0
C     was 0.24 _d -1 / pday
      a_kexcN = 0.00 _d 0
      b_kexcN = -0.33 _d 0
      a_vmaxNO2 = 0.51 _d 0 / pday
      a_vmaxNO2_denom = 1.0 _d 0
      b_vmaxNO2 = -0.27 _d 0
      a_ksatNO2 = 0.17 _d 0
      b_ksatNO2 = 0.27 _d 0
      a_ksatNO2fac = 1.0 _d 0
      a_vmaxNH4 = 0.26 _d 0 / pday
      a_vmaxNH4_denom = 1.0 _d 0
      b_vmaxNH4 = -0.27 _d 0
      a_ksatNH4 = 0.85 _d -1
      b_ksatNH4 = 0.27 _d 0
      a_ksatNH4fac = 0.5 _d 0
      a_vmaxN = 1.28 _d 0 / pday
      a_vmaxN_denom = 1. _d 0
      b_vmaxN = -0.27 _d 0
      a_vmaxPO4 = 0.77 _d -1 / pday
      a_vmaxPO4_denom = 1.0 _d 0
      b_vmaxPO4 = -0.27 _d 0
      a_ksatPO4 = 0.26 _d -1
      b_ksatPO4 = 0.27 _d 0
      a_Qpmin = 2.00 _d -3
      b_Qpmin = 0.00 _d 0
      a_Qpmax = 0.01 _d 0
      b_Qpmax = 0.00 _d 0
      a_kexcP = 0.24 _d -1 / pday
      b_kexcP = -0.33 _d 0
      a_vmaxSiO2 = 0.77 _d -1 / pday
      a_vmaxSiO2_denom = 1.0 _d 0
      b_vmaxSiO2 = -0.27 _d 0
      a_ksatSiO2 = 0.24 _d -1
      b_ksatSiO2 = 0.27 _d 0
C     was 0.084
      a_Qsimin = 2.00 _d -3
C     was -0.17
      b_Qsimin = 0.00 _d 0
C     was 0.3
      a_Qsimax = 4.00 _d -3
C     was -0.13
      b_Qsimax = 0.00 _d 0
      a_kexcSi = 0.00 _d 0  / pday
      b_kexcSi = 0.00 _d 0
C     was 96.2 _d -6 / pday
      a_vmaxFeT = 14.0 _d -6 / pday
      a_vmaxFeT_denom = 1.0 _d 0
      b_vmaxFeT = -0.27 _d 0
C     was 32.1 _d -6
      a_ksatFeT = 80.0 _d -6
      b_ksatFeT = 0.27 _d 0
C     [Mongin 2006]
      a_Qfemin = 1.50 _d -6
      b_Qfemin = 0.00 _d 0
C     [Mongin 2006]
      a_Qfemax = 80.0 _d -6
      b_Qfemax = 0.00 _d 0
      a_kexcFe = 0.00 _d 0  / pday
      b_kexcFe = 0.00 _d 0
      grp_ExportFracPreyPred = 0.5 _d 0
      grp_ass_eff = 0.7 _d 0

      READ(UNIT=iUnit, NML=DARWIN_TRAIT_PARAMS)


      a_acclimtimescl = a_acclimtimescl/a_acclimtimescl_denom
      a_grazemax = a_grazemax/a_grazemax_denom
      a_biosink = a_biosink/a_biosink_denom
      a_bioswim = a_bioswim/a_bioswim_denom
      a_PCmax = a_PCmax/a_PCmax_denom
      a_respRate_c = a_respRate_c/a_respRate_c_denom
      a_vmaxNO3 = a_vmaxNO3/a_vmaxNO3_denom
      a_vmaxNO2 = a_vmaxNO2/a_vmaxNO2_denom
      a_vmaxNH4 = a_vmaxNH4/a_vmaxNH4_denom
      a_vmaxN = a_vmaxN/a_vmaxN_denom
      a_vmaxPO4 = a_vmaxPO4/a_vmaxPO4_denom
      a_vmaxSiO2 = a_vmaxSiO2/a_vmaxSiO2_denom
      a_vmaxFeT = a_vmaxFeT/a_vmaxFeT_denom

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     log all parameters to a namelist file

      IF ( oUnit .GE. 0 ) THEN
       WRITE(UNIT=oUnit, NML=DARWIN_RANDOM_PARAMS)
       WRITE(UNIT=oUnit, NML=DARWIN_TRAIT_PARAMS)
      ENDIF

#endif /* ALLOW_DARWIN */

      RETURN
      END
