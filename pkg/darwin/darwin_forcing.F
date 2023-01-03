#include "DARWIN_OPTIONS.h"
#ifdef ALLOW_SEAICE
#include "SEAICE_OPTIONS.h"
#endif

CBOP
C !ROUTINE: DARWIN_FORCING
C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_FORCING( Ptrdummy,
     I                        bi, bj, iMin, iMax, jMin, jMax,
     I                        myIter, myTime, myThid )

C !DESCRIPTION:

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "GRID.h"
#include "EEPARAMS.h"
#ifdef ALLOW_EXCH2
#include "W2_EXCH2_SIZE.h"
#include "W2_EXCH2_TOPOLOGY.h"
#include "W2_EXCH2_PARAMS.h"
#endif
#include "PARAMS.h"
#include "DYNVARS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PTRACERS_FIELDS.h"
#ifdef ALLOW_SEAICE
#include "SEAICE_SIZE.h"
#include "SEAICE.h"
#endif
#ifdef ALLOW_RADTRANS
#include "RADTRANS_SIZE.h"
#endif
#ifdef ALLOW_DARWIN
#include "GCHEM.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_DIAGS.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"
#include "DARWIN_FIELDS.h"
#include "DARWIN_EXF_FIELDS.h"
#endif
#ifdef DARWIN_NUTRIENT_RUNOFF
#include "DARWIN_EXF_PARAMS.h"
#endif

C !INPUT PARAMETERS: ===================================================
C  Ptrdummy             :: dummy for darwin2 compatibility
C  myThid               :: thread number
      _RL Ptrdummy(*)
      _RL myTime
      INTEGER iMin, iMax, jMin, jMax, bi, bj, myIter, myThid
CEOP

#ifdef ALLOW_DARWIN

C!LOCAL VARIABLES: ====================================================
C  i,j                  :: loop indices
C  k                    :: vertical level
      LOGICAL  DIAGNOSTICS_IS_ON
      EXTERNAL DIAGNOSTICS_IS_ON
      INTEGER i,j,k,kdn,iTr,l,isub
      CHARACTER*8 diagname
      _RL dTsub(Nr)
      _RL midTime, subTime
#if defined ALLOW_DIAGNOSTICS && ! defined DARWIN_ALLOW_CONS
      _RL DARWIN_minFeLoss(sNx,sNy,Nr,nSx,nSy)
