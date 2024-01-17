#include "OASIM_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_FORCING

C     !INTERFACE:
      SUBROUTINE OASIM_FORCING( dodiags, myTime, myIter, myThid )

C     !DESCRIPTION:
C     Main driver for OASIM state package.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "OASIM_SIZE.h"
#include "OASIM_PARAMS.h"
#include "OASIM_INTERNAL.h"
#include "OASIM_FIELDS.h"
#ifdef ALLOW_EXF
#include "OASIM_EXF_PARAMS.h"
#endif

C     !INPUT PARAMETERS:
C     myTime   :: Current time of simulation ( s )
C     myIter   :: Current iteration number in simulation
C     myThid   :: my Thread Id number
      LOGICAL dodiags
      _RL     myTime
      INTEGER myIter, myThid
CEOP

#ifdef ALLOW_OASIM

C     !FUNCTIONS:
      LOGICAL DIAGNOSTICS_IS_ON
      EXTERNAL DIAGNOSTICS_IS_ON

C     !LOCAL VARIABLES:
      CHARACTER*8 diagName
      _RL daycor, rday, secs, ylen
      INTEGER year, imon, iday, ss, lp, wd, currentdate(4)
      INTEGER yday, yymmdd, difftime(4), yearstart(4)
      INTEGER i, j, l, bi, bj
      _RL sPARF(1-OLx:sNx+OLx,1-OLy:sNy+OLy)

C compute solar zenith angles
      CALL OASIM_CALC_SOLZ( myTime, myIter, myThid )

c compute approximate correction to earth-sun distance
#ifdef ALLOW_CAL
      CALL cal_GetDate( myiter, mytime, currentdate, mythid )
      CALL cal_convDate( currentdate,year,imon,iday,ss,lp,wd,mythid )
C     compute yearday
      yymmdd = year*10000 + 101
      CALL cal_fullDate( yymmdd, 0, yearstart, mythid )
      CALL cal_timePassed( yearstart, currentdate, difftime, mythid )
      CALL cal_ToSeconds (difftime,secs,myThid)
      rday = (secs+0.5 _d 0*deltaT)/86400.0 _d 0 + 1.0 _d 0
      ylen = 365.0 _d 0
c      print*,'iter',myIter,'rday',rday
#else
c     make up a yearday
      year = FLOOR(myTime/31104000. _d 0)
      secs = (myTime - 31104000. _d 0*year)
      rday = secs/86400. _d 0 + 1.0 _d 0
      ylen = 360.0 _d 0
#endif
      daycor = (1.0 _d 0 + 1.67 _d -2*cos(pi2*(rday-3.0 _d 0)/ylen))**2

C compute irradiances above sea surface
      CALL OASIM_CALC_ABOVE( daycor, dodiags, myThid )

C compute sea-surface reflectance and irradiances below surface
      CALL OASIM_CALC_BELOW( dodiags, myThid )

#ifdef ALLOW_DIAGNOSTICS
      IF (useDiagnostics .AND. dodiags) THEN
       DO l=1,nlt
        WRITE(diagName,'(A5,I3.3)')'Edabv',l
        CALL DIAGNOSTICS_FILL(OASIM_Edabove(1-OLx,1-OLy,1,1,l),
     &                                       diagName,0,1,0,1,1,myThid)
        WRITE(diagName,'(A5,I3.3)')'Esabv',l
        CALL DIAGNOSTICS_FILL(OASIM_Esabove(1-OLx,1-OLy,1,1,l),
     &                                       diagName,0,1,0,1,1,myThid)
        WRITE(diagName,'(A5,I3.3)')'Edblw',l
        CALL DIAGNOSTICS_FILL(OASIM_Edbelow(1-OLx,1-OLy,1,1,l),
     &                                       diagName,0,1,0,1,1,myThid)
        WRITE(diagName,'(A5,I3.3)')'Esblw',l
        CALL DIAGNOSTICS_FILL(OASIM_Esbelow(1-OLx,1-OLy,1,1,l),
     &                                       diagName,0,1,0,1,1,myThid)
       ENDDO
       CALL DIAGNOSTICS_FILL(OASIM_solz,'OASIMsol',0,1,0,1,1,myThid)
       CALL DIAGNOSTICS_FILL(OASIM_rmud,'OASIMrmd',0,1,0,1,1,myThid)
       IF (DIAGNOSTICS_IS_ON('sPARblw ', myThid)) THEN
        DO bj=myByLo(myThid),myByHi(myThid)
         DO bi=myBxLo(myThid),myBxHi(myThid)
          DO j=1,sNy
           DO i=1,sNx
            sPARF(i,j) = 0 _d 0
           ENDDO
          ENDDO
          DO l=1,nlt
           DO j=1,sNy
            DO i=1,sNx
             sPARF(i,j) = sPARF(i,j) + (
     &                oasim_rmud(i,j,bi,bj)*OASIM_Edbelow(i,j,bi,bj,l)
     &              + oasim_rmus*OASIM_Esbelow(i,j,bi,bj,l)
     &              )*WtouEins(l)*oasim_PARwgt(l)
            ENDDO
           ENDDO
          ENDDO
          CALL DIAGNOSTICS_FILL(sPARF,'sPARblw ',0,1,2,bi,bj,myThid)
         ENDDO
        ENDDO
       ENDIF
      ENDIF
#endif

#endif /* ALLOW_OASIM */

      RETURN
      END
