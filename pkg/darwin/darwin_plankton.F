#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_PLANKTON
C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_PLANKTON(
     I     Ptr,
     U     gTr,
     O     chlout, diags,
     I     PAR, photoTempFunc, hetTempFunc, grazTempFunc, reminTempFunc,
     I     mortTempFunc, mort2TempFunc, uptakeTempFunc,
#ifdef DARWIN_DEBUG
     I     iG, jG, k, dT,
#endif
     I     myTime,myIter,myThid)

C !DESCRIPTION:

C !USES: ===============================================================
      IMPLICIT NONE
#ifdef ALLOW_RADTRANS
#include "RADTRANS_SIZE.h"
#endif
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_DIAGS.h"
#include "DARWIN_RADTRANS.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"

C !INPUT PARAMETERS: ===================================================
C  Ptr    :: darwin model tracers
C  PAR    :: PAR in uEin/s/m2
C         :: either non-spectral (tlam=1) or waveband total
C  myTime :: current time
C  myIter :: current iteration number
C  myThid :: thread number
      _RL Ptr(nDarwin)
      _RL PAR(nlam)
      _RL photoTempFunc(nplank)
      _RL hetTempFunc(nplank)
      _RL reminTempFunc
      _RL uptakeTempFunc
      _RL grazTempFunc(nplank)
      _RL mortTempFunc
      _RL mort2TempFunc
      INTEGER myThid, myIter
      _RL myTime
#ifdef DARWIN_DEBUG
      INTEGER iG, jG, k
      _RL dT
#endif

C !INPUT/OUTPUT PARAMETERS: ============================================
C  gTr    :: accumulates computed tendencies
      _RL gTr(nDarwin)

C !OUTPUT PARAMETERS: ==================================================
C  chlout :: computed acclimated chlorophyll if not dynamic
      _RL chlout(nPhoto)
      _RL diags(darwin_nDiag)
CEOP

#ifdef ALLOW_DARWIN

c !LOCAL VARIABLES: ====================================================
      INTEGER j, l
      INTEGER jz, jp

      _RL DIC
      _RL NH4
      _RL NO2
      _RL NO3
      _RL PO4
      _RL SiO2
      _RL FeT
      _RL DOC
      _RL DON
      _RL DOP
      _RL DOFe
      _RL POC
      _RL PON
      _RL POP
      _RL POSi
      _RL POFe
      _RL pIC
      _RL O2

      _RL X(nplank)
      _RL Qc(nplank)
      _RL Qctot(nplank)
      _RL Qn(nplank)
      _RL Qp(nplank)
      _RL Qsi(nplank)
      _RL Qfe(nplank)
#ifdef DARWIN_ALLOW_CHLQUOTA
      _RL QChl(nPhoto)
#endif
      _RL Qch(nplank)

      _RL regQc
      _RL regQn
      _RL regQp
      _RL regQfe
      _RL regQsi

      _RL MM_PO4
      _RL MM_SiO2
      _RL MM_FeT
      _RL MM_NH4
      _RL MM_NO2
      _RL MM_NO3

      _RL limitpCO2
      _RL limitNH4
      _RL limitNO2
      _RL limitNO3
      _RL fracNH4
      _RL fracNO2
      _RL fracNO3
      _RL limitn
      _RL limitp
      _RL limitsi
      _RL limitfe
      _RL limitnut
      _RL limitI

      _RL muPON
      _RL muPOC
      _RL muPOP
      _RL muPOFe
      _RL muDON
      _RL muDOC
      _RL muDOP
      _RL muDOFe
      _RL muO
      _RL mu

      _RL uptakeDIC
      _RL uptakeNH4
      _RL uptakeNO2
      _RL uptakeNO3
      _RL uptakeN
      _RL uptakePO4
      _RL uptakeSiO2
      _RL uptakeFeT
      _RL consumDIC
      _RL consumDIC_PIC
      _RL consumNH4
      _RL consumNO2
      _RL consumNO3
      _RL consumPO4
      _RL consumSiO2
      _RL consumFeT

      _RL uptakePON
      _RL uptakePOP
      _RL uptakePOC
      _RL uptakePOFe
      _RL uptakeDON
      _RL uptakeDOP
      _RL uptakeDOC
      _RL uptakeDOFe
      _RL uptakeO2

      _RL respPON
      _RL respPOP
      _RL respPOC
      _RL respPOFe
      _RL respPOSi
      _RL respDON
      _RL respDOP
      _RL respDOC
      _RL respDOFe

      _RL hydrolPON
      _RL hydrolPOP
      _RL hydrolPOC
      _RL hydrolPOFe
      _RL solubilPON
      _RL solubilPOP
      _RL solubilPOC
      _RL solubilPOFe

      _RL consumPON
      _RL consumPOP
      _RL consumPOC
      _RL consumPOFe
      _RL consumPOSi
      _RL consumDON
      _RL consumDOP
      _RL consumDOC
      _RL consumDOFe
      _RL consumO2

      _RL inhibNH4

      _RL photoSyn
      _RL alpha_I
      _RL alpha_I_growth
      _RL PCm
      _RL PC
      _RL acclim
      _RL chl2c
      _RL growth
      _RL rhochl
      _RL Ek
      _RL EkoverE

      _RL synthChl

      _RL reminDOC
      _RL reminDON
      _RL reminDOP
      _RL reminDOFe
      _RL reminPOC
      _RL reminPON
      _RL reminPOP
      _RL reminPOSi
      _RL reminPOFe
      _RL disscPIC

      _RL prodNO2
      _RL prodNO3

      _RL PARtot

      _RL tmp

#ifdef DARWIN_ALLOW_CDOM
      _RL CDOM
      _RL reminPOC_CDOM
      _RL reminPON_CDOM
      _RL reminPOP_CDOM
      _RL reminPOFe_CDOM
      _RL degrCDOM_DOC
      _RL degrCDOM_DON
      _RL degrCDOM_DOP
      _RL degrCDOM_DOFe
#endif

#ifdef DARWIN_ALLOW_DENIT
      _RL denit, denitNH4
#endif

#ifdef DARWIN_ALLOW_CSTORE
      _RL Dmd_NC
      _RL Dmd_PC
      _RL Dmd_SiC
      _RL Dmd_FeC
      _RL Dmd_min
      _RL excretC
      _RL excC
      _RL storeC
#endif

C for grazing

      _RL sumprey, sumpref, grazphy

      _RL preygraz   (nplank)
      _RL preygrazexp(nplank)
      _RL grazrate   (nplank)
      _RL predgrazc  (nplank)
#ifdef DARWIN_ALLOW_NQUOTA
      _RL predgrazn  (nplank)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
      _RL predgrazp  (nplank)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
      _RL predgrazfe (nplank)
#endif

      _RL predexpc, predexpn, predexpp, predexpfe
      _RL graz2OC, graz2ON, graz2OP, graz2OFe
      _RL graz2POC, graz2PON, graz2POP, graz2POSi, graz2POFe
      _RL graz2PIC

      _RL expfrac

      _RL Xe
      _RL mortX
      _RL mortX2

      _RL exude_DOC
      _RL exude_DON
      _RL exude_DOP
      _RL exude_DOFe

      _RL exude_PIC
      _RL exude_POC
      _RL exude_PON
      _RL exude_POP
      _RL exude_POSi
      _RL exude_POFe

      _RL mort_c(nplank)

      _RL respir
      _RL respir_c
      _RL respirN
      _RL respirP
      _RL respirFe
      _RL respirSi

#ifdef DARWIN_ALLOW_CDOM
      _RL graz2CDOM, exude_CDOM
#endif

C=======================================================================
C==== Precompute a few things ==========================================

      PARtot = SUM(PAR)

C==== Make all bio fields non-negative and compute quotas ==============

      DIC  = MAX(0., Ptr(iDIC))
      NH4  = MAX(0., Ptr(iNH4))
      NO2  = MAX(0., Ptr(iNO2))
      NO3  = MAX(0., Ptr(iNO3))
      PO4  = MAX(0., Ptr(iPO4))
      SiO2 = MAX(0., Ptr(iSiO2))
      FeT  = MAX(0., Ptr(iFeT))

      DOC  = MAX(0., Ptr(iDOC))
      DON  = MAX(0., Ptr(iDON))
      DOP  = MAX(0., Ptr(iDOP))
      DOFe = MAX(0., Ptr(iDOFe))

      PIC  = MAX(0., Ptr(iPIC))
      POC  = MAX(0., Ptr(iPOC))
      PON  = MAX(0., Ptr(iPON))
      POP  = MAX(0., Ptr(iPOP))
      POSi = MAX(0., Ptr(iPOSi))
      POFe = MAX(0., Ptr(iPOFe))
