#include "DARWIN_OPTIONS.h"

      SUBROUTINE DARWIN_READ_PARAMS(iUnit,oUnit,myThid)
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#ifdef ALLOW_RADTRANS
#include "RADTRANS_SIZE.h"
#endif
#include "DARWIN_SIZE.h"
#include "DARWIN_RADTRANS.h"
#include "DARWIN_PARAMS.h"

      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER errCount,iUnit,oUnit,myThid
#ifndef DARWIN_SOLVESAPHE
      INTEGER selectBTconst, selectFTconst, selectHFconst
      INTEGER selectK1K2const, selectPHsolver
#endif

#ifdef ALLOW_DARWIN

C Pa2Atm    :: Conversion factor for atmospheric pressure anomaly pLoad (when
C              coupled to atmospheric model) into Atm.
C              Default assumes pLoad in Pascal: 1 Atm = 1.01325e5 Pa = 1013.25 mb
C ptr2mol   :: set carbon mmol/m3 <---> mol/m3 conversion factor
C              default permil = 1 _d -3
C  selectBTconst :: estimates borate concentration from salinity:
C     =1 :: use default formulation of Uppström (1974)(same as S/R CARBON_COEFFS)
C     =2 :: use new formulation from Lee et al (2010)
C  selectFTconst :: estimates fluoride concentration from salinity:
C     =1 :: use default formulation of Riley (1965) (same as S/R CARBON_COEFFS)
C     =2 :: use new formulation from Culkin (1965)
C  selectHFconst :: sets the first dissociation constant for hydrogen fluoride:
C     =1 :: use default  Dickson and Riley (1979) (same as S/R CARBON_COEFFS)
C     =2 :: use new formulation of Perez and Fraga (1987)
C  selectK1K2const :: sets the 1rst & 2nd dissociation constants of carbonic acid:
C     =1 :: use default formulation of Millero (1995) with data
C            from Mehrbach et al. (1973) (same as S/R CARBON_COEFFS)
C     =2 :: use formulation of Roy et al. (1993)
C     =3 :: use "combination" formulation of Millero (1995)
C     =4 :: use formulation of Luecker et al. (2000)
C     =5 :: use formulation of Millero (2010, Mar. Fresh Wat. Res.)
C     =6 :: use formulation of Waters, Millero, Woosley (2014, Mar. Chem.)
C  selectPHsolver :: sets the pH solver to use:
C     =0 :: use Follows et al., (2006) solver;
C     =1 :: use the GENERAL solver from Munhoven (2013);
C     =2 :: use SEC solver  from Munhoven (2013);
C     =3 :: use FAST solver from Munhoven (2013);
C----

      NAMELIST/DARWIN_CONSTANTS/
     &    rad2deg

#ifdef DARWIN_ALLOW_CARBON
      NAMELIST/CARBON_CONSTANTS/
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
#endif

      NAMELIST/DARWIN_PARAMS/
     &    darwin_seed,
     &    darwin_strict_check,
     &    iDEBUG,
     &    jDEBUG,
     &    kDEBUG,
     &    darwin_pickupSuff,
     &    darwin_linFSConserve,
     &    darwin_read_phos,
     &    darwin_chlInitBalanced,
     &    darwin_chlIter0,
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
     &    ligand_tot,
     &    ligand_stab,
     &    freefemax,
#ifdef DARWIN_PART_SCAV_POP
     &    scav_rat,
     &    scav_inter,
     &    scav_exp,
     &    scav_R_POPPOC,
#elif defined(DARWIN_PART_SCAV)
     &    scav_tau,
     &    scav_inter,
     &    scav_exp,
     &    scav_POC_wgt,
     &    scav_PSi_wgt,
     &    scav_PIC_wgt,
     &    scav_degrPOM,
#else
     &    scav,
