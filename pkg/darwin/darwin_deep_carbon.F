#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_DEEP_CARBON

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_DEEP_CARBON(
     I           bi,bj,imin,imax,jmin,jmax,
     I           myTime,myIter,myThid)

C !DESCRIPTION:
C Compute calcite saturation and pH, CO3 at depth

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "DYNVARS.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "FFIELDS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_FIELDS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_EXF_FIELDS.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"
#include "DARWIN_FIELDS.h"
#include "DARWIN_FLUX.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
C  myIter               :: current timestep
C  myTime               :: current time
C  bi,bj                :: tile indices
      INTEGER iMin,iMax,jMin,jMax,bi,bj
      INTEGER myIter, myThid
      _RL myTime

#ifdef ALLOW_DARWIN
#ifdef DARWIN_ALLOW_CARBON

C !LOCAL VARIABLES: ====================================================
      INTEGER i,j,k
      LOGICAL debugPrt
C Number of iterations for pCO2 solvers...
C Solubility relation coefficients
C local variables for carbon chem
      _RL localdic
      _RL localalk
      _RL localphos
      _RL localsi
      _RL localtemp(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL localsalt(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL pCO2(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL CO3(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL calcium
CEOP

C ======================================================================
      DO k=1,Nr
C ======================================================================

C determine inorganic carbon chem coefficients
       DO j=jmin,jmax
        DO i=imin,imax
c put bounds on tracers so pH solver doesn't blow up
         localsalt(i,j) = MAX(surfSaltMin,
     &                    MIN(surfSaltMax, salt(i,j,k,bi,bj)))
         localtemp(i,j) = MAX(surfTempMin,
     &                    MIN(surfTempMax, theta(i,j,k,bi,bj)))
        ENDDO
       ENDDO

#ifdef DARWIN_SOLVESAPHE
#ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL(
     &    'DARWIN_COEFFS_DEEP',myThid)
#endif
C Calculate carbon coefficients
       CALL DARWIN_COEFFS_SURF(
     I                          localtemp, localsalt,
     I                          bi,bj,iMin,iMax,jMin,jMax,
     I                          k,myThid)

C Now correct the coefficients for pressure dependence
        CALL DARWIN_COEFFS_DEEP(
     I                          localtemp, localsalt,
     I                          bi,bj,iMin,iMax,jMin,jMax,
     I                          k,myThid)
#else
#ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('DARWIN_CARBON_COEFFS',myThid)
#endif
       CALL DARWIN_CARBON_COEFFS(
     I                            localtemp,localsalt,
     I                            bi,bj,iMin,iMax,jMin,jMax,k,myThid)
#endif /* DARWIN_SOLVESAPHE */

C====================================================================
       debugPrt = debugMode
c pCO2 solver...
       DO j=jmin,jmax
        DO i=imin,imax
         IF ( maskC(i,j,k,bi,bj).NE.0. _d 0 ) THEN

c put bounds on tracers so pH solver doesn't blow up
          localdic  = ptr2mol * MAX(surfDICMin,
     &                MIN(surfDICMax, Ptracer(i,j,k,bi,bj,iDIC)))
     &                * maskC(i,j,k,bi,bj)
          localalk  = ptr2mol * MAX(surfALKMin,
     &                MIN(surfALKMax, Ptracer(i,j,k,bi,bj,iALK)))
     &                * maskC(i,j,k,bi,bj)
          localphos = ptr2mol * MAX(surfPO4Min,
     &                MIN(surfPO4Max, Ptracer(i,j,k,bi,bj,iPO4)))
     &                * maskC(i,j,k,bi,bj)
          localsi   = ptr2mol * MAX(surfSiMin,
     &                MIN(surfSiMax, Ptracer(i,j,k,bi,bj,iSiO2)))
     &                * maskC(i,j,k,bi,bj)

#ifdef DARWIN_SOLVESAPHE
          IF ( selectPHsolver.GT.0 ) THEN
C Use Munhoven (2013) Solvesaphe routine to calculate pH and pCO2
#ifdef ALLOW_DEBUG
            IF (debugPrt) CALL DEBUG_CALL('CALC_PCO2_SOLVESAPHE',myThid)
#endif
            CALL CALC_PCO2_SOLVESAPHE(
     I          localtemp(i,j), localsalt(i,j),
     I          localdic, localphos, localsi, localalk,
     U          pH(i,j,k,bi,bj),
     O          pCO2(i,j), CO3(i,j),
     I          i,j,k,bi,bj, debugPrt,myIter,myThid )
            debugPrt = .FALSE.
          ELSE
C Use the original Follows et al. (2006) solver
#endif /* DARWIN_SOLVESAPHE */
#ifdef ALLOW_DEBUG
            IF (debugPrt) CALL DEBUG_CALL('CALC_PCO2_APPROX',myThid)
            debugPrt = .FALSE.
#endif
            CALL DARWIN_CALC_PCO2_APPROX(
     I        localtemp(i,j), localsalt(i,j),
     I        localdic, localphos, localsi, localalk,
     I        ak1(i,j,bi,bj), ak2(i,j,bi,bj),
     I        ak1p(i,j,bi,bj), ak2p(i,j,bi,bj), ak3p(i,j,bi,bj),
     I        aks(i,j,bi,bj), akb(i,j,bi,bj), akw(i,j,bi,bj),
     I        aksi(i,j,bi,bj), akf(i,j,bi,bj),
     I        ak0(i,j,bi,bj),  fugf(i,j,bi,bj),
     I        ff(i,j,bi,bj),
     I        bt(i,j,bi,bj), st(i,j,bi,bj), ft(i,j,bi,bj),
     U        pH(i,j,k,bi,bj),
     O        pCO2(i,j), CO3(i,j),
     I        i,j,k,bi,bj,myIter,myThid )
#ifdef DARWIN_SOLVESAPHE
          ENDIF
#endif /* DARWIN_SOLVESAPHE */

C Compute calcite saturation ratio omegaC
#ifdef DARWIN_SOLVESAPHE
          calcium = cat(i,j,bi,bj)
#else
C         calcium concentration in mol/kg-SW
          calcium = 1.028 _d -2*salt(i,j,k,bi,bj)/35. _d 0
#endif
C         [calcium] = mol/kg
C         [CO3] = mol/kg
C         [Ksp_TP_Calc] = mol^2/kg^2
          omegaC(i,j,k,bi,bj) = MAX(0 _d 0, calcium * CO3(i,j)) /
     &                          Ksp_TP_Calc(i,j,bi,bj)

         ELSE
          pCO2(i,j)=0. _d 0
          CO3(i,j) = 0. _d 0
          omegaC(i,j,k,bi,bj) = 0 _d 0
         ENDIF

C      enddo i,j
        ENDDO
       ENDDO

#ifdef ALLOW_DIAGNOSTICS
       IF (useDiagnostics) THEN
        CALL DIAGNOSTICS_FILL(pCO2,       'pCO2    ',k,1,2,bi,bj,myThid)
        CALL DIAGNOSTICS_FILL(CO3,        'CO3     ',k,1,2,bi,bj,myThid)
        CALL DIAGNOSTICS_FILL(Ksp_TP_Calc,'KspTPClc',k,1,1,bi,bj,myThid)
       ENDIF
#endif

C === k ================================================================
      ENDDO
C ======================================================================

#ifdef ALLOW_DIAGNOSTICS
      IF (useDiagnostics) THEN
       CALL DIAGNOSTICS_FILL(pH,    'pH      ',0,Nr,1,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(omegaC,'OmegaC  ',0,Nr,1,bi,bj,myThid)
      ENDIF
#endif

#endif /* DARWIN_ALLOW_CARBON */
#endif /* ALLOW_DARWIN */

      RETURN
      END
