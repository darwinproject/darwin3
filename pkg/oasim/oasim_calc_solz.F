#include "OASIM_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_CALC_SOLZ

C     !INTERFACE:
      SUBROUTINE OASIM_CALC_SOLZ( myTime, myIter, myThid )

C     !DESCRIPTION:
C     Compute solar zenith angles
C
C     NOTE: we assume time steps do not span days, i.e. midnight is between times steps

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "OASIM_SIZE.h"
#include "OASIM_PARAMS.h"
#include "OASIM_FIELDS.h"

C     !INPUT PARAMETERS:
C     myTime   :: Current time of simulation ( s )
C     myIter   :: Current iteration number in simulation
C     myThid   :: my Thread Id number
      _RL     myTime
      INTEGER myIter, myThid
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      INTEGER year, imon, iday, secs, lp, wd, currentdate(4)
      INTEGER yday, yymmdd, difftime(4), yearstart(4)
      INTEGER i, j, bi, bj
      _RL t1, t2

      IF (OASIM_fixedSolz .GE. 0 _d 0) THEN

       DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
        DO j=1,sNy
        DO i=1,sNx
         OASIM_solz(i,j,bi,bj) = OASIM_fixedSolz
        ENDDO
        ENDDO
       ENDDO
       ENDDO

      ELSE

#ifdef ALLOW_CAL
       CALL cal_GetDate( myiter, mytime, currentdate, mythid )
       CALL cal_convDate( currentdate,year,imon,iday,secs,lp,wd,mythid )
       t1 = secs
       t2 = t1 + deltaT
C      compute yearday
       yymmdd = year*10000 + 101
       CALL cal_fullDate( yymmdd, 0, yearstart, mythid )
       CALL cal_timePassed( yearstart, currentdate, difftime, mythid )
       yday = difftime(1) + 1
#else
c      make up a yearday
       year = FLOOR(myTime/31104000. _d 0)
       t1 = (myTime - 31104000. _d 0*year)*365. _d 0/360. _d 0
       year = oasim_startYear + year
c      day of year
       yday = FLOOR(t1/86400. _d 0)
c      time of day
       t1 = t1 - 86400. _d 0*yday
       t2 = t1 + deltaT
       yday = yday + 1
#endif

#ifdef OASIM_INST_ZENITH_ANGLE
       CALL OASIM_SFCSOLZ_INST(year,yday,t1,myThid)
#else
c compute (cos)average solar zenith angle from t1 to t2
       CALL OASIM_SFCSOLZ(year,yday,t1,t2,oasim_dTsolz,myThid)
#endif

C     OASIM_fixedSolz
      ENDIF

#endif /* ALLOW_OASIM */

      RETURN
      END


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: OASIM_SFCSOLZ

C     !INTERFACE:
      SUBROUTINE OASIM_SFCSOLZ(iyr,iday,t1,t2,dt,myThid)

C     !DESCRIPTION:
C     Computes solar zenith angle (stored in common block) at surface
C     given location and time.  The cosine of the zenith angle is
C     averaged over the interval [t1,t2] using the trapezoidal rule with
C     resolution dt.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "OASIM_SIZE.h"
#include "OASIM_INTERNAL.h"
#include "OASIM_FIELDS.h"

C     !INPUT PARAMETERS:
      INTEGER iyr, iday, myThid
      _RL t1, t2, dt
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      INTEGER i, j, bi, bj, jj, nstps, it
#ifdef OASIM_SCALAR_ZENITH_ANGLE_COMP
      _RL csza
#else
      _RL csza(sNx,sNy)
#endif
      _RL gmt, sunz, cosunz, rsza, sza
      _RL rs, sunvec(3), sunv, sunn, sune

      nstps = NINT((t2-t1)/dt) + 1

c  Integrate to obtain mean cosine solar zenith angle
#ifdef OASIM_SCALAR_ZENITH_ANGLE_COMP

      DO bj=myByLo(myThid),myByHi(myThid)
      DO bi=myBxLo(myThid),myBxHi(myThid)
      DO j=1,sNy
      DO i=1,sNx
       csza = 0.0 _d 0
       DO it = 1,nstps,(nstps-1)
        gmt = (t1 + (it-1)*dt)/3600. _d 0
        CALL OASIM_SUN_VECTOR(iday,iyr,gmt,sunvec,rs)
c  Compute components of spacecraft and sun vector in the
c  vertical (up), North (no), and East (ea) vectors frame
        sunv = 0.0 _d 0
        sunn = 0.0 _d 0
        sune = 0.0 _d 0
        DO jj = 1,3
         sunv = sunv + sunvec(jj)*OASIM_up(i,j,bi,bj,jj)
         sunn = sunn + sunvec(jj)*OASIM_no(i,j,bi,bj,jj)
         sune = sune + sunvec(jj)*OASIM_ea(i,j,bi,bj,jj)
        ENDDO
        sunz = rad*ATAN2(SQRT(sunn*sunn+sune*sune),sunv)
        csza = csza + 0.5 _d 0*COS(sunz/rad)
       ENDDO    !end of it loop
       DO it = 2,nstps-1
        gmt = (t1 + (it-1)*dt)/3600. _d 0
        CALL OASIM_SUN_VECTOR(iday,iyr,gmt,sunvec,rs)