#endif
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
     &    KPOP,
     &    KPON,
     &    KPOFe,
     &    KPOSi,
     &    wC_sink,
     &    wP_sink,
     &    wN_sink,
     &    wFe_sink,
     &    wSi_sink,
     &    wPIC_sink,
     &    darwin_disscSelect,
     &    Kdissc,
     &    darwin_KeirCoeff,
     &    darwin_KeirExp,
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
     &    selectBTconst, selectFTconst,
     &    selectHFconst, selectK1K2const,
     &    selectPHsolver,
#endif
     &    diaz_ini_fac,
     &    O2crit,
     &    denit_NP,
     &    denit_NO3,
     &    NO3crit,
     &    PARmin,
     &    aphy_chl_ave,
     &    Chl2Nmax,
     &    synthcost,
     &    inhib_graz,
     &    inhib_graz_exp,
     &    hillnumUptake,
     &    hillnumGraz,
     &    hollexp,
     &    phygrazmin,
     &    pmaxDIN,
     &    pcoefO2,
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

#ifdef DARWIN_ALLOW_CDOM
      NAMELIST/DARWIN_CDOM_PARAMS/
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
#endif

      NAMELIST/DARWIN_DEPENDENT_PARAMS/
#ifdef ALLOW_RADTRANS
#ifdef DARWIN_ALLOW_CDOM
#else
     &    laCDOM,
#endif
#endif
     &    darwin_dependent_i_dummy


#ifdef ALLOW_RADTRANS
      NAMELIST/DARWIN_RADTRANS_PARAMS/
     &    darwin_waterAbsorbFile,
     &    darwin_phytoAbsorbFile,
     &    darwin_particleAbsorbFile,
     &    darwin_part_size_P,
     &    darwin_bbmin,
     &    darwin_bbw,
     &    darwin_lambda_aCDOM,
     &    darwin_Sdom,
     &    darwin_aCDOM_fac,
     &    darwin_rCDOM,
     &    darwin_RPOC,
     &    darwin_allomSpectra,
     &    darwin_aCarCell,
     &    darwin_bCarCell,
     &    darwin_absorpSlope,
     &    darwin_bbbSlope,
     &    darwin_scatSwitchSizeLog,
     &    darwin_scatSlopeSmall,
     &    darwin_scatSlopeLarge
#endif

#ifdef ALLOW_RADTRANS
      NAMELIST/DARWIN_RT_DEPPARAMS/
     &    aw,
     &    bw,
     &    aphy_chl_type,
     &    aphy_chl_ps_type,
     &    aphy_mgC_type,
     &    bphy_mgC_type,
     &    bbphy_mgC_type,
     &    asize,
     &    apsize,
     &    asize_mgC,
     &    bsize,
     &    bbsize,
     &    apart,
     &    bpart,
     &    bbpart,
     &    apart_P,
     &    bpart_P,
     &    bbpart_P,
     &    exCDOM
#endif


      _RL pday
      _RL pyear

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     locals
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      pday = 86400.0 _d 0
      pyear = 360 _d 0 * pday

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     DARWIN_CONSTANTS
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      rad2deg = 180 _d 0 / PI

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     CARBON_CONSTANTS
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

#ifdef DARWIN_ALLOW_CARBON
      Pa2Atm = 1.01325 _d 5
      ptr2mol = 1.0 _d -3
      sca1 = 2073.1 _d 0
      sca2 = -125.62 _d 0
      sca3 = 3.6276 _d 0
      sca4 = -0.043219 _d 0
      sox1 = 1638.0 _d 0
      sox2 = -81.83 _d 0
      sox3 = 1.483 _d 0
      sox4 = -0.008004 _d 0
      oA0 = 2.00907 _d 0
      oA1 = 3.22014 _d 0
      oA2 = 4.05010 _d 0
      oA3 = 4.94457 _d 0
      oA4 = -2.56847 _d -1
      oA5 = 3.88767 _d 0
      oB0 = -6.24523 _d -3
      oB1 = -7.37614 _d -3
      oB2 = -1.03410 _d -2
      oB3 = -8.17083 _d -3
      oC0 = -4.88682 _d -7

