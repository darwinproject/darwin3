#include "OASIM_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: OASIM_LIGHT

C     !INTERFACE:
      SUBROUTINE OASIM_LIGHT(
     I sunz,cosunz,daycor,pres,ws,ozone,wvapor,relhum,
     I ta,wa,asym,cov,clwp,re,
     O Ed,Es,Edclr,Esclr,Edcld,Escld,
     I myThid)

C     !DESCRIPTION:
C     calls clrtrans.F to get cloud-free transmittance and slingo.F to
C     get cloudy transmittance, then computes total irradiance in
C     W/m2/(variable)nm weighted by the cloudiness.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "OASIM_SIZE.h"
#include "OASIM_INTERNAL.h"
#include "OASIM_SLINGO.h"

C     !INPUT PARAMETERS:
      _RL ta(nlt),wa(nlt),asym(nlt)
      _RL sunz,cosunz,daycor,pres,ws,ozone,wvapor,relhum
      _RL cov,clwp,re
      INTEGER myThid

C     !OUTPUT PARAMETERS:
      _RL Ed(nlt),Es(nlt)
      _RL Edclr(nlt),Esclr(nlt)
      _RL Edcld(nlt),Escld(nlt)
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
c     Tdclr :: spectral clear sky direct transmittance
c     Tsclr :: spectral clear sky diffuse transmittance
c     Tdcld :: spectral cloudy direct transmittance
c     Tscld :: spectral cloudy diffuse transmittance
      INTEGER l
      _RL ag, ccov1, edir, edif, garg, foinc, gtmp, gtmp2, oarg
      _RL otmp, rm, rmp, rmo, rmu0, rtmp, to
      _RL warg, wtmp, wtmp2
      _RL Tgas(nlt)
      _RL Tdclr(nlt),Tsclr(nlt)
      _RL Tdcld(ncld),Tscld(ncld)
c
      IF (pres .LT. 0.0 _d 0 .OR. ws .LT. 0.0 _d 0 .OR.
     &    relhum .LT. 0.0 _d 0 .OR.
     &    ozone .LT. 0.0 _d 0 .OR. wvapor .LT. 0.0 _d 0) THEN
       DO l = 1,nlt
        Ed(l) = 0.0 _d 0
        Es(l) = 0.0 _d 0
        Edclr(l) = 0.0 _d 0
        Esclr(l) = 0.0 _d 0
        Edcld(l) = 0.0 _d 0
        Escld(l) = 0.0 _d 0
       ENDDO
       RETURN
      ENDIF
c
c  Compute atmospheric path lengths (air mass); not pressure-corrected
      rtmp = (93.885 _d 0-sunz)**(-1.253 _d 0)
      rmu0 = cosunz+0.15 _d 0*rtmp
      rm = 1.0 _d 0/rmu0
      otmp = (cosunz*cosunz+ozfac1)**0.5 _d 0
      rmo = ozfac2/otmp
c
c  Compute pressure-corrected atmospheric path length (air mass)
      rmp = pres/p0*rm
c
c  Loop to compute total irradiances at each grid point
c   Compute direct and diffuse irradiance for a cloudy and non-cloudy
c   atmosphere
c   Account for gaseous absorption
      DO l = 1,nlt
c    Ozone
       to = oza(l)*ozone*0.001 _d 0   !optical thickness
       oarg = -to*rmo
c   Oxygen/gases
       ag = ao(l) + aco2(l)
       gtmp = (1.0 _d 0 + 118.3 _d 0*ag*rmp)**0.45 _d 0
       gtmp2 = -1.41 _d 0*ag*rmp
       garg = gtmp2/gtmp
c   Water Vapor
       wtmp = (1.0 _d 0+20.07 _d 0*awv(l)*wvapor*rm)**0.45 _d 0
       wtmp2 = -0.2385 _d 0*awv(l)*wvapor*rm
       warg = wtmp2/wtmp
       Tgas(l) = EXP(oarg+garg+warg)
      enddo
c
c  Compute clear sky transmittances
      CALL OASIM_CLRTRANS(
     I              cosunz,rm,rmp,ta,wa,asym,
     O              Tdclr,Tsclr,
     I              myThid)
      DO l = 1,nlt
       Foinc = Fobar(l)*daycor*cosunz
c    Direct irradiance
       Edir = Foinc*Tgas(l)*Tdclr(l)
c    Diffuse irradiance
       Edif = Foinc*Tgas(l)*Tsclr(l)
c    Spectral components
       Edclr(l) = Edir
       Esclr(l) = Edif
      ENDDO    !end clear l loop
c  Compute cloudy transmittances
      CALL OASIM_SLINGO(rmu0,clwp,re,
     O                  Tdcld,Tscld,
     I                  myThid)
      DO l = 1,nlt
       Foinc = Fobar(l)*daycor*cosunz
c    Direct irradiance
       Edir = Foinc*Tgas(l)*Tdcld(ica(l))
c    Diffuse irradiance
       Edif = Foinc*Tgas(l)*Tscld(ica(l))
c    Spectral components
       Edcld(l) = Edir
       Escld(l) = Edif
      ENDDO   !end cloudy l loop
c
c  Sum clear and cloudy by percent
      ccov1 = cov*0.01 _d 0  !convert from percent to fraction
      DO l = 1,nlt
       Ed(l) = (1.0 _d 0-ccov1)*Edclr(l) + ccov1*Edcld(l)
       Es(l) = (1.0 _d 0-ccov1)*Esclr(l) + ccov1*Escld(l)
      ENDDO
c
c   Total short-wave (W/m2)
c       sirrsw = sirrsw + Edir + Edif

#endif /* ALLOW_OASIM */

      RETURN
      END
