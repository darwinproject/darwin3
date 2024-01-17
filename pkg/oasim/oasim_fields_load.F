#include "OASIM_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_FIELDS_LOAD

C     !INTERFACE:
      SUBROUTINE OASIM_FIELDS_LOAD( dodiags, myTime, myIter, myThid )

C     !DESCRIPTION:
C     Main entry point: Load input fields for OASIM package and
C     compute above- and below-water irradiances.

C     !USES:
      IMPLICIT NONE

C     !INPUT PARAMETERS:
C     myTime   :: Current time of simulation ( s )
C     myIter   :: Current iteration number in simulation
C     myThid   :: my Thread Id number
      LOGICAL dodiags
      _RL     myTime
      INTEGER myIter, myThid
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:

#ifdef OASIM_READ_UNFORMATTED
      CALL OASIM_LOAD_UNFORMATTED( myTime, myIter, myThid )
#else
      CALL OASIM_EXF_LOAD( myTime, myIter, myThid )
#endif

      CALL OASIM_FORCING( dodiags, myTime, myIter, myThid )

      CALL OASIM_MONITOR( myTime, myIter, myThid )

#endif /* ALLOW_OASIM */

      RETURN
      END
