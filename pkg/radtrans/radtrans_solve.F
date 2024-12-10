#include "RADTRANS_OPTIONS.h"

CBOP
C !ROUTINE: RADTRANS_DIRECT

C !INTERFACE: ==========================================================
      subroutine RADTRANS_SOLVE(
     I                   H,rmud,Edsf,Essf,a_k,bt_k,bb_k,kbot,
     O                   Edbot,Esbot,Eubot,Estop,Eutop,
     O                   amp1, amp2, x, y,
     O                   r1, r2, kappa1, kappa2,
     I                   myThid)

C !DESCRIPTION:
c
c  Model of irradiance in the water column.  Accounts for three
c  irradiance streams [Ackleson, Balch, Holligan, JGR, 1994],
c
c  Edbot = direct downwelling irradiance in W/m2 per waveband
c  Esbot = diffuse downwelling irradiance in W/m2 per waveband
c  Eubot = diffuse upwelling irradiance in W/m2 per waveband
c
c  all defined at the bottom of each layer.  Also computed are Estop,
c  Eutop at the top of each layer which should be very close to Esbot,
c  Eubot of the layer above.
c
c  The Ed equation is integrated exactly, Es and Eu are computed by
c  solving a set of linear equation for the amplitudes in the exact
c  solution [see, e.g., Kylling, Stamnes, Tsay, JAC, 1995].
c  The boundary condition in the deepest wet layer is
c  downward-decreasing modes only (i.e., zero irradiance at infinite
c  depth, assuming the optical properties of the last layer).
c
c  Also computed are scalar radiance and PAR at the grid cell center
c  (both in uEin/m2/s).
c
C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"

C !INPUT PARAMETERS: ===================================================
C     H     :: layer thickness (including hFacC!)
C     rmud  :: inv.cosine of direct (underwater solar) zenith angle
C     Edsf  :: direct downwelling irradiance below surface per waveband
C     Essf  :: diffuse downwelling irradiance below surface per waveband
C     a_k   :: absorption coefficient per level and waveband (1/m)
C     bt_k  :: total scattering coefficient per level and waveband (1/m)
C              = forward + back scattering coefficient
C     bb_k  :: backscattering coefficient per level and waveband (1/m)
C     kbot  :: maximum number of layers to compute
      _RL H(Nr)
      _RL rmud
      _RL Edsf, Essf
      _RL a_k(Nr), bt_k(Nr), bb_k(Nr)
      INTEGER kbot
      INTEGER myThid

C !OUTPUT PARAMETERS: ==================================================
C     Edbot  :: direct downwelling irradiance at bottom of layer
C     Esbot  :: diffuse downwelling irradiance at bottom of layer
C     Eubot  :: diffuse upwelling irradiance at bottom of layer
C     Estop  :: diffuse downwelling irradiance at top of layer
C     Eutop  :: diffuse upwelling irradiance at top of layer
C     amp1   :: amplitude of downward increasing mode
C     amp2   :: amplitude of downward decreasing mode
      _RL Edbot(Nr),Esbot(Nr),Eubot(Nr)
      _RL Estop(Nr),Eutop(Nr)
      _RL amp1(Nr), amp2(Nr)
      _RL x(Nr), y(Nr)
      _RL kappa1(Nr),kappa2(Nr)
      _RL r2(Nr),r1(Nr)
CEOP

#ifdef ALLOW_RADTRANS

C !LOCAL VARIABLES: ====================================================
      INTEGER k
      _RL Edtop(Nr)
      _RL Etopwq, Ebotwq
      _RL zd
      _RL rmus,rmuu
      _RL cd,au,Bu,Cu
      _RL as,Bs,Cs,Bd,Fd
      _RL bquad,D
      _RL denom
      _RL c1,c2
      _RL ed(Nr),e2(Nr),e1(Nr)
      _RL a3d(2*Nr), b3d(2*Nr), c3d(2*Nr), y3d(2*Nr)

      rmus = RT_rmus
      rmuu = RT_rmuu

      DO k=1,Nr
        Edtop(k) = 0.0
        Estop(k) = 0.0
        Eutop(k) = 0.0
        Edbot(k) = 0.0
        Esbot(k) = 0.0
        Eubot(k) = 0.0
        amp1(k) = 0.0
        amp2(k) = 0.0
        kappa1(k) = 0.0
        kappa2(k) = 0.0
        r1(k) = 0.0
        r2(k) = 0.0
        x(k) = 0.0
        y(k) = 0.0
      ENDDO
      IF (kbot.GT.0 .AND.
     &    (Edsf.GE.RT_sfcIrrThresh .OR. Essf.GE.RT_sfcIrrThresh)) THEN
        DO k=1,kbot
          zd = H(k)
          cd = (a_k(k)+bt_k(k))*rmud
          au = a_k(k)*rmuu
          Bu = RT_ru*bb_k(k)*rmuu
          Cu = au+Bu
          as = a_k(k)*rmus
          Bs = RT_rd*bb_k(k)*rmus
          Cs = as+Bs
          Bd = bb_k(k)*rmud
          Fd = (bt_k(k)-bb_k(k))*rmud
          bquad = Cs + Cu
          D = 0.5*(bquad + SQRT(bquad*bquad - 4.0*Bs*Bu))
          kappa1(k) = D - Cs
          kappa2(k) = Cs - Bs*Bu/D  ! == D - Cu
          r1(k) = Bu/D
          r2(k) = Bs/D
          denom = (cd-Cs)*(cd+Cu) + Bs*Bu
          x(k) = -((cd+Cu)*Fd+Bu*Bd)/denom
          y(k) = (-Bs*Fd+(cd-Cs)*Bd)/denom
          ed(k) = EXP(-cd*zd)
          e1(k) = EXP(-kappa1(k)*zd)
          e2(k) = EXP(-kappa2(k)*zd)
        ENDDO

