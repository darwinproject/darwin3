#include "DARWIN_OPTIONS.h"
#include "EXF_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_FIELDS_LOAD

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_FIELDS_LOAD( myIter, myTime, myThid )

C !DESCRIPTION:
C     Load and interpolate forcing fields for darwin package

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#ifdef ALLOW_EXF
#include "EXF_FIELDS.h"
#endif
#ifdef ALLOW_DARWIN
#include "DARWIN_SIZE.h"
#include "DARWIN_EXF_FIELDS.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"
#endif

C !INPUT PARAMETERS: ===================================================
      _RL     mytime
      integer myiter
      integer mythid
CEOP

#ifdef ALLOW_DARWIN
#ifdef ALLOW_EXF

C !LOCAL VARIABLES: ====================================================
      INTEGER bi,bj,i,j

c--   read forcing fields from files and temporal interpolation

      CALL DARWIN_EXF_LOAD(myTime, myIter, myThid)

      IF (DARWIN_useEXFwind) THEN
       DO bj=myByLo(mythid),myByHi(myThid)
        DO bi=myBxLo(mythid),myBxHi(myThid)
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
           windSpeed(i,j,bi,bj) = wspeed(i,j,bi,bj)
          ENDDO
         ENDDO
        ENDDO
       ENDDO
      ENDIF

      CALL DARWIN_MONITOR(myTime, myIter, myThid)

#ifdef ALLOW_DIAGNOSTICS
      IF (useDIAGNOSTICS) THEN
       CALL DIAGNOSTICS_FILL(surfPAR,'surfPAR ',1,1,0,0,0,myThid)
       CALL DIAGNOSTICS_FILL(inputFe,'surfiron',0,1,0,0,0,myThid)
       CALL DIAGNOSTICS_FILL(iceFrac,'DARice  ',0,1,0,0,0,myThid)
       CALL DIAGNOSTICS_FILL(windSpeed,'DARwind ',0,1,0,0,0,myThid)
       CALL DIAGNOSTICS_FILL(atmospCO2,'surfpCO2',0,1,0,0,0,myThid)
      ENDIF
#endif

#endif /* ALLOW_EXF */
#endif /* ALLOW_DARWIN */

      RETURN
      END
