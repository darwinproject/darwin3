#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_BENTHIC_EMULATOR
C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_BENTHIC_EMULATOR(
     I     omega_ca_bw, fpoc, fpon, fpop, no3_bw,
     O     J_DIC, J_TA,
     O     J_O2, J_NH4, J_PO4, J_NO3,
     O     J_DIC_carb, J_TA_carb,
     O     J_DIC_rest, J_DIC_rest_raw, J_TA_rest, y_R,
     I     iMin, iMax, jMin, jMax, myThid)

C !DESCRIPTION:
C
C  Standalone benthic emulator for:
C    - DIC / TA
C    - O2 / NH4 / PO4 / NO3
C
C  This version reads all coefficients and logical toggles from:
C      DARWIN_PARAMS.h
C
C  Required inputs:
C    omega_ca_bw : bottom-water Omega_Ca just above seafloor
C    fpoc        : benthic organic carbon flux driver
C    fpon        : benthic organic nitrogen flux driver
C    fpop        : benthic organic phosphorus flux driver
C    no3_bw      : bottom-water NO3 concentration (mmol m^-3)
C
C  Runtime logical switches from DARWIN_PARAMS.h:
C    useBenthicCarbEmul
C    useBenthicNutrEmul
C    disable_carb_below_omega_emul
C
C  Outputs:
C    J_DIC, J_TA       : total benthic DIC / TA fluxes
C    J_O2              : benthic O2 flux
C    J_NH4             : benthic NH4 flux
C    J_PO4             : benthic PO4 flux
C    J_NO3             : benthic NO3 flux
C    J_DIC_carb        : carbonate DIC contribution
C    J_TA_carb         : carbonate TA contribution
C    J_DIC_rest        : residual DIC contribution
C    J_DIC_rest_raw    : uncapped residual DIC contribution
C    J_TA_rest         : residual TA contribution
C    y_R               : residual TA:DIC ratio
C
C  Compile as .F (capital F) so CPP expands _RL, etc.

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "DARWIN_PARAMS.h"

