#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "DARWIN_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

#ifdef ALLOW_CARBON

CBOP
C !ROUTINE: DIC_SURFFORCING

C !INTERFACE: ==========================================================
      SUBROUTINE DIC_SURFFORCING( PTR_DIC , PTR_ALK, PTR_PO4, PTR_SIL,
     O           GDC, 
     I           bi,bj,imin,imax,jmin,jmax,
     I           myIter,myTime,myThid)

C !DESCRIPTION:
C  Calculate the carbon air-sea flux terms              
C  following external_forcing_dic.F (OCMIP run) from Mick            

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "DYNVARS.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "FFIELDS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_IO.h"
#include "DARWIN_FLUX.h"
#ifdef USE_EXFWIND
#include "EXF_FIELDS.h"
#endif

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
C  myIter               :: current timestep
C  myTime               :: current time
c  PTR_DIC              :: DIC tracer field
      INTEGER myIter, myThid
      _RL myTime
      _RL  PTR_DIC(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  PTR_ALK(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  PTR_PO4(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL  PTR_SIL(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      INTEGER iMin,iMax,jMin,jMax, bi, bj

C !OUTPUT PARAMETERS: ===================================================
c GDC                   :: tendency due to air-sea exchange
      _RL  GDC(1-OLx:sNx+OLx,1-OLy:sNy+OLy)


C !LOCAL VARIABLES: ====================================================
       INTEGER I,J, kLev, it
C Number of iterations for pCO2 solvers...
C Solubility relation coefficients
      _RL SchmidtNoDIC(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL pCO2sat(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL Kwexch(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL pisvel(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
C local variables for carbon chem
      _RL surfdic(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL surfalk(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL surfphos(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL surfsi(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL surfsalt(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL surftemp(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
#ifdef ALLOW_OLD_VIRTUALFLUX
      _RL VirtualFlux(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
#endif
CEOP

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      kLev=1

cc if coupled to atmsopheric model, use the
cc Co2 value passed from the coupler
c#ifndef USE_ATMOSCO2
cC PRE-INDUSTRIAL STEADY STATE pCO2 = 278.0 ppmv
c       DO j=1-OLy,sNy+OLy
c        DO i=1-OLx,sNx+OLx
c           AtmospCO2(i,j,bi,bj)=278.0 _d -6
c        ENDDO
c       ENDDO
c#endif
C =================================================================
C determine inorganic carbon chem coefficients
        DO j=jmin,jmax
         DO i=imin,imax
c put bounds on tracers so pH solver doesn't blow up
             surfdic(i,j) = 
     &           max(400. _d 0 , min(4000. _d 0, PTR_DIC(i,j)))*1e-3
     &                          * maskC(i,j,kLev,bi,bj)
             surfalk(i,j) = 
     &           max(400. _d 0 , min(4000. _d 0, PTR_ALK(i,j)))*1e-3
     &                          * maskC(i,j,kLev,bi,bj)
             surfphos(i,j)  = 
     &           max(1. _d -10, min(10. _d 0, PTR_PO4(i,j)))*1e-3
     &                          * maskC(i,j,kLev,bi,bj)
             surfsi(i,j)   = 
     &           max(1. _d -8, min(500. _d 0, PTR_SIL(i,j)))*1e-3
     &                          * maskC(i,j,kLev,bi,bj)
             surfsalt(i,j) = 
     &           max(4. _d 0, min(50. _d 0, salt(i,j,kLev,bi,bj)))
             surftemp(i,j) =
     &            max(-4. _d 0, min(39. _d 0, theta(i,j,kLev,bi,bj)))
         ENDDO
        ENDDO

         CALL CARBON_COEFFS(
     I                       surftemp,surfsalt,
     I                       bi,bj,iMin,iMax,jMin,jMax,myThid)
C====================================================================

       DO j=jmin,jmax
        DO i=imin,imax
C Compute AtmosP and Kwexch_Pre which are re-used for flux of O2

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
#ifdef USE_EXFWIND
              pisvel(i,j)=0.337 _d 0 *wspeed(i,j,bi,bj)**2/3.6 _d 5
#else
              pisvel(i,j)=0.337 _d 0 *wind(i,j,bi,bj)**2/3.6 _d 5
#endif
              Kwexch_Pre(i,j,bi,bj) = pisvel(i,j)
     &                              * (1. _d 0 - FIce(i,j,bi,bj))

        ENDDO
       ENDDO

c pCO2 solver...
C$TAF LOOP = parallel
       DO j=jmin,jmax
C$TAF LOOP = parallel
        DO i=imin,imax

          IF ( maskC(i,j,kLev,bi,bj).NE.0. _d 0 ) THEN
            CALL CALC_PCO2_APPROX(
     I        surftemp(i,j),surfsalt(i,j),
     I        surfdic(i,j), surfphos(i,j),
     I        surfsi(i,j),surfalk(i,j),
     I        ak1(i,j,bi,bj),ak2(i,j,bi,bj),
     I        ak1p(i,j,bi,bj),ak2p(i,j,bi,bj),ak3p(i,j,bi,bj),
     I        aks(i,j,bi,bj),akb(i,j,bi,bj),akw(i,j,bi,bj),
     I        aksi(i,j,bi,bj),akf(i,j,bi,bj),
     I        ak0(i,j,bi,bj), fugf(i,j,bi,bj),
     I        ff(i,j,bi,bj),
     I        bt(i,j,bi,bj),st(i,j,bi,bj),ft(i,j,bi,bj),
     U        pH(i,j,bi,bj),pCO2(i,j,bi,bj),
     I        myThid )
          ELSE
            pCO2(i,j,bi,bj)=0. _d 0
          ENDIF
        ENDDO
       ENDDO


       DO j=jmin,jmax
        DO i=imin,imax

          IF ( maskC(i,j,kLev,bi,bj).NE.0. _d 0 ) THEN
C calculate SCHMIDT NO. for CO2
              SchmidtNoDIC(i,j) = 
     &            sca1 
     &          + sca2 * surftemp(i,j)
     &          + sca3 * surftemp(i,j)*surftemp(i,j)
     &          + sca4 * surftemp(i,j)*surftemp(i,j)
     &                *surftemp(i,j)
c put positive bound on SCHMIT number (will go negative for temp>40)
              SchmidtNoDIC(i,j) = max(1. _d -2, SchmidtNoDIC(i,j))

C Determine surface flux (FDIC)
C first correct pCO2at for surface atmos pressure
              pCO2sat(i,j) = 
     &          AtmosP(i,j,bi,bj)*AtmospCO2(i,j,bi,bj)

C then account for Schmidt number
                Kwexch(i,j) = Kwexch_Pre(i,j,bi,bj)
     &                    / sqrt(SchmidtNoDIC(i,j)/660.0 _d 0)

#ifdef WATERVAP_BUG
C Calculate flux in terms of DIC units using K0, solubility
C Flux = Vp * ([CO2sat] - [CO2])
C CO2sat = K0*pCO2atmos*P/P0
C Converting pCO2 to [CO2] using ff, as in CALC_PCO2
              FluxCO2(i,j,bi,bj) = 
     &         Kwexch(i,j)*( 
     &         ak0(i,j,bi,bj)*pCO2sat(i,j) - 
     &         ff(i,j,bi,bj)*pCO2(i,j,bi,bj) 
     &         ) 
#else
C Corrected by Val Bennington Nov 2010 per G.A. McKinley's finding
C of error in application of water vapor correction
c Flux = kw*rho*(ff*pCO2atm-k0*FugFac*pCO2ocean)
               FluxCO2(i,j,bi,bj) =
     &          Kwexch(i,j)*(
     &            ff(i,j,bi,bj)*pCO2sat(i,j) -
     &            pCO2(i,j,bi,bj)*fugf(i,j,bi,bj)
     &            *ak0(i,j,bi,bj) )
     &
#endif
          ELSE
              FluxCO2(i,j,bi,bj) = 0. _d 0
          ENDIF
C convert flux (mol kg-1 m s-1) to (mol m-2 s-1)
            FluxCO2(i,j,bi,bj) = FluxCO2(i,j,bi,bj)/permil
c convert flux (mol m-2 s-1) to (mmol m-2 s-1)
            FluxCO2(i,j,bi,bj) = FluxCO2(i,j,bi,bj)*1. _d 3


#ifdef ALLOW_OLD_VIRTUALFLUX
            IF (maskC(i,j,kLev,bi,bj).NE.0. _d 0) THEN
c calculate virtual flux
c EminusPforV = dS/dt*(1/Sglob)
C NOTE: Be very careful with signs here!
C Positive EminusPforV => loss of water to atmos and increase
C in salinity. Thus, also increase in other surface tracers
C (i.e. positive virtual flux into surface layer)
C ...so here, VirtualFLux = dC/dt!
              VirtualFlux(i,j)=gsm_DIC*surfaceForcingS(i,j,bi,bj)/gsm_s
c OR
c let virtual flux be zero
c              VirtualFlux(i,j)=0.d0
c
            ELSE
              VirtualFlux(i,j)=0. _d 0
            ENDIF
#endif /* ALLOW_OLD_VIRTUALFLUX */
          ENDDO
         ENDDO

C update tendency      
         DO j=jmin,jmax
          DO i=imin,imax
           GDC(i,j)= recip_drF(kLev)*recip_hFacC(i,j,kLev,bi,bj)
     &              *(FluxCO2(i,j,bi,bj) 
#ifdef ALLOW_OLD_VIRTUALFLUX
     &              + VirtualFlux(i,j)
#endif
     &               )
          ENDDO
         ENDDO

        RETURN
        END
#endif  /*ALLOW_CARBON*/

#endif  /*DARWIN*/
#endif  /*ALLOW_PTRACERS*/
c ==================================================================
