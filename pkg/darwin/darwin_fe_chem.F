#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_FE_CHEM

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_FE_CHEM(
     U                        FeT,
     O                        freeFe,
     U                        FeLoss,
     I                        bi, bj, iMin, iMax, jMin, jMax, myThid )

C !DESCRIPTION: ========================================================
C     Calculate L,FeL,Fe concentration
C
C     Stephanie Dutkiewicz, 2004
C        following from code by Payal Parekh

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "GRID.h"
#ifdef ALLOW_DARWIN
#include "DARWIN_SIZE.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"
#endif

C !INPUT PARAMETERS: ===================================================
      INTEGER bi, bj, iMin, iMax, jMin, jMax, myThid

C !INPUT/OUTPUT PARAMETERS: ============================================
      _RL FeT(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr)
      _RL FeLoss(sNx, sNy, Nr)

C !OUTPUT PARAMETERS: ==================================================
      _RL freeFe(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr)
CEOP

#ifdef ALLOW_DARWIN

c !LOCAL VARIABLES: ====================================================
      INTEGER i, j, k
      _RL lig
      _RL FeL

      DO k=1,Nr
       DO j=jMin,jMax
        DO i=iMin,iMax
         IF (maskC(i, j, k, bi, bj) .GT. 0.0 _d 0) THEN
          lig = (-ligand_stab*FeT(i,j,k) +
     &            ligand_stab*ligand_tot - 
     &            1. _d 0 +
     &            ( ( ligand_stab*FeT(i,j,k) -
     &                ligand_stab*ligand_tot+1. _d 0
     &              )**2 +
     &              4. _d 0*ligand_stab*ligand_tot
     &            )**0.5 _d 0
     &          )/(2. _d 0*ligand_stab)

          FeL = ligand_tot - lig
          freefe(i,j,k) = FeT(i,j,k) - FeL
#ifdef DARWIN_MINFE
          freefe(i,j,k) = MIN(freefe(i,j,k), freefemax)
          IF (maskInC(i,j,bi,bj) .GT. 0.0) THEN
           FeLoss(i,j,k) = FeLoss(i,j,k) + FeT(i,j,k) - FeL
     &                                   - freefe(i,j,k)
           FeT(i,j,k) = FeL + freefe(i,j,k)
          ENDIF
#endif
         ELSE
          freefe(i,j,k) = 0.0 _d 0
         ENDIF
        ENDDO
       ENDDO
      ENDDO

#endif /* ALLOW_DARWIN */

      RETURN
      END SUBROUTINE
