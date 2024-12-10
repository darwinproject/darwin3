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
     &    tempMort2
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
      COMMON /DARWIN_TRAITS_r/
     &    Xmin,
     &    amminhib,
     &    acclimtimescl,
     &    mort,
     &    mort2,
     &    ExportFracMort,
     &    ExportFracMort2,
     &    ExportFracExude,
     &    phytoTempCoeff,
     &    phytoTempExp1,
     &    phytoTempExp2,
     &    phytoTempOptimum,
     &    phytoDecayPower,
     &    R_NC,
     &    R_PC,
     &    R_SiC,
     &    R_FeC,
     &    R_ChlC,
     &    R_PICPOC,
     &    biosink,
     &    bioswim,
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
     &    ksatDOFe
      _RL Xmin(nplank)
      _RL amminhib(nplank)
      _RL acclimtimescl(nplank)
      _RL mort(nplank)
      _RL mort2(nplank)
      _RL ExportFracMort(nplank)
      _RL ExportFracMort2(nplank)
      _RL ExportFracExude(nplank)
      _RL phytoTempCoeff(nplank)
      _RL phytoTempExp1(nplank)
      _RL phytoTempExp2(nplank)
      _RL phytoTempOptimum(nplank)
      _RL phytoDecayPower(nplank)
      _RL R_NC(nplank)
      _RL R_PC(nplank)
      _RL R_SiC(nplank)
      _RL R_FeC(nplank)
      _RL R_ChlC(nplank)
      _RL R_PICPOC(nplank)
      _RL biosink(nplank)
      _RL bioswim(nplank)
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
      COMMON /DARWIN_DEPENDENT_TRAITS_r/
#ifndef DARWIN_ALLOW_GEIDER
     &    normI,
#endif
     &    biovol,
     &    qcarbon,
     &    biovol_bygroup,
     &    alpha_mean,
     &    chl2cmin,
     &    mortTempFuncMin,
     &    mort2TempFuncMin
#ifndef DARWIN_ALLOW_GEIDER
      _RL normI(nplank)
#endif
      _RL biovol(nplank)
      _RL qcarbon(nplank)
      _RL biovol_bygroup(nplank,ngroup)
      _RL alpha_mean(nplank)
      _RL chl2cmin(nplank)
      _RL mortTempFuncMin(nplank)
      _RL mort2TempFuncMin(nplank)


#endif /* ALLOW_DARWIN */

