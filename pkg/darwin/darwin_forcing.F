C TODO
C - have to call fechem after model?

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
      _RL gPtr(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nDarwin)
      _RL PAR(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL diags(1-OLx:sNx+OLx,1-OLy:sNy+OLy, Nr, darwin_nDiag)
      _RL gDIC(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
      _RL gALK(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
      _RL gO2(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
      _RL surfFe(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
      _RL freeFe(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr)
      _RL scv,scav_poc
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
      _RL tmp

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
     I                    bi,bj,iMin,iMax,jMin,jMax,
     I                    subTime,myIter,myThid)
      CALL TIMER_STOP ('DARWIN_SURFFORCING [DARWIN_FORCING]',myThid)
      DO j=jMin,jMax
      DO i=iMin,iMax
        gPtr(i,j,1,iDIC) = gPtr(i,j,1,iDIC) + gDIC(i,j)
        gPtr(i,j,1,iALK) = gPtr(i,j,1,iALK) + gALK(i,j)
        gPtr(i,j,1,iO2)  = gPtr(i,j,1,iO2)  + gO2(i,j)
      ENDDO
      ENDDO
#endif

C === iron =============================================================
#ifdef DARWIN_ALLOW_CONS
      DO k=1,Nr
       DO j=jMin,jMax
        DO i=iMin,iMax
         DARWIN_minFeLoss(i,j,k,bi,bj) = Ptracer(i,j,k,bi,bj,iFeT)
        ENDDO
       ENDDO
      ENDDO
#endif
      CALL TIMER_START('DARWIN_FE_CHEM [DARWIN_FORCING]',myThid)
      CALL DARWIN_FE_CHEM(
     U                 Ptracer(1-OLx,1-OLy,1,bi,bj,iFeT),
     O                 freeFe(1-OLx, 1-OLy, 1),
     I                 bi, bj, iMin, iMax, jMin, jMax, myThid)
      CALL TIMER_STOP ('DARWIN_FE_CHEM [DARWIN_FORCING]',myThid)
#ifdef DARWIN_ALLOW_CONS
      DO k=1,Nr
       DO j=jMin,jMax
        DO i=iMin,iMax
         DARWIN_minFeLoss(i,j,k,bi,bj) = DARWIN_minFeLoss(i,j,k,bi,bj)
     &                                 - Ptracer(i,j,k,bi,bj,iFeT)
        ENDDO
       ENDDO
      ENDDO
#endif

C     iron dust input
      CALL TIMER_START('DARWIN_FE_DUST [DARWIN_FORCING]',myThid)
      DO j=jMin,jMax
      DO i=iMin,iMax
      IF (hFacC(i,j,1,bi,bj) .NE. 0.) THEN
        gPtr(i,j,1,iFeT) =
     &  gPtr(i,j,1,iFeT) + alpfe * inputFe(i,j,bi,bj) /
     &                           drF(1) / hFacC(i,j,1,bi,bj)
      ENDIF
      ENDDO
      ENDDO
      CALL TIMER_STOP ('DARWIN_FE_DUST [DARWIN_FORCING]',myThid)

C     scavenging
      CALL TIMER_START('DARWIN_FE_SCAV [DARWIN_FORCING]',myThid)
      DO k=1,Nr
      DO j=jMin,jMax
      DO i=iMin,iMax
#ifdef DARWIN_PART_SCAV_POP
        scav_poc = MAX(0 _d 0, Ptracer(i,j,k,bi,bj,iPOP))/scav_R_POPPOC
        scv = scav_rat*scav_inter*(scav_poc**scav_exp)
#elif defined(DARWIN_PART_SCAV)
        scav_poc = MAX(0 _d 0, Ptracer(i,j,k,bi,bj,iPOC))
        scv = scav_rat*scav_inter*(scav_poc**scav_exp)
#else
        scv = scav
#endif
        gPtr(i,j,k,iFeT) = gPtr(i,j,k,iFeT) -
     &                     scv*MAX(0 _d 0, freefe(i,j,k))
#ifdef DARWIN_ALLOW_CONS
        DARWIN_partScav(i,j,k,bi,bj) = scv*MAX(0 _d 0, freefe(i,j,k))
#endif
      ENDDO
      ENDDO
      ENDDO
      CALL TIMER_STOP ('DARWIN_FE_SCAV [DARWIN_FORCING]',myThid)

C     iron sediment source (in bottom grid cell above kMaxFeSed)
      CALL TIMER_START('DARWIN_FE_SED [DARWIN_FORCING]',myThid)
#ifdef DARWIN_ALLOW_CONS
      DO j=jMin,jMax
       DO i=iMin,iMax
        ironSedFlux(i,j,bi,bj) = 0 _d 0
       ENDDO
      ENDDO
#endif
      DO k = kMinFeSed, kMaxFeSed
       kdn = MIN(Nr, k+1)
       DO j=jMin,jMax
        DO i=iMin,iMax
         IF (hFacC(i,j,k,bi,bj) .GT. 0. .AND.
     &       (hFacC(i,j,kdn,bi,bj) .EQ. 0. .OR. k .EQ. Nr)) THEN
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
          gPtr(i,j,k,iFeT) = gPtr(i,j,k,iFeT) +
     &                             flx/(drF(k)*hFacC(i,j,k,bi,bj))
#ifdef DARWIN_ALLOW_CONS
          ironSedFlux(i,j,bi,bj) = flx
#endif
         ENDIF
        ENDDO
       ENDDO
      ENDDO
      CALL TIMER_STOP ('DARWIN_FE_SED [DARWIN_FORCING]',myThid)

C === plankton =========================================================
      CALL TIMER_START('DARWIN_PLANKTON [DARWIN_FORCING]',myThid)
      do k=1,Nr
      do j=jMin,jMax
      do i=iMin,iMax
      if (hFacC(i,j,k,bi,bj) .GT. 0.) then
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
#ifdef DARWIN_DEBUG
     I                 myxgloballo+(bi-1)*sNx+i-1,
     I                 myygloballo+(bj-1)*sNy+j-1,
     I                 k, dTsub(k),
#endif
     I                 subTime, myIter, myThid )
        DO l=1,darwin_nDiag
         diags(i, j, k, l) = diagsl(l)
        ENDDO
#ifdef DARWIN_ALLOW_CONS
        DARWIN_Nfix(i,j,k,bi,bj) = diagsl(iNfix)
        DARWIN_Ndenit(i,j,k,bi,bj) = diagsl(iDenitN)
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

C === sinking ==========================================================
      CALL TIMER_START('DARWIN_SINKING [DARWIN_FORCING]',myThid)
      CALL DARWIN_SINKING( Ptracer,gPtr,bi,bj,iMin,iMax,jMin,jMax,
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
#ifdef DARWIN_ALLOW_CONS
      DO k=1,Nr
       DO j=jMin,jMax
        DO i=iMin,iMax
         DARWIN_minFeLoss(i,j,k,bi,bj) = DARWIN_minFeLoss(i,j,k,bi,bj)
     &                                 + Ptracer(i,j,k,bi,bj,iFeT)
        ENDDO
       ENDDO
      ENDDO
#endif
      CALL TIMER_START('DARWIN_FE_CHEM [DARWIN_FORCING]',myThid)
      CALL DARWIN_FE_CHEM(
     U                 pTracer(1-OLx,1-OLy,1,bi,bj,iFeT),
     O                 freeFe(1-OLx,1-OLy,1),
     I                 bi, bj, iMin, iMax, jMin, jMax, myThid)
      CALL TIMER_STOP ('DARWIN_FE_CHEM [DARWIN_FORCING]',myThid)
#ifdef DARWIN_ALLOW_CONS
      DO k=1,Nr
       DO j=jMin,jMax
        DO i=iMin,iMax
         DARWIN_minFeLoss(i,j,k,bi,bj) = DARWIN_minFeLoss(i,j,k,bi,bj)
     &                                 - Ptracer(i,j,k,bi,bj,iFeT)
        ENDDO
       ENDDO
      ENDDO
#endif

C === diagnostics ======================================================
#ifdef ALLOW_DIAGNOSTICS
      IF (useDIAGNOSTICS) THEN
       CALL TIMER_START('DIAGS_FILL [DARWIN_FORCING]',myThid)
       DO l = 1, nlam
        WRITE(diagname, '(A,I3.3)') 'PAR', l
        CALL DIAGNOSTICS_FILL(PAR(1-OLx,1-OLy,1,l),diagname,0,Nr,2,
     &        bi,bj,myThid)
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
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iPP),   'PP      ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iNfix), 'Nfix    ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iDenit),'Denit   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iDenitN),'DenitN  ',
     &       0,Nr,2,bi,bj,myThid)

C      nutrient consumption diagnostics
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsDIN),'C_DIN   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsPO4),'C_PO4   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsSi),'C_Si    ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsFe),'C_Fe    ',
     &       0,Nr,2,
     &          bi,bj,myThid)

