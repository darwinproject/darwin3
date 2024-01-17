#include "OASIM_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: OASIM_NAVAER

C     !INTERFACE:
      SUBROUTINE OASIM_NAVAER(
     I  relhum,am,Vi,ws,
     O  beta,eta,wa,asymp,
     I  myThid)

C     !DESCRIPTION:
C     Computes aerosol parameters according to a simplified version
C     of the Navy marine aerosol model.

C     !USES:
      IMPLICIT NONE

C     !INPUT PARAMETERS:
      _RL relhum, am, Vi, ws
      INTEGER myThid

C     !OUTPUT PARAMETERS:
      _RL beta, eta, wa, asymp
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      INTEGER n,i
      _RL rnum, rden, frh, arg, rval, sumx, sumy, sumxy, sumx2
      _RL rlrn, rldndr, gama, rlogc, alpha, cext
      _RL a(3),ro(3),dndr(3),r(3),rlam
      DATA ro /0.03 _d 0,0.24 _d 0,2.0 _d 0/
      DATA r /0.1 _d 0,1.0 _d 0,10.0 _d 0/
      DATA rlam /0.55 _d 0/
c
c  Relative humidity factor
c      IF (relhum .GE. 100.0 _d 0)relhum = 99.9 _d 0
      relhum = MIN(99.9 _d 0,relhum)
      rnum = 2.0 _d 0 - relhum/100.0 _d 0
      rden = 6.0 _d 0*(1.0 _d 0-relhum/100.0 _d 0)
      frh = (rnum/rden)**0.333 _d 0
c
c  Size distribution amplitude components
      a(1) = 2000.0 _d 0*am*am
      a(2) = 5.866 _d 0*(ws-2.2 _d 0)
c      IF (a(2) .LT. 0.5 _d 0)a(2) = 0.5 _d 0
      a(2) = MAX(0.5 _d 0,a(2))
      a(3) = 0.01527 _d 0*(ws-2.2 _d 0)*0.05 _d 0        !from Hughes 1987
c      IF (a(3) .LT. 1.4 _d -5)a(3) = 1.4 _d -5
      a(3) = MAX(1.4 _d -5,a(3))
c
c  Compute size distribution at three selected radii according to
c  Navy method
      DO n = 1,3
       dndr(n) = 0.0
       DO i = 1,3
        rden = frh*ro(i)
        arg = LOG(r(n)/rden)*LOG(r(n)/rden)
        rval = a(i)*EXP(-arg)/frh
        dndr(n) = dndr(n) + rval
       ENDDO
      ENDDO
c
c  Least squares approximation
      sumx = 0.0 _d 0
      sumy = 0.0 _d 0
      sumxy = 0.0 _d 0
      sumx2 = 0.0 _d 0
      DO n = 1,3
       rlrn = LOG10(r(n))
       rldndr = LOG10(dndr(n))
       sumx = sumx + rlrn
       sumy = sumy + rldndr
       sumxy = sumxy + rlrn*rldndr
       sumx2 = sumx2 + rlrn*rlrn
      ENDDO
      gama = sumxy/sumx2
      rlogc = sumy/3.0 _d 0 - gama*sumx/3.0 _d 0
      alpha = -(gama+3.0 _d 0)
      eta = -alpha
c
c  Compute beta
      cext = 3.91 _d 0/Vi
      beta = cext*rlam**alpha
c
c  Compute asymmetry parameter -- a function of alpha
      IF (alpha .GT. 1.2 _d 0)THEN
       asymp = 0.65 _d 0
      ELSE IF (alpha .LT. 0.0 _d 0)THEN
       asymp = 0.82 _d 0
      ELSE
       asymp = -0.14167 _d 0*alpha + 0.82 _d 0
      ENDIF
c
c  Single scattering albedo at 550; function of RH
      wa = (-0.0032 _d 0*am + 0.972 _d 0)*EXP(3.06 _d -4*relhum)

#endif /* ALLOW_OASIM */

      RETURN
      END