#ifdef DARWIN_ALLOW_CARBON
      O2   = MAX(0., Ptr(iO2))
#endif
#ifdef DARWIN_ALLOW_CDOM
      CDOM = MAX(0., Ptr(iCDOM))
#endif

      DO j = 1, nplank
C fixed carbon quota, for now 1.0 (may change later)
        Qc(j) = 1.0
        Qctot(j) = 1.0
        X(j) = MAX(0., Ptr(ic+j-1))/Qc(j)
C other elements get quota from corresponding ptracer or set to fixed
c ratio if not variable.
#ifdef DARWIN_ALLOW_NQUOTA
        IF (X(j) .GT. 0 _d 0) THEN
          Qn(j) = MAX(0 _d 0, Ptr(in+j-1))/X(j)
        ELSE
          Qn(j) = Qnmax(j)
        ENDIF
#else
        Qn(j) = R_NC(j)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
        IF (X(j) .GT. 0 _d 0) THEN
          Qp(j) = MAX(0 _d 0, Ptr(ip+j-1))/X(j)
        ELSE
          Qp(j) = Qpmax(j)
        ENDIF
#else
        Qp(j) = R_PC(j)
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
        IF (X(j) .GT. 0 _d 0) THEN
          Qsi(j) = MAX(0 _d 0, Ptr(isi+j-1))/X(j)
        ELSE
          Qsi(j) = Qsimax(j)
        ENDIF
#else
        Qsi(j) = R_SiC(j)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
        IF (X(j) .GT. 0 _d 0) THEN
          Qfe(j) = MAX(0 _d 0, Ptr(ife+j-1))/X(j)
        ELSE
          Qfe(j) = Qfemax(j)
        ENDIF
#else
        Qfe(j) = R_FeC(j)
#endif
      ENDDO
#ifdef DARWIN_ALLOW_CHLQUOTA
      DO j = 1, nPhoto
        IF (X(j) .GT. 0 _d 0) THEN
          QChl(j) = MAX(0 _d 0, Ptr(iChl+j-1))/X(j)
        ELSE
          QChl(j) = chl2cmax(j)
        ENDIF
      ENDDO
#endif
#ifdef DARWIN_ALLOW_CSTORE
      DO j = 1, nPhoto
        IF (X(j) .GT. 0 _d 0) THEN
          Qch(j) = MAX(0 _d 0, Ptr(ich+j-1))/X(j)
        ELSE
          Qch(j) = 0 _d 0
        ENDIF
        Qctot(j) = Qctot(j) + Qch(j)
      ENDDO
#endif

C==== Initialize accumulators ==========================================
      consumDIC  = 0.0
      consumDIC_PIC = 0.0
      consumNH4  = 0.0
      consumNO2  = 0.0
      consumNO3  = 0.0
      consumPO4  = 0.0
      consumSiO2 = 0.0
      consumFeT  = 0.0
      consumPON  = 0.0
      consumPOP  = 0.0
      consumPOC = 0.0
      consumPOFe  = 0.0
      consumPOSi  = 0.0
      consumDON  = 0.0
      consumDOP  = 0.0
      consumDOC = 0.0
      consumDOFe  = 0.0
      consumO2 = 0.0
      reminPON  = 0.0
      reminPOP  = 0.0
      reminPOC = 0.0
      reminPOFe  = 0.0
      reminPOSi  = 0.0
      reminDON  = 0.0
      reminDOP  = 0.0
      reminDOC = 0.0
      reminDOFe  = 0.0
      solubilPON  = 0.0
      solubilPOP  = 0.0
      solubilPOC = 0.0
      solubilPOFe  = 0.0
      prodNO2 = 0.0
      prodNO3 = 0.0
      respir = 0.0 _d 0
#ifdef DARWIN_ALLOW_CSTORE
      excC = 0.0
#endif

      DO j = 1, nPhoto
        chlout(j) = 0.0 _d 0
      ENDDO

      DO l=1,darwin_nDiag
        diags(l) = 0.0
      ENDDO

C=======================================================================
C==== Phototrophy ======================================================

      DO j = 1, nPhoto
       IF (isPhoto(j) .NE. 0) THEN

C==== Uptake and nutrient limitation ===================================
C       for quota elements, growth is limiteed by available quota,
C       for non-quota elements, by available nutrients in medium

C       to not use PO4, ..., set ksatPO4=0 and vmaxPO4=0 (if DARWIN_ALLOW_PQUOTA)
C       or R_PC=0 (if not)
C       the result will be limitp = 1, uptakePO4 = 0

C       CSTORE/exudation:
C       Dmd_XC means the amount of carbon needed for biosynthesis when X
C       is the limiting nutrient.  To find the lowest demand (maximum
C       achievable growth rate), start with a large value.  Quota
C       elements will be handled further down in a dedicatd CSTORE
C       section.
#ifdef DARWIN_ALLOW_CSTORE
        Dmd_min = HUGE(Dmd_min)
#endif

c phosphorus
        IF (ksatPO4(j) .GT. 0 _d 0) THEN
          MM_PO4 = PO4/(PO4 + ksatPO4(j))
        ELSE
          MM_PO4 = 1 _d 0
        ENDIF
#ifdef DARWIN_ALLOW_PQUOTA
        regQp = MAX(0., MIN(1., (Qpmax(j)-Qp(j))/
     &                          (Qpmax(j)-Qpmin(j)) ))
        regQp = regQp**hillnumUptake
C       carbon-specific PO4 uptake rate
        uptakePO4 = vmaxPO4(j)*MM_PO4*regQp*uptakeTempFunc*X(j)
c       normalized Droop limitation
        limitp = MIN(1., (1.0-Qpmin(j)/MAX(Qpmin(j), Qp(j)))/
     &                   (1.0-Qpmin(j)/Qpmax(j)))
#else /* no PQUOTA */
# ifdef DARWIN_ALLOW_CSTORE
        IF (R_PC(j) .GT. 0 _d 0) THEN
          Dmd_PC = vmaxPO4(j)*MM_PO4*uptakeTempFunc*X(j)/R_PC(j)
          Dmd_min = MIN(Dmd_min, Dmd_PC)
        ELSE
C       set to zero to avoid floating point error in diagonstic
          Dmd_PC = 0 _d 0
        ENDIF
# else
        limitp = MM_PO4
# endif
#endif /* pquota */

c silica
        IF (ksatSiO2(j) .GT. 0 _d 0) THEN
          MM_SiO2 = SiO2/(SiO2 + ksatSiO2(j))
        ELSE
          MM_SiO2 = 1 _d 0
        ENDIF
#ifdef DARWIN_ALLOW_SIQUOTA
        regQsi = MAX(0., MIN(1., (Qsimax(j) - Qsi(j))/
     &                           (Qsimax(j) - Qsimin(j)) ))
        regQsi = regQsi**hillnumUptake
        uptakeSiO2 = vmaxSiO2(j)*MM_SiO2*regQsi*uptakeTempFunc*X(j)
c       linear limitation
        limitsi = MAX(0., MIN(1., (Qsi(j) - Qsimin(j))/
     &                         (Qsimax(j) - Qsimin(j)) ))
#else /* no SIQUOTA */
# ifdef DARWIN_ALLOW_CSTORE
        IF (R_SiC(j) .GT. 0 _d 0) THEN
          Dmd_SiC = VmaxSiO2(j)*MM_SiO2*uptakeTempFunc*X(j)/R_SiC(j)
          Dmd_min = MIN(Dmd_min, Dmd_SiC)
        ELSE
          Dmd_SiC = 0 _d 0
        ENDIF
# else
        limitsi = MM_SiO2
# endif
#endif

c iron
        IF (ksatFeT(j) .GT. 0 _d 0) THEN
          MM_FeT = FeT/(FeT + ksatFeT(j))
        ELSE
          MM_FeT = 1 _d 0
        ENDIF
#ifdef DARWIN_ALLOW_FEQUOTA
        regQfe = MAX(0., MIN(1., (Qfemax(j)-Qfe(j))/
     &                           (Qfemax(j)-Qfemin(j)) ))
        regQfe = regQfe**hillnumUptake
        uptakeFeT = vmaxFeT(j)*MM_FeT*regQfe*uptakeTempFunc*X(j)
c       normalized Droop limitation
        limitfe = MIN(1., (1.0-Qfemin(j)/MAX(Qfemin(j), Qfe(j)))/
     &                    (1.0-Qfemin(j)/Qfemax(j)))
#else /* no FEQUOTA */
C iron limit is applied in Geider
# ifdef DARWIN_ALLOW_CSTORE
        IF (R_FeC(j) .GT. 0 _d 0) THEN
          Dmd_FeC = vmaxFeT(j)*MM_FeT*uptakeTempFunc*X(j)/R_FeC(j)
          Dmd_min = MIN(Dmd_min, Dmd_FeC)
        ELSE
          Dmd_FeC = 0 _d 0
        ENDIF
