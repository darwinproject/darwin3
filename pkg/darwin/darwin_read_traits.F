#include "DARWIN_OPTIONS.h"

      SUBROUTINE DARWIN_READ_TRAITS(iUnit,oUnit,myThid)
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#ifdef ALLOW_RADTRANS
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"
#endif
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_RADTRANS.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITPARAMS.h"
#include "DARWIN_TRAITS.h"

      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER iUnit,oUnit,myThid

#ifdef ALLOW_DARWIN

      INTEGER jp
      INTEGER jp2
      INTEGER jz
      INTEGER l
      INTEGER iopt

      NAMELIST/DARWIN_TRAITS/
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
     &    tempGraz,
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

      NAMELIST/DARWIN_DEPENDENT_TRAITS/
#ifndef DARWIN_ALLOW_GEIDER
     &    normI,
#endif
#ifdef ALLOW_RADTRANS
     &    aptype,
#endif
     &    biovol,
     &    group,
     &    igroup,
     &    qcarbon,
     &    biovol_bygroup,
     &    alpha_mean,
     &    chl2cmin


#ifdef ALLOW_RADTRANS
      NAMELIST/DARWIN_RADTRANS_TRAITS/
     &    aphy_chl,
     &    aphy_chl_ps,
     &    aphy_mgC,
     &    bphy_mgC,
     &    bbphy_mgC
#endif

      NAMELIST/DARWIN_RT_DEPTRAITS/
     &    alphachl

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     DARWIN_TRAITS
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      READ(UNIT=iUnit, NML=DARWIN_TRAITS)

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     DARWIN_RADTRANS_TRAITS
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

#ifdef ALLOW_RADTRANS
      READ(UNIT=iUnit, NML=DARWIN_RADTRANS_TRAITS)
#endif

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     DARWIN_DEPENDENT_TRAITS
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      DO jp = 1,nPlank
        vmaxNH4(jp) = vmaxNH4(jp) * useNH4(jp)
        vmaxNO2(jp) = vmaxNO2(jp) * useNO2(jp)
        vmaxNO3(jp) = vmaxNO3(jp) * useNO3(jp)
#ifndef DARWIN_ALLOW_NQUOTA
        IF (diazo(jp).NE.0) THEN
          useNH4(jp) = 0
          useNO2(jp) = 0
          useNO3(jp) = 0
        ENDIF
#endif
        IF (useNO3(jp).EQ.0 .OR. useNO2(jp).EQ.0) THEN
          combNO(jp)=0
        ENDIF
C       Silicate parameters to zero for non-diatoms
        IF (hasSi(jp) .EQ. 0) THEN
          vmaxSiO2(jp) = 0.0 _d 0
          ksatSiO2(jp) = 0.0 _d 0
          R_SiC(jp) = 0.0 _d 0
        ENDIF
C       only Coccolithophores have PIC
        IF (hasPIC(jp) .EQ. 0) THEN
          R_PICPOC(jp) = 0.0 _d 0
        ENDIF
      ENDDO

#ifdef ALLOW_RADTRANS

      DO jp = 1, nPhoto
       alpha_mean(jp) = 0.0 _d 0
       DO l = 1, nlam
        alphachl(jp,l) = mQyield(jp) * aphy_chl_ps(jp,l)
        alpha_mean(jp) = alpha_mean(jp) + RT_wbWidths(l)*alphachl(jp,l)
       ENDDO
       alpha_mean(jp) = alpha_mean(jp)/RT_wbTotalWidth
      ENDDO
#else
      DO jp = 1, nPhoto
       alphachl(jp,1) = mQyield(jp) * aphy_chl_ave
       alpha_mean(jp) = alphachl(jp,1)
      ENDDO
#endif /* ALLOW_RADTRANS */

#ifdef ALLOW_RADTRANS
      DO jp = 1, nplank
       IF (pcmax(jp) .GT. 0 _d 0) THEN
         chl2cmin(jp)=chl2cmax(jp)/
     &     (1+(chl2cmax(jp)* alpha_mean(jp) *2000. _d 0)/(2*pcmax(jp)))
       ELSE
         chl2cmin(jp) = 0 _d 0
       ENDIF
      ENDDO
#else
      DO jp = 1, nPhoto
       chl2cmin(jp) = 0. _d 0
      ENDDO
#endif

#ifndef DARWIN_ALLOW_GEIDER
      DO jp = 1, nplank
       IF (ksatPAR(jp)*kinhPAR(jp) .GT. 0.0) THEN
        normI(jp) = 1.0/(ksatPAR(jp)/(ksatPAR(jp)+kinhPAR(jp))*
     &    EXP(kinhPAR(jp)/ksatPAR(jp)*
     &        LOG(kinhPAR(jp)/(ksatPAR(jp)+kinhPAR(jp)))))
       ELSE
        normI(jp) = 1.0
       ENDIF
      ENDDO
#endif

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     Checks
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