#endif
      _RL gPtr(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nDarwin)
      _RL PAR(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL diags(1-OLx:sNx+OLx,1-OLy:sNy+OLy, Nr, darwin_nDiag)
      _RL gDIC(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
      _RL gALK(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
#ifdef DARWIN_DIAG_TENDENCIES
      _RL gDICsurfForc(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL gNO3surfForc(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL gNO2surfForc(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL gNH4surfForc(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL gPO4surfForc(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL gFeTsurfForc(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL gSiO2surfForc(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
#ifdef DARWIN_ALLOW_CARBON
      _RL gALKsurfForc(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL gO2surfForc(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
#endif
#endif
      _RL gO2(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
      _RL surfFe(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
      _RL freeFe(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr)
      _RL sedFlxFe(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
      _RL tmp3d(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr)
      _RL scavRate(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr)
      _RL scavLoss(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr)
      _RL scv,scav_pom
      _RL flx, POCl
      _RL ptr(nDarwin), gtr(nDarwin), PARl(nlam)
      _RL chlout(nPhoto)
      _RL diagsl(darwin_nDiag)
      _RL photoTempFunc(nplank)
      _RL hetTempFunc(nplank)
      _RL grazTempFunc(nplank)
      _RL reminTempFunc
      _RL mortTempFunc
      _RL mort2TempFunc
      _RL uptakeTempFunc
      _RL tmp, tmpFac
      _RL sedFe(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
#ifdef DARWIN_ALLOW_HYDROTHERMAL_VENTS
      _RL ventFe(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
#endif
      INTEGER k_debug
#ifdef DARWIN_DEBUG
      INTEGER iG, jG
      INTEGER iBase, jBase
      INTEGER iGjLoc, jGjLoc
#ifdef ALLOW_EXCH2
      INTEGER tN
#endif /* ALLOW_EXCH2 */
#endif /* DARWIN_DEBUG */

      DO k=1,Nr
       DO j=1,sNy
        DO i=1,sNx
         DARWIN_minFeLoss(i,j,k,bi,bj) = 0 _d 0
        ENDDO
       ENDDO
      ENDDO

      DO l=1,darwin_nDiag
       DO k=1,Nr
        DO j=1,sNy
         DO i=1,sNx
          diags(i,j,k,l) = 0 _d 0
         ENDDO
        ENDDO
       ENDDO
      ENDDO

      DO k=1,Nr
       dTsub(k) = PTRACERS_dTLev(k)/nsubtime
      ENDDO

C     time at middle of sub-timestep
      midTime = myTime - deltaTclock + .5*deltaTclock/nsubtime
C     time at end of sub-timestep
      subTime = myTime - deltaTclock + deltaTclock/nsubtime
      DO isub=1,nsubtime

C === reset tendencies =================================================
      DO itr=1,nDarwin
      DO k=1,Nr
      DO j=jMin,jMax
      DO i=iMin,iMax
        gPtr(i,j,k,iTr) = 0.0 _d 0
      ENDDO
      ENDDO
      ENDDO
      ENDDO

C === light ============================================================
C     Initialize Chl from balanced-growth Chl:C if requested
C     and check Chl:C bounds.
C     Note: myIter has already been incremented
c      IF (myIter-1 .EQ. darwin_chlIter0) THEN
c        CALL DARWIN_INIT_CHL(bi, bj, subTime, myIter, myThid)
c      ENDIF

#ifdef ALLOW_SEAICE
      IF (DARWIN_useSEAICE) THEN
       DO j=jMin,jMax
        DO i=iMin,iMax
         iceFrac(i,j,bi,bj) = AREA(i,j,bi,bj)
        ENDDO
       ENDDO
      ENDIF
#endif

      CALL TIMER_START('DARWIN_LIGHT [DARWIN_FORCING]',myThid)
#ifdef ALLOW_RADTRANS
      CALL DARWIN_LIGHT_RADTRANS(PAR,subTime,bi,bj,iMin,iMax,jMin,jMax,
     &                        subTime,myIter,myThid)
#else
      CALL DARWIN_LIGHT(PAR, midTime, bi, bj, iMin, iMax, jMin, jMax,
     &               subTime, myIter, myThid)
#endif
      CALL TIMER_STOP ('DARWIN_LIGHT [DARWIN_FORCING]',myThid)

C === dic ==============================================================
#ifdef DARWIN_ALLOW_CARBON
C carbon air-sea interaction
      CALL TIMER_START('DARWIN_SURFFORCING [DARWIN_FORCING]',myThid)
      CALL DARWIN_SURFFORCING(
     O                    gDIC, gALK, gO2,
     I                    dTsub,bi,bj,iMin,iMax,jMin,jMax,
     I                    subTime,myIter,myThid)
      CALL TIMER_STOP ('DARWIN_SURFFORCING [DARWIN_FORCING]',myThid)
      DO j=jMin,jMax
      DO i=iMin,iMax
        gPtr(i,j,1,iDIC) = gPtr(i,j,1,iDIC) + gDIC(i,j)
        gPtr(i,j,1,iALK) = gPtr(i,j,1,iALK) + gALK(i,j)
        gPtr(i,j,1,iO2)  = gPtr(i,j,1,iO2)  + gO2(i,j)
      ENDDO
      ENDDO

#ifdef NONLIN_FRSURF
C-    Account for change in level thickness
C     Other contributions to gPtr must come after these calls!
      IF (nonlinFreeSurf.GT.0) THEN
        CALL FREESURF_RESCALE_G(
     I                           bi, bj, 1,
     U                           gPtr(1-OLx,1-OLy,1,iDIC),
     I                           myThid )
        CALL FREESURF_RESCALE_G(
     I                           bi, bj, 1,
     U                           gPtr(1-OLx,1-OLy,1,iALK),
     I                           myThid )
        CALL FREESURF_RESCALE_G(
     I                           bi, bj, 1,
     U                           gPtr(1-OLx,1-OLy,1,iO2),
     I                           myThid )
      ENDIF
#endif /* NONLIN_FRSURF */
#endif /* DARWIN_ALLOW_CARBON */

#ifdef DARWIN_DIAG_TENDENCIES
C surface fluxes from E/P/runoff with constant/local concentrations
      DO j=jMin,jMax
      DO i=iMin,iMax
        gDICsurfForc(i,j) = surfaceForcingPTr(i,j,bi,bj,iDIC)
     &   * recip_drF(1)*recip_hFacC(i,j,1,bi,bj)
        gNO3surfForc(i,j) = surfaceForcingPTr(i,j,bi,bj,iNO3)
     &   * recip_drF(1)*recip_hFacC(i,j,1,bi,bj)
        gNO2surfForc(i,j) = surfaceForcingPTr(i,j,bi,bj,iNO2)
     &   * recip_drF(1)*recip_hFacC(i,j,1,bi,bj)
        gNH4surfForc(i,j) = surfaceForcingPTr(i,j,bi,bj,iNH4)
     &   * recip_drF(1)*recip_hFacC(i,j,1,bi,bj)
        gPO4surfForc(i,j) = surfaceForcingPTr(i,j,bi,bj,iPO4)
     &   * recip_drF(1)*recip_hFacC(i,j,1,bi,bj)
        gFeTsurfForc(i,j) = surfaceForcingPTr(i,j,bi,bj,iFeT)
     &   * recip_drF(1)*recip_hFacC(i,j,1,bi,bj)
        gSiO2surfForc(i,j) = surfaceForcingPTr(i,j,bi,bj,iSiO2)
     &   * recip_drF(1)*recip_hFacC(i,j,1,bi,bj)
#ifdef DARWIN_ALLOW_CARBON
        gALKsurfForc(i,j) = surfaceForcingPTr(i,j,bi,bj,iALK)
     &   * recip_drF(1)*recip_hFacC(i,j,1,bi,bj)
        gO2surfForc(i,j) = surfaceForcingPTr(i,j,bi,bj,iO2)
     &   * recip_drF(1)*recip_hFacC(i,j,1,bi,bj)
#endif
      ENDDO
      ENDDO
#endif

C === nutrient runoff ==================================================
#ifdef DARWIN_NUTRIENT_RUNOFF
      CALL DARWIN_ADD_SURFFORC(
     U                          gPtr(1-OLx,1-OLy,1,iDOC),
     I                          DOCrunoff(1-OLx,1-OLy,bi,bj), 1 _d 0,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )

      CALL DARWIN_ADD_SURFFORC(
     U                          gPtr(1-OLx,1-OLy,1,iDON),
     I                          DONrunoff(1-OLx,1-OLy,bi,bj), 1 _d 0,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )

      CALL DARWIN_ADD_SURFFORC(
     U                          gPtr(1-OLx,1-OLy,1,iDOP),
     I                          DOPrunoff(1-OLx,1-OLy,bi,bj), 1 _d 0,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )

      CALL DARWIN_ADD_SURFFORC(
     U                          gPtr(1-OLx,1-OLy,1,iNO3),
     I                          DINrunoff(1-OLx,1-OLy,bi,bj),
     I                          R_NO3_DIN_runoff,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )

      CALL DARWIN_ADD_SURFFORC(
     U                          gPtr(1-OLx,1-OLy,1,iNO2),
     I                          DINrunoff(1-OLx,1-OLy,bi,bj),
     I                          R_NO2_DIN_runoff,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )

      CALL DARWIN_ADD_SURFFORC(
     U                          gPtr(1-OLx,1-OLy,1,iNH4),
     I                          DINrunoff(1-OLx,1-OLy,bi,bj),
     I                          R_NH4_DIN_runoff,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )

      CALL DARWIN_ADD_SURFFORC(
     U                          gPtr(1-OLx,1-OLy,1,iPO4),
     I                          IPrunoff(1-OLx,1-OLy,bi,bj),
     I                          R_DIP_IP_runoff,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )

      CALL DARWIN_ADD_SURFFORC(
     U                          gPtr(1-OLx,1-OLy,1,iSiO2),
     I                          DSirunoff(1-OLx,1-OLy,bi,bj), 1 _d 0,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )

      CALL DARWIN_ADD_SURFFORC(
     U                          gPtr(1-OLx,1-OLy,1,iPOC),
     I                          POCrunoff(1-OLx,1-OLy,bi,bj), 1 _d 0,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )

      CALL DARWIN_ADD_SURFFORC(
     U                          gPtr(1-OLx,1-OLy,1,iPON),
     I                          PONrunoff(1-OLx,1-OLy,bi,bj), 1 _d 0,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )

      CALL DARWIN_ADD_SURFFORC(
     U                          gPtr(1-OLx,1-OLy,1,iPOP),
     I                          POPrunoff(1-OLx,1-OLy,bi,bj), 1 _d 0,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )

      CALL DARWIN_ADD_SURFFORC(
     U                          gPtr(1-OLx,1-OLy,1,iDIC),
     I                          DICrunoff(1-OLx,1-OLy,bi,bj), 1 _d 0,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )

#ifdef DARWIN_ALLOW_CARBON
      CALL DARWIN_ADD_SURFFORC(
     U                          gPtr(1-OLx,1-OLy,1,iALK),
     I                          DICrunoff(1-OLx,1-OLy,bi,bj),
     I                          R_ALK_DIC_runoff,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )
#endif

      CALL DARWIN_ADD_SURFFORC(
     U                          gPtr(1-OLx,1-OLy,1,iFeT),
     I                          IPrunoff(1-OLx,1-OLy,bi,bj),
     I                          R_DIP_IP_runoff*R_DFe_DIP_runoff,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )

      CALL DARWIN_ADD_SURFFORC(
     U                          gPtr(1-OLx,1-OLy,1,iDOFe),
     I                          DOPrunoff(1-OLx,1-OLy,bi,bj),
     I                          R_DOFe_DOP_runoff,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )

      CALL DARWIN_ADD_SURFFORC(
     U                          gPtr(1-OLx,1-OLy,1,iPOFe),
     I                          POPrunoff(1-OLx,1-OLy,bi,bj),
     I                          R_POFe_POP_runoff,
     I                          bi, bj, iMin, iMax, jMin, jMax,
     I                          myIter, myTime, myThid )
#endif

C === iron =============================================================

C     compute (and limit if DARWIN_MINFE) free iron
      CALL TIMER_START('DARWIN_FE_CHEM [DARWIN_FORCING]',myThid)
      CALL DARWIN_FE_CHEM(
     U                 Ptracer(1-OLx,1-OLy,1,bi,bj,iFeT),
     O                 freeFe(1-OLx,1-OLy,1),
     U                 DARWIN_minFeLoss(1,1,1,bi,bj),
     I                 bi, bj, iMin, iMax, jMin, jMax, myThid)
      CALL TIMER_STOP ('DARWIN_FE_CHEM [DARWIN_FORCING]',myThid)

C ----------------------------------------------------------------------
C     scavenging
      CALL TIMER_START('DARWIN_FE_SCAV [DARWIN_FORCING]',myThid)
      DO k=1,Nr
      DO j=jMin,jMax
      DO i=iMin,iMax
C       compute POM in mg/L
#ifdef DARWIN_PART_SCAV_POP
        scav_pom = MAX(0 _d 0, Ptracer(i,j,k,bi,bj,iPOP))/scav_R_POPPOC
        scv = scav_rat*scav_inter*(scav_pom**scav_exp)
#elif defined(DARWIN_PART_SCAV)
        scav_pom = scav_POC_wgt*MAX(0 _d 0, Ptracer(i,j,k,bi,bj,iPOC))
     &           + scav_POSi_wgt*MAX(0 _d 0, Ptracer(i,j,k,bi,bj,iPOSi))
     &           + scav_PIC_wgt*MAX(0 _d 0, Ptracer(i,j,k,bi,bj,iPIC))
        scv = scav_tau*scav_inter*(scav_pom**scav_exp)
#else
        scv = scav
#endif
        scavRate(i,j,k) = scv
        scavLoss(i,j,k) = scv*MAX(0 _d 0, freefe(i,j,k))
        gPtr(i,j,k,iFeT) = gPtr(i,j,k,iFeT) - scavLoss(i,j,k)
#ifdef DARWIN_ALLOW_CONS
        DARWIN_partScav(i,j,k,bi,bj) = DARWIN_partScav(i,j,k,bi,bj)
     &                               + dTsub(k)*scavLoss(i,j,k)
#endif
      ENDDO
      ENDDO
      ENDDO
      CALL TIMER_STOP ('DARWIN_FE_SCAV [DARWIN_FORCING]',myThid)

C ----------------------------------------------------------------------
C     iron dust input
      CALL TIMER_START('DARWIN_FE_DUST [DARWIN_FORCING]',myThid)
      DO j=jMin,jMax
       DO i=iMin,iMax
        tmp3d(i,j,1) = alpfe * inputFe(i,j,bi,bj)
     &               * recip_drF(1) * recip_hFacC(i,j,1,bi,bj)
       ENDDO
      ENDDO
#ifdef NONLIN_FRSURF
C-    Account for change in level thickness
      IF (nonlinFreeSurf.GT.0) THEN
        CALL FREESURF_RESCALE_G(
     I                           bi, bj, 1,
     U                           tmp3d,
     I                           myThid )
      ENDIF
#endif /* NONLIN_FRSURF */
      DO j=jMin,jMax
       DO i=iMin,iMax
        gPtr(i,j,1,iFeT) = gPtr(i,j,1,iFeT) + tmp3d(i,j,1)
       ENDDO
      ENDDO
      CALL TIMER_STOP ('DARWIN_FE_DUST [DARWIN_FORCING]',myThid)

C ----------------------------------------------------------------------
C     iron sediment source (in bottom grid cell above kMaxFeSed)
      CALL TIMER_START('DARWIN_FE_SED [DARWIN_FORCING]',myThid)
      DO k=1,Nr
       DO j=jMin,jMax
        DO i=iMin,iMax
         sedFe(i,j,k) = 0 _d 0
        ENDDO
       ENDDO
      ENDDO
      DO j=jMin,jMax
       DO i=iMin,iMax
        k = kLowC(i,j,bi,bj)
        IF (k .GE. kMinFeSed .AND. k .LE. kMaxFeSed) THEN
#ifdef DARWIN_IRON_SED_SOURCE_VARIABLE
# ifdef DARWIN_IRON_SED_SOURCE_POP
          flx = fesedflux_pcm*wp_sink*R_CP_fesed*
     &            MAX(0 _d 0, Ptracer(i,j,k-1,bi,bj,iPOP))
# else
          POCl = MAX(0 _d 0, Ptracer(i,j,k,bi,bj,iPOC))
          flx = fesedflux_pcm*wc_sink*POCl - fesedflux_min
          flx = MAX(0. _d 0, flx)
# endif
#else
          flx = fesedflux
#endif
          sedFlxFe(i,j) = flx
          sedFe(i,j,k) = flx/(drF(k)*hFacC(i,j,k,bi,bj))
#ifdef DARWIN_ALLOW_CONS
          ironSedFlx(i,j,bi,bj) = ironSedFlx(i,j,bi,bj) + dTsub(k)*flx
#endif
        ELSE
         sedFlxFe(i,j) = 0 _d 0
        ENDIF
       ENDDO
      ENDDO
      DO k=kMinFeSed, kMaxFeSed
#ifdef NONLIN_FRSURF
C-    Account for change in level thickness
       IF (nonlinFreeSurf.GT.0) THEN
        CALL FREESURF_RESCALE_G(
     I                           bi, bj, k,
     U                           sedFe,
     I                           myThid )
       ENDIF
#endif /* NONLIN_FRSURF */
       DO j=jMin,jMax
        DO i=iMin,iMax
          gPtr(i,j,k,iFeT) = gPtr(i,j,k,iFeT) + sedFe(i,j,k)
        ENDDO
       ENDDO
      ENDDO
      CALL TIMER_STOP ('DARWIN_FE_SED [DARWIN_FORCING]',myThid)

C ----------------------------------------------------------------------
C     iron sediment source (in bottom grid cell above kMaxFeSed)
C     iron source due to hydrothermal input into bottom layer below
C     kMinFeVents (ventHe3 flux is mmol.m-2.s-1)
#ifdef DARWIN_ALLOW_HYDROTHERMAL_VENTS
      IF (darwin_haveVentHe3) THEN
       CALL TIMER_START('DARWIN_FE_VENT [DARWIN_FORCING]',myThid)
       DO k=1,Nr
        DO j=jMin,jMax
         DO i=iMin,iMax
          ventFe(i,j,k) = 0 _d 0
         ENDDO
        ENDDO
       ENDDO
       DO j=jMin,jMax
        DO i=iMin,iMax
         k = kLowC(i,j,bi,bj)
         IF (k .GE. kMinFeVent) THEN
          flx = solFeVent*R_FeHe3_vent*ventHe3(i,j,bi,bj)
          ventFe(i,j,k) = flx*recip_drF(k)*recip_hFacC(i,j,k,bi,bj)
# ifdef DARWIN_ALLOW_CONS
          ironVentFlx(i,j,bi,bj)=ironVentFlx(i,j,bi,bj) + dTsub(k)*flx
# endif
         ENDIF
        ENDDO
       ENDDO
       DO k=kMinFeVent,Nr
# ifdef NONLIN_FRSURF
C-    Account for change in level thickness
        IF (nonlinFreeSurf.GT.0) THEN
         CALL FREESURF_RESCALE_G(
     I                            bi, bj, k,
     U                            ventFe,
     I                            myThid )
        ENDIF
# endif /* NONLIN_FRSURF */
        DO j=jMin,jMax
         DO i=iMin,iMax
           gPtr(i,j,k,iFeT) = gPtr(i,j,k,iFeT) + ventFe(i,j,k)
         ENDDO
        ENDDO
       ENDDO
       CALL TIMER_STOP ('DARWIN_FE_VENT [DARWIN_FORCING]',myThid)
      ENDIF
#endif

C === plankton =========================================================
      CALL TIMER_START('DARWIN_PLANKTON [DARWIN_FORCING]',myThid)

#ifdef DARWIN_DEBUG
C Set dimensions:
C-    default:
      iGjLoc = 0
      jGjLoc = 1
      iBase = myXGlobalLo-1 + (bi-1)*sNx
      jBase = myYGlobalLo-1 + (bj-1)*sNy
#ifdef ALLOW_EXCH2
      IF ( W2_useE2ioLayOut ) THEN
        tN = W2_myTileList(bi,bj)
        iBase = exch2_txGlobalo(tN) - 1
        jBase = exch2_tyGlobalo(tN) - 1
        IF   ( exch2_mydNx(tN) .GT. exch2_global_Nx ) THEN
C-      face x-size larger than glob-size : fold it
          iGjLoc = 0
          jGjLoc = exch2_mydNx(tN) / exch2_global_Nx
        ELSEIF ( exch2_tNy(tN) .GT. exch2_global_Ny ) THEN
C-      tile y-size larger than glob-size : make a long line
          iGjLoc = exch2_mydNx(tN)
          jGjLoc = 0
        ELSE
C-      default (face fit into global-IO-array)
          iGjLoc = 0
          jGjLoc = 1
        ENDIF
      ENDIF
#endif /* ALLOW_EXCH2 */
#endif /* DARWIN_DEBUG */

      do k=1,Nr
      do j=jMin,jMax
#ifdef DARWIN_DEBUG
       iG = iBase + (j-1)*iGjLoc
       jG = jBase + (j-1)*jGjLoc + 1
#endif /* DARWIN_DEBUG */

       do i=iMin,iMax
       if (hFacC(i,j,k,bi,bj) .GT. 0.) then
        k_debug = 0
#ifdef DARWIN_DEBUG
        IF (iG+i.eq.iDEBUG.and.jG.eq.jDEBUG) THEN
         IF (kDEBUG.EQ.0 .OR. k.EQ.kDebug) THEN
          k_debug = k
         ENDIF
        ENDIF
#endif
        CALL DARWIN_TEMPFUNC(Theta(i,j,k,bi,bj),
     &         photoTempFunc, hetTempFunc, grazTempFunc,
     &         reminTempFunc, mortTempFunc, mort2TempFunc,
     &         uptakeTempFunc, myThid)
        DO iTr=1,nDarwin
         ptr(iTr) = Ptracer(i, j, k, bi, bj, iTr)
         gtr(iTr) = gPtr(i, j, k, iTr)
        ENDDO
        DO l=1,nlam
         PARl(l) = MAX(0 _d 0, PAR(i, j, k, l))
        ENDDO
        CALL DARWIN_PLANKTON(
     I                 ptr,
     U                 gtr,
     O                 chlout, diagsl,
     I                 PARl, photoTempFunc,
     I                 hetTempFunc,
     I                 grazTempFunc,
     I                 reminTempFunc,
     I                 mortTempFunc, mort2TempFunc,
     I                 uptakeTempFunc,
     I                 k_debug,
     I                 subTime, myIter, myThid )
        DO l=1,darwin_nDiag
         diags(i, j, k, l) = diagsl(l)
        ENDDO
#ifdef DARWIN_ALLOW_CONS
        DARWIN_Nfix(i,j,k,bi,bj)   = DARWIN_Nfix(i,j,k,bi,bj)
     &                             + dTsub(k)*diagsl(iNfix)
        DARWIN_Ndenit(i,j,k,bi,bj) = DARWIN_Ndenit(i,j,k,bi,bj)
     &                             + dTsub(k)*diagsl(iDenitN)
        DARWIN_O2prod(i,j,k,bi,bj) = DARWIN_O2prod(i,j,k,bi,bj)
     &                             + dTsub(k)*diagsl(iProdO2)
        DARWIN_O2cons(i,j,k,bi,bj) = DARWIN_O2cons(i,j,k,bi,bj)
     &                             + dTsub(k)*diagsl(iConsO2)
        DARWIN_AlkSrc(i,j,k,bi,bj) = DARWIN_AlkSrc(i,j,k,bi,bj)
     &                             + dTsub(k)*diagsl(iSrcAlk)
#endif
#ifndef DARWIN_ALLOW_CHLQUOTA
#ifdef ALLOW_RADTRANS
        DO l=1,nPhoto
         chlPrev(i, j, k, bi, bj, l) = chlout(l)
        ENDDO
#else
        tmp = 0 _d 0
        DO l=1,nPhoto
         tmp = tmp + chlout(l)
        ENDDO
        chlPrev(i, j, k, bi, bj) = tmp
#endif
#endif
        DO iTr=1,nDarwin
         gPtr(i, j, k, iTr) = gtr(iTr)
        ENDDO
       endif
       enddo
      enddo
      enddo
      CALL TIMER_STOP('DARWIN_PLANKTON [DARWIN_FORCING]',myThid)

C === pre-sinking diags ================================================
#ifdef ALLOW_DIAGNOSTICS
      IF (useDIAGNOSTICS) THEN
       CALL TIMER_START('DIAGS_FILL [DARWIN_FORCING]',myThid)
       DO iTr=1,nDarwin
        diagname = 'gECO'//PTRACERS_ioLabel(iTr)
        CALL DIAGNOSTICS_FILL(gPtr(1-OLx,1-OLy,1,iTr), diagname,
     &                        0,Nr,2,bi,bj,myThid)
       ENDDO
       CALL TIMER_STOP ('DIAGS_FILL [DARWIN_FORCING]',myThid)
      ENDIF
#endif

C === sinking ==========================================================
      CALL TIMER_START('DARWIN_SINKING [DARWIN_FORCING]',myThid)
      CALL DARWIN_SINKING( Ptracer,gPtr,dTsub,bi,bj,iMin,iMax,jMin,jMax,
     &                  subTime,myIter,myThid )
      CALL TIMER_STOP ('DARWIN_SINKING [DARWIN_FORCING]',myThid)

C === apply tendencies to tracers ======================================
      CALL TIMER_START('DARWIN_STEP [DARWIN_FORCING]',myThid)
      DO iTr=1,nDarwin
      DO k=1,Nr
      DO j=jMin,jMax
      DO i=iMin,iMax
        pTracer(i,j,k,bi,bj,iTr)=pTracer(i,j,k,bi,bj,iTr)
     &                      +dTsub(k)*gPtr(i,j,k,iTr)*maskInC(i,j,bi,bj)
      ENDDO
      ENDDO
      ENDDO
      ENDDO
      CALL TIMER_STOP ('DARWIN_STEP [DARWIN_FORCING]',myThid)

C === iron =============================================================
C     re-apply free iron limit to FeT
#ifdef DARWIN_MINFE
      CALL TIMER_START('DARWIN_FE_CHEM [DARWIN_FORCING]',myThid)
      CALL DARWIN_FE_CHEM(
     U                 pTracer(1-OLx,1-OLy,1,bi,bj,iFeT),
     O                 freeFe(1-OLx,1-OLy,1),
     U                 DARWIN_minFeLoss(1,1,1,bi,bj),
     I                 bi, bj, iMin, iMax, jMin, jMax, myThid)
      CALL TIMER_STOP ('DARWIN_FE_CHEM [DARWIN_FORCING]',myThid)
#endif

C === diagnostics ======================================================
#ifdef ALLOW_DIAGNOSTICS
      IF (useDIAGNOSTICS) THEN
       CALL TIMER_START('DIAGS_FILL [DARWIN_FORCING]',myThid)
       DO l = 1, nlam
        WRITE(diagname, '(A,I3.3)') 'PAR', l
        CALL DIAGNOSTICS_FILL(PAR(1-OLx,1-OLy,1,l),diagname,0,Nr,2,
     &                        bi,bj,myThid)
       ENDDO
       IF (DIAGNOSTICS_IS_ON('PAR     ', myThid)) THEN
        DO l=2,nlam
         DO k=1,Nr
          DO j=1,sNy
           DO i=1,sNx
            PAR(i,j,k,1) = PAR(i,j,k,1) + PAR(i,j,k,l)
           ENDDO
          ENDDO
         ENDDO
        ENDDO
        WRITE(diagname, '(A)') 'PAR'
        CALL DIAGNOSTICS_FILL(PAR,diagname,0,Nr,2,bi,bj,myThid)
       ENDIF
#ifndef DARWIN_ALLOW_CHLQUOTA
       IF (DIAGNOSTICS_IS_ON('Chl     ', myThid)) THEN
#ifdef ALLOW_RADTRANS
        DO k=1,Nr
         DO j=1,sNy
          DO i=1,sNx
           tmp3d(i,j,k) = 0 _d 0
          ENDDO
         ENDDO
        ENDDO
        DO l=1,nlam
         DO k=1,Nr
          DO j=1,sNy
           DO i=1,sNx
            tmp3d(i,j,k) = tmp3d(i,j,k) + chlPrev(i,j,k,bi,bj,l)
           ENDDO
          ENDDO
         ENDDO
        ENDDO
        CALL DIAGNOSTICS_FILL(tmp3d,'Chl     ',0,Nr,2,bi,bj,myThid)
#else
        CALL DIAGNOSTICS_FILL(chlPrev,'Chl     ',0,Nr,1,bi,bj,myThid)
#endif
       ENDIF
#endif
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iPP),   'PP      ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iNfix), 'Nfix    ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iDenit),'Denit   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iDenitN),'DenitN  ',
     &       0,Nr,2,bi,bj,myThid)
#ifdef DARWIN_ALLOW_CSTORE
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iEX),   'EXU     ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iGW),   'BioSyn  ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iDN),   'DmdN    ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iDP),   'DmdP    ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iDFe),  'DmdFe   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iDSi),  'DmdSi   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iDmin), 'Dmdmin  ',
     &       0,Nr,2,bi,bj,myThid)
#endif

C      nutrient consumption diagnostics
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsDIN),'C_DIN   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsNO3),'C_NO3   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsNO2),'C_NO2   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsNH4),'C_NH4   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsPO4),'C_PO4   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsSi), 'C_Si    ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsFe), 'C_Fe    ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsDIC),'C_DIC   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsDIC_PIC),
     &           'C_DICPIC',0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iRespirDIC),'respDIC ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iReminDIC_DOC),
     &           'rDIC_DOC',0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iReminDIC_POC),
     &           'rDIC_POC',0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iDisscDIC_PIC),
     &           'dDIC_PIC',0,Nr,2,bi,bj,myThid)