# else
        limitfe = MM_FeT
# endif
#endif

c nitrogen
#ifdef DARWIN_ALLOW_NQUOTA
c       have nitrogen quota
        inhibNH4 = EXP(-amminhib(j)*NH4)
        MM_NH4 = NH4/(NH4 + ksatNH4(j))
        MM_NO2 = NO2/(NO2 + ksatNO2(j))*inhibNH4
        MM_NO3 = NO3/(NO3 + ksatNO3(j))*inhibNH4
        regQn = MAX(0., MIN(1., (Qnmax(j)-Qn(j))/
     &                          (Qnmax(j)-Qnmin(j)) ))
        regQn = regQn**hillnumUptake
        uptakeNH4 = vmaxNH4(j)*MM_NH4*regQn*uptakeTempFunc*X(j)
        uptakeNO2 = vmaxNO2(j)*MM_NO2*regQn*uptakeTempFunc*X(j)
        uptakeNO3 = vmaxNO3(j)*MM_NO3*regQn*uptakeTempFunc*X(j)
#ifdef DARWIN_ALLOW_FEQUOTA
#ifdef DARWIN_NITRATE_FELIMIT
        uptakeNO3 = uptakeNO3 * limitfe
#endif
#endif
        uptakeN = MAX(uptakeNH4 + uptakeNO2 + uptakeNO3,
     &                vmaxN(j)*regQn*uptakeTempFunc*X(j)*diazo(j))

c       linear limitation
        limitn = MAX(0., MIN(1., (Qn(j) - Qnmin(j))/
     &                        (Qnmax(j) - Qnmin(j)) ))
#else /* not DARWIN_ALLOW_NQUOTA */
        inhibNH4 = EXP(-amminhib(j)*NH4)
        limitNH4 = useNH4(j)*NH4/(NH4 + ksatNH4(j))
        limitNO2 = useNO2(j)*NO2/
     &   (NO2 + combNO(j)*(NO3 + ksatNO3(j) - ksatNO2(j)) + ksatNO2(j))*
     &   inhibNH4
        limitNO3 = useNO3(j)*NO3/
     &   (combNO(j)*NO2 + NO3 + ksatNO3(j))*inhibNH4
        limitn = limitNH4 + limitNO2 + limitNO3
C       normalize to sum 1
        IF (limitn .GT. 0 _d 0) THEN
          fracNH4 = limitNH4/limitn
          fracNO2 = limitNO2/limitn
          fracNO3 = limitNO3/limitn
        ELSE
          fracNH4 = 0 _d 0
          fracNO2 = 0 _d 0
          fracNO3 = 0 _d 0
        ENDIF
# ifdef DARWIN_ALLOW_CSTORE
C       compute maximum N uptake and C demand by N
        uptakeNH4 = vmaxNH4(j)*limitNH4*uptakeTempFunc*X(j)
        uptakeNO2 = vmaxNO2(j)*limitNO2*uptakeTempFunc*X(j)
        uptakeNO3 = vmaxNO3(j)*limitNO3*uptakeTempFunc*X(j)
        uptakeN = MAX(uptakeNH4 + uptakeNO2 + uptakeNO3,
     &                VmaxN(j)*uptakeTempFunc*diazo(j)*X(j))
        IF (R_NC(j) .GT. 0 _d 0) THEN
          Dmd_NC = uptakeN/R_NC(j)
          Dmd_min = MIN(Dmd_min, Dmd_NC)
        ELSE
          Dmd_NC = 0 _d 0
        ENDIF
# endif
C if diazo, all fracN* == 0 but want no N limitation
        limitn = MIN(1 _d 0, limitn)
        IF (diazo(j) .GT. 0) THEN
          limitn = 1 _d 0
        ENDIF
#endif /* DARWIN_ALLOW_NQUOTA */

#ifdef DARWIN_ALLOW_CSTORE
C       will apply limits for quota elements to growth rate instead
        limitnut = 1 _d 0
#else
        limitnut = MIN(limitn, limitp, limitsi)
#if !(defined DARWIN_ALLOW_GEIDER && defined DARWIN_ALLOW_FEQUOTA)
        limitnut = MIN(limitnut, limitfe)
#endif
#endif

        limitpCO2 = 1.

C==== Photosynthesis ===================================================
#ifdef DARWIN_ALLOW_GEIDER

        alpha_I = 0 _d 0
        DO l = 1, nlam
          alpha_I = alpha_I + alphachl(j,l)*PAR(l)
        ENDDO
C       NB: for quota, PCmax(j) = Vmax_c(j)
        PCm = PCmax(j)*limitnut*photoTempFunc(j)*limitpCO2

C       chl:c for 'balanced growth' at given light
        IF (PCm .GT. 0.0) THEN
          acclim = MAX(chl2cmin(j), MIN(chl2cmax(j),
     &             chl2cmax(j)/(1+(chl2cmax(j)*alpha_I)/(2*PCm)) ))
        ELSE
          acclim = chl2cmin(j)
        ENDIF

#ifdef DARWIN_ALLOW_CHLQUOTA
C       quotas are already relative to carbon
        chl2c = QChl(j)
#else
        chl2c = acclim
#endif

        alpha_I_growth = alpha_I
C a la quota
#ifdef DARWIN_ALLOW_FEQUOTA
        alpha_I_growth = alpha_I_growth*limitfe
#endif

C       carbon-specific growth rate
C       PC = PCm*(1-EXP(-alpha_I_growth*chl2c/MAX(EPS, PCm)))
        IF (PCm .GT. 0.0 .AND. PARtot .GT. PARmin) THEN
          PC = PCm*(1-EXP(-alpha_I_growth*chl2c/PCm))
        ELSE
          PC = 0.0 _d 0
        ENDIF

        IF (inhibGeider(j) .GT. 0.0) THEN
C         "total" PAR:
          tmp = alpha_I/alpha_mean(j)
          Ek = PCm/(chl2c*alpha_mean(j))
          EkoverE = Ek / tmp
          IF (tmp .GE. Ek) THEN
            PC = PC*EkoverE*inhibGeider(j)
          ENDIF
        ENDIF

#else /* not DARWIN_ALLOW_GEIDER */

        IF (PARtot .GT. PARmin) THEN
C         only 1 waveband without DARWIN_ALLOW_GEIDER
          limitI = (1.0 _d 0 - EXP(-PARtot*ksatPAR(j)))*
     &             EXP(-PARtot*kinhPAR(j)) * normI(j)
          PC = PCmax(j)*limitnut*limitI*photoTempFunc(j)*limitpCO2
        ELSE
          PC = 0.0 _d 0
        ENDIF
        synthChl = 0.0

#endif /* DARWIN_ALLOW_GEIDER */

        photoSyn = PC*X(j)

C==== Respiration ======================================================
C Respiration goes straight back to DIC, so we subtract from DIC uptake.
C Uptake of other non-quota elements is reduced according to plankton
C stoichiometry to ensure conservation of chemical elements.
C Zooplankton respiration is handled in the mortality/exudation loop.
        Xe = MAX(0 _d 0, X(j) - Xmin(j))
        respir_c = respRate(j)*Xe*reminTempFunc
        respir = respir + respir_c
        uptakeDIC = photoSyn - respir_c

C==== Growth ===========================================================
C Growth is growth rate of functional internal carbon

#ifdef DARWIN_ALLOW_CSTORE
C To decide the growth rate according to the minimum of C demand and
C photosynthesis.  To decide the minimum of C demand by the four
C elements (N, P, Si, Fe), Dmd_XC is the maximum carbon-specific
C photosynthesis rate convertible into biomass when X is the limiting
C nutrient as computed above.
        growth = MIN(uptakeDIC, Dmd_min)
        excretC = MAX(0.0, uptakeDIC - growth)*FracExudeC(j)
        excC = excC + excretC
        storeC = uptakeDIC - growth - excretC
#else /* without CSTORE */
        growth = uptakeDIC
#endif /* DARWIN_ALLOW_CSTORE */

C==== Geider 1997 Chlorophyll ==========================================
#ifdef DARWIN_ALLOW_GEIDER
# ifdef DARWIN_ALLOW_CHLQUOTA
#  ifdef DARWIN_ALLOW_NQUOTA
C       Geider 1998
        IF (PARtot .GT. PARmin) THEN
         IF (alpha_I*chl2c .GT. 0.0 _d 0) THEN
          rhochl = Chl2Nmax*PC/(alpha_I*chl2c)
         ELSE
          rhochl = Chl2Nmax
         ENDIF
         synthChl = rhochl*uptakeN
        ELSE
         synthChl = 0 _d 0
        ENDIF