C !INPUT PARAMETERS: ===================================================
      _RL omega_ca_bw(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL fpoc(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL fpon(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL fpop(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL no3_bw(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      INTEGER iMin, iMax, jMin, jMax, myThid

C !OUTPUT PARAMETERS: ==================================================
      _RL J_DIC(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL J_TA(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL J_O2(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL J_NH4(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL J_PO4(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL J_NO3(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL J_DIC_carb(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL J_TA_carb(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL J_DIC_rest(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL J_DIC_rest_raw(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL J_TA_rest(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL y_R(1-OLx:sNx+OLx,1-OLy:sNy+OLy)

#ifdef DARWIN_ALLOW_RADIv2_EMUL

C!LOCAL VARIABLES: ====================================================
      INTEGER i,j
      _RL eps, zclip, z
      _RL fpoc_eff, fpon_eff, fpop_eff, no3_eff, omega_eff
C----- Carbon / TA-DIC locals
      _RL J_bg, J_om_carb, D_om, dm_bg
      _RL C_raw, carb_active_mask
C----- Nutrient / O2 locals
      _RL JO2_mag, qox, fox, fred, A_no3
      _RL J_NO3_rel, J_NO3_upt

C======================================================================
C  Numerical safety
C======================================================================
      eps   = 1. _d -30
      zclip = 60. _d 0

      DO j=jMin,jMax
      DO i=iMin,iMax
C======================================================================
C  Sanitize inputs
C======================================================================
       fpoc_eff  = MAX( fpoc(i,j), eps )
       fpon_eff  = MAX( fpon(i,j), eps )
       fpop_eff  = MAX( fpop(i,j), eps )
       no3_eff   = MAX( no3_bw(i,j), eps )
       omega_eff = MAX( omega_ca_bw(i,j), 0. _d 0 )

C======================================================================
C  1) DIC / TA emulator
C======================================================================
       IF ( useBenthicCarbEmul ) THEN

C----- carbonate branch:
C      J_bg  = a_omega * max(1 - omega,0)^m_omega
C      D_om  = 1 / (1 + exp[s_omega * (omega - omega_c)])
C      J_om  = a_fpoc * fpoc^b_fpoc * D_om
C      C_raw = J_bg + J_om

        dm_bg = MAX( 1. _d 0 - omega_eff, 0. _d 0 )
        J_bg  = a_omega_emul * dm_bg**m_omega_emul

        z = s_omega_emul * ( omega_eff - omega_c_emul )
        z = MAX( -zclip, MIN( zclip, z ) )
        D_om = 1. _d 0 / ( 1. _d 0 + EXP( z ) )

        J_om_carb = a_fpoc_carb_emul * fpoc_eff**b_fpoc_carb_emul
     &            * D_om

        C_raw = J_bg + J_om_carb

C----- optionally disable carbonate below omega cutoff
        IF ( disable_carb_below_omega_emul ) THEN
          IF ( omega_eff .GE. omega_carb_cutoff_emul ) THEN
            carb_active_mask = 1. _d 0
            J_DIC_carb(i,j) = C_raw
          ELSE
            carb_active_mask = 0. _d 0
            J_DIC_carb(i,j) = 0. _d 0
          ENDIF
        ELSE
          carb_active_mask = 1. _d 0
          J_DIC_carb(i,j) = C_raw
        ENDIF

        J_TA_carb(i,j) = 2. _d 0 * J_DIC_carb(i,j)

C----- residual OM/redox branch:
C      S_raw = a_om * fpoc^b_om
C      S     = min(S_raw, fpoc)
C      y_R   = y_max * fpoc / (fpoc + K_F)
C      R_T   = y_R * S

        J_DIC_rest_raw(i,j) = a_om_emul * fpoc_eff**b_om_emul

        J_DIC_rest(i,j) = MIN( J_DIC_rest_raw(i,j), fpoc_eff )

        y_R(i,j) = y_max_emul * fpoc_eff / ( fpoc_eff + K_F_emul + eps )
        J_TA_rest(i,j) = y_R(i,j) * J_DIC_rest(i,j)

C----- totals
        J_DIC(i,j) = J_DIC_carb(i,j) + J_DIC_rest(i,j)
        J_TA(i,j)  = J_TA_carb(i,j)  + J_TA_rest(i,j)

       ELSE

        J_DIC(i,j) = 0. _d 0
        J_TA(i,j)  = 0. _d 0
        J_DIC_carb(i,j) = 0. _d 0
        J_TA_carb(i,j)  = 0. _d 0
        J_DIC_rest(i,j)     = 0. _d 0
        J_DIC_rest_raw(i,j) = 0. _d 0
        J_TA_rest(i,j)      = 0. _d 0
        y_R(i,j)   = 0. _d 0

       ENDIF

C======================================================================
C  2) Nutrient / O2 emulator
C======================================================================
       IF ( useBenthicNutrEmul ) THEN

C----- O2 from FPOC:
C      J_O2 = - a_o2 * fpoc^b_o2
        JO2_mag = a_o2_emul * fpoc_eff**b_o2_emul
        J_O2(i,j) = -JO2_mag

C----- NH4 from FPON:
C      J_NH4 = a_nh4 * fpon^b_nh4
        J_NH4(i,j) = a_nh4_emul * fpon_eff**b_nh4_emul

C----- PO4 from FPOP:
C      J_PO4 = a_po4 * fpop^b_po4
        J_PO4(i,j) = a_po4_emul * fpop_eff**b_po4_emul

C----- oxic proxy from O2(FPOC):
C      qox = |J_O2| / fpoc
C      fox = qox / (qox + K_ox)
        qox = JO2_mag / ( fpoc_eff + eps )
        fox = qox / ( qox + K_ox_emul + eps )
        fox = MAX( 0. _d 0, MIN( 1. _d 0, fox ) )
        fred = 1. _d 0 - fox

C----- NO3 availability from bottom-water NO3:
C      A_no3 = no3_bw / (no3_bw + K_no3)
        A_no3 = no3_eff / ( no3_eff + K_no3_emul + eps )
        A_no3 = MAX( 0. _d 0, MIN( 1. _d 0, A_no3 ) )

C----- NO3 two-part emulator from FPON:
C      J_rel = a_rel * fpon^b_rel * fox^m_rel
C      J_upt = a_upt * fpon^b_upt * fred^m_upt * A_no3
C      J_NO3 = J_rel - J_upt
        J_NO3_rel = a_rel_emul * fpon_eff**b_rel_emul
     &           * fox**m_rel_emul

        J_NO3_upt = a_upt_emul * fpon_eff**b_upt_emul
     &           * fred**m_upt_emul * A_no3

        J_NO3(i,j) = J_NO3_rel - J_NO3_upt

       ELSE

        J_O2(i,j)  = 0. _d 0
        J_NH4(i,j) = 0. _d 0
        J_PO4(i,j) = 0. _d 0
        J_NO3(i,j) = 0. _d 0

       ENDIF
      ENDDO
      ENDDO

#endif

      RETURN
      END
