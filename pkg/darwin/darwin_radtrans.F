C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_radtrans.F,v 1.2 2010/07/08 20:49:08 jahn Exp $
C $Name:  $

#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_RADTRANS

C !INTERFACE: ==========================================================
      subroutine darwin_radtrans(
     I                   H,rmud,Ed,Es,a_k,bt_k,bb_k,
     O                   Edz,Esz,Euz,Eutop,
     O                   tirrq,tirrwq,
     I                   myThid)

C !DESCRIPTION:
c MODIFIED VERSION OF WG's edeu.F
c
c
c  Model of irradiance in the water column.  Accounts for three 
c  irradiance streams:
c
c  Edz = direct downwelling irradiance in W/m2 per waveband
c  Esz = diffuse downwelling irradiance in W/m2 per waveband
c  Euz = diffuse upwelling irradiance in W/m2 per waveband
c
c  Propagation is done in energy units, tests are done in quanta,
c  final is quanta for phytoplankton growth.
c
C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"             /* Nr */
C#include "EEPARAMS.h"
#include "DARWIN_SIZE.h"      /* tlam */
#include "DARWIN.h"           /* WtouEin */
#include "WAVEBANDS_PARAMS.h" /* darwin_PAR_ilamLo/Hi 
                                 darwin_radmodThresh
                                 darwin_Dmax darwin_rmus darwin_rmuu */

C !INPUT PARAMETERS: ===================================================
C     H      :: layer thickness (should include hFacC!)
C     rmud   :: inv.cosine of direct (underwater solar) zenith angle
C     Ed     :: direct downwelling irradiance below surface per waveband
C     Es     :: diffuse downwelling irradiance below surface per waveband
C     a_k    :: absorption coefficient per level and waveband (1/m)
C     bt_k   :: total scattering coefficient per level and waveband (1/m)
C               = forward + back scattering coefficient
C     bb_k   :: backscattering coefficient per level and waveband (1/m)
      _RL H(Nr)
      _RL rmud
      _RL Ed(tlam), Es(tlam)
      _RL a_k(Nr,tlam), bt_k(Nr,tlam), bb_k(Nr,tlam)
      INTEGER myThid

C !OUTPUT PARAMETERS: ==================================================
C     Edz    :: direct downwelling irradiance at bottom of layer
C     Esz    :: diffuse downwelling irradiance at bottom of layer
C     Euz    :: diffuse upwelling irradiance at bottom of layer
C     tirrq  :: total scalar irradiance at cell center (uEin/m2/s)
C     tirrwq :: total scalar irradiance at cell center per waveband
      _RL Edz(tlam,Nr),Esz(tlam,Nr),Euz(tlam,Nr),Eutop(tlam,Nr)
      _RL tirrq(Nr)
      _RL tirrwq(tlam,Nr)

#ifdef DAR_RADTRANS

C !LOCAL VARIABLES: ====================================================
      INTEGER k, np, nl
C     _RL Etop, Ebot
      _RL Etopq,Ebotq
      _RL Etopwq(tlam), Ebotwq(tlam)
      _RL zd,zirrq
C     _RL zirr
C      _RL Etopql,Ebotql,Emidql
      _RL Emidq,Emidwq
      _RL Edtop(tlam),Estop(tlam) 
CEOP

C     Ebot = 0.0
      do nl = 1,tlam
C initialize state variables
        Edtop(nl) = Ed(nl)
        Estop(nl) = Es(nl)
C       Ebot = Ebot + (Ed(nl)+Es(nl))
      enddo
c  Convert to quanta: divide by Avos # to get moles quanta; then mult by
c  1E6 to get uM or uEin
      do nl = 1,tlam
C  don't include upwelling at surface
        Ebotwq(nl) = (Edtop(nl)+Estop(nl))*WtouEins(nl)
      enddo
C  sum PAR range
      Ebotq = 0.0
      do nl = darwin_PAR_ilamLo,darwin_PAR_ilamHi
        Ebotq = Ebotq + Ebotwq(nl)
      enddo
      do k = 1,Nr
C       Etop = Ebot
        Etopq = Ebotq
        zd = min(darwin_Dmax,H(k))
C       zirr = 0.0
        do nl = 1,tlam
          Edz(nl,k) = 0.0
          Esz(nl,k) = 0.0
          Euz(nl,k) = 0.0
          Eutop(nl,k) = 0.0
          if (Edtop(nl) .ge. darwin_radmodThresh .or.
     &        Estop(nl) .ge. darwin_radmodThresh) then
c           print*,'pre',zd,Edtop(nl),Estop(nl),
c    &                    rmud,rmus,rmuu,a,bt,bb,Dmax
#ifdef DAR_RADTRANS_DECREASING
C      truncation to decreasing modes a la Aas
            call radtrans_radmod_decr(
     I              zd,Edtop(nl),Estop(nl),
     I              rmud,darwin_rmus,darwin_rmuu,
     I              a_k(k,nl),bt_k(k,nl),bb_k(k,nl),darwin_Dmax,
     O              Edz(nl,k),Esz(nl,k),Euz(nl,k),Eutop(nl,k))
#else
C      Watson Gregg's original
            call radtrans_radmod(
     I              zd,Edtop(nl),Estop(nl),
     I              rmud,darwin_rmus,darwin_rmuu,
     I              a_k(k,nl),bt_k(k,nl),bb_k(k,nl),darwin_Dmax,
     O              Edz(nl,k),Esz(nl,k),Euz(nl,k),Eutop(nl,k))
#endif
c           print*,'radmod',Edz(nl,k),Esz(nl,k),Euz(nl,k)
          endif
C  cycle
          Edtop(nl) = Edz(nl,k)
          Estop(nl) = Esz(nl,k)
C         zirr = zirr + (Edz(nl,k)+Esz(nl,k)+Euz(nl,k))
C-      enddo nl
        enddo
C       Ebot = zirr
c ANNA  SPEC retrieve and pass spectral irrq
        do nl = 1,tlam
          Etopwq(nl) = Ebotwq(nl)
C add vertical components, ...
          Ebotwq(nl)=(Edz(nl,k)+Esz(nl,k)+Euz(nl,k))*WtouEins(nl)
C ... interpolate ...
          Emidwq = sqrt(Etopwq(nl)*Ebotwq(nl))
C ... and convert using rmus !?
          tirrwq(nl,k) = Emidwq*darwin_rmus
        enddo
C  sum PAR range
        zirrq = 0.0
        do nl = darwin_PAR_ilamLo,darwin_PAR_ilamHi
         zirrq = zirrq + Ebotwq(nl)
        enddo
        Ebotq = zirrq
C interpolate nonspectral PAR separately !?
        Emidq = sqrt(Etopq*Ebotq)
        tirrq(k) = Emidq*darwin_rmus    !scalar irradiance
C-    enddo k
      enddo
c
#endif /* DAR_RADTRANS */

      return
      end

