C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_radtrans_iter.F,v 1.1 2010/07/13 19:16:37 jahn Exp $
C $Name:  $

#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_RADTRANS_ITER

C !INTERFACE: ==========================================================
      subroutine darwin_radtrans_iter(
     I                   H,rmud,Edsf,Essf,a_k,bt_k,bb_k,kmax,niter,
     O                   Edbot,Esbot,Eubot,Eutop,
     O                   tirrq,tirrwq,
     I                   myThid)

C !DESCRIPTION:
c
c  Model of irradiance in the water column.  Accounts for three
c  irradiance streams:
c
c  Edbot = direct downwelling irradiance in W/m2 per waveband
c  Esbot = diffuse downwelling irradiance in W/m2 per waveband
c  Eubot = diffuse upwelling irradiance in W/m2 per waveband
c
c  Propagation is done in energy units, tests are done in quanta,
c  final is quanta for phytoplankton growth.
c
c  The Ed equation is integrated exactly.
c  Es and Eu are first computed using a truncation to downward-
c  decreasing modes a la Aas that makes Es continuous.
c  Then niter alternating upward and downward integrations are performed,
c  each time using Es at the top and Eu at the bottom of each layer as a
c  boundary condition.  The boundary condition in the deepest wet layer
c  is always downward-decreasing modes only.
c  During upward integrations, Eu is made continuous, during downward
c  integrations, Es.
c  At the end, Ed and Es are continuous, but Eu is so only approximately.
c
C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"             /* Nr */
C#include "EEPARAMS.h"
#include "DARWIN_SIZE.h"      /* tlam */
#include "DARWIN.h"           /* WtouEin */
#include "WAVEBANDS_PARAMS.h" /* darwin_PAR_ilamLo/Hi
                                 darwin_radmodThresh
                                 darwin_rmus darwin_rmuu */

C !INPUT PARAMETERS: ===================================================
C     H     :: layer thickness (including hFacC!)
C     rmud  :: inv.cosine of direct (underwater solar) zenith angle
C     Edsf  :: direct downwelling irradiance below surface per waveband
C     Essf  :: diffuse downwelling irradiance below surface per waveband
C     a_k   :: absorption coefficient per level and waveband (1/m)
C     bt_k  :: total scattering coefficient per level and waveband (1/m)
C              = forward + back scattering coefficient
C     bb_k  :: backscattering coefficient per level and waveband (1/m)
C     kmax  :: maximum number of layers to compute
C     niter :: number of up-down iterations after initial Aas integration
      _RL H(Nr)
      _RL rmud
      _RL Edsf(tlam), Essf(tlam)
      _RL a_k(Nr,tlam), bt_k(Nr,tlam), bb_k(Nr,tlam)
      INTEGER kmax,niter
      INTEGER myThid

C !OUTPUT PARAMETERS: ==================================================
C     Edbot    :: direct downwelling irradiance at bottom of layer
C     Esbot    :: diffuse downwelling irradiance at bottom of layer
C     Eubot    :: diffuse upwelling irradiance at bottom of layer
C     tirrq  :: total scalar irradiance at cell center (uEin/m2/s)
C     tirrwq :: total scalar irradiance at cell center per waveband
      _RL Edbot(tlam,Nr),Esbot(tlam,Nr),Eubot(tlam,Nr),Eutop(tlam,Nr)
      _RL tirrq(Nr)
      _RL tirrwq(tlam,Nr)

#ifdef DAR_RADTRANS

C !LOCAL VARIABLES: ====================================================
      INTEGER k, nl, iter, kbot
      _RL Edtop(tlam,Nr),Estop(tlam,Nr)
      _RL Etopwq, Ebotwq
      _RL zd
      _RL rmus,rmuu