#ifdef DARWIN_ALLOW_CARBON
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsALK),'C_ALK   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsO2), 'C_O2    ',
     &       0,Nr,2,bi,bj,myThid)
#endif

C      compute 'source' diagnostics: tendencies without consumption;
C      add full tendencies to consumption and store result back into
C      diags(iCons*) for convenience
       DO k=1,Nr
        DO j=1,sNy
         DO i=1,sNx
            diags(i,j,k,iConsDIN) = diags(i,j,k,iConsDIN)
     &         + gPtr(i,j,k,iNH4) + gPtr(i,j,k,iNO2) + gPtr(i,j,k,iNO3)
            diags(i,j,k,iConsNO3) = diags(i,j,k,iConsNO3)
     &                            + gPtr(i,j,k,iNO3)
            diags(i,j,k,iConsNO2) = diags(i,j,k,iConsNO2)
     &                            + gPtr(i,j,k,iNO2)
            diags(i,j,k,iConsNH4) = diags(i,j,k,iConsNH4)
     &                            + gPtr(i,j,k,iNH4)
            diags(i,j,k,iConsPO4) = diags(i,j,k,iConsPO4)
     &                            + gPtr(i,j,k,iPO4)
            diags(i,j,k,iConsSi) = diags(i,j,k,iConsSi)
     &                           + gPtr(i,j,k,iSiO2)
            diags(i,j,k,iConsFe) = diags(i,j,k,iConsFe)
     &                           + gPtr(i,j,k,iFeT)
