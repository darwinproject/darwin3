C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/radtrans/radtrans_radmod.F,v 1.1 2010/06/09 15:59:37 jahn Exp $
C $Name:  $

#include "RADTRANS_OPTIONS.h"

CBOP
C     !ROUTINE: RADTRANS_RADMOD

C     !INTERFACE: ======================================================
      subroutine radtrans_radmod(zd,Edtop,Estop,
     I                           rmud,rmus,rmuu,a,bt,bb,Dmax,
     O                           Edz,Esz,Euz,Eutop)

C     !DESCRIPTION:

C     !USES: ===========================================================
      IMPLICIT NONE

c SLIGHTLY MODIFIED WG CODE PREVIOUSLY CALLED aasack.f
c
c  Model of irradiance in the water column.  Accounts for three 
c  irradiance streams:
c
c  Edz = direct downwelling irradiance
c  Esz = diffuse downwelling irradiance
c  Euz = diffuse upwelling irradiance
c
c  Uses Ackelson's (1994, JGR) mod's to the Aas (1987, AO) 
c  two-stream model.
c
c  Propagation is done in energy units, tests are done in quanta,
c  final is quanta for phytoplankton growth.
c
c  Commented out terms produce a max error of 
c  0.8% in Esz for a > 0.004 and bb > 0.0001 and
c  3.9% in Euz for a > 0.004 and bb > 0.00063
c
C     !INPUT PARAMETERS: ===============================================
C     Edtop        :: direct downward irradiance at top (incl.cos)
C     Estop        :: diffuse downward irradiance at top (incl.cos)
C     a            :: attenuation coefficient
C     bt           :: total scattering coefficient
C     bb           :: backward scattering coefficient (bt = bf + bb)
C     Dmax         :: depth at which Eu = 0 (not used!)
      _RL zd
      _RL Edtop,Estop
      _RL rmud
      _RL rmus,rmuu
      _RL a,bt,bb
      _RL Dmax
c     INTEGER myThid

C     !OUTPUT PARAMETERS: ==============================================
c     Edz          :: direct downwelling irradiance (incl.cos)
c     Esz          :: diffuse downwelling irradiance (incl.cos)
c     Euz          :: diffuse upwelling irradiance (incl.cos)
      _RL Esz,Euz,Edz,Eutop

C     !LOCAL VARIABLES: ================================================
      _RL cd,au,Bu,Cu
      _RL as,Bs,Cs,Bd,Fd
      _RL bquad,cquad,sqarg
      _RL a1,a2,S,SEdz,a2ma1
      _RL rM,rN
      _RL c2,Ta2z,Eutmp
c note - have left WG's assignment of these params so as to keep 
c his code as similar as possible to what he provided, 
c but could assign elsewhere...

      _RL rbot, rd, ru
      data rbot /0.0/ !bottom reflectance
      data rd /1.5/   !these are taken from Ackleson, et al. 1994 (JGR)
      data ru /3.0/
c
c  Downwelling irradiance: Edz, Esz
c  Compute irradiance components at depth
c     direct part
      cd = (a+bt)*rmud
      Edz = Edtop*exp(-cd*zd)
c
      au = a*rmuu
      Bu = ru*bb*rmuu
      Cu = au+Bu
      as = a*rmus
      Bs = rd*bb*rmus
      Cs = as+Bs
      Bd = bb*rmud
      Fd = (bt-bb)*rmud
      bquad = Cs - Cu
      cquad = Bs*Bu - Cs*Cu
      sqarg = bquad*bquad - 4.0*cquad
      a1 = 0.5*(-bquad + sqrt(sqarg))  ! K of Aas
      a2 = 0.5*(-bquad - sqrt(sqarg))
      S = -(Bu*Bd + Cu*Fd)
      SEdz = S*Edz
      a2ma1 = a2 - a1
      rM = SEdz/(a1*a2ma1)
      rN = SEdz/(a2*a2ma1)
c      ea2Dmax = exp(a2ma1*Dmax)
c      c1 = (rN-rM)*exp(-a1*Dmax) - (Estop-rM+rN)*ea2Dmax
c     *                             /(1.0-ea2Dmax)
c      c2 = Estop - rM + rN - c1
      c2 = Estop - rM + rN 
c      a1arg = a1*zd
c      a1arg = min(a1arg,82.8)
c      Ta1z = exp(a1arg)
      Ta2z = exp(a2*zd)
c      Esz = c1*Ta1z + c2*Ta2z + rM - rN
      Esz = c2*Ta2z + rM - rN
      Esz = max(Esz,0.0)
c      Eutmp = ((a1+Cs)*c1)*Ta1z + ((a2+Cs)*c2)*Ta2z + Cs*rM
c     *             - Cs*rN - Fd*Edz
      Eutmp = ((a2+Cs)*c2)*Ta2z + Cs*rM
     *             - Cs*rN - Fd*Edz
      Euz = Eutmp/Bu
      Euz = max(Euz,0.0)
c
c Eu at top of layer
      rM = S*Edtop/(a1*a2ma1)
      rN = S*Edtop/(a2*a2ma1)
      Eutmp = (a2+Cs)*c2 + Cs*rM - Cs*rN - Fd*Edtop
      Eutop = Eutmp/Bu
      Eutop = max(Eutop,0.0)
c
      return
      end
