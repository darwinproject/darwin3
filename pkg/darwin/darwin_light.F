#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_LIGHT
C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_LIGHT(
     O                         PAR,
     I                         midTime, bi, bj, iMin, iMax, jMin, jMax,
     I                         myTime, myIter, myThid )

C !DESCRIPTION:

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "GRID.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
C#include "DYNVARS.h"
#include "FFIELDS.h"
#include "PTRACERS_SIZE.h"
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
      _RL midTime
      _RL myTime
      INTEGER bi, bj, iMin, iMax, jMin, jMax, myIter, myThid

C !OUTPUT PARAMETERS: ==================================================
      _RL PAR(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr)
CEOP

#ifdef ALLOW_DARWIN
#ifndef ALLOW_RADTRANS

C!LOCAL VARIABLES: ====================================================
C  i,j                  :: loop indices
C  k                    :: vertical level
      INTEGER i,j,k,jp
      _RL PARlat(1-OLy:sNy+OLy)
      _RL Chl(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL PARF(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL atten(1-OLx:sNx+OLx,1-OLy:sNy+OLy)

C ======================================================================
      IF (DARWIN_haveSurfPAR) THEN
       DO j=jMin,jMax
        DO i=iMin,iMax
         PARF(i,j) = surfPAR(i,j,bi,bj)
        ENDDO
       ENDDO
      ELSEIF (DARWIN_useQsw) THEN
       DO j=jMin,jMax
        DO i=iMin,iMax
         PARF(i,j) = -parfrac*parconv*Qsw(i,j,bi,bj)*maskC(i,j,1,bi,bj)
        ENDDO
       ENDDO
      ELSE
       CALL DARWIN_INSOL(midTime, PARlat, bj, .FALSE.)
       DO j=jMin,jMax
        DO i=iMin,iMax
C        convert W/m2 to uEin/s/m2
         PARF(i,j) = PARlat(j)/.2174
        ENDDO
       ENDDO
      ENDIF

#ifdef ALLOW_DIAGNOSTICS
      IF (useDiagnostics .AND. myIter .GE.0) THEN
       CALL DIAGNOSTICS_FILL(PARF,'surfPAR ',1,1,2,bi,bj,myThid)
      ENDIF
#endif

      IF (myiter .gt. -99 .AND. .NOT.DARWIN_useQsw) THEN
       DO j=jMin,jMax
        DO i=iMin,iMax
         PARF(i,j) = PARF(i,j) * (1.0 _d 0 - iceFrac(i,j,bi,bj))
        ENDDO
       ENDDO
      ENDIF

      DO k=1,Nr

       DO j=jMin,jMax
        DO i=iMin,iMax
         Chl(i,j) = 0.0 _d 0
        ENDDO
       ENDDO
#ifdef DARWIN_ALLOW_GEIDER
#ifdef DARWIN_ALLOW_CHLQUOTA
       DO jp=1,nPhoto
        DO j=jMin,jMax
         DO i=iMin,iMax
          Chl(i,j) = Chl(i,j) + MAX(0 _d 0,
     &                              Ptracer(i,j,k,bi,bj,iChl+jp-1))
         ENDDO
        ENDDO
       ENDDO
#else
       DO j=jMin,jMax
        DO i=iMin,iMax
         Chl(i,j) = ChlPrev(i,j,k,bi,bj)
        ENDDO
       ENDDO
#endif
#else
       DO jp=1,nPhoto
        DO j=jMin,jMax
         DO i=iMin,iMax
          Chl(i,j) = Chl(i,j) + MAX(0 _d 0,
     &                 Ptracer(i,j,k,bi,bj,ic+jp-1)*R_ChlC(jp))
         ENDDO
        ENDDO
       ENDDO
#endif

       DO j=jMin,jMax
        DO i=iMin,iMax
C TODO should include hFacC
         atten(i,j) = (katten_w + katten_Chl*Chl(i,j))*DRF(k)
#ifdef DARWIN_AVPAR
         PAR(i,j,k) = PARF(i,j)*(1.0 - EXP(-atten(i,j)))/atten(i,j)
#else /* USE_MIDPAR */
         PAR(i,j,k) = PARF(i,j)*EXP(-0.5*atten(i,j))
#endif
         PAR(i,j,k) = PAR(i,j,k)*maskC(i,j,k,bi,bj)
        ENDDO
       ENDDO

#ifdef ALLOW_DIAGNOSTICS
       IF (useDiagnostics .AND. myIter .GE.0) THEN
        CALL DIAGNOSTICS_FILL(PARF,'PARF    ',k,1,2,bi,bj,myThid)
        CALL DIAGNOSTICS_FILL(atten,'atten   ',k,1,2,bi,bj,myThid)
       ENDIF
#endif
       DO j=jMin,jMax
        DO i=iMin,iMax
         PARF(i,j) = PARF(i,j)*EXP(-atten(i,j))
        ENDDO
       ENDDO

C     k
      ENDDO

#endif /* not ALLOW_RADTRANS */
#endif /* ALLOW_DARWIN */

      RETURN
      END
