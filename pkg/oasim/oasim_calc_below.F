#include "OASIM_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_CALC_BELOW

C     !INTERFACE:
      SUBROUTINE OASIM_CALC_BELOW( dodiags, myThid )

C     !DESCRIPTION:
C     compute below-water irradiances

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "OASIM_SIZE.h"
#include "OASIM_PARAMS.h"
#include "OASIM_INTERNAL.h"
#include "OASIM_FIELDS.h"

C     !INPUT PARAMETERS:
C     myThid   :: my Thread Id number
      LOGICAL dodiags
      INTEGER myThid
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      CHARACTER*8 diagName
      INTEGER i,j,bi,bj,l
      _RL rsolzw
      _RL rod(sNx,sNy,nlt), ros(sNx,sNy,nlt)
      _RL rodl(nlt), rosl(nlt)
      _RL E0(sNx,sNy)
c
      DO bj=myByLo(myThid),myByHi(myThid)
      DO bi=myBxLo(myThid),myBxHi(myThid)

       DO j=1,sNy
       DO i=1,sNx
        rsolzw = ASIN(SIN(oasim_solz(i,j,bi,bj)/rad)/rn)
        oasim_rmud(i,j,bi,bj) = MAX(0.0, MIN(1.5 _d 0, 1/COS(rsolzw)))
       ENDDO
       ENDDO

       DO j=1,sNy
       DO i=1,sNx
        CALL OASIM_SFCRFL(oasim_solz(i,j,bi,bj), wsm(i,j,bi,bj),
     O              rodl, rosl,
     I              myThid)
        DO l=1,nlt
         rod(i,j,l) = rodl(l)
         ros(i,j,l) = rosl(l)
        ENDDO
       ENDDO
       ENDDO

       DO l=1,nlt

        DO j=1,sNy
        DO i=1,sNx
         oasim_edbelow(i,j,bi,bj,l) = oasim_edabove(i,j,bi,bj,l)
     &                                *(1-rod(i,j,l))
         oasim_esbelow(i,j,bi,bj,l) = oasim_esabove(i,j,bi,bj,l)
     &                                *(1-ros(i,j,l))
         E0(i,j) = oasim_rmud(i,j,bi,bj)*oasim_edbelow(i,j,bi,bj,l)
     &                      + oasim_rmus*oasim_esbelow(i,j,bi,bj,l)
        ENDDO
        ENDDO

#ifdef ALLOW_DIAGNOSTICS
        IF (useDiagnostics .AND. dodiags) THEN
         WRITE(diagName,'(A5,I3.3)')'OArod',l
         CALL DIAGNOSTICS_FILL(rod(1,1,l),diagName,0,1,3,bi,bj,myThid)
         WRITE(diagName,'(A5,I3.3)')'OAros',l
         CALL DIAGNOSTICS_FILL(ros(1,1,l),diagName,0,1,3,bi,bj,myThid)
         WRITE(diagName,'(A5,I3.3)')'E0blw',l
         CALL DIAGNOSTICS_FILL(E0,diagName,0,1,3,bi,bj,myThid)
        ENDIF
#endif

C      l
       ENDDO

      ENDDO  ! bi
      ENDDO  ! bj

#endif /* ALLOW_OASIM */

      RETURN
      END


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: OASIM_SFCRFL

C     !INTERFACE:
      SUBROUTINE OASIM_SFCRFL(
     I                        theta,ws,
     O                        rod,ros,
     I                        myThid)

C     !DESCRIPTION:
C     Computes surface reflectance for direct (rod) and diffuse (ros)
C     components separately, as a function of theta, wind speed or stress.
C     Includes spectral dependence of foam reflectance derived from Frouin
C     et al., 1996 (JGR)

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "OASIM_SIZE.h"
#include "OASIM_INTERNAL.h"

C     !INPUT PARAMETERS:
      _RL theta, ws
      INTEGER myThid

C     !OUTPUT PARAMETERS:
      _RL rod(nlt),ros(nlt)

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      INTEGER l
      _RL a, b, cn, rpls, rmin, rospd, rof, rosps, sintr, rtheta
      _RL rthetar, sinrmin, sinp, sinrpls, tanrmin, tanp, tanrpls
c
c  Foam and diffuse reflectance
      IF (ws .GT. 4.0 _d 0)THEN
       IF (ws .LE. 7.0 _d 0)THEN
        cn = 6.2 _d -4 + 1.56 _d -3/ws
        rof = roair*cn*2.2 _d -5*ws*ws - 4.0 _d -4
       ELSE
        cn = 0.49 _d -3 + 0.065 _d -3*ws
        rof = (roair*cn*4.5 _d -5 - 4.0 _d -5)*ws*ws
       ENDIF
       rosps = 0.057 _d 0
      ELSE
       rof = 0.0 _d 0
       rosps = 0.066 _d 0
      ENDIF
c
c  Direct
c   Fresnel reflectance for theta < 40, ws < 2 m/s
      IF (theta .LT. 40.0 _d 0 .OR. ws .LT. 2.0 _d 0)THEN
       IF (theta .EQ. 0.0 _d 0)THEN
        rospd = 0.0211 _d 0
       ELSE
        rtheta = theta/rad
        sintr = SIN(rtheta)/rn
        rthetar = ASIN(sintr)
        rmin = rtheta - rthetar
        rpls = rtheta + rthetar
        sinrmin = SIN(rmin)
        sinrpls = SIN(rpls)
        tanrmin = TAN(rmin)
        tanrpls = TAN(rpls)
        sinp = (sinrmin*sinrmin)/(sinrpls*sinrpls)
        tanp = (tanrmin*tanrmin)/(tanrpls*tanrpls)
        rospd = 0.5 _d 0*(sinp + tanp)
       ENDIF
      ELSE
c   Empirical fit otherwise
       a = 0.0253 _d 0
       b = -7.14 _d -4*ws + 0.0618 _d 0
       rospd = a*EXP(b*(theta-40.0 _d 0))
      ENDIF
c
c  Reflectance totals
      DO l = 1,nlt
       rod(l) = rospd + rof*wfac(l)
       ros(l) = rosps + rof*wfac(l)
      ENDDO
c
#endif /* ALLOW_OASIM */

      RETURN
      END