C integrate Ed equation first
        Edtop(1) = Edsf
        DO k=1,kbot-1
          Edbot(k) = Edtop(k)*ed(k)
          Edtop(k+1) = Edbot(k)
        ENDDO
        Edbot(kbot) = Edtop(kbot)*ed(kbot)

C setup tridiagonal matrix of continuity/boundary conditions
C variables: c2(1), c1(1), c2(2), ..., c1(kbot)
C a3d,b3d,c3d: lower, main and upper diagonal
C y3d: right-hand side
C
C top b.c.: c2(1) + e1(1)*r1(1)*c1(1) = Essf - x(1)*Edsf
        a3d(1) = 0. _d 0  ! not used
        b3d(1) = 1.           ! A(1,1)*c2(1)
        c3d(1) = e1(1)*r1(1)  ! A(1,2)*c1(1)
        y3d(1) = Essf - x(1)*Edsf
C continuity at layer boundaries
        DO k=1, kbot-1
          a3d(2*k) = (1. - r2(k)*r1(k+1))*e2(k)  !   A(2k,2k-1)*c2(k)
          b3d(2*k) = r1(k) - r1(k+1)             ! + A(2k,2k  )*c1(k)
          c3d(2*k) = -1. + r2(k+1)*r1(k+1)       ! + A(2k,2k+1)*c2(k+1)
          y3d(2*k)=(x(k+1) - x(k) - r1(k+1)*(y(k+1)-y(k)))
     &             *Edbot(k)
          a3d(2*k+1) = 1 - r1(k)*r2(k)                !   A(2k+1,2k  )*c1(k)
          b3d(2*k+1) = r2(k) - r2(k+1)                ! + A(2k+1,2k+1)*c2(k+1)
          c3d(2*k+1) = (-1. + r1(k+1)*r2(k))*e1(k+1)  ! + A(2k+1,2k+2)*c1(k+1)
          y3d(2*k+1)=(y(k+1) - y(k) - r2(k)*(x(k+1)-x(k)))
     &               *Edbot(k)
        ENDDO
c bottom boundary condition: c1 = 0
        a3d(2*kbot) = 0. _d 0  !   A(2*kbot,2*kbot-1)*c2(kbot)
        b3d(2*kbot) = 1. _d 0  ! + A(2*kbot,2*kbot  )*c1(kbot)
        c3d(2*kbot) = 0. _d 0  ! not used
        y3d(2*kbot) = 0. _d 0  ! = 0

        CALL RADTRANS_SOLVE_TRIDIAG(a3d,b3d,c3d,y3d,2*kbot,myThid)

C compute irradiances
        DO k=1,kbot
          c2 = y3d(2*k-1)
          c1 = y3d(2*k)
          Estop(k) = c2 + r1(k)*e1(k)*c1 + x(k)*Edtop(k)
          Esbot(k) = e2(k)*c2 + r1(k)*c1 + x(k)*Edbot(k)
          Eutop(k) = r2(k)*c2 + e1(k)*c1 + y(k)*Edtop(k)
          Eubot(k) = r2(k)*e2(k)*c2 + c1 + y(k)*Edbot(k)
          amp1(k) = c1
          amp2(k) = c2
        ENDDO
        IF (kbot .LT. Nr) THEN
          Estop(kbot+1) = Esbot(kbot)
          Eutop(kbot+1) = Eubot(kbot)
        ENDIF

C     endif kbot.gt.0
      ENDIF

#endif /* ALLOW_RADTRANS */

      RETURN
      END