C      compute 'source' diagnostics: tendencies without consumption;
C      add full tendencies to consumption and store result back into
C      diags(iCons*) for convenience
       DO k=1,Nr
        DO j=1,sNy
         DO i=1,sNx
            diags(i,j,k,iConsDIN) = diags(i,j,k,iConsDIN)
     &         + gPtr(i,j,k,iNH4) + gPtr(i,j,k,iNO2) + gPtr(i,j,k,iNO3)
            diags(i,j,k,iConsPO4) = diags(i,j,k,iConsPO4)
     &                            + gPtr(i,j,k,iPO4)
            diags(i,j,k,iConsSi) = diags(i,j,k,iConsSi)
     &                           + gPtr(i,j,k,iSiO2)
            diags(i,j,k,iConsFe) = diags(i,j,k,iConsFe)
     &                           + gPtr(i,j,k,iFeT)
         ENDDO
        ENDDO
       ENDDO
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsDIN),'S_DIN   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsPO4),'S_PO4   ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsSi),'S_Si    ',
     &       0,Nr,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iConsFe),'S_Fe    ',
     &       0,Nr,2,bi,bj,myThid)

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
        WRITE(diagname, '(A,I4.4)') 'GR', iTr
        CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iGRplank+iTr-1),
     &        diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I4.4)') 'GrGn', iTr
        CALL DIAGNOSTICS_FILL(diags(1-OLx,1-OLy,1,iGrGn+iTr-1),
     &        diagname,0,Nr,2,bi,bj,myThid)
       ENDDO
#endif
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
       CALL TIMER_STOP ('DIAGS_FILL [DARWIN_FORCING]',myThid)
      ENDIF
#endif

      midTime = midTime + deltaTclock/nsubtime
      subTime = subTime + deltaTclock/nsubtime
C     isub
      ENDDO

#endif /* ALLOW_DARWIN */

      RETURN
      END