#ifdef DARWIN_ALLOW_CARBON
            diags(i,j,k,iConsALK) = diags(i,j,k,iConsALK)
     &                            + gPtr(i,j,k,iALK)
            diags(i,j,k,iConsO2)  = diags(i,j,k,iConsO2)
     &                            + gPtr(i,j,k,iO2)
#endif
         ENDDO
        ENDDO
       ENDDO
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsDIN),'S_DIN   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsNO3),'S_NO3   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsNO2),'S_NO2   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsNH4),'S_NH4   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsPO4),'S_PO4   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsSi), 'S_Si    ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsFe), 'S_Fe    ',
     &       0,Nr,2,bi,bj,myThid)
#ifdef DARWIN_ALLOW_CARBON
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsALK),'S_ALK   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsO2), 'S_O2    ',
     &       0,Nr,2,bi,bj,myThid)
#endif

       DO iTr=1,nDarwin
        diagname = 'gDAR'//PTRACERS_ioLabel(iTr)
        CALL DIAGNOSTICS_FILL(gPtr(1-OLx,1-OLy,1,iTr), diagname,
     &          0,Nr,2,bi,bj,myThid)
       ENDDO

#ifdef DARWIN_DIAG_PERTYPE
       DO iTr=1,nplank
        WRITE(diagname, '(A,I4.4)') 'PP', iTr
        CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iPPplank+iTr-1),
     &        diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I4.4)') 'PC', iTr
        CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iPCplank+iTr-1),
     &        diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I4.4)') 'HP', iTr
        CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iHPplank+iTr-1),
     &        diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I4.4)') 'HC', iTr
        CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iHCplank+iTr-1),
     &        diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I4.4)') 'GR', iTr
        CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iGRplank+iTr-1),
     &        diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I4.4)') 'GrGn', iTr
        CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iGrGn+iTr-1),
     &        diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I4.4)') 'GrGC', iTr
        CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iGrGC+iTr-1),
     &        diagname,0,Nr,2,bi,bj,myThid)
       ENDDO