C     check types are within type ranges
      DO jp=1,nplank
       IF (isPhoto(jp) .NE. 0) THEN
        IF (jp.GT.nPhoto) THEN
          WRITE(msgBuf,'(2A,I4)') 'DARWIN_READTRAITS: ERROR: ',
     &    'isPhoto set for type outside of photo range: ', jp
          CALL PRINT_ERROR( msgBuf , 1)
          STOP 'ABNORMAL END: S/R DARWIN_READTRAITS'
        ENDIF
#ifdef DARWIN_ALLOW_CHLQUOTA
        IF (jp.GT.nPhoto) THEN
          WRITE(msgBuf,'(2A,I4)') 'DARWIN_READTRAITS: ERROR: ',
     &    'isPhoto set for type outside of Chl range: ', jp
          CALL PRINT_ERROR( msgBuf , 1)
          STOP 'ABNORMAL END: S/R DARWIN_READTRAITS'
        ENDIF
#endif
       ELSE
        IF (bacttype(jp) .EQ. 0) THEN
         PCmax(jp) = 0 _d 0
        ENDIF
        vmaxPO4(jp) = 0 _d 0
        vmaxNO3(jp) = 0 _d 0
        vmaxNO2(jp) = 0 _d 0
        vmaxNH4(jp) = 0 _d 0
        vmaxFeT(jp) = 0 _d 0
        vmaxSiO2(jp) = 0 _d 0
       ENDIF

       IF (bactType(jp) .NE. 0) THEN
        IF (isAerobic(jp).NE.0 .AND. isDenit(jp).NE.0) THEN
          WRITE(msgBuf,'(2A,I4)') 'DARWIN_READTRAITS: ERROR: ',
     &    'isAerobic and isDenit both set: ', jp
          CALL PRINT_ERROR( msgBuf , 1)
          STOP 'ABNORMAL END: S/R DARWIN_READTRAITS'
        ENDIF
        IF (R_PICPOC(jp).NE.0) THEN
          WRITE(msgBuf,'(2A,I4)') 'DARWIN_READTRAITS: ERROR: ',
     &    'bacteria has R_PICPOC.NE.0: ', jp
          CALL PRINT_ERROR( msgBuf , 1)
          STOP 'ABNORMAL END: S/R DARWIN_READTRAITS'
        ENDIF
       ELSE
        IF (isAerobic(jp).NE.0) THEN
          WRITE(msgBuf,'(2A,I4)') 'DARWIN_READTRAITS: ERROR: ',
     &    'isAerobic set for non-bacteria type: ', jp
          CALL PRINT_ERROR( msgBuf , 1)
          STOP 'ABNORMAL END: S/R DARWIN_READTRAITS'
        ENDIF
        IF (isDenit(jp).NE.0) THEN
          WRITE(msgBuf,'(2A,I4)') 'DARWIN_READTRAITS: ERROR: ',
     &    'isDenit set for non-bacteria type: ', jp
          CALL PRINT_ERROR( msgBuf , 1)
          STOP 'ABNORMAL END: S/R DARWIN_READTRAITS'
        ENDIF
       ENDIF

       DO jz=1,nplank
        IF (palat(jp,jz) .NE. 0.) THEN
         IF (isPrey(jp) .EQ. 0) THEN
          WRITE(msgBuf,'(2A,2I4)') 'DARWIN_READTRAITS: WARNING: ',
     &    'palat set for type outside of prey range: ', jp, jz
          CALL PRINT_ERROR( msgBuf , 1)
          IF (darwin_strict_check) THEN
           STOP 'palat set outside of prey range'
          ELSE
           palat(jp,jz) = 0. _d 0
          ENDIF
         ENDIF
         IF (isPred(jz) .EQ. 0) THEN
          WRITE(msgBuf,'(2A,2I4)') 'DARWIN_READTRAITS: WARNING: ',
     &    'palat set for type outside of predator range: ', jp, jz
          CALL PRINT_ERROR( msgBuf , 1)
          IF (darwin_strict_check) THEN
           STOP 'palat set outside of predator range'
          ELSE
           palat(jp,jz) = 0. _d 0
          ENDIF
         ENDIF
        ENDIF
       ENDDO
      ENDDO

C re-compute isPrey and isPred to speed up grazing loops
      DO jp=1,nplank
       isPrey(jp) = 0
       isPred(jp) = 0
      ENDDO
      DO jp=1,nplank
       DO jz=1,nplank
        IF (palat(jp,jz) .NE. 0.) THEN
         isPrey(jp) = 1
         isPred(jz) = 1
        ENDIF
       ENDDO
      ENDDO

      DO jz=1,nplank
        IF (isPred(jz) .NE. 0 .AND. R_PICPOC(jz).NE.0) THEN
          WRITE(msgBuf,'(2A,I4)') 'DARWIN_READTRAITS: ERROR: ',
     &    'predator has R_PICPOC.NE.0: ', jz
          CALL PRINT_ERROR( msgBuf , 1)
          STOP 'ABNORMAL END: S/R DARWIN_READTRAITS'
        ENDIF
      ENDDO

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C zero out unused trait entries, so they do not mess up the traits file
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      DO jp=1,nplank
#ifndef DARWIN_ALLOW_NQUOTA
       vmaxNH4(jp) = DARWIN_UNUSED
       vmaxNO2(jp) = DARWIN_UNUSED
       vmaxNO3(jp) = DARWIN_UNUSED
       vmaxN(jp) = DARWIN_UNUSED
       Qnmax(jp) = DARWIN_UNUSED
       Qnmin(jp) = DARWIN_UNUSED
