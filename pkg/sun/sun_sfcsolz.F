#include "SUN_OPTIONS.h"

CBOP
C     !ROUTINE: SUN_SFCSOLZ
C     !INTERFACE: ======================================================
      SUBROUTINE SUN_SFCSOLZ(
     O                        solz,
     I                        isec,
     I                        bi, bj, iMin, iMax, jMin, jMax,
     I                        myTime, myIter, myThid )

C     !DESCRIPTION:
C     Computes solar zenith angle above sea surface

C     !USES: ===========================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "SUN_FIELDS.h"

C     !INPUT PARAMETERS: ===============================================
C     isec :: time of day in seconds when to compute the zenith angle
C             .LT. 0 means current time
C             .GE. 0 is the time in seconds since midnight
C             so 43200 is noon
C     myTime :: time at end of current (sub)timestep
      _RL myTime
      INTEGER isec, bi, bj, iMin, iMax, jMin, jMax, myIter, myThid

C     !OUTPUT PARAMETERS: ==============================================
C     solz :: solar zenith angle above sea surface in degrees
      _RL solz(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
CEOP

#ifdef ALLOW_SUN

C     !FUNCTIONS: ======================================================
      INTEGER SUN_JD
      EXTERNAL SUN_JD

C     !LOCAL VARIABLES: ================================================
      INTEGER i,j,l
      INTEGER iyr,imon,iday,isecnow,lp,wd,myDate(4)
      _RL sec, suni(3), sung(3), sunv, sunn, sune, rs, gha, rlon
      _RL rjd, t
      _RL xls, gs, xlm, asc, dpsi, eps

C  Get current date and time of day: iyr/imon/iday+isecnow
      CALL CAL_GETDATE( myIter,myTime,myDate,myThid )
      CALL CAL_CONVDATE( mydate,iyr,imon,iday,isecnow,lp,wd,myThid )
      IF ( isec .GE. 0 )THEN
C       overwrite time of day as requested
        sec = isec
      ELSE
        sec = isecnow
      ENDIF

C  Compute floating point days since Jan 1.5, 2000
C  Note that the Julian day starts at noon on the specified date
      rjd = SUN_JD(iyr,imon,iday)
      t = rjd - 2451545 _d 0 + (sec-43200 _d 0)/86400 _d 0

C  Compute solar ephemeris parameters
      CALL SUN_EPHPARMS (t,xls,gs,xlm,asc)

C  Compute nutation corrections
      CALL SUN_NUTATE (t,xls,gs,xlm,asc,dpsi,eps)

C  Compute unit sun vector in geocentric inertial coordinates
      CALL SUN_SUN2000 (t,xls,gs,xlm,asc,dpsi,eps,suni,rs)

C  Get Greenwich mean sidereal angle
      CALL SUN_GHA2000 (t,dpsi,eps,gha)
      gha = gha*deg2rad

      IF ( isec .GE. 0 )THEN

       DO j=jMin,jMax
        DO i=iMin,iMax

C        isec is in local time, need to transform gha
         rlon = XC(i,j,bi,bj)*deg2rad

C  Transform Sun vector into geocentric rotating frame
         sung(1) = suni(1)*COS(gha-rlon) + suni(2)*SIN(gha-rlon)
         sung(2) = suni(2)*COS(gha-rlon) - suni(1)*SIN(gha-rlon)
         sung(3) = suni(3)

C  Compute components of spacecraft and sun vector in the
C  vertical (up), North (no), and East (ea) vectors frame
         sunv = 0 _d 0
         sunn = 0 _d 0
         sune = 0 _d 0
         DO l=1,3
          sunv = sunv + sung(l)*SUN_up(i,j,bi,bj,l)
          sunn = sunn + sung(l)*SUN_no(i,j,bi,bj,l)
          sune = sune + sung(l)*SUN_ea(i,j,bi,bj,l)
         ENDDO

C  Compute the solar zenith
         solz(i,j) = ATAN2(SQRT(sunn*sunn+sune*sune), sunv)/deg2rad
        ENDDO
       ENDDO

      ELSE

C  Transform Sun vector into geocentric rotating frame
       sung(1) = suni(1)*COS(gha) + suni(2)*SIN(gha)
       sung(2) = suni(2)*COS(gha) - suni(1)*SIN(gha)
       sung(3) = suni(3)

       DO j=jMin,jMax
        DO i=iMin,iMax
C  Compute components of spacecraft and sun vector in the
C  vertical (up), North (no), and East (ea) vectors frame
         sunv = 0 _d 0
         sunn = 0 _d 0
         sune = 0 _d 0
         DO l=1,3
          sunv = sunv + sung(l)*SUN_up(i,j,bi,bj,l)
          sunn = sunn + sung(l)*SUN_no(i,j,bi,bj,l)
          sune = sune + sung(l)*SUN_ea(i,j,bi,bj,l)
         ENDDO

C  Compute the solar zenith
         solz(i,j) = ATAN2(SQRT(sunn*sunn+sune*sune), sunv)/deg2rad
        ENDDO
       ENDDO

      ENDIF

#endif /* ALLOW_SUN */

      RETURN
      END
