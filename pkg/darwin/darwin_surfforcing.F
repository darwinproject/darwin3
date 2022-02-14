#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_SURFFORCING

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_SURFFORCING(
     O           gDIC, gALK, gO2,
     I           dTsub,
     I           bi,bj,imin,imax,jmin,jmax,
     I           myTime,myIter,myThid)

C !DESCRIPTION:
C Update tendency terms for alkalinity, oxygen and DIC from air-sea
C exchanges

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "DYNVARS.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "FFIELDS.h"
#ifdef ALLOW_PTRACERS
#include "PTRACERS_SIZE.h"
#include "PTRACERS_FIELDS.h"
#endif
#ifdef ALLOW_DARWIN
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_EXF_FIELDS.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"
#include "DARWIN_FIELDS.h"
#include "DARWIN_FLUX.h"
#endif

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
C  myIter               :: current timestep
C  myTime               :: current time
C  bi,bj                :: tile indices
      _RL dTsub(Nr)
      INTEGER iMin,iMax,jMin,jMax,bi,bj
      INTEGER myIter, myThid
      _RL myTime

C !OUTPUT PARAMETERS: ==================================================
C  gDIC :: DIC tendency due to air-sea exchange
C  gALK :: ALK tendency due to air-sea exchange
C  gO2  :: O2 tendency due to air-sea exchange
      _RL  gDIC(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  gALK(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  gO2(1-OLx:sNx+OLx,1-OLy:sNy+OLy)

#ifdef ALLOW_DARWIN
#ifdef DARWIN_ALLOW_CARBON

C !LOCAL VARIABLES: ====================================================
      INTEGER i,j,k,ks
      LOGICAL debugPrt
      _RL co3dummy
C Number of iterations for pCO2 solvers...
C Solubility relation coefficients
      _RL SchmidtNoDIC(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL apCO2sat(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL Kwexch(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL Kwexch0(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL pisvel0(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
C local variables for carbon chem
      _RL surfdic
      _RL surfalk
      _RL surfphos
      _RL surfsi
      _RL surftemp(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL surfsalt(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL SchmidtNoO2(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL O2sat(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL fugCO2(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL aTT
      _RL aTK
      _RL aTS
      _RL aTS2
      _RL aTS3
      _RL aTS4
      _RL aTS5
      _RL o2s
      _RL ttemp
      _RL stemp
      _RL oCnew
CEOP

      ks = 1

      DO j=jmin,jmax
       DO i=imin,imax
         gDIC(i,j) = 0.0 _d 0
         gALK(i,j) = 0.0 _d 0
         gO2(i,j) = 0.0 _d 0
       ENDDO
      ENDDO

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
C Compute AtmosP and Kwexch0 which are used for flux of CO2 and O2
      DO j=jmin,jmax
       DO i=imin,imax
        IF (maskC(i,j,ks,bi,bj).NE.0. _d 0) THEN

#ifdef USE_PLOAD
C Convert anomalous pressure pLoad (in Pa) from atmospheric model
C to total pressure (in Atm)
C Note: it is assumed the reference atmospheric pressure is 1Atm=1013mb
C       rather than the actual ref. pressure from Atm. model so that on
C       average AtmosP is about 1 Atm.
         AtmosP(i,j,bi,bj)= 1. _d 0 + pLoad(i,j,bi,bj)/Pa2Atm
#endif

C Pre-compute part of exchange coefficient: pisvel*(1-fice)
C Schmidt number is accounted for later
         pisvel0(i,j) = 0.337 _d 0 * windSpeed(i,j,bi,bj)**2/3.6 _d 5
         Kwexch0(i,j) = pisvel0(i,j) *
     &                   (1. _d 0 - iceFrac(i,j,bi,bj))

        ENDIF
       ENDDO
      ENDDO

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c flux of alkalinity

#ifdef ALLOW_OLD_VIRTUALFLUX
      DO j=jmin,jmax
       DO i=imin,imax
        IF (maskC(i,j,ks,bi,bj).NE.0. _d 0) THEN
c calculate virtual flux
c EminusPforV = dS/dt*(1/Sglob)
C NOTE: Be very careful with signs here!
C Positive EminusPforV => loss of water to atmos and increase
C in salinity. Thus, also increase in other surface tracers
C (i.e. positive virtual flux into surface layer)
         VFluxAlk(i,j,bi,bj) = gsm_ALK*surfaceForcingS(i,j,bi,bj)/gsm_S
         gALK(i,j) =
     &     recip_drF(ks)*recip_hFacC(i,j,ks,bi,bj)*VFluxAlk(i,j,bi,bj)
         alkVirFlx(i,j,bi,bj) = alkVirFlx(i,j,bi,bj)
     &                        + VFluxAlk(i,j,bi,bj)*dTsub(ks)
        ELSE
         VFluxAlk(i,j,bi,bj) = 0 _d 0
        ENDIF
       ENDDO
      ENDDO
#endif /* ALLOW_OLD_VIRTUALFLUX */

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c flux of O2

C calculate SCHMIDT NO. for O2
      DO j=jmin,jmax
       DO i=imin,imax
        IF (maskC(i,j,ks,bi,bj).NE.0.) THEN
         ttemp = theta(i,j,ks,bi,bj)
         stemp = salt(i,j,ks,bi,bj)

         SchmidtNoO2(i,j) =
     &       sox1
     &     + sox2 * ttemp
     &     + sox3 * ttemp*ttemp
     &     + sox4 * ttemp*ttemp*ttemp

C Determine surface flux of O2
C exchange coeff accounting for ice cover and Schmidt no.
C Kwexch0= pisvel*(1-fice): previously computed in dic_surfforcing.F

         Kwexch(i,j) = Kwexch0(i,j)
     &                / sqrt(SchmidtNoO2(i,j)/660.0 _d 0)

C determine saturation O2
C using Garcia and Gordon (1992), L&O (mistake in original ?)
         aTT  = 298.15 _d 0 -ttemp
         aTK  = 273.15 _d 0 +ttemp
         aTS  = log(aTT/aTK)
         aTS2 = aTS*aTS
         aTS3 = aTS2*aTS
         aTS4 = aTS3*aTS
         aTS5 = aTS4*aTS

         oCnew = oA0 + oA1*aTS + oA2*aTS2 + oA3*aTS3 +
     &           oA4*aTS4 + oA5*aTS5 +
     &           (oB0 + oB1*aTS + oB2*aTS2 + oB3*aTS3)*stemp +
     &           oC0*stemp*stemp

         o2s = EXP(oCnew)

c molar volume of O2: O2mol2L = 22.391 L mol-1 = 0.022391 L mmol-1
c o2s in ml/l = l/m3
c O2sat = o2s / O2mmol2L  (in mmol/m3)
c Convert from ml/l to mmol/m^3
         O2sat(i,j) = o2s/22.3916 _d -3

C Determine flux, inc. correction for local atmos surface pressure
         FluxO2(i,j,bi,bj) = Kwexch(i,j)*
     &                     (AtmosP(i,j,bi,bj)*O2sat(i,j)
     &                      - pTracer(i,j,ks,bi,bj,iO2))
#ifdef DARWIN_ALLOW_CONS
         oxySfcFlx(i,j,bi,bj) = oxySfcFlx(i,j,bi,bj)
     &                        + FluxO2(i,j,bi,bj)*dTsub(ks)
#endif

         gO2(i,j) =
     &      recip_drF(ks)*recip_hFacC(i,j,ks,bi,bj)*FluxO2(i,j,bi,bj)
        ENDIF
       ENDDO
      ENDDO

C ======================================================================
      DO k=1,Nr
C ======================================================================

C determine inorganic carbon chem coefficients
      DO j=jmin,jmax
       DO i=imin,imax
c put bounds on tracers so pH solver doesn't blow up
        surfsalt(i,j) = MAX(surfSaltMin,
     &                  MIN(surfSaltMax, salt(i,j,k,bi,bj)))
        surftemp(i,j) = MAX(surfTempMin,
     &                  MIN(surfTempMax, theta(i,j,k,bi,bj)))
       ENDDO
      ENDDO

#ifdef DARWIN_SOLVESAPHE
#ifdef ALLOW_DEBUG
      IF (debugMode) CALL DEBUG_CALL(
     &   'DARWIN_COEFFS_DEEP',myThid)
#endif
C Calculate carbon coefficients
      CALL DARWIN_COEFFS_SURF(
     I                       surftemp, surfsalt,
     I                       bi,bj,iMin,iMax,jMin,jMax,myThid)

C Now correct the coefficients for pressure dependence
      CALL DARWIN_COEFFS_DEEP(
     I                       surftemp, surfsalt,
     I                       bi,bj,iMin,iMax,jMin,jMax,
     I                       k,myThid)
#else
#ifdef ALLOW_DEBUG
      IF (debugMode) CALL DEBUG_CALL(
     &   'DARWIN_CARBON_COEFFS',myThid)
#endif
      CALL DARWIN_CARBON_COEFFS(
     I                   surftemp,surfsalt,
     I                   bi,bj,iMin,iMax,jMin,jMax,k,myThid)
#endif /* DARWIN_SOLVESAPHE */

C====================================================================
       debugPrt = debugMode
c pCO2 solver...
      DO j=jmin,jmax
       DO i=imin,imax
        IF ( maskC(i,j,k,bi,bj).NE.0. _d 0 ) THEN

c put bounds on tracers so pH solver doesn't blow up
         surfdic  = ptr2mol * MAX(surfDICMin,
     &              MIN(surfDICMax, Ptracer(i,j,k,bi,bj,iDIC)))
     &              * maskC(i,j,k,bi,bj)
         surfalk  = ptr2mol * MAX(surfALKMin,
     &              MIN(surfALKMax, Ptracer(i,j,k,bi,bj,iALK)))
     &              * maskC(i,j,k,bi,bj)
         surfphos = ptr2mol * MAX(surfPO4Min,
     &              MIN(surfPO4Max, Ptracer(i,j,k,bi,bj,iPO4)))
     &              * maskC(i,j,k,bi,bj)
         surfsi   = ptr2mol * MAX(surfSiMinINit,
     &              MIN(surfSiMax, Ptracer(i,j,k,bi,bj,iSiO2)))
     &              * maskC(i,j,k,bi,bj)

#ifdef DARWIN_SOLVESAPHE
         IF ( selectPHsolver.GT.0 ) THEN
C Use Munhoven (2013) Solvesaphe routine to calculate pH and pCO2
#ifdef ALLOW_DEBUG
            IF (debugPrt) CALL DEBUG_CALL('CALC_PCO2_SOLVESAPHE',myThid)
#endif
            CALL CALC_PCO2_SOLVESAPHE(
     I          surftemp(i,j), surfsalt(i,j),
     I          surfdic, surfphos, surfsi, surfalk,
     U          pH(i,j,k,bi,bj), pCO2(i,j,k,bi,bj), co3dummy,
     I          i,j,k,bi,bj, debugPrt,myIter,myThid )
            debugPrt = .FALSE.
         ELSE
C Use the original Follows et al. (2006) solver
#endif /* DARWIN_SOLVESAPHE */
#ifdef ALLOW_DEBUG
            IF (debugPrt) CALL DEBUG_CALL('CALC_PCO2_APPROX',myThid)
            debugPrt = .FALSE.
#endif
            CALL DARWIN_CALC_PCO2_APPROX(
     I        surftemp(i,j), surfsalt(i,j),
     I        surfdic, surfphos, surfsi, surfalk,
     I        ak1(i,j,bi,bj), ak2(i,j,bi,bj),
     I        ak1p(i,j,bi,bj), ak2p(i,j,bi,bj), ak3p(i,j,bi,bj),
     I        aks(i,j,bi,bj), akb(i,j,bi,bj), akw(i,j,bi,bj),
     I        aksi(i,j,bi,bj), akf(i,j,bi,bj),
     I        ak0(i,j,bi,bj),  fugf(i,j,bi,bj),
     I        ff(i,j,bi,bj),
     I        bt(i,j,bi,bj), st(i,j,bi,bj), ft(i,j,bi,bj),
     U        pH(i,j,k,bi,bj), pCO2(i,j,k,bi,bj), co3dummy,
     I        i,j,k,bi,bj,myIter,myThid )
#ifdef DARWIN_SOLVESAPHE
         ENDIF
#endif /* DARWIN_SOLVESAPHE */

        ELSE
         pCO2(i,j,k,bi,bj)=0. _d 0
        ENDIF
       ENDDO
      ENDDO

      IF (k .EQ. ks) THEN

      DO j=jmin,jmax
       DO i=imin,imax
        IF ( maskC(i,j,ks,bi,bj).NE.0. _d 0 ) THEN
         ttemp = theta(i,j,ks,bi,bj)
C calculate SCHMIDT NO. for CO2
         SchmidtNoDIC(i,j) =
     &      sca1 +
     &      sca2*ttemp +
     &      sca3*ttemp*ttemp +
     &      sca4*ttemp*ttemp*ttemp
c make sure Schmidt number is not negative (will happen if temp>39C)
         SchmidtNoDIC(i,j) = MAX(1.0 _d -2, SchmidtNoDIC(i,j))

C Determine surface flux (FDIC)
C first correct apCO2 for surface atmos pressure
         apCO2sat(i,j) = AtmosP(i,j,bi,bj)*atmospCO2(i,j,bi,bj)

C then account for Schmidt number
         Kwexch(i,j) = Kwexch0(i,j)
     &                 / sqrt(SchmidtNoDIC(i,j)/660.0 _d 0)

C compute fugacity of CO2
         fugCO2(i,j) = pCO2(i,j,ks,bi,bj)*fugf(i,j,bi,bj)

c Flux = kw*rho*(ff*pCO2atm-k0*FugFac*pCO2ocean)
         FluxCO2(i,j,bi,bj) = Kwexch(i,j)*(
     &    ff(i,j,bi,bj)*apCO2sat(i,j) - fugCO2(i,j)*ak0(i,j,bi,bj)
     &   )
        ELSE
         FluxCO2(i,j,bi,bj) = 0. _d 0
        ENDIF
C convert flux (mol kg-1 m s-1) to (mmol m-2 s-1)
        FluxCO2(i,j,bi,bj) = FluxCO2(i,j,bi,bj)/m3perkg/ptr2mol
#ifdef DARWIN_ALLOW_CONS
        carbSfcFlx(i,j,bi,bj) = carbSfcFlx(i,j,bi,bj)
     &                        + FluxCO2(i,j,bi,bj)*dTsub(ks)
#endif

#ifdef ALLOW_OLD_VIRTUALFLUX
        IF (maskC(i,j,ks,bi,bj).NE.0. _d 0) THEN
c calculate virtual flux
c EminusPforV = dS/dt*(1/Sglob)
C NOTE: Be very careful with signs here!
C Positive EminusPforV => loss of water to atmos and increase
C in salinity. Thus, also increase in other surface tracers
C (i.e. positive virtual flux into surface layer)
C ...so here, VirtualFLux = dC/dt!
         VFluxCO2(i,j,bi,bj)=gsm_DIC*surfaceForcingS(i,j,bi,bj)/gsm_S
         carbVirFlx(i,j,bi,bj) = carbVirFlx(i,j,bi,bj)
     &                         + VFluxCO2(i,j,bi,bj)*dTsub(ks)
c OR
c let virtual flux be zero
c        VirtualFlux(i,j)=0.d0
c
        ELSE
         VFluxCO2(i,j,bi,bj)=0. _d 0
        ENDIF
#endif /* ALLOW_OLD_VIRTUALFLUX */
       ENDDO
      ENDDO

C update tendency
      DO j=jmin,jmax
       DO i=imin,imax
        IF ( maskC(i,j,ks,bi,bj).NE.0. _d 0 ) THEN
         gDIC(i,j) =
     &     recip_drF(ks)*recip_hFacC(i,j,ks,bi,bj)*
     &              ( FluxCO2(i,j,bi,bj)
#ifdef ALLOW_OLD_VIRTUALFLUX
     &              + VFluxCO2(i,j,bi,bj)
#endif
     &              )
        ENDIF
       ENDDO
      ENDDO

#ifdef ALLOW_DIAGNOSTICS
      IF (useDiagnostics) THEN
       CALL DIAGNOSTICS_FILL(atmospCO2,'apCO2   ',0,1,1,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(apCO2sat,'apCO2sat',0,1,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(fugf,    'fugfCO2 ',0,1,1,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(fugCO2,  'fCO2    ',0,1,2,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(FluxO2,  'fluxO2  ',0,1,1,bi,bj,myThid)
#ifdef ALLOW_OLD_VIRTUALFLUX
       CALL DIAGNOSTICS_FILL(VFluxCO2,'VfluxCO2',0,1,1,bi,bj,myThid)
       CALL DIAGNOSTICS_FILL(VFluxAlk,'VfluxAlk',0,1,1,bi,bj,myThid)
#endif
      ENDIF
#endif

C     k is at surface
      ENDIF

C === k ================================================================
      ENDDO
C ======================================================================

#endif /* DARWIN_ALLOW_CARBON */
#endif /* ALLOW_DARWIN */

      RETURN
      END