#endif
#ifndef DARWIN_ALLOW_PQUOTA
       vmaxPO4(jp) = DARWIN_UNUSED
       Qpmax(jp) = DARWIN_UNUSED
       Qpmin(jp) = DARWIN_UNUSED
#endif
#ifndef DARWIN_ALLOW_SIQUOTA
       vmaxSiO2(jp) = DARWIN_UNUSED
       Qsimax(jp) = DARWIN_UNUSED
       Qsimin(jp) = DARWIN_UNUSED
#endif
#ifndef DARWIN_ALLOW_FEQUOTA
       vmaxFeT(jp) = DARWIN_UNUSED
       Qfemax(jp) = DARWIN_UNUSED
       Qfemin(jp) = DARWIN_UNUSED
#endif
#ifndef DARWIN_ALLOW_EXUDE
       kexcc(jp) = DARWIN_UNUSED
       kexcn(jp) = DARWIN_UNUSED
       kexcp(jp) = DARWIN_UNUSED
       kexcsi(jp) = DARWIN_UNUSED
       kexcfe(jp) = DARWIN_UNUSED
#endif
       IF (jp.GT.nPhoto) THEN
        diazo(jp) = DARWIN_UNUSED
        useNH4(jp) = DARWIN_UNUSED
        useNO2(jp) = DARWIN_UNUSED
        useNO3(jp) = DARWIN_UNUSED
        combNO(jp) = DARWIN_UNUSED
        amminhib(jp) = DARWIN_UNUSED
        acclimtimescl(jp) = DARWIN_UNUSED

        phytoTempCoeff(jp) = DARWIN_UNUSED
        phytoTempExp1(jp) = DARWIN_UNUSED
        phytoTempAe(jp) = DARWIN_UNUSED
        phytoTempExp2(jp) = DARWIN_UNUSED
        phytoTempOptimum(jp) = DARWIN_UNUSED
        phytoDecayPower(jp) = DARWIN_UNUSED

        vmaxNH4(jp) = DARWIN_UNUSED
        vmaxNO2(jp) = DARWIN_UNUSED
        vmaxNO3(jp) = DARWIN_UNUSED
        vmaxPO4(jp) = DARWIN_UNUSED
        vmaxSiO2(jp) = DARWIN_UNUSED
        vmaxFeT(jp) = DARWIN_UNUSED

        ksatNH4(jp) = DARWIN_UNUSED
        ksatNO2(jp) = DARWIN_UNUSED
        ksatNO3(jp) = DARWIN_UNUSED
        ksatPO4(jp) = DARWIN_UNUSED
        ksatSiO2(jp) = DARWIN_UNUSED
        ksatFeT(jp) = DARWIN_UNUSED

#ifdef DARWIN_ALLOW_GEIDER
        inhibGeider(jp) = DARWIN_UNUSED
#else
        ksatPAR(jp) = DARWIN_UNUSED
        kinhPAR(jp) = DARWIN_UNUSED
        normI(jp) = DARWIN_UNUSED
#endif
        mQyield(jp) = DARWIN_UNUSED
        chl2cmax(jp) = DARWIN_UNUSED
        chl2cmin(jp) = DARWIN_UNUSED
        DO l=1,nlam
         alphachl(jp,l) = DARWIN_UNUSED
        ENDDO
        alpha_mean(jp) = DARWIN_UNUSED
       ENDIF
       IF (isPred(jp) .EQ. 0) THEN
        grazemax(jp) = DARWIN_UNUSED
        kgrazesat(jp) = DARWIN_UNUSED
       ENDIF
       DO jp2=1,nplank
        IF (isPred(jp).EQ.0 .OR. isPrey(jp2).EQ.0) THEN
          palat(jp2,jp) = DARWIN_UNUSED
          asseff(jp2,jp) = DARWIN_UNUSED
          ExportFracPreyPred(jp2,jp) = DARWIN_UNUSED
        ENDIF
       ENDDO
      ENDDO

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     log all parameters to a namelist file

      IF ( oUnit .GE. 0 ) THEN
       WRITE(UNIT=oUnit, NML=DARWIN_TRAITS)
       WRITE(UNIT=oUnit, NML=DARWIN_DEPENDENT_TRAITS)
#ifdef ALLOW_RADTRANS
       WRITE(UNIT=oUnit, NML=DARWIN_RADTRANS_TRAITS)
#endif
       WRITE(UNIT=oUnit, NML=DARWIN_RT_DEPTRAITS)
      ENDIF

#endif /* ALLOW_DARWIN */

      RETURN
      END
