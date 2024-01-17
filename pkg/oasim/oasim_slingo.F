#include "OASIM_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: OASIM_SLINGO

C     !INTERFACE:
      SUBROUTINE OASIM_SLINGO(
     I                  rmu0,clwp,cre,
     O                  Tcd,Tcs,
     I                  myThid)

C     !DESCRIPTION:
C     Slingo's (1989) Delta-Eddington approximation for the two-stream
C     equations applied to clouds.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "OASIM_SIZE.h"
#include "OASIM_INTERNAL.h"
#include "OASIM_SLINGO.h"

C     !INPUT PARAMETERS:
c     rmu0   :: Kasten's approx for cosine of solar zenith angle
c     clwp   :: liquid water path in cloud (g/m2)
c     cre    :: cloud droplet effective radius (um)
      _RL rmu0, clwp, cre
      INTEGER myThid

C     !OUTPUT PARAMETERS:
c     Tcd :: spectral transmittance for downwelling direct irradiance
c     Tcs :: spectral transmittance for downwelling diffuse irradiance
      _RL Tcd(ncld),Tcs(ncld)
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
C     Tcu :: spectral transmittance for upwelling irradiance
      INTEGER izero, nc
      _RL Tcu(ncld)
      _RL b0, alpha1, alpha3, alpha2, alpha4, bmu0
      _RL e, eps, f, g, gama1, gama2, oneomega, omega
      _RL rdif, rden, re, rm, rnum, sqarg, tauc, tdb
      _RL tdir, tdif, u2, val2, val1, val3
c
c  Compute re as funtion of cldtau and LWP according to eq. 1 in
c  Slingo.
c   tau is derived at this wavelength (0.6 um) in the ISCCP data set
c      re = clwp*bsl(9)/(cldtau - clwp*asl(9))
c      re = min(re,15.0)  !block high re -- produces excessive direct
c  Changes to the ISCCP-D2 data set make this relationship untenable
c  (excessive res are derived).  Instead choose a fixed re of 10 um
c  for ocean (Kiehl et al., 1998 -- J. Clim.)
c       re = 10.0
c  Paper by Han et al., 1994 (J.Clim.) show mean ocean cloud radius
c  = 11.8 um
c       re = 11.8
c  Mean of Kiehl and Han
      re = (10.0 _d 0+11.8 _d 0)/2.0 _d 0
c
c  Compute spectral cloud characteristics
c   If MODIS re is available use it; otherwise use parameterized re above
      IF (cre .GE. 0.0 _d 0)THEN   !use MODIS re
       re = cre
      ENDIF
      izero = 0
      DO nc = 1,ncld
       tauc = clwp*(asl(nc)+bsl(nc)/re)
       oneomega = csl(nc) + dsl(nc)*re
       omega = 1.0 _d 0 - oneomega
       g = esl(nc) + fsl(nc)*re
       b0 = 3.0 _d 0/7.0 _d 0*(1.0 _d 0-g)
       bmu0 = 0.5 _d 0 - 0.75 _d 0*rmu0*g/(1.0 _d 0+g)
       f = g*g
       U2 = U1*(1.0 _d 0-((1.0 _d 0-omega)/(7.0 _d 0*omega*b0)))
       U2 = MAX(U2,0.0 _d 0)
       alpha1 = U1*(1.0 _d 0-omega*(1.0 _d 0-b0))
       alpha2 = U2*omega*b0
       alpha3 = (1.0 _d 0-f)*omega*bmu0
       alpha4 = (1.0 _d 0-f)*omega*(1.0 _d 0-bmu0)
       sqarg = alpha1*alpha1 - alpha2*alpha2
       sqarg = MAX(sqarg,1.0 _d -17)
       eps = SQRT(sqarg)
       rM = alpha2/(alpha1+eps)
       E = EXP(-eps*tauc)
       val1 = 1.0 _d 0 - omega*f
       val2 = eps*eps*rmu0*rmu0
       rnum = val1*alpha3 - rmu0*(alpha1*alpha3+alpha2*alpha4)
       rden = val1*val1 - val2
       gama1 = rnum/rden
       rnum = -val1*alpha4 - rmu0*(alpha1*alpha4+alpha2*alpha3)
       gama2 = rnum/rden
       Tdb = EXP(-val1*tauc/rmu0)
       val3 = 1.0 _d 0 - E*E*rM*rM
       Rdif = rM*(1.0 _d 0-E*E)/val3
       Tdif = E*(1.0 _d 0-rM*rM)/val3
c       Rdir = -gama2*Rdif - gama1*Tdb*Tdif + gama1
       Tdir = -gama2*Tdif - gama1*Tdb*Rdif + gama2*Tdb
c       Tdir = max(Tdir,0.0 _d 0)
       Tcd(nc) = Tdb
       Tcs(nc) = Tdir
       IF (Tcs(nc) .LT. 0.0 _d 0)izero=1
c       Tcu(nc) = Tdif
      ENDDO
      IF (izero .EQ. 1)THEN    !block negative diffuse irrads
       DO nc = 1,ncld
        Tcs(nc) = 0.0
       ENDDO
      ENDIF

#endif /* ALLOW_OASIM */

      RETURN
      END