#ifdef DARWIN_ALLOW_RADI
C for sediment model
      sed_a1 = -0.101 _d 0
      sed_b1 = 1.04 _d 0
      sed_c1 = 0.128 _d 0
      sed_d1 = 0.125 _d 0
      sed_a2 = -0.225 _d 0
      sed_b2 = 0.581 _d 0
      sed_c2 = 0.273 _d 0
      sed_d2 = 0.211 _d 0
      sed_a3 = -0.018 _d 0
      sed_b3 = -0.8 _d 0
      sed_c3 = 0.011 _d 0
      sed_d3 = -0.033 _d 0
      sed_a4 = 0. _d 0
      sed_b4 = 0.027 _d 0
      sed_c4 = 0.012 _d 0
      sed_d4 = -0.001 _d 0
      sed_a5 = 0.117 _d 0
      sed_b5 = -0.251 _d 0
      sed_c5 = 0.852 _d 0
      sed_d5 = -0.127 _d 0
      sed_c = 3.17 _d -5
#endif
#endif

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     DARWIN_PARAMS
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      darwin_seed = 0
      darwin_strict_check = .FALSE.
      iDEBUG = 1
      jDEBUG = 1
      kDEBUG = 1
      darwin_pickupSuff = pickupSuff
      darwin_linFSConserve = .FALSE.
      darwin_read_phos = .FALSE.
      darwin_chlInitBalanced = .FALSE.
      darwin_chlIter0 = 0
      katten_w = 4. _d -2
      katten_chl = 4. _d -2
      parfrac = 0.4 _d 0
      parconv = 1 _d 0/0.2174 _d 0
      tempnorm = 0.3 _d 0
      TempAeArr = -4000.0 _d 0
      TemprefArr = 293.15 _d 0
      TempCoeffArr = 0.5882 _d 0
      reminTempAe = 0.0438 _d 0
      mortTempAe = 0.0438 _d 0
      mort2TempAe = 0.0438 _d 0
      uptakeTempAe = 0.0 _d 0
      alpfe = 0.04 _d 0
      ligand_tot = 1. _d -3
      ligand_stab = 2. _d 5
      freefemax = 0.4 _d -3
#ifdef DARWIN_PART_SCAV_POP
      scav_rat = 0.005 _d 0 / pday
      scav_inter = 0.079 _d 0
      scav_exp = 0.58 _d 0
      scav_R_POPPOC = 1.1321 _d -4
#elif defined(DARWIN_PART_SCAV)
      scav_tau = 0.2 _d 0
      scav_inter = 0.079 _d 0 / pday
      scav_exp = 0.58 _d 0
      scav_POC_wgt = 0.12728 _d 0
      scav_PSi_wgt = 0 _d 0
      scav_PIC_wgt = 0 _d 0
      scav_degrPOM = 0 _d 0
#else
      scav = 0.4 _d 0/pyear
#endif
      depthfesed = -1.0 _d 0
      fesedflux = 1 _d -3 / pday
      fesedflux_pcm = 0.68 _d -3
      fesedflux_min = 0.5 _d -3 / pday
      R_CP_fesed = 106 _d 0
C These values for hydrothermal input of iron from Tagliabue et al (2014)       
      R_FeHe3_vent = 4.5 _d 8
      solFeVent = 2 _d -3
      depthFeVent = 750 _d 0
C
      Knita = 1 _d 0/(0.5 _d 0*pday)
      Knitb = 1 _d 0/(10 _d 0*pday)
      PAR_oxi = 10 _d 0
      Kdoc = 1 _d 0/(100 _d 0*pday)
      Kdop = 1 _d 0/(100 _d 0*pday)
      Kdon = 1 _d 0/(100 _d 0*pday)
      KdoFe = 1 _d 0/(100 _d 0*pday)
      KPOC = 1 _d 0/(50 _d 0*pday)
      KPOP = KPOC
      KPON = KPOC
      KPOFe = KPOC
      KPOSi = 1 _d 0/(300 _d 0*pday)
      wC_sink = 10 _d 0/pday
      wP_sink = wC_sink
      wN_sink = wC_sink
      wFe_sink = wC_sink
      wSi_sink = wC_sink
      wPIC_sink = 15 _d 0/pday
      darwin_disscSelect = 0
      Kdissc = 1 _d 0/(300 _d 0*pday)
      darwin_KeirCoeff = EXP(7.177 _d 0)/100 _d 0/86400 _d 0
      darwin_KeirExp = 4.54 _d 0