C       synth cost goes straight back to DIC
        uptakeDIC = uptakeDIC - synthcost*uptakeN
        growth = growth - synthcost*uptakeN
#  else /* not DARWIN_ALLOW_NQUOTA */
#   ifdef DARWIN_GEIDER_RHO_SYNTH
        IF (alpha_I .GT. 0.0 _d 0 .AND. acclim .GT. 0.0 _d 0) THEN
C         should be chl2c instead of acclim?
          rhochl = Chl2Cmax(j)*PC/(alpha_I*acclim)
        ELSE
          rhochl = 0.0 _d 0    ! should be Chl2Cmax(j) ?????
        ENDIF
        synthChl = rhochl*growth +
     &                      acclimtimescl(j)*(acclim-chl2c)*X(j)
#   else
        synthChl = acclim*growth +
     &                      acclimtimescl(j)*(acclim-chl2c)*X(j)
#   endif
#  endif /* not DARWIN_ALLOW_NQUOTA */
# else /* not DARWIN_ALLOW_CHLQUOTA */
        chlout(j) = X(j)*Qc(j)*chl2c
        synthChl = 0.0
# endif /* DARWIN_ALLOW_CHLQUOTA */
#endif /* DARWIN_ALLOW_GEIDER */

C==== Uptake of non-quota elements =====================================
C       non-quota elements are taken up with fixed stoichiometry
#ifndef DARWIN_ALLOW_NQUOTA
        uptakeN = growth*R_NC(j)
C Maintain ratios of NH4, NO2 and NO3 uptake.
        IF (uptakeN .GE. 0 _d 0) THEN
         uptakeNH4 = uptakeN*fracNH4
         uptakeNO2 = uptakeN*fracNO2
         uptakeNO3 = uptakeN*fracNO3
        ELSE
C Do not allow uptake of NH4 and NO2 to go negative.
C Excess respired N goes to NO3.
         uptakeNH4 = 0 _d 0
         uptakeNO2 = 0 _d 0
         uptakeNO3 = uptakeN
        ENDIF
#endif
#ifndef DARWIN_ALLOW_PQUOTA
        uptakePO4 = growth*R_PC(j)
#endif
#ifndef DARWIN_ALLOW_SIQUOTA
        uptakeSiO2 = growth*R_SiC(j)
#endif
#ifndef DARWIN_ALLOW_FEQUOTA
        uptakeFeT = growth*R_FeC(j)
#endif

C==== Nutrient consumption =============================================
        consumDIC_PIC = consumDIC_PIC + growth*R_PICPOC(j)
        consumDIC  = consumDIC  + uptakeDIC
        consumNH4  = consumNH4  + uptakeNH4
        consumNO2  = consumNO2  + uptakeNO2
        consumNO3  = consumNO3  + uptakeNO3
        consumPO4  = consumPO4  + uptakePO4
        consumSiO2 = consumSiO2 + uptakeSiO2
        consumFeT  = consumFeT  + uptakeFeT

        diags(iPP) = diags(iPP) + uptakeDIC
#ifdef DARWIN_DIAG_PERTYPE
        diags(iPPplank+j-1) = diags(iPPplank+j-1) + uptakeDIC
        diags(iPCplank+j-1) = diags(iPCplank+j-1) + PC
#endif
        IF (diazo(j) .GT. 0.0 _d 0) THEN
         diags(iNfix)=diags(iNfix)+uptakeN-uptakeNH4-uptakeNO2-uptakeNO3
        ENDIF
#ifdef DARWIN_ALLOW_CSTORE
        diags(iEX) = diags(iEX) + excretC
        diags(iGW) = diags(iGW) + growth
        diags(iDN) = diags(iDN) + Dmd_NC
        diags(iDP) = diags(iDP) + Dmd_PC
        diags(iDFe) = diags(iDFe) + Dmd_FeC
        diags(iDSi) = diags(iDSi) + Dmd_SiC
        diags(iDmin)= diags(iDmin)+ Dmd_min
#ifdef DARWIN_ALLOW_CSTORE_DIAGS
        diags(iEXplank+j-1) = diags(iEXplank+j-1) + excretC
        diags(iGWplank+j-1) = diags(iGWplank+j-1) + growth
        diags(iDNplank+j-1) = diags(iDNplank+j-1) + Dmd_NC
        diags(iDPplank+j-1) = diags(iDPplank+j-1) + Dmd_PC
        diags(iDFplank+j-1) = diags(iDFplank+j-1) + Dmd_FeC
        diags(iDSplank+j-1) = diags(iDSplank+j-1) + Dmd_SiC
        diags(iDminplank+j-1) = diags(iDminplank+j-1) + Dmd_min
#endif
#endif

C==== Apply phototrophy tendencies =====================================

        gTr(ic+j-1)=gTr(ic+j-1)  + growth
#ifdef DARWIN_ALLOW_CSTORE
        gTr(ich+j-1)=gTr(ich+j-1)  + storeC
#endif
#ifdef DARWIN_ALLOW_NQUOTA
        gTr(in+j-1)=gTr(in+j-1)  + uptakeN
#endif
#ifdef DARWIN_ALLOW_PQUOTA
        gTr(ip+j-1)=gTr(ip+j-1)  + uptakePO4
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
        gTr(isi+j-1)=gTr(isi+j-1) + uptakeSiO2
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
        gTr(ife+j-1)=gTr(ife+j-1) + uptakeFeT
#endif
#ifdef DARWIN_ALLOW_CHLQUOTA
        gTr(iChl+j-1)=gTr(iChl+j-1) + synthChl
#endif