#endif
#ifdef DARWIN_ALLOW_CSTORE
#ifdef DARWIN_ALLOW_CSTORE_DIAGS
       DO iTr=1,nPhoto
        WRITE(diagname, '(A,I4.4)') 'EXU', iTr
        CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iEXplank+iTr-1),
     &        diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I4.4)') 'BS', iTr
        CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iGWplank+iTr-1),
     &        diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I4.4)') 'DN', iTr
        CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iDNplank+iTr-1),
     &        diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I4.4)') 'DP', iTr
        CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iDPplank+iTr-1),
     &        diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I4.4)') 'DFe', iTr
        CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iDFplank+iTr-1),
     &        diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I4.4)') 'DSi', iTr
        CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iDSplank+iTr-1),
     &        diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I4.4)') 'Dmin', iTr
        CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iDminplank+iTr-1),
     &        diagname,0,Nr,2,bi,bj,myThid)
       ENDDO
#endif
#endif
       CALL DIAGNOSTICS_FILL(scavRate,'scavRate',0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(scavLoss,'scvLosFe',0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(sedFe,   'sedFe   ',0,Nr,1,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(sedFlxFe,'sedFlxFe',0,1,2,bi,bj,myThid)
       IF (DIAGNOSTICS_IS_ON('sfcSolFe', myThid)) THEN
        DO j=jMin,jMax
         DO i=iMin,iMax
          IF (hFacC(i,j,1,bi,bj) .EQ. 0.) THEN
           surfFe(i,j) = 0 _d 0
          ELSE
           surfFe(i,j) = alpfe * inputFe(i,j,bi,bj)
          ENDIF
         ENDDO
        ENDDO
        CALL DIAGNOSTICS_FILL(surfFe,'sfcSolFe',0,1,2,bi,bj,myThid)
       ENDIF

#ifdef DARWIN_ALLOW_CARBON
       CALL DIAGNOSTICS_FILL(pH,     'pH      ',0,Nr,1,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(pCO2,   'pCO2    ',0,Nr,1,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(FluxCO2,'fluxCO2 ',0,1,1,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(gDIC,   'gDICsurf',0,1,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(gALK,   'gALKsurf',0,1,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(gO2,    'gO2surf ',0,1,2,bi,bj,myThid)
#endif

#ifdef DARWIN_DIAG_TENDENCIES
       CALL DIAGNOSTICS_FILL(gDICsurfForc,'gDICEpr ',0,1,2,
     &  bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(gNO3surfForc,'gNO3Epr ',0,1,2,
     &  bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(gNO2surfForc,'gNO2Epr ',0,1,2,
     &  bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(gNH4surfForc,'gNH4Epr ',0,1,2,
     &  bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(gPO4surfForc,'gPO4Epr ',0,1,2,
     &  bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(gFeTsurfForc,'gFeTEpr ',0,1,2,
     &  bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(gSiO2surfForc,'gSiO2Epr',0,1,2,
     &  bi,bj,myThid)
#ifdef DARWIN_ALLOW_CARBON
       CALL DIAGNOSTICS_FILL(gALKsurfForc,'gALKEpr ',0,1,2,
     &  bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(gO2surfForc, 'gO2Epr  ',0,1,2,
     &  bi,bj,myThid)
#endif
#endif

       CALL TIMER_STOP ('DIAGS_FILL [DARWIN_FORCING]',myThid)
C     useDiagnostics
      ENDIF
#endif /* ALLOW_DIAGNOSTICS */

      midTime = midTime + deltaTclock/nsubtime
      subTime = subTime + deltaTclock/nsubtime
C     isub
      ENDDO

#ifdef ALLOW_DIAGNOSTICS
      IF (useDIAGNOSTICS) THEN
       IF (DIAGNOSTICS_IS_ON('freeFeLs', myThid)) THEN
        DO k=1,Nr
         tmpFac = 1 _d 0 / PTRACERS_dTLev(k)
         DO j=1,sNy
          DO i=1,sNx
           tmp3d(i,j,k) = tmpFac*DARWIN_minFeLoss(i,j,k,bi,bj)
          ENDDO
         ENDDO
        ENDDO
        CALL DIAGNOSTICS_FILL(tmp3d,'freeFeLs',0,Nr,2,bi,bj,myThid)
       ENDIF
      ENDIF
#endif

#endif /* ALLOW_DARWIN */

      RETURN
      END