#ifdef DARWIN_ALLOW_CARBON
      R_OP = 170 _d 0
      R_OC = 170 _d 0/120.0 _d 0
      m3perkg = 1 _d 0 / 1024.5 _d 0
      surfSaltMinInit = 4.0 _d 0
      surfSaltMaxInit = 50.0 _d 0
      surfTempMinInit = -4.0 _d 0
      surfTempMaxInit = 39.0 _d 0
      surfDICMinInit = 10.0 _d 0
      surfDICMaxInit = 4000.0 _d 0
      surfALKMinInit = 10.0 _d 0
      surfALKMaxInit = 4000.0 _d 0
      surfPO4MinInit = 1.0 _d -10
      surfPO4MaxInit = 10.0 _d 0
      surfSiMinInit = 1.0 _d -8
      surfSiMaxInit = 500.0 _d 0
      surfSaltMin = 4.0 _d 0
      surfSaltMax = 50.0 _d 0
      surfTempMin = -4.0 _d 0
      surfTempMax = 39.0 _d 0
      surfDICMin = 400.0 _d 0
      surfDICMax = 4000.0 _d 0
      surfALKMin = 400.0 _d 0
      surfALKMax = 4000.0 _d 0
      surfPO4Min = 1.0 _d -10
      surfPO4Max = 10.0 _d 0
      surfSiMin = 1.0 _d -8
      surfSiMax = 500.0 _d 0
      selectBTconst   = UNSET_I
      selectFTconst   = UNSET_I
      selectHFconst   = UNSET_I
      selectK1K2const = UNSET_I
      selectPHsolver  = UNSET_I
#endif
      diaz_ini_fac = 1 _d 0
C     O2crit from Lipschultz et al 1990, DSR 37, 1513-1541:
      O2crit = 6.0 _d 0
      denit_NP = 120.0 _d 0
      denit_NO3 = 104.0 _d 0
      NO3crit = 1. _d -2
      PARmin = 0.1 _d 0
      aphy_chl_ave = 0.02 _d 0
      Chl2Nmax = 3.00 _d 0
      synthcost = 0.0 _d 0
      inhib_graz = 1.0 _d 0
      inhib_graz_exp = 0.0 _d 0
      hillnumUptake = 1.0 _d 0
      hillnumGraz = 1.0 _d 0
      hollexp = 1.0 _d 0
      phygrazmin = 120 _d -10
      pcoefO2 = 290.82 _d 0/pday
      pmaxDIN = 20/pday
      ksatDIN = 0.01 _d 0
      alpha_hydrol = 2.0 _d 0
      yod = 0.2 _d 0
      yoe = yod/467*4/(1-yod)*106 _d 0
      ynd = 0.16 _d 0
      yne = ynd/467*5/(1-ynd)*106 _d 0
C      fnh4 = 0.1 _d 0
C      ynh4 = 1/(16+467/6/fnh4)*106 _d 0
C      yonh4 = fnh4/467*4/(1-fnh4)*106 _d 0
C      fno2 = 0.1 _d 0
C      yno2 = 1/(16+563/2/fno2)*106 _d 0
C      yono2 = fno2/563*4/(1-fno2)*106 _d 0
      depthdenit = 185.0 _d 0

      READ(UNIT=iUnit, NML=DARWIN_PARAMS)

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     DARWIN_CDOM_PARAMS
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

#ifdef DARWIN_ALLOW_CDOM
      fracCDOM = 2. _d 0 / 100. _d 0
      CDOMdegrd = 1. _d 0 / (200 _d 0*pday)
      CDOMbleach = 1. _d 0 / (15 _d 0*pday)
      PARCDOM = 20. _d 0