c  Compute components of spacecraft and sun vector in the
c  vertical (up), North (no), and East (ea) vectors frame
        sunv = 0.0 _d 0
        sunn = 0.0 _d 0
        sune = 0.0 _d 0
        DO jj = 1,3
         sunv = sunv + sunvec(jj)*OASIM_up(i,j,bi,bj,jj)
         sunn = sunn + sunvec(jj)*OASIM_no(i,j,bi,bj,jj)
         sune = sune + sunvec(jj)*OASIM_ea(i,j,bi,bj,jj)
        ENDDO
        sunz = rad*ATAN2(SQRT(sunn*sunn+sune*sune),sunv)
        csza = csza + COS(sunz/rad)
       ENDDO   !end of it loop
       cosunz = csza*rad/(nstps-1)
       rsza = ACOS(cosunz/rad)
       sza = rsza*rad
       sza = min(sza, 90.0 _d 0)
       OASIM_solz(i,j,bi,bj) = max(sza, 0.0 _d 0)
      ENDDO
      ENDDO
      ENDDO
      ENDDO

#else /* not OASIM_SCALAR_ZENITH_ANGLE_COMP */

      DO bj=myByLo(myThid),myByHi(myThid)
      DO bi=myBxLo(myThid),myBxHi(myThid)
       DO j=1,sNy
       DO i=1,sNx
        csza(i,j) = 0.0 _d 0
       ENDDO
       ENDDO

       DO it = 1,nstps,(nstps-1)
        gmt = (t1 + (it-1)*dt)/3600. _d 0
        CALL OASIM_SUN_VECTOR(iday,iyr,gmt,sunvec,rs)
        DO j=1,sNy
        DO i=1,sNx
c  Compute components of spacecraft and sun vector in the
c  vertical (up), North (no), and East (ea) vectors frame
         sunv = 0.0 _d 0
         sunn = 0.0 _d 0
         sune = 0.0 _d 0
         DO jj = 1,3
          sunv = sunv + sunvec(jj)*OASIM_up(i,j,bi,bj,jj)
          sunn = sunn + sunvec(jj)*OASIM_no(i,j,bi,bj,jj)
          sune = sune + sunvec(jj)*OASIM_ea(i,j,bi,bj,jj)
         ENDDO
         sunz = rad*ATAN2(SQRT(sunn*sunn+sune*sune),sunv)
         csza(i,j) = csza(i,j) + 0.5 _d 0*COS(sunz/rad)
        ENDDO
        ENDDO
       ENDDO    !end of it loop

       DO it = 2,nstps-1
        gmt = (t1 + (it-1)*dt)/3600. _d 0
        CALL OASIM_SUN_VECTOR(iday,iyr,gmt,sunvec,rs)
        DO j=1,sNy
        DO i=1,sNx
c  Compute components of spacecraft and sun vector in the
c  vertical (up), North (no), and East (ea) vectors frame
         sunv = 0.0 _d 0
         sunn = 0.0 _d 0
         sune = 0.0 _d 0
         DO jj = 1,3
          sunv = sunv + sunvec(jj)*OASIM_up(i,j,bi,bj,jj)
          sunn = sunn + sunvec(jj)*OASIM_no(i,j,bi,bj,jj)
          sune = sune + sunvec(jj)*OASIM_ea(i,j,bi,bj,jj)
         ENDDO
         sunz = rad*ATAN2(SQRT(sunn*sunn+sune*sune),sunv)
         csza(i,j) = csza(i,j) + COS(sunz/rad)
        ENDDO
        ENDDO
       ENDDO   !end of it loop

       DO j=1,sNy
       DO i=1,sNx
        cosunz = csza(i,j)/(nstps-1)
        rsza = ACOS(cosunz)
        sza = rsza*rad
        sza = MIN(sza, 90.0 _d 0)
        OASIM_solz(i,j,bi,bj) = MAX(sza, 0.0 _d 0)
       ENDDO
       ENDDO
      ENDDO
      ENDDO

#endif /* OASIM_SCALAR_ZENITH_ANGLE_COMP */

#endif /* ALLOW_OASIM */

      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: OASIM_SFCSOLZ_INST

C     !INTERFACE:
      SUBROUTINE OASIM_SFCSOLZ_INST(iyr,iday,t1,myThid)

C     !DESCRIPTION:
C     Computes solar zenith angle (stored in common block) at surface
C     given location and time.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "OASIM_SIZE.h"
#include "OASIM_INTERNAL.h"
#include "OASIM_FIELDS.h"

C     !INPUT PARAMETERS:
      INTEGER iyr, iday, myThid
      _RL t1
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      INTEGER i, j, bi, bj, jj
      _RL gmt, rs, sunv, sunn, sune, sza
      _RL sunvec(3)

      gmt = t1/3600. _d 0
      CALL OASIM_SUN_VECTOR(
     I                       iday,iyr,gmt,
     O                       sunvec,rs )
      DO bj=myByLo(myThid),myByHi(myThid)
      DO bi=myBxLo(myThid),myBxHi(myThid)
       DO j=1,sNy
       DO i=1,sNx
c  Compute components of spacecraft and sun vector in the
c  vertical (up), North (no), and East (ea) vectors frame
        sunv = 0.0 _d 0
        sunn = 0.0 _d 0
        sune = 0.0 _d 0
        DO jj = 1,3
         sunv = sunv + sunvec(jj)*OASIM_up(i,j,bi,bj,jj)
         sunn = sunn + sunvec(jj)*OASIM_no(i,j,bi,bj,jj)
         sune = sune + sunvec(jj)*OASIM_ea(i,j,bi,bj,jj)
        ENDDO
        sza = rad*ATAN2(SQRT(sunn*sunn+sune*sune),sunv)
        sza = MIN(sza, 90.0 _d 0)
        OASIM_solz(i,j,bi,bj) = MAX(sza, 0.0 _d 0)
       ENDDO
       ENDDO
      ENDDO
      ENDDO

#endif /* ALLOW_OASIM */

      RETURN
      END