C     !LOCAL VARIABLES: ================================================
      _RL cd,au,Bu,Cu
      _RL as,Bs,Cs,Bd,Fd
      _RL bquad,cquad,sqarg
      _RL a1,a2,denom
      _RL c1,c2,tmp,Esnew,Eunew
      _RL R2(Nr),R1(Nr),x(Nr),y(Nr)
      _RL expAddr(Nr),expAsdr(Nr),expmAudr(Nr),idenom(Nr)
c
      _RL rbot, rd, ru
      data rbot /0.0/ !bottom reflectance (not used)
      data rd /1.5/   !these are taken from Ackleson, et al. 1994 (JGR)
      data ru /3.0/
CEOP
      rmus = darwin_rmus
      rmuu = darwin_rmuu

c     find deepest wet layer
      kbot = kmax
      DO WHILE (H(kbot).EQ.0 .AND. kbot.GT.1)
        kbot = kbot - 1
      ENDDO

      DO nl = 1,tlam
       DO k=1,Nr
        Edtop(nl,k) = 0.0
        Estop(nl,k) = 0.0
        Eutop(nl,k) = 0.0
        Edbot(nl,k) = 0.0
        Esbot(nl,k) = 0.0
        Eubot(nl,k) = 0.0
       ENDDO
       IF (Edsf(nl) .GE. darwin_radmodThresh .OR.
     &     Essf(nl) .GE. darwin_radmodThresh) THEN
        DO k=1,kbot
         zd = H(k)
         cd = (a_k(k,nl)+bt_k(k,nl))*rmud
         au = a_k(k,nl)*rmuu
         Bu = ru*bb_k(k,nl)*rmuu
         Cu = au+Bu
         as = a_k(k,nl)*rmus
         Bs = rd*bb_k(k,nl)*rmus
         Cs = as+Bs
         Bd = bb_k(k,nl)*rmud
         Fd = (bt_k(k,nl)-bb_k(k,nl))*rmud
         bquad = Cs - Cu
         cquad = Bs*Bu - Cs*Cu
         sqarg = bquad*bquad - 4.0*cquad
         a1 = 0.5*(-bquad + sqrt(sqarg))
         a2 = 0.5*(-bquad - sqrt(sqarg))  ! K of Aas
         R1(k) = (a1+Cs)/Bu
         R2(k) = (a2+Cs)/Bu
         denom = (cd-Cs)*(cd+Cu) + Bs*Bu
         x(k) = -((cd+Cu)*Fd+Bu*Bd)/denom
         y(k) = (-Bs*Fd+(cd-Cs)*Bd)/denom
         expAddr(k) = exp(-cd*zd)
         expmAudr(k) = exp(-a1*zd)
         expAsdr(k) = exp(a2*zd)
         idenom(k) = 1./(R1(k)-R2(k)*expAsdr(k)*expmAudr(k))
        ENDDO

C     integrate Ed equation first
        Edtop(nl,1) = Edsf(nl)
        DO k=1,kbot-1
         Edbot(nl,k) = Edtop(nl,k)*expAddr(k)
         Edtop(nl,k+1) = Edbot(nl,k)
        ENDDO
        Edbot(nl,kbot) = Edtop(nl,kbot)*expAddr(kbot)

C     start with Aas solution (no increasing mode)
        Estop(nl,1) = Essf(nl)
        DO k=1,kbot-1
         c2 = Estop(nl,k) - x(k)*Edtop(nl,k)
         Estop(nl,k+1) = MAX(0., c2*expAsdr(k) + x(k)*Edbot(nl,k))
         Eubot(nl,k) = MAX(0., R2(k)*c2*expAsdr(k) + y(k)*Edbot(nl,k))
         Eutop(nl,k) = R2(k)*c2 + y(k)*Edtop(nl,k)
        ENDDO
C       Aas b.c. in bottom layer
        c2 = Estop(nl,kbot) - x(kbot)*Edtop(nl,kbot)
        Eutop(nl,kbot) = R2(kbot)*c2 + y(kbot)*Edtop(nl,kbot)

c     improve solution iteratively
        DO iter=1,niter