# ifdef DARWIN_CDOM_UNITS_CARBON
      R_NC_CDOM = 16. _d 0 / 120 _d 0
      R_FeC_CDOM = 1. _d -3 / 120 _d 0
      R_PC_CDOM = 1 _d 0 / 120. _d 0
      CDOMcoeff = .1 _d -1  / 1. _d -4 / 120 _d 0
# else
      R_NP_CDOM = 16. _d 0
      R_FeP_CDOM = 1. _d -3
      R_CP_CDOM = 120. _d 0
      CDOMcoeff = .1 _d -1  / 1. _d -4
# endif

      READ(UNIT=iUnit, NML=DARWIN_CDOM_PARAMS)
#endif

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     DARWIN_DEPENDENT_PARAMS
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

#ifdef ALLOW_RADTRANS
#ifdef DARWIN_ALLOW_CDOM
#else
      laCDOM = -1
#endif
#endif
      kMinFeSed = 1
      kMaxFeSed = 0

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     DARWIN_RADTRANS_PARAMS
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

#ifdef ALLOW_RADTRANS
      darwin_waterAbsorbFile = ' '
      darwin_phytoAbsorbFile = ' '
      darwin_particleAbsorbFile = ' '
      darwin_part_size_P = 1 _d -15
      darwin_bbmin = 0.0002 _d 0
      darwin_bbw = 0.5 _d 0
      darwin_lambda_aCDOM = 450.0 _d 0
      darwin_Sdom = 0.014 _d 0
      darwin_aCDOM_fac = 0.2 _d 0
      darwin_rCDOM = 0.0 _d 0
      darwin_RPOC = 0.0 _d 0
      darwin_allomSpectra = .FALSE.
C     from Montagnes et al 1994:
      darwin_aCarCell = 0.109 _d -9
      darwin_bCarCell = 0.991 _d 0
      darwin_absorpSlope = -0.075 _d 0
      darwin_bbbSlope = -1.458 _d 0
      darwin_scatSwitchSizeLog = 0. _d 0
      darwin_scatSlopeSmall = 1.5 _d 0
      darwin_scatSlopeLarge = 1.5 _d 0

      READ(UNIT=iUnit, NML=DARWIN_RADTRANS_PARAMS)

      aw = -1
      bw = -1
      aphy_chl_type = -1
      aphy_chl_ps_type = -1
      aphy_mgC_type = -1
      bphy_mgC_type = -1
      bbphy_mgC_type = -1
      asize = -1
      apsize = -1
      asize_mgC = -1
      bsize = -1
      bbsize = -1
      apart = -1
      bpart = -1
      bbpart = -1
      apart_P = -1
      bpart_P = -1
      bbpart_P = -1
      exCDOM = -1
#endif

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
C-    derive other parameters:

C-    set parameter default values
#ifdef DARWIN_ALLOW_CARBON
      IF ( selectBTconst  .EQ.UNSET_I ) selectBTconst   = 1
      IF ( selectFTconst  .EQ.UNSET_I ) selectFTconst   = 1
      IF ( selectHFconst  .EQ.UNSET_I ) selectHFconst   = 1
      IF ( selectK1K2const.EQ.UNSET_I ) selectK1K2const = 1
      IF ( selectPHsolver .EQ.UNSET_I ) selectPHsolver  = 0
#endif

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
C--   Print out parameter values :

      errCount = 0

#ifdef DARWIN_SOLVESAPHE
C Record the solver to calculate pH and evaluate surface ocean pCO2
      IF ( selectPHsolver.GT.0 ) THEN
         WRITE(msgBuf,'(A)')
     &  'Using Munhoven (2013) Solvesaphe for pH/pCO2'
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
      ELSEIF ( selectPHsolver.EQ.0 ) THEN
         WRITE(msgBuf,'(A)')
     &  'Using Follows et al. (2006) for pH/pCO2'
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
      ENDIF
#endif /* DARWIN_SOLVESAPHE */

C Record which carbonate coefficients are used and which pH/pCO2 solver
#ifdef DARWIN_SOLVESAPHE
      WRITE(msgBuf,'(A)')
     &  'Using Munhoven (2013) Solvesaphe carbon coefficients'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
