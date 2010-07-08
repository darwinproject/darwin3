C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/radtrans/radtrans_radmod_decr.F,v 1.1 2010/07/08 20:49:08 jahn Exp $
C $Name:  $

#include "RADTRANS_OPTIONS.h"

CBOP
C     !ROUTINE: RADTRANS_RADMOD_DECR

C     !INTERFACE: ======================================================
      subroutine radtrans_radmod_decr(zd,Edtop,Estop,
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
c  In the spirit of Aas, the solution in each layer is truncated to the
c  2 downward decreasing modes.  Ed and Es are matched between layers,
c  Eu is discontinuous.
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
c     Eutop        :: diffuse upwelling irradiance at top of layer
      _RL Esz,Euz,Edz,Eutop

C     !LOCAL VARIABLES: ================================================
      _RL cd,au,Bu,Cu
      _RL as,Bs,Cs,Bd,Fd
      _RL bquad,cquad,sqarg
      _RL a2,denom,x,y
      _RL c2,Ta2z
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
c      a1 = 0.5*(-bquad + sqrt(sqarg))
      a2 = 0.5*(-bquad - sqrt(sqarg))  ! K of Aas
      denom = (cd-Cs)*(cd+Cu) + Bs*Bu
      x = -((cd+Cu)*Fd+Bu*Bd)/denom
      y = (-Bs*Fd+(cd-Cs)*Bd)/denom
      c2 = Estop - x*Edtop 
      Ta2z = exp(a2*zd)
      Esz = c2*Ta2z + x*Edz
      Esz = max(Esz,0.0)
      Euz = ((a2+Cs)*c2)*Ta2z/Bu + y*Edz
      Euz = max(Euz,0.0)
c
c Eu at top of layer
      Eutop = (a2+Cs)*c2/Bu + y*Edtop
      Eutop = max(Eutop,0.0)
c
      return
      end
