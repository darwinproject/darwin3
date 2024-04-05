#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_SURFFORCING_INIT

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_SURFFORCING_INIT(myThid)

C !DESCRIPTION:
C  Calculate first guess of pH

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "DYNVARS.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "FFIELDS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PTRACERS_FIELDS.h"
#ifdef ALLOW_DARWIN
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_EXF_FIELDS.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"
#include "DARWIN_FIELDS.h"
#endif

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER  myThid

#ifdef ALLOW_DARWIN
#ifdef DARWIN_ALLOW_CARBON

C !LOCAL VARIABLES: ====================================================
       LOGICAL debugPrt
       INTEGER i,j,k,it
       _RL pco2dummy
       _RL co3dummy
C Number of iterations for pCO2 solvers...
C Solubility relation coefficients
C local variables for carbon chem
      INTEGER iMin,iMax,jMin,jMax, bi, bj
      _RL surfdic
      _RL surfalk
      _RL surfphos
      _RL surfsi
      _RL surftemp(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL surfsalt(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
CEOP

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

#ifdef ALLOW_OFFLINE
      IF ( useOffLine ) THEN
        CALL OFFLINE_FIELDS_LOAD( startTime, nIter0, myThid )
      ENDIF
#endif

C =================================================================

      jMin=1
      jMax=sNy
      iMin=1
      iMax=sNx

      IF (nIter0.EQ.PTRACERS_Iter0 .AND. darwin_pickupSuff.EQ.' ') THEN
C set guess of pH for first step here

       DO bj=myByLo(myThid),myByHi(myThid)
        DO bi=myBxLo(myThid),myBxHi(myThid)

         DO k=1,Nr

C determine inorganic carbon chem coefficients
          DO j=jMin,jMax
           DO i=iMin,iMax
            surfsalt(i,j) = MAX(surfSaltMinInit,
     &                      MIN(surfSaltMaxInit, salt(i,j,k,bi,bj)))
            surftemp(i,j) = MAX(surfTempMinInit,
     &                      MIN(surfTempMaxInit, theta(i,j,k,bi,bj)))
           ENDDO
          ENDDO

          DO j=1-OLy,sNy+OLy
           DO i=1-OLx,sNx+OLx
            ak0(i,j,bi,bj)=0. _d 0
            ak1(i,j,bi,bj)=0. _d 0
            ak2(i,j,bi,bj)=0. _d 0
            akw(i,j,bi,bj)=0. _d 0
            akb(i,j,bi,bj)=0. _d 0
            akf(i,j,bi,bj)=0. _d 0
            ak1p(i,j,bi,bj)=0. _d 0
            ak2p(i,j,bi,bj)=0. _d 0
            ak3p(i,j,bi,bj)=0. _d 0
            aksi(i,j,bi,bj)=0. _d 0
            fugf(i,j,bi,bj)=0. _d 0
            ff(i,j,bi,bj)=0. _d 0
            ft(i,j,bi,bj)=0. _d 0
            st(i,j,bi,bj)=0. _d 0
            bt(i,j,bi,bj)=0. _d 0
           ENDDO
          ENDDO

#ifdef DARWIN_SOLVESAPHE
#ifdef ALLOW_DEBUG
          IF (debugMode) CALL DEBUG_CALL('DARWIN_COEFFS_SURF',myThid)
#endif
          CALL DARWIN_COEFFS_SURF(
     I                       surftemp,surfsalt,
     I                       bi,bj,iMin,iMax,jMin,jMax,
     I                       k,myThid)

C Now correct the coefficients for pressure dependence
          CALL DARWIN_COEFFS_DEEP(
     I                       surftemp, surfsalt,
     I                       bi,bj,iMin,iMax,jMin,jMax,
     I                       k,myThid)
#else /* DARWIN_SOLVESAPHE */
#ifdef ALLOW_DEBUG
          IF (debugMode) CALL DEBUG_CALL('CARBON_COEFFS',myThid)
#endif
          CALL DARWIN_CARBON_COEFFS(
     I                       surftemp,surfsalt,
     I                       bi,bj,iMin,iMax,jMin,jMax,k,myThid)
#endif /* DARWIN_SOLVESAPHE */

          DO j=1-OLy,sNy+OLy
           DO i=1-OLx,sNx+OLx
            pH(i,j,k,bi,bj) = 8. _d 0
           ENDDO
          ENDDO

          debugPrt = debugMode

c first approximation
C$TAF LOOP = parallel
          DO j=jMin,jMax
C$TAF LOOP = parallel
           DO i=iMin,iMax
            IF ( maskC(i,j,k,bi,bj) .NE. 0. _d 0) THEN
c put bounds on tracers so pH solver doesn't blow up
             surfdic  = ptr2mol * MAX(surfDICMinInit,
     &                  MIN(surfDICMaxInit, Ptracer(i,j,k,bi,bj,iDIC)))
     &                  * maskC(i,j,k,bi,bj)
             surfalk  = ptr2mol * MAX(surfALKMinInit,
     &                  MIN(surfALKMaxInit, Ptracer(i,j,k,bi,bj,iALK)))
     &                  * maskC(i,j,k,bi,bj)
             surfphos = ptr2mol * MAX(surfPO4MinInit,
     &                  MIN(surfPO4MaxInit, Ptracer(i,j,k,bi,bj,iPO4)))
     &                  * maskC(i,j,k,bi,bj)
             surfsi   = ptr2mol * MAX(surfSiMinInit,
     &                  MIN(surfSiMaxInit, Ptracer(i,j,k,bi,bj,iSiO2)))
     &                  * maskC(i,j,k,bi,bj)
C$TAF init dic_surf = static, 10
#ifdef DARWIN_SOLVESAPHE
             IF ( selectPHsolver.GT.0 ) THEN
C Use Munhoven (2013) Solvesaphe routine to initialize pH
#ifdef ALLOW_DEBUG
              IF (debugPrt) CALL DEBUG_CALL('AHINI_FOR_AT',myThid)
#endif
C call AHINI_FOR_AT to get better initial guess of pH
              CALL AHINI_FOR_AT(
     I           surfalk*m3perkg,
     I           surfdic*m3perkg,
     I           bt(i,j,bi,bj),
     U           pH(i,j,k,bi,bj),
     I           i,j,k,bi,bj,nIter0,myThid )

C$TAF STORE pH(i,j,k,bi,bj)                            = dic_surf
C$TAF STORE surfalk, surfphos, surfsi                  = dic_surf

#ifdef ALLOW_DEBUG
              IF (debugPrt)
     &          CALL DEBUG_CALL('CALC_PCO2_SOLVESAPHE',myThid)
#endif
              CALL CALC_PCO2_SOLVESAPHE(
     I         surftemp(i,j),surfsalt(i,j),
     I         surfdic, surfphos,
     I         surfsi,surfalk,
     U         pH(i,j,k,bi,bj),
     O         pco2dummy,co3dummy,
     I         i,j,k,bi,bj, debugPrt, nIter0, myThid )
              debugPrt = .FALSE.
             ELSE
C Use the original Follows et al. (2006) solver
#endif /* DARWIN_SOLVESAPHE */
#ifdef ALLOW_DEBUG
              IF (debugPrt) THEN
                CALL DEBUG_CALL('CALC_PCO2_APPROX',myThid)
                debugPrt = .FALSE.
              ENDIF
#endif
             DO it=1,10
C$TAF STORE pH(i,j,k,bi,bj)                            = dic_surf
C$TAF STORE surfalk, surfphos, surfs                   = dic_surf
              CALL DARWIN_CALC_PCO2_APPROX(
     I        surftemp(i,j), surfsalt(i,j),
     I        surfdic, surfphos, surfsi, surfalk,
     I        ak1(i,j,bi,bj), ak2(i,j,bi,bj),
     I        ak1p(i,j,bi,bj), ak2p(i,j,bi,bj), ak3p(i,j,bi,bj),
     I        aks(i,j,bi,bj), akb(i,j,bi,bj), akw(i,j,bi,bj),
     I        aksi(i,j,bi,bj), akf(i,j,bi,bj),
     I        ak0(i,j,bi,bj), fugf(i,j,bi,bj),
     I        ff(i,j,bi,bj),
     I        bt(i,j,bi,bj), st(i,j,bi,bj), ft(i,j,bi,bj),
     U        pH(i,j,k,bi,bj),
     O        pco2dummy, co3dummy,
     I        i,j,k,bi,bj, it ,  myThid )
             ENDDO
#ifdef DARWIN_SOLVESAPHE
             ENDIF
#endif /* DARWIN_SOLVESAPHE */
            ENDIF
           ENDDO
          ENDDO

C        end k loop
         ENDDO

C      end bi,bj loops
        ENDDO
       ENDDO

C     time to initialize
      ENDIF

#endif /* DARWIN_ALLOW_CARBON */
#endif /* ALLOW_DARWIN */

      RETURN
      END