C Munhoven (2013)'s "Solvesaphe" coefficients have several options:
      IF ( selectK1K2const.EQ.1 ) THEN
         WRITE(msgBuf,'(A)')
     &  'Using Millero (1995)/Mehrbach K1 and K2 coefficients'
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
      ELSEIF ( selectK1K2const.EQ.2 ) THEN
         WRITE(msgBuf,'(A)')
     &  'Using Roy et al. (1993) K1 and K2 coefficients'
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
      ELSEIF ( selectK1K2const.EQ.3 ) THEN
         WRITE(msgBuf,'(A)')
     &  'Using Millero (1995) "consensus" K1 and K2 coefficients'
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
      ELSEIF ( selectK1K2const.EQ.4 ) THEN
         WRITE(msgBuf,'(A)')
     &  'Using Luecker et al. (2000) K1 and K2 coefficients'
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
      ELSEIF ( selectK1K2const.EQ.5 ) THEN
         WRITE(msgBuf,'(A)')
     &  'Using Millero et al. (2010) K1 and K2 coefficients'
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
      ELSEIF ( selectK1K2const.EQ.6 ) THEN
         WRITE(msgBuf,'(A)')
     &  'Using Waters et al. (2014) K1 and K2 coefficients'
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
      ENDIF

      IF ( selectHFconst.EQ.1 ) THEN
         WRITE(msgBuf,'(A)')
     &  'Using Dickson and Riley (1979) KF coefficient'
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
      ELSEIF ( selectHFconst.EQ.2 ) THEN
         WRITE(msgBuf,'(A)')
     &  'Using Perez and Fraga (1987) KF coefficient'
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
      ENDIF

      IF ( selectBTconst.EQ.1 ) THEN
         WRITE(msgBuf,'(A)')
     & 'Using Uppstrom (1974) BT estimation from salinity'
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
      ELSEIF ( selectBTconst.EQ.2 ) THEN
         WRITE(msgBuf,'(A)')
     &  'Using Lee et al (2010) BT estimation from salinity'
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
      ENDIF

      IF ( selectFTconst.EQ.1 ) THEN
         WRITE(msgBuf,'(A)')
     &  'Using Riley (1965) FT estimation from salinity'
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
      ELSEIF ( selectBTconst.EQ.2 ) THEN
         WRITE(msgBuf,'(A)')
     &  'Using Culkin (1965) FT estimation from salinity'
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
      ENDIF
#else /* DARWIN_SOLVESAPHE */
C OCMIP2 Coefficients from S/R CARBON_COEFFS in CARBON_CHEM.F
      WRITE(msgBuf,'(A)')
     &  'Using Millero (1995)/Mehrbach K1 and K2 coefficients'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)')
     &  'Using Dickson and Riley (1979) KF coefficient'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)')
     &  'Using Uppstrom (1974) BT estimation from salinity'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)')
     &  'Using Riley (1965) FT estimation from salinity'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
#endif /* DARWIN_SOLVESAPHE */

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     log all parameters to a namelist file

      IF ( oUnit .GE. 0 ) THEN
       WRITE(UNIT=oUnit, NML=DARWIN_CONSTANTS)
#ifdef DARWIN_ALLOW_CARBON
       WRITE(UNIT=oUnit, NML=CARBON_CONSTANTS)
#endif
       WRITE(UNIT=oUnit, NML=DARWIN_PARAMS)
#ifdef DARWIN_ALLOW_CDOM
       WRITE(UNIT=oUnit, NML=DARWIN_CDOM_PARAMS)
#endif
       WRITE(UNIT=oUnit, NML=DARWIN_DEPENDENT_PARAMS)
#ifdef ALLOW_RADTRANS
       WRITE(UNIT=oUnit, NML=DARWIN_RADTRANS_PARAMS)
       WRITE(UNIT=oUnit, NML=DARWIN_RT_DEPPARAMS)
#endif
      ENDIF

#endif /* ALLOW_DARWIN */

      RETURN
      END
