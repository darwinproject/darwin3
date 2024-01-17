#include "OASIM_OPTIONS.h"
#ifdef ALLOW_EXF
#include "EXF_OPTIONS.h"
#endif

CBOP
C     !ROUTINE: OASIM_GetMonthsRec
C     !INTERFACE:
      SUBROUTINE OASIM_GetMonthsRec(
     I                             fldStartTime, useFldYearlyFields,
     I                             order,
     O                             fac, first, changed,
     O                             count0, count1, year0, year1,
     I                             myTime, myIter, myThid )

C     !DESCRIPTION: \bv
C     *==========================================================*
C     | SUBROUTINE OASIM_GetMonthsRec
C     | o Get flags, counters, and the linear interpolation
C     |   factor for a given field for the case of monthly,
C     |   interannual forcing
C     *==========================================================*
C     \ev

C     !USES:
      IMPLICIT NONE
C     == Global variables ==
#include "cal.h"

C     !INPUT PARAMETERS:
C     fldStartTime       :: time in seconds of first fld record from the
C                           beginning of the model integration or, if
C                           usefldyearlyfields, from the beginning of year
C     useFldYearlyFields :: when set, use yearly forcing files
C     order              :: order for time interpolation (0 or 1)
C     myTime             :: current time in simulation
C     myIter             :: current iteration number in simulation
C     myThid             :: my thread identification number
      _RL     fldStartTime
      LOGICAL useFldYearlyFields
      INTEGER order
      _RL     myTime
      INTEGER myIter
      INTEGER myThid

C     !OUTPUT PARAMETERS:
C     fac     :: weight of record count0 for linear interpolation purposes
C     first   :: model initialization flag: read two forcing records
C     changed :: flag indicating that a new forcing record must be read
C     count0  :: record number for forcing field preceding myTime
C     count1  :: record number for forcing field following myTime
C     year0   :: year of forcing file for record preceding myTime
C     year1   :: year of forcing file for record following myTime
      _RL     fac
      LOGICAL first, changed
      INTEGER count0, count1, year0, year1

#ifdef ALLOW_EXF
#ifdef ALLOW_CAL
C     !LOCAL VARIABLES:
      INTEGER startDate(4)
      INTEGER yy, mm, dd, ss, lp, wd
      integer modelsteptime(4)
      integer currentdate(4)
      integer prevdate(4)
      integer prevcount
CEOP

      IF (order .EQ. 0) THEN

c--    Set switches for reading new records.
       first = ((mytime - modelstart) .lt. 0.5*modelstep)

       CALL cal_TimeInterval( -modelstep, 'secs', modelsteptime,
     &                        mythid )

c      Determine the current date and the current month.
       call cal_GetDate( myiter, mytime, currentdate, mythid )
       call cal_AddTime( currentdate, modelsteptime, prevdate, mythid )

       year0 = currentdate(1)/10000
       count0 = mod(currentdate(1)/100,100)

       year1 = year0
       count1 = count0
C      use only year1, count1
       fac = 0 _d 0
       prevcount = mod(prevdate(1)/100,100)
c      only check month, not year, as it will always change
       IF ( (.NOT. first) .AND. (prevcount .NE. count0) ) THEN
         changed = .TRUE.
       ELSE
         changed = .FALSE.
       ENDIF

      ELSE

       CALL cal_GetMonthsRec(
     O                        fac, first, changed,
     O                        count0, count1, year0, year1,
     I                        myTime, myIter, myThid )

      ENDIF

      IF (.NOT.useFldYearlyFields) THEN
        CALL CAL_GETDATE( 0, fldStartTime, startDate, myThid )
        CALL CAL_CONVDATE( startDate, yy, mm, dd, ss, lp, wd, myThid )
        count0 = (year0-yy)*12 + count0 - mm + 1
        count1 = (year1-yy)*12 + count1 - mm + 1
        year0 = 0
        year1 = 0
      ENDIF

#endif /* ALLOW_CAL */
#endif /* ALLOW_EXF */

      RETURN
      END
