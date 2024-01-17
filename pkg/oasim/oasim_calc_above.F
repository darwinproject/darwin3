#include "OASIM_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_CALC_ABOVE

C     !INTERFACE:
      SUBROUTINE OASIM_CALC_ABOVE( daycor, dodiags, myThid )

C     !DESCRIPTION:
C     compute above-water irradiances

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
C     daycor   :: correction to earth-sun distance for current day
C     myThid   :: my Thread Id number
      _RL     daycor
      LOGICAL dodiags
      INTEGER myThid
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      CHARACTER*8 diagName
      INTEGER i,j,bi,bj,l
      _RL cov, clwp, cosunz, wvapor
      _RL re, ozone, pres, relhum, sunz, ws
      _RL betaaer, etaaer, wa1, asym1
      _RL ta(nlt),wa(nlt),asym(nlt)
      _RL Edl(nlt),Esl(nlt)
      _RL Edclrl(nlt),Esclrl(nlt)
      _RL Edcldl(nlt),Escldl(nlt)
      _RL Edclr(sNx,sNy,nlt),Esclr(sNx,sNy,nlt)
      _RL Edcld(sNx,sNy,nlt),Escld(sNx,sNy,nlt)
      _RL tauao(sNx,sNy,nlt)
      _RL asympo(sNx,sNy,nlt)
      _RL ssalbo(sNx,sNy,nlt)
c
c  Initialize arrays everytime
      oasim_Edabove = 0.0 _d 0
      oasim_Esabove = 0.0 _d 0
c
c could be taken from sunmod!(?)
c  Obtain Earth-Sun distance only for the middle of the hour
c      hr = float(ihr)
c      rday = float(iday) + hr*o24
c      daycor = (1.0 _d 0+1.67 _d -2*cos(pi2*(rday-3.0 _d 0)/365.0 _d 0))**2
c
c  Compute Ed, Es just above surface
      DO bj=myByLo(myThid),myByHi(myThid)
      DO bi=myBxLo(myThid),myBxHi(myThid)

      DO j=1,sNy
      DO i=1,sNx
c   atmospheric gases
        pres = slp(i,j,bi,bj)
        ws = wsm(i,j,bi,bj)
        ozone = oz(i,j,bi,bj)
        wvapor = wv(i,j,bi,bj)
        relhum = rh(i,j,bi,bj)

c   aerosols
C       Obtain aerosol parameters; simplified Navy aerosol model
        CALL OASIM_NAVAER(relhum,oasim_am,oasim_Vi,ws,
     O                    betaaer,etaaer,wa1,asym1,
     I                    myThid)
        DO l = 1,nlt
         ta(l) = taua(i,j,bi,bj,l)
         asym(l) = asymp(i,j,bi,bj,l)
         wa(l) = ssalb(i,j,bi,bj,l)
         IF (ta(l) .LT. 0.0 _d 0)THEN
          ta(l) = betaaer*rlamu(l)**etaaer
         ENDIF
         IF (wa(l) .LT. 0.0 _d 0)THEN
          wa(l) = wa1
         ENDIF
         IF (asym(l) .LT. 0.0 _d 0 .OR. asym(l) .GE. 1.0 _d 0) THEN
          asym(l) = asym1
         ENDIF
         tauao(i,j,l) = ta(l)
         asympo(i,j,l) = asym(l)
         ssalbo(i,j,l) = wa(l)
        ENDDO

c   clouds
        cov = ccov(i,j,bi,bj)
        clwp = rlwp(i,j,bi,bj)
        re = cdre(i,j,bi,bj)

        cosunz = COS(oasim_solz(i,j,bi,bj)/rad)
        sunz = oasim_solz(i,j,bi,bj)
        IF (sunz .LT. 90.0 _d 0)THEN
c   Ed, Es
         CALL OASIM_LIGHT(sunz,cosunz,daycor,
     I    pres,ws,ozone,wvapor,relhum,
     I    ta,wa,asym,cov,clwp,re,
     O    Edl,Esl,Edclrl,Esclrl,Edcldl,Escldl,
     I    myThid)
        ELSE
         DO l = 1,nlt
          Edl(l) = 0.0 _d 0
          Esl(l) = 0.0 _d 0
          Edclrl(l) = 0.0 _d 0
          Esclrl(l) = 0.0 _d 0
          Edcldl(l) = 0.0 _d 0
          Escldl(l) = 0.0 _d 0
         ENDDO
        ENDIF
        DO l = 1,nlt
         OASIM_Edabove(i,j,bi,bj,l) = Edl(l)
         OASIM_Esabove(i,j,bi,bj,l) = Esl(l)
         Edclr(i,j,l) = Edclrl(l)
         Esclr(i,j,l) = Esclrl(l)
         Edcld(i,j,l) = Edcldl(l)
         Escld(i,j,l) = Escldl(l)
        ENDDO
      ENDDO
      ENDDO

#ifdef ALLOW_DIAGNOSTICS
      IF (useDiagnostics .AND. dodiags) THEN
       DO l = 1,nlt
        WRITE(diagName,'(A5,I3.3)')'Edclr',l
        CALL DIAGNOSTICS_FILL(Edclr(1,1,l),diagName,0,1,3,bi,bj,myThid)
        WRITE(diagName,'(A5,I3.3)')'Esclr',l
        CALL DIAGNOSTICS_FILL(Esclr(1,1,l),diagName,0,1,3,bi,bj,myThid)
        WRITE(diagName,'(A5,I3.3)')'Edcld',l
        CALL DIAGNOSTICS_FILL(Edcld(1,1,l),diagName,0,1,3,bi,bj,myThid)
        WRITE(diagName,'(A5,I3.3)')'Escld',l
        CALL DIAGNOSTICS_FILL(Escld(1,1,l),diagName,0,1,3,bi,bj,myThid)
        WRITE(diagName,'(A4,I3.3)')'taua',l
        CALL DIAGNOSTICS_FILL(tauao(1,1,l),diagName,0,1,3,bi,bj,myThid)
        WRITE(diagName,'(A5,I3.3)')'asymp',l
        CALL DIAGNOSTICS_FILL(asympo(1,1,l),diagName,0,1,3,bi,bj,myThid)
        WRITE(diagName,'(A5,I3.3)')'ssalb',l
        CALL DIAGNOSTICS_FILL(ssalbo(1,1,l),diagName,0,1,3,bi,bj,myThid)
       ENDDO
      ENDIF
#endif

      ENDDO ! bi
      ENDDO ! bj

#endif /* ALLOW_OASIM */

      RETURN
      END