c        bottom boundary condition
         Eubot(nl,kbot-1) = Eutop(nl,kbot)

         DO k=kbot-1,2,-1
c         compute Eubot(k-1) from Estop(k) and Eubot(k)
          tmp = Estop(nl,k)-x(k)*Edtop(nl,k)
          c1 = (Eubot(nl,k)-R2(k)*expAsdr(k)*tmp-y(k)*Edbot(nl,k))
     &         *idenom(k)
          c2 = (R1(k)*tmp + y(k)*expmAudr(k)*Edbot(nl,k)
     &          - expmAudr(k)*Eubot(nl,k))*idenom(k)
          Eunew = R2(k)*c2 + R1(k)*expmAudr(k)*c1 + y(k)*Edtop(nl,k)
          Eubot(nl,k-1) = MAX(0., Eunew)
         ENDDO
         DO k=1,kbot-1
c         compute Estop(k+1) from Estop(k) and Eubot(k)
          tmp = Estop(nl,k) - x(k)*Edtop(nl,k)
          c1 = (Eubot(nl,k)-R2(k)*expAsdr(k)*tmp-y(k)*Edbot(nl,k))
     &         *idenom(k)
          c2 = (R1(k)*tmp + y(k)*expmAudr(k)*Edbot(nl,k)
     &          - expmAudr(k)*Eubot(nl,k))*idenom(k)
          Esnew = expAsdr(k)*c2 + c1 + x(k)*Edbot(nl,k)
          Estop(nl,k+1) = MAX(0., Esnew)
          Eutop(nl,k) = R2(k)*c2+R1(k)*expmAudr(k)*c1+y(k)*Edtop(nl,k)
         ENDDO
C        Aas b.c. in bottom layer
         c2 = Estop(nl,kbot) - x(kbot)*Edtop(nl,kbot)
         Eutop(nl,kbot) = R2(kbot)*c2 + y(kbot)*Edtop(nl,kbot)
C       enddo iter
        ENDDO

c     compute missing fields
C       uses c2 from previous iteration!
        Esbot(nl,kbot) = c2*expAsdr(kbot) + x(kbot)*Edbot(nl,kbot)
        Eubot(nl,kbot) = R2(kbot)*c2*expAsdr(kbot)
     &                  + y(kbot)*Edbot(nl,kbot)

C       Es is continuous now (unless negative...)
        DO k=1,kbot-1
         Esbot(nl,k) = Estop(nl,k+1)
        ENDDO
C      endif thresh
       ENDIF

       DO k = 1,Nr
#ifdef DAR_RADTRANS_RMUS_PAR
        Etopwq = (Edtop(nl,k)+Estop(nl,k)+Eutop(nl,k))*WtouEins(nl)
        Ebotwq = (Edbot(nl,k)+Esbot(nl,k)+Eubot(nl,k))*WtouEins(nl)
C       interpolate and convert to scalar using rmus only!?
        tirrwq(nl,k) = sqrt(Etopwq*Ebotwq)*rmus
#else
C       convert to scalar irradiance in quanta
        Etopwq = (rmud*Edtop(nl,k)+rmus*Estop(nl,k)+rmuu*Eutop(nl,k))
     &           *WtouEins(nl)
        Ebotwq = (rmud*Edbot(nl,k)+rmus*Esbot(nl,k)+rmuu*Eubot(nl,k))
     &           *WtouEins(nl)
C       and interpolate
        tirrwq(nl,k) = sqrt(Etopwq*Ebotwq)
#endif
       ENDDO

C     enddo nl
      ENDDO

      DO k = 1,Nr
C  sum PAR range
       tirrq(k) = 0.0
       DO nl = darwin_PAR_ilamLo,darwin_PAR_ilamHi
        tirrq(k) = tirrq(k) + tirrwq(nl,k)
       ENDDO
      ENDDO
c
#endif /* DAR_RADTRANS */

      return
      end