#ifdef DARWIN_DEBUG
        IF (iG.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
         print*,'uptake',myiter,k,j,
     &     uptakeDIC,
     &     uptakeNH4,
     &     uptakeNO2,
     &     uptakeNO3,
     &     uptakeN,
     &     uptakePO4,
     &     uptakeSiO2,
     &     uptakeFeT
        ENDIF
#endif

C      isPhoto(j)
       ENDIF
C     j
      ENDDO

C=======================================================================
C==== Bacteria =========================================================

      DO j = 1, nplank
       IF (bactType(j) .NE. 0) THEN

        uptakeO2  = 0. _d 0
        uptakeNO3 = 0. _d 0
        uptakePOC = 0. _d 0
        uptakePON = 0. _d 0
        uptakePOP = 0. _d 0
        uptakePOFe = 0. _d 0
        uptakeDOC = 0. _d 0
        uptakeDON = 0. _d 0
        uptakeDOP = 0. _d 0
        uptakeDOFe = 0. _d 0
        hydrolPOC = 0. _d 0
        hydrolPON = 0. _d 0
        hydrolPOP = 0. _d 0
        hydrolPOFe = 0. _d 0
        respPOC = 0. _d 0
        respPON = 0. _d 0
        respPOP = 0. _d 0
        respPOFe = 0. _d 0
        respDOC = 0. _d 0
        respDON = 0. _d 0
        respDOP = 0. _d 0
        respDOFe = 0. _d 0
        growth = 0. _d 0

        IF (isAerobic(j) .NE. 0) THEN
          muO = yieldO2(j)*pcoefO2*O2
        ELSEIF (isDenit(j) .NE. 0) THEN
          muO = yieldNO3(j)*pmaxDIN*NO3/(NO3 + ksatDIN)*hetTempFunc(j)
        ENDIF

C       POM-consuming (particle-associated)
        IF (bactType(j) .EQ. 1) THEN

          PCm = yield(j)*PCmax(j)*hetTempFunc(j)
          muPON  = PCm*PON/(PON + ksatPON(j))
          muPOC  = PCm*POC/(POC + ksatPOC(j))
          muPOP  = PCm*POP/(POP + ksatPOP(j))
          muPOFe = PCm*POFe/(POFe + ksatPOFe(j))
          mu = MIN(muPON, muPOC, muPOP, muPOFe, muO)

          growth = mu*X(j)

          uptakePOC = alpha_hydrol*growth/yield(j)
          uptakePON  = uptakePOC*R_NC(j)
          uptakePOP  = uptakePOC*R_PC(j)
          uptakePOFe = uptakePOC*R_FeC(j)
C         O2/NO3 is only used for the part of POC that is metabolized:
          uptakeO2 = isAerobic(j)*growth/yieldO2(j)
          uptakeNO3 = isDenit(j)*growth/yieldNO3(j)

C         This is the part of POM that is hydrolized into DOM:
          hydrolPOC = (alpha_hydrol-1)*growth/yield(j)
          hydrolPON  = hydrolPOC*R_NC(j)
          hydrolPOP  = hydrolPOC*R_PC(j)
          hydrolPOFe = hydrolPOC*R_FeC(j)

C         These are the bacteria products for remineralization of POM:
          respPOC = growth*(1/yield(j)-1)
          respPON  = respPOC*R_NC(j)
          respPOP  = respPOC*R_PC(j)
          respPOFe = respPOC*R_FeC(j)

C       DOM-consuming (free-living):
        ELSEIF (bactType(j) .EQ. 2) THEN

          PCm = yield(j)*PCmax(j)*hetTempFunc(j)
          muDON  = PCm*DON/(DON + ksatDON(j))
          muDOC  = PCm*DOC/(DOC + ksatDOC(j))
          muDOP  = PCm*DOP/(DOP + ksatDOP(j))
          muDOFe = PCm*DOFe/(DOFe + ksatDOFe(j))
          mu = MIN(muDON, muDOC, muDOP, muDOFe, muO)

          growth = mu*X(j)

          uptakeDOC = growth/yield(j)
          uptakeDON  = uptakeDOC*R_NC(j)
          uptakeDOP  = uptakeDOC*R_PC(j)
          uptakeDOFe = uptakeDOC*R_FeC(j)
          uptakeO2 = isAerobic(j)*growth/yieldO2(j)
          uptakeNO3 = isDenit(j)*growth/yieldNO3(j)

C         DOC respired to DIC
          respDOC = growth*(1/yield(j)-1)
          respDON  = respDOC*R_NC(j)
          respDOP  = respDOC*R_PC(j)
          respDOFe = respDOC*R_FeC(j)

        ENDIF

        diags(iDenitN) = diags(iDenitN) + uptakeNO3
#ifdef DARWIN_DIAG_PERTYPE
        diags(iHPplank+j-1) = diags(iHPplank+j-1) + growth
        diags(iHCplank+j-1) = diags(iHCplank+j-1) + mu
#endif

        gTr(ic+j-1) = gTr(ic+j-1) + growth

C bacteria have fixed elemental ratios for now
#ifdef DARWIN_ALLOW_NQUOTA
        gTr(in+j-1) = gTr(in+j-1) + growth*R_NC(j)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
        gTr(ip+j-1) = gTr(ip+j-1) + growth*R_PC(j)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
        gTr(ife+j-1) = gTr(ife+j-1) + growth*R_FeC(j)
#endif

C==== Cumulative consum, remin, and prod ===============================
        consumNO3  = consumNO3  + uptakeNO3

C       add B consum and accumulating remin, and prod:
        consumO2 = consumO2 + uptakeO2

        consumDOC = consumDOC + uptakeDOC
        consumDON = consumDON + uptakeDON
        consumDOP = consumDOP + uptakeDOP
        consumDOFe = consumDOFe + uptakeDOFe

        consumPOC = consumPOC + uptakePOC
        consumPON = consumPON + uptakePON
        consumPOP = consumPOP + uptakePOP
        consumPOFe = consumPOFe + uptakePOFe

        reminPOC = reminPOC + respPOC
        reminPON = reminPON + respPON
        reminPOP = reminPOP + respPOP
        reminPOFe = reminPOFe + respPOFe

        solubilPOC = solubilPOC + hydrolPOC
        solubilPON = solubilPON + hydrolPON
        solubilPOP = solubilPOP + hydrolPOP
        solubilPOFe = solubilPOFe + hydrolPOFe

        reminDOC = reminDOC + respDOC
        reminDON = reminDON + respDON
        reminDOP = reminDOP + respDOP
        reminDOFe = reminDOFe + respDOFe

       ENDIF
C     j loop end
      ENDDO

C=======================================================================
C==== Apply phototrophic and bacterial nutrient consumption ============

      gTr(iDIC )=gTr(iDIC ) - consumDIC - consumDIC_PIC

      diags(iConsDIC) = consumDIC
      diags(iConsDIC_PIC) = consumDIC_PIC

      gTr(iNH4 )=gTr(iNH4 ) - consumNH4
      gTr(iNO2 )=gTr(iNO2 ) - consumNO2
      gTr(iNO3 )=gTr(iNO3 ) - consumNO3
      gTr(iPO4 )=gTr(iPO4 ) - consumPO4
      gTr(iSiO2)=gTr(iSiO2) - consumSiO2
      gTr(iFeT )=gTr(iFeT ) - consumFeT

C==== Add parameterized remineralization ===============================
#ifdef DARWIN_ALLOW_DENIT
      IF (O2 .GE. O2crit .OR. NO3 .GE. NO3crit) THEN
#else
      IF (.TRUE.) THEN
#endif
C parameterized remineralization; want to set all K except KPOSi to zero
C if running with bacteria
      respDOC  = reminTempFunc*KDOC *DOC
      respDON  = reminTempFunc*KDON *DON
      respDOP  = reminTempFunc*KDOP *DOP
      respDOFe = reminTempFunc*KDOFe*DOFe
      respPOC  = reminTempFunc*KPOC *POC
      respPON  = reminTempFunc*KPON *PON
      respPOP  = reminTempFunc*KPOP *POP
      respPOSi = reminTempFunc*KPOSi*POSi
      respPOFe = reminTempFunc*KPOFe*POFe

      consumDOC  = consumDOC  + respDOC
      consumDON  = consumDON  + respDON
      consumDOP  = consumDOP  + respDOP
      consumDOFe = consumDOFe + respDOFe
      consumPOC  = consumPOC  + respPOC
      consumPON  = consumPON  + respPON
      consumPOP  = consumPOP  + respPOP
      consumPOSi = consumPOSi + respPOSi
      consumPOFe = consumPOFe + respPOFe

      reminDOC  = reminDOC  + respDOC
      reminDON  = reminDON  + respDON
      reminDOP  = reminDOP  + respDOP
      reminDOFe = reminDOFe + respDOFe
      reminPOC  = reminPOC  + respPOC
      reminPON  = reminPON  + respPON
      reminPOP  = reminPOP  + respPOP
      reminPOSi = reminPOSi + respPOSi
      reminPOFe = reminPOFe + respPOFe
C     endif O2, NO3 for DARWIN_ALLOW_DENIT
      ENDIF

#ifdef DARWIN_ALLOW_CARBON
      IF (O2 .GE. O2crit) THEN
        consumO2  = consumO2  + respDOP*R_OP
#ifndef DARWIN_ALLOW_CDOM
        consumO2  = consumO2  + respPOP*R_OP
#endif
      ENDIF
#endif

      disscPIC = Kdissc*PIC

C==== Nitrogen chemistry ===============================================
c NH4 -> NO2 -> NO3 by bacterial action, parameterized
      prodNO2 = knita*NH4
      prodNO3 = knitb*NO2
      IF (PAR_oxi .NE. 0.0 _d 0) THEN
        prodNO2 = prodNO2*MAX(0.0, 1.0 - PARtot/PAR_oxi)
        prodNO3 = prodNO3*MAX(0.0, 1.0 - PARtot/PAR_oxi)
      ENDIF

C==== CDOM =============================================================
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
      reminPOC_CDOM = fracCDOM*reminPOC
      reminPOP_CDOM = R_PC_CDOM*reminPOC_CDOM
      reminPON_CDOM = R_NC_CDOM*reminPOC_CDOM
      reminPOFe_CDOM = R_FeC_CDOM*reminPOC_CDOM
# else
      reminPOP_CDOM = fracCDOM*reminPOP
      reminPOC_CDOM = R_CP_CDOM*reminPOP_CDOM
      reminPON_CDOM = R_NP_CDOM*reminPOP_CDOM
      reminPOFe_CDOM = R_FeP_CDOM*reminPOP_CDOM
# endif
c degradation of  CDOM
      tmp = CDOMdegrd
#ifdef DARWIN_ALLOW_DENIT
      IF (O2 .LT. O2crit .AND. NO3 .LT. NO3crit) THEN
        tmp = 0 _d 0
      ENDIF
#endif
c increase when bleached by light
      tmp = tmp + CDOMbleach*MIN(1.0 _d 0, PARtot/PARCDOM)
# ifdef DARWIN_CDOM_UNITS_CARBON
      degrCDOM_DOC = reminTempFunc*CDOM*tmp
      degrCDOM_DOP  = R_PC_CDOM  * degrCDOM_DOC
      degrCDOM_DON  = R_NC_CDOM  * degrCDOM_DOC
      degrCDOM_DOFe = R_FeC_CDOM * degrCDOM_DOC
# else
      degrCDOM_DOP = reminTempFunc*CDOM*tmp
      degrCDOM_DOC  = R_CP_CDOM  * degrCDOM_DOP
      degrCDOM_DON  = R_NP_CDOM  * degrCDOM_DOP
      degrCDOM_DOFe = R_FeP_CDOM * degrCDOM_DOP
# endif
#endif

C==== Apply remaining tendencies =======================================

#ifdef DARWIN_ALLOW_CARBON
c production of O2 by photosynthesis
      gTr(iO2  )=gTr(iO2  ) + R_OP*consumPO4
      diags(iProdO2) = diags(iProdO2) + R_OP*consumPO4
c loss of O2 by remineralization
      IF (O2 .GE. O2crit) THEN
        gTr(iO2)=gTr(iO2) - consumO2
        diags(iConsO2) = diags(iConsO2) + consumO2
      ENDIF

      gTr(iALK)=gTr(iALK) - (prodNO3 - consumNO3)
     &                    - 2.0 _d 0*(consumDIC_PIC - disscPIC)
      diags(iSrcAlk) = diags(iSrcAlk) - (prodNO3 - consumNO3)
     &                    - 2.0 _d 0*(consumDIC_PIC - disscPIC)
#endif /* DARWIN_ALLOW_CARBON */

      gTr(iDIC )=gTr(iDIC ) + reminDOC + disscPIC

      diags(iReminDIC_DOC) = reminDOC
      diags(iDisscDIC_PIC) = disscPIC

      gTr(iNH4 )=gTr(iNH4 ) + reminDON - prodNO2
      gTr(iNO2 )=gTr(iNO2 ) + prodNO2 - prodNO3
      gTr(iNO3 )=gTr(iNO3 ) + prodNO3
#ifdef DARWIN_ALLOW_DENIT
      IF (O2 .LT. O2crit) THEN
        denitNH4 = reminDON
        denit = denit_NP*reminDOP
#ifndef DARWIN_ALLOW_CDOM
        denitNH4 = denitNH4 + reminPON
        denit = denit + denit_NP*reminPOP
#endif
        diags(iDenit) = denit
        gTr(iNH4)=gTr(iNH4) - denitNH4
        gTr(iNO3)=gTr(iNO3) - denit_NO3/denit_np*denit
        gTr(iALK)=gTr(iALK) + denit_NO3/denit_np*denit
        diags(iDenitN)=diags(iDenitN)+denitNH4+denit_NO3/denit_np*denit
        diags(iSrcAlk)=diags(iSrcAlk)+denit_NO3/denit_np*denit
      ENDIF
#endif /* DARWIN_ALLOW_DENIT */

      gTr(iPO4 )=gTr(iPO4 ) + reminDOP
      gTr(iFeT )=gTr(iFeT ) + reminDOFe
      gTr(iSiO2)=gTr(iSiO2)             + reminPOSi

C     DOC is created by #4 PA-assoc solubilization and consumed by #5
      gTr(iDOC )=gTr(iDOC ) + solubilPOC - consumDOC
#ifdef DARWIN_ALLOW_CSTORE
      gTr(iDOC )=gTr(iDOC ) + excC
#endif
      gTr(iDON )=gTr(iDON ) + solubilPON - consumDON
      gTr(iDOP )=gTr(iDOP ) + solubilPOP - consumDOP
      gTr(iDOFe)=gTr(iDOFe) + solubilPOFe - consumDOFe

      gTr(iPIC )=gTr(iPIC ) - disscPIC
      gTr(iPOC )=gTr(iPOC ) - consumPOC
      gTr(iPON )=gTr(iPON ) - consumPON
      gTr(iPOP )=gTr(iPOP ) - consumPOP
      gTr(iPOFe)=gTr(iPOFe) - consumPOFe
      gTr(iPOSi)=gTr(iPOSi) - consumPOSi

#ifdef DARWIN_ALLOW_CDOM
      gTr(iDOC )=gTr(iDOC ) + reminPOC  - reminPOC_CDOM  + degrCDOM_DOC
      gTr(iDON )=gTr(iDON ) + reminPON  - reminPON_CDOM  + degrCDOM_DON
      gTr(iDOP )=gTr(iDOP ) + reminPOP  - reminPOP_CDOM  + degrCDOM_DOP
      gTr(iDOFe)=gTr(iDOFe) + reminPOFe - reminPOFe_CDOM + degrCDOM_DOFe

# ifdef DARWIN_CDOM_UNITS_CARBON
      gTr(iCDOM)=gTr(iCDOM) + reminPOC_CDOM - degrCDOM_DOC
# else
      gTr(iCDOM)=gTr(iCDOM) + reminPOP_CDOM - degrCDOM_DOP
# endif
#else
      gTr(iDIC )=gTr(iDIC ) + reminPOC

      diags(iReminDIC_POC) = reminPOC

      gTr(iNH4 )=gTr(iNH4 ) + reminPON
      gTr(iPO4 )=gTr(iPO4 ) + reminPOP
      gTr(iFeT )=gTr(iFeT ) + reminPOFe
#endif /* DARWIN_ALLOW_CDOM */

      diags(iConsALK) = (prodNO3 - consumNO3)
     & +2.0 _d 0*(consumDIC_PIC - disscPIC)
      diags(iConsDIN) = consumNH4 + consumNO2 + consumNO3
      diags(iConsNO3) = consumNO3
      diags(iConsNO2) = consumNO2
      diags(iConsNH4) = consumNH4
      diags(iConsPO4) = consumPO4
      diags(iConsSi)  = consumSiO2
      diags(iConsFe)  = consumFeT

C=======================================================================
C==== Grazing ==========================================================

      DO j=1,nplank
       preygraz(j)   = 0.0
       preygrazexp(j) = 0.0
       grazrate(j)  = 0.0
       predgrazc(j)  = 0.0
#ifdef DARWIN_ALLOW_NQUOTA
       predgrazn(j)  = 0.0
#endif
#ifdef DARWIN_ALLOW_PQUOTA
       predgrazp(j)  = 0.0
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
       predgrazfe(j) = 0.0
#endif
      ENDDO
      graz2POC  = 0.0
      graz2PON  = 0.0
      graz2POP  = 0.0
      graz2POSI = 0.0
      graz2POFE = 0.0
      graz2OC   = 0.0
      graz2ON   = 0.0
      graz2OP   = 0.0
      graz2OFE  = 0.0
      graz2PIC  = 0.0

      regQn  = 1.0
      regQp  = 1.0
      regQfe = 1.0
      regQc  = 1.0

C=======================================================================
      DO jz = 1, nplank
       IF (isPred(jz).NE.0) THEN

C       regulate grazing near full quota
        regQc = 1.0 _d 0
#ifdef DARWIN_ALLOW_NQUOTA
        regQn = MAX(0., MIN(1., (Qnmax(jz)-Qn(jz))/
     &                          (Qnmax(jz)-Qnmin(jz)) ))
        regQc = MIN(regQc, 1.0 _d 0 - regQn)
        regQn = regQn**hillnumGraz
#endif
#ifdef DARWIN_ALLOW_PQUOTA
        regQp = MAX(0., MIN(1., (Qpmax(jz)-Qp(jz))/
     &                          (Qpmax(jz)-Qpmin(jz)) ))
        regQc = MIN(regQc, 1.0 _d 0 - regQp)
        regQp = regQp**hillnumGraz
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
        regQfe= MAX(0., MIN(1., (Qfemax(jz)-Qfe(jz))/
     &                          (Qfemax(jz)-Qfemin(jz)) ))
        regQc = MIN(regQc, 1.0 _d 0 - regQfe)
        regQfe=regQfe**hillnumGraz
#endif
        regQc = regQc**hillnumGraz

        sumprey = 0.0
        sumpref = 0.0
        DO jp = 1, nplank
        IF (palat(jp,jz).NE.0 _d 0) THEN
         sumprey = sumprey + palat(jp,jz)*X(jp)
#ifdef DARWIN_GRAZING_SWITCH
         sumpref = sumpref + palat(jp,jz)*palat(jp,jz)*X(jp)*X(jp)
#else
         sumpref = sumpref + palat(jp,jz)*X(jp)
#endif
        ENDIF
        ENDDO
        sumprey = MAX(0.0, sumprey - phygrazmin)
        sumpref = MAX(phygrazmin, sumpref)
        tmp = grazemax(jz)*grazTempFunc(jz)**tempGraz(jz)*
     &    (sumprey**hollexp/(sumprey**hollexp+kgrazesat(jz)**hollexp))*
     &    (1.0 - EXP(-inhib_graz*sumprey))**inhib_graz_exp

        predexpc  = 0.0 _d 0
        predexpn  = 0.0 _d 0
        predexpp  = 0.0 _d 0
        predexpfe = 0.0 _d 0
        DO jp = 1, nplank
         IF (palat(jp,jz).NE.0 _d 0) THEN
#ifdef DARWIN_GRAZING_SWITCH
          grazphy = tmp*palat(jp,jz)*palat(jp,jz)*X(jp)*X(jp)/sumpref
#else
          grazphy = tmp*palat(jp,jz)*X(jp)/sumpref
#endif
          grazrate(jz) = grazrate(jz) + grazphy*asseff(jp,jz)*regQc
          grazphy = grazphy*X(jz)

          expFrac = ExportFracPreyPred(jp,jz)

          preygraz(jp) = preygraz(jp) + grazphy
          preygrazexp(jp) = preygrazexp(jp) + expFrac*grazphy

          predgrazc(jz) = predgrazc(jz) + grazphy*asseff(jp,jz)*
     &                                    regQc*Qctot(jp)
          predexpc = predexpc + expFrac*grazphy*asseff(jp,jz)*
     &                                    regQc*Qctot(jp)
#ifdef DARWIN_ALLOW_NQUOTA
          predgrazn(jz) = predgrazn(jz) + grazphy*asseff(jp,jz)*
     &                                    regQn*Qn(jp)
          predexpn = predexpn + expFrac*grazphy*asseff(jp,jz)*
     &                                    regQn*Qn(jp)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
          predgrazp(jz) = predgrazp(jz) + grazphy*asseff(jp,jz)*
     &                                    regQp*Qp(jp)
          predexpp = predexpp + expFrac*grazphy*asseff(jp,jz)*
     &                                  regQp*Qp(jp)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
          predgrazfe(jz) = predgrazfe(jz) + grazphy*asseff(jp,jz)*
     &                                      regQfe*Qfe(jp)
          predexpfe = predexpfe + expFrac*grazphy*asseff(jp,jz)*
     &                                    regQfe*Qfe(jp)
#endif
         ENDIF
        ENDDO

C organic-matter gain will be total preygraz - predgraz
        graz2OC   = graz2OC  - predgrazc(jz)
        graz2POC  = graz2POC - predexpc

#ifdef DARWIN_ALLOW_NQUOTA
        graz2ON   = graz2ON  - predgrazn(jz)
        graz2PON  = graz2PON - predexpn
#else
        graz2ON   = graz2ON  - predgrazc(jz)*Qn(jz)
        graz2PON  = graz2PON - predexpc     *Qn(jz)
#endif

#ifdef DARWIN_ALLOW_PQUOTA
        graz2OP   = graz2OP  - predgrazp(jz)
        graz2POP  = graz2POP - predexpp
#else
        graz2OP   = graz2OP  - predgrazc(jz)*Qp(jz)
        graz2POP  = graz2POP - predexpc     *Qp(jz)
#endif

#ifdef DARWIN_ALLOW_FEQUOTA
        graz2OFe  = graz2OFe  - predgrazfe(jz)
        graz2POFe = graz2POFe - predexpfe
#else
        graz2OFe  = graz2OFe  - predgrazc(jz)*Qfe(jz)
        graz2POFe = graz2POFe - predexpc     *Qfe(jz)
#endif

       ENDIF
C     end predator loop
      ENDDO

      DO jp = 1, nplank
       IF (isPrey(jp).NE.0) THEN
          graz2OC  = graz2OC  + preygraz(jp)*Qctot(jp)
          graz2ON  = graz2ON  + preygraz(jp)*Qn (jp)
          graz2OP  = graz2OP  + preygraz(jp)*Qp (jp)
          graz2POSi = graz2POSi + preygraz(jp)*Qsi(jp)
          graz2OFe = graz2OFe + preygraz(jp)*Qfe(jp)
          graz2PIC = graz2PIC + preygraz(jp)*R_PICPOC(jp)

          graz2POC  = graz2POC  + preygrazexp(jp)*Qctot(jp)
          graz2PON  = graz2PON  + preygrazexp(jp)*Qn (jp)
          graz2POP  = graz2POP  + preygrazexp(jp)*Qp (jp)
          graz2POFe = graz2POFe + preygrazexp(jp)*Qfe(jp)
       ENDIF
      ENDDO

C==== Apply grazing tendencies =========================================

      gTr(iDOC )=gTr(iDOC ) + graz2OC  - graz2POC
      gTr(iDON )=gTr(iDON ) + graz2ON  - graz2PON
      gTr(iDOP )=gTr(iDOP ) + graz2OP  - graz2POP
      gTr(iDOFe)=gTr(iDOFe) + graz2OFe - graz2POFe
      gTr(iPOC )=gTr(iPOC ) + graz2POC
      gTr(iPON )=gTr(iPON ) + graz2PON
      gTr(iPOP )=gTr(iPOP ) + graz2POP
      gTr(iPOSi)=gTr(iPOSi) + graz2POSi
      gTr(iPOFe)=gTr(iPOFe) + graz2POFe
      gTr(iPIC )=gTr(iPIC ) + graz2PIC
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
      graz2CDOM = fracCDOM*(graz2OC - graz2POC)
# else
      graz2CDOM = fracCDOM*(graz2OP - graz2POP)
# endif
      gTr(iCDOM)=gTr(iCDOM) + graz2CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
      gTr(iDOC )=gTr(iDOC ) -           graz2CDOM
      gTr(iDON )=gTr(iDON ) - R_NC_CDOM*graz2CDOM
      gTr(iDOP )=gTr(iDOP ) - R_PC_CDOM*graz2CDOM
      gTr(iDOFe)=gTr(iDOFe) - R_FeC_CDOM*graz2CDOM
# else
      gTr(iDOC )=gTr(iDOC )             - R_CP_CDOM*graz2CDOM
      gTr(iDON )=gTr(iDON )             - R_NP_CDOM*graz2CDOM
      gTr(iDOP )=gTr(iDOP ) - graz2CDOM
      gTr(iDOFe)=gTr(iDOFe)             - R_FeP_CDOM*graz2CDOM
# endif
#endif

      DO jp = 1, nplank
      IF (isPrey(jp).NE.0) THEN
       gTr(ic+jp-1)= gTr(ic+jp-1) - preygraz(jp)
#ifdef DARWIN_ALLOW_NQUOTA
       gTr(in+jp-1)=gTr(in+jp-1) - preygraz(jp)*Qn(jp)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
       gTr(ip+jp-1)=gTr(ip+jp-1) - preygraz(jp)*Qp(jp)
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
       gTr(isi+jp-1)=gTr(isi+jp-1) - preygraz(jp)*Qsi(jp)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
       gTr(ife+jp-1)=gTr(ife+jp-1) - preygraz(jp)*Qfe(jp)
#endif
      ENDIF
      ENDDO
#ifdef DARWIN_ALLOW_CHLQUOTA
      DO jp = 1, nPhoto
      IF (isPrey(jp).NE.0) THEN
       gTr(iChl+jp-1)=gTr(iChl+jp-1) - preygraz(jp)*QChl(jp)
      ENDIF
      ENDDO
#endif
#ifdef DARWIN_ALLOW_CSTORE
      DO jp = 1, nPhoto
      IF (isPrey(jp).NE.0) THEN
       gTr(ich+jp-1)=gTr(ich+jp-1) - preygraz(jp)*Qch(jp)
      ENDIF
      ENDDO
#endif

      DO jz = 1, nplank
      IF (isPred(jz).NE.0) THEN
       gTr(ic+jz-1)=gTr(ic+jz-1) + predgrazc(jz)
#ifdef DARWIN_ALLOW_NQUOTA
       gTr(in+jz-1)=gTr(in+jz-1) + predgrazn(jz)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
       gTr(ip+jz-1)=gTr(ip+jz-1) + predgrazp(jz)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
       gTr(ife+jz-1)=gTr(ife+jz-1) + predgrazfe(jz)
#endif
      ENDIF
      ENDDO

#ifdef DARWIN_DIAG_PERTYPE
      DO jp = 1, nplank
        diags(iGRplank+jp-1) = preygraz(jp)
      ENDDO
      DO jz = 1, nplank
        diags(iGrGn+jz-1) = predgrazc(jz)
        diags(iGrGC+jz-1) = grazrate(jz)
      ENDDO
#endif

C=======================================================================
C==== Mortality and parameterized exudation ============================
      exude_DOC  = 0.0 _d 0
      exude_POC  = 0.0 _d 0
      exude_DON  = 0.0 _d 0
      exude_PON  = 0.0 _d 0
      exude_DOFe = 0.0 _d 0
      exude_POFe = 0.0 _d 0
      exude_DOP  = 0.0 _d 0
      exude_POP  = 0.0 _d 0
      exude_POSi = 0.0 _d 0
      exude_PIC  = 0.0 _d 0
      respir     = 0.0 _d 0
      respirN    = 0.0 _d 0
      respirP    = 0.0 _d 0
      respirFe   = 0.0 _d 0
      respirSi   = 0.0 _d 0

      DO jp = 1, nplank
        Xe = MAX(0 _d 0, X(jp) - Xmin(jp))
        mortX = mort(jp)*Xe*mortTempFunc**tempMort(jp)
        mortX2= mort2(jp)*Xe*Xe*mort2TempFunc**tempMort2(jp)

        mort_c(jp) = mortX + mortX2

#ifdef DARWIN_ALLOW_CSTORE
        exude_DOC=exude_DOC+(1.-ExportFracMort(jp)) *mortX*Qctot(jp)
     &                     +(1.-ExportFracMort2(jp))*mortX2*Qctot(jp)
        exude_POC=exude_POC+    ExportFracMort(jp)  *mortX*Qctot(jp)
     &                     +    ExportFracMort2(jp) *mortX2*Qctot(jp)
#else
        exude_DOC = exude_DOC + (1.-ExportFracMort(jp)) *mortX
     &                        + (1.-ExportFracMort2(jp))*mortX2
        exude_POC = exude_POC +     ExportFracMort(jp)  *mortX
     &                        +     ExportFracMort2(jp) *mortX2
#endif

        exude_DON = exude_DON + (1.-ExportFracMort(jp)) *mortX *Qn(jp)
     &                        + (1.-ExportFracMort2(jp))*mortX2*Qn(jp)
        exude_PON = exude_PON +     ExportFracMort(jp)  *mortX *Qn(jp)
     &                        +     ExportFracMort2(jp) *mortX2*Qn(jp)

        exude_DOP = exude_DOP + (1.-ExportFracMort(jp)) *mortX *Qp(jp)
     &                        + (1.-ExportFracMort2(jp))*mortX2*Qp(jp)
        exude_POP = exude_POP +     ExportFracMort(jp)  *mortX *Qp(jp)
     &                        +     ExportFracMort2(jp) *mortX2*Qp(jp)

        exude_DOFe= exude_DOFe+ (1.-ExportFracMort(jp)) *mortX *Qfe(jp)
     &                        + (1.-ExportFracMort2(jp))*mortX2*Qfe(jp)
        exude_POFe= exude_POFe+     ExportFracMort(jp)  *mortX *Qfe(jp)
     &                        +     ExportFracMort2(jp) *mortX2*Qfe(jp)

        exude_POSi = exude_POSi + mort_c(jp)*Qsi(jp)

        exude_PIC = exude_PIC + mort_c(jp)*R_PICPOC(jp)

C Respiration of non-phototrophs
C Respired carbon goes to DIC.  Other non-quota elements go to inorganic
C matter pools according to plankton stoichiometry.  PIC also goes back
C to DIC as if it had never been synthesized.
        IF (isPhoto(jp) .EQ. 0) THEN
         respir_c = respRate(jp)*Xe*reminTempFunc
         gTr(ic+jp-1) = gTr(ic+jp-1) - respir_c
         respir = respir + respir_c*(1 _d 0 + R_PICPOC(jp))
#ifndef DARWIN_ALLOW_NQUOTA
         respirN = respirN + respir_c*R_NC(jp)
#endif
#ifndef DARWIN_ALLOW_PQUOTA
         respirP = respirP + respir_c*R_PC(jp)
#endif
#ifndef DARWIN_ALLOW_FEQUOTA
         respirFe = respirFe + respir_c*R_FeC(jp)
#endif
#ifndef DARWIN_ALLOW_SIQUOTA
         respirSi = respirSi + respir_c*R_SiC(jp)
#endif
        ENDIF

        gTr(ic+jp-1)=gTr(ic+jp-1)  - mort_c(jp)
#ifdef DARWIN_ALLOW_NQUOTA
        gTr(in+jp-1)=gTr(in+jp-1)  - mort_c(jp)*Qn(jp)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
        gTr(ip+jp-1)=gTr(ip+jp-1)  - mort_c(jp)*Qp(jp)
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
        gTr(isi+jp-1)=gTr(isi+jp-1) - mort_c(jp)*Qsi(jp)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
        gTr(ife+jp-1)=gTr(ife+jp-1) - mort_c(jp)*Qfe(jp)
#endif

#ifdef DARWIN_ALLOW_EXUDE
        exude_DOC =
     &  exude_DOC + (1.-ExportFracExude(jp))*kexcc(jp)*Xe
        exude_POC =
     &  exude_POC +     ExportFracExude(jp) *kexcc(jp)*Xe
        exude_DON =
     &  exude_DON + (1.-ExportFracExude(jp))*kexcn(jp)*Xe*Qn(jp)
        exude_PON =
     &  exude_PON +     ExportFracExude(jp) *kexcn(jp)*Xe*Qn(jp)
        exude_DOP =
     &  exude_DOP + (1.-ExportFracExude(jp))*kexcp(jp)*Xe*Qp(jp)
        exude_POP =
     &  exude_POP +     ExportFracExude(jp) *kexcp(jp)*Xe*Qp(jp)
        exude_DOFe =
     &  exude_DOFe + (1.-ExportFracExude(jp))*kexcfe(jp)*Xe*Qfe(jp)
        exude_POFe =
     &  exude_POFe +     ExportFracExude(jp) *kexcfe(jp)*Xe*Qfe(jp)
        exude_POSi =
     &  exude_POSi + kexcsi(jp)*Xe*Qsi(jp)
        exude_PIC = exude_PIC + kexcc(jp)*Xe*R_PICPOC(jp)
        gTr(ic+jp-1)=gTr(ic+jp-1)   - kexcc(jp)*Xe
#ifdef DARWIN_ALLOW_NQUOTA
        gTr(in+jp-1)=gTr(in+jp-1)   - kexcn(jp)*Xe*Qn(jp)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
        gTr(ip+jp-1)=gTr(ip+jp-1)   - kexcp(jp)*Xe*Qp(jp)
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
        gTr(isi+jp-1)=gTr(isi+jp-1) - kexcsi(jp)*Xe*Qsi(jp)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
        gTr(ife+jp-1)=gTr(ife+jp-1) - kexcfe(jp)*Xe*Qfe(jp)
#endif
#endif
      ENDDO

#ifdef DARWIN_ALLOW_CHLQUOTA
      DO jp = 1, nPhoto
        gTr(iChl+jp-1)=gTr(iChl+jp-1) - mort_c(jp)*QChl(jp)
      ENDDO
#endif
#ifdef DARWIN_ALLOW_CSTORE
      DO jp = 1, nPhoto
        gTr(ich+jp-1)=gTr(ich+jp-1) - mort_c(jp)*Qch(jp)
      ENDDO
#endif

      gTr(iDIC) = gTr(iDIC) + respir
#ifndef DARWIN_ALLOW_NQUOTA
      gTr(iNO3) = gTr(iNO3) + respirN
#endif
#ifndef DARWIN_ALLOW_PQUOTA
      gTr(iPO4) = gTr(iPO4) + respirP
#endif
#ifndef DARWIN_ALLOW_FEQUOTA
      gTr(iFeT) = gTr(iFeT) + respirFe
#endif
#ifndef DARWIN_ALLOW_SIQUOTA
      gTr(iSiO2) = gTr(iSiO2) + respirSi
#endif

      diags(iRespirDIC) = respir

      gTr(iDOC )=gTr(iDOC ) + exude_DOC
      gTr(iDON )=gTr(iDON ) + exude_DON
      gTr(iDOP )=gTr(iDOP ) + exude_DOP
      gTr(iDOFe)=gTr(iDOFe) + exude_DOFe

      gTr(iPIC )=gTr(iPIC ) + exude_PIC
      gTr(iPOC )=gTr(iPOC ) + exude_POC
      gTr(iPON )=gTr(iPON ) + exude_PON
      gTr(iPOP )=gTr(iPOP ) + exude_POP
      gTr(iPOSi)=gTr(iPOSi) + exude_POSi
      gTr(iPOFe)=gTr(iPOFe) + exude_POFe
#ifdef DARWIN_ALLOW_CDOM
      exude_CDOM = fracCDOM*exude_DOP
      gTr(iCDOM)=gTr(iCDOM) + exude_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
      gTr(iDOC )=gTr(iDOC ) -           exude_CDOM
      gTr(iDON )=gTr(iDON ) - R_NC_CDOM*exude_CDOM
      gTr(iDOP )=gTr(iDOP ) - R_PC_CDOM*exude_CDOM
      gTr(iDOFe)=gTr(iDOFe) - R_FeC_CDOM*exude_CDOM
# else
      gTr(iDOC )=gTr(iDOC )              - R_CP_CDOM*exude_CDOM
      gTr(iDON )=gTr(iDON )              - R_NP_CDOM*exude_CDOM
      gTr(iDOP )=gTr(iDOP ) - exude_CDOM
      gTr(iDOFe)=gTr(iDOFe)              - R_FeP_CDOM*exude_CDOM
# endif
#endif

#endif /* ALLOW_DARWIN */

      RETURN
      END SUBROUTINE

