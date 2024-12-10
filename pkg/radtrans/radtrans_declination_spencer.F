#include "RADTRANS_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: RADTRANS_RDECLINATION_SPENCER

C     !INTERFACE:
      SUBROUTINE RADTRANS_DECLINATION_SPENCER(
     O                            delta,
     I                            myTime, myIter, myThid )

C     !DESCRIPTION:
C     Compute declination for current date using Spencer's Fourier series

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "cal.h"

C     !INPUT PARAMETERS:
      _RL myTime
      INTEGER myIter, myThid

C     !OUTPUT PARAMETERS:
C     delta :: declination in radians
      _RL delta
CEOP

#ifdef ALLOW_RADTRANS

C     !LOCAL VARIABLES:
      INTEGER year0,myDate(4),yearStartDate(4),difftime(4)
      _RL secondsInYear, myDateSeconds, yearangle

C find how many seconds have passed in the current year

      CALL CAL_GETDATE( myIter, myTime, myDate, myThid )

      year0            = int(myDate(1)/10000.)
      yearStartDate(1) = year0 * 10000 + 101
      yearStartDate(2) = 0
      yearStartDate(3) = myDate(3)
      yearStartDate(4) = myDate(4)
      CALL cal_TimePassed(yearStartDate,myDate,difftime,myThid)
      CALL cal_ToSeconds (difftime,myDateSeconds,myThid)

      IF ( myDate(3) .EQ. 2 ) THEN
        secondsInYear = ndaysleap * secondsperday
      ELSE
        secondsInYear = ndaysnoleap * secondsperday
      ENDIF

C convert to radians
      yearangle = 2.0 _d 0*PI*myDateSeconds/secondsInYear

C approximate declination according to Spencer 1971

      delta = 0.006918 _d 0
     &      - 0.399912 _d 0*cos(yearangle)
     &      + 0.070257 _d 0*sin(yearangle)
     &      - 0.006758 _d 0*cos(2.0 _d 0*yearangle)
     &      + 0.000907 _d 0*sin(2.0 _d 0*yearangle)
     &      - 0.002697 _d 0*cos(3.0 _d 0*yearangle)
     &      + 0.001480 _d 0*sin(3.0 _d 0*yearangle)

#endif /* ALLOW_RADTRANS */

      RETURN
      END

