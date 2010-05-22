C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_readparams.F,v 1.13 2010/05/22 19:30:08 jahn Exp $
C $Name:  $

#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_READPARMS

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_READPARMS( myThid )

C !DESCRIPTION:
C     Initialize DARWIN parameters, read in data.darwin

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GCHEM.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_IO.h"
#include "DARWIN_PARAMS.h"
#ifdef WAVEBANDS
#include "WAVEBANDS_PARAMS.h"
#endif

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid

C !OUTPUT PARAMETERS: ==================================================
C  none

#ifdef ALLOW_DARWIN

C !LOCAL VARIABLES: ====================================================
C  iUnit		:: unit number for I/O
C  msgBuf		:: message buffer
      INTEGER iUnit
      CHARACTER*(MAX_LEN_MBUF) msgBuf
#ifdef OASIM
      INTEGER ilam
      _RL darwin_oasim_waves(tlam)
      _RL planck, c, hc, oavo, hcoavo, rlamm
#endif
CEOP

      NAMELIST /DARWIN_FORCING/
     &           darwin_iceFile,
     &           darwin_ironFile,
     &           darwin_PARFile,
     &           darwin_nutWVelFile,
     &           darwin_PO4_relaxFile, darwin_NO3_relaxFile, 
     &           darwin_FeT_relaxFile, darwin_Si_relaxFile,
     &           darwin_PO4_fluxFile, darwin_NO3_fluxFile,
     &           darwin_FeT_fluxFile, darwin_Si_fluxFile,
     &           darwin_waterabsorbFile, darwin_phytoabsorbFile,
     &           darwin_surfacespecFile, darwin_acdomFile,
#ifdef OASIM
     &           darwin_oasim_edFile, darwin_oasim_esFile,
     &           darwin_oasim_waves,
#endif
     &           darwin_relaxscale,
     &           darwin_ForcingPeriod, darwin_ForcingCycle,
#ifdef ALLOW_PAR_DAY
     &           darwin_PARavPeriod,
#endif
#ifdef DAR_CALC_ACDOM
     &           darwin_Sdom,
#endif
#ifdef DAR_DIAG_ACDOM
     &           darwin_diag_acdom_ilam,
#endif
     &           darwin_seed

#ifdef DAR_DIAG_CHL
      NAMELIST /DARWIN_CHL/
     &       Geider_Bigalphachl, Geider_smallalphachl,
     &       Geider_Bigchl2cmax, Geider_smallchl2cmax,
     &       Geider_Bigchl2cmin,
     &       Doney_Bmin, Doney_Bmax, Doney_PARstar,
     &       Cloern_A, Cloern_B, Cloern_C, Cloern_chl2cmin
#endif

#ifdef ALLOW_CARBON
      NAMELIST /DIC_FORCING/
     &        DIC_windFile, DIC_atmospFile,
     &        dic_pCO2, dic_int1, dic_int2, dic_int3, dic_int4
#endif

C Set defaults values for parameters in DARWIN_IO.h
      darwin_iceFile=' '
      darwin_ironFile=' '
      darwin_PARFile=' '
      darwin_nutWVelFile=' '
      darwin_PO4_relaxFile=' '
      darwin_NO3_relaxFile=' '
      darwin_FeT_relaxFile=' '
      darwin_Si_relaxFile=' '
      darwin_PO4_fluxFile=' '
      darwin_NO3_fluxFile=' '
      darwin_FeT_fluxFile=' '
      darwin_Si_fluxFile=' '
      darwin_waterabsorbFile=' '
      darwin_phytoabsorbFile=' '
      darwin_surfacespecFile=' '
      darwin_acdomFile=' '
      darwin_oasim_edFile=' '
      darwin_oasim_esFile=' '
      darwin_relaxscale=0. _d 0
      darwin_seed=0
#ifdef ALLOW_CARBON
       DIC_windFile  = ' '
       DIC_atmospFile= ' '
       dic_int1    = 0
       dic_int2    = 0
       dic_int3    = 0
       dic_int4    = 0
       dic_pCO2    = 0. _d 0
#endif
#ifdef ALLOW_PAR_DAY
      darwin_PARavPeriod=86400. _d 0
#endif
#ifdef OASIM
      DO ilam=1,tlam
        darwin_oasim_waves(ilam) = 0 _d 0
      ENDDO
      IF (tlam.EQ.13) THEN
        darwin_oasim_waves(1) = 400 _d 0
        darwin_oasim_waves(2) = 425 _d 0
        darwin_oasim_waves(3) = 450 _d 0
        darwin_oasim_waves(4) = 475 _d 0
        darwin_oasim_waves(5) = 500 _d 0
        darwin_oasim_waves(6) = 525 _d 0
        darwin_oasim_waves(7) = 550 _d 0
        darwin_oasim_waves(8) = 575 _d 0
        darwin_oasim_waves(9) = 600 _d 0
        darwin_oasim_waves(10) = 625 _d 0
        darwin_oasim_waves(11) = 650 _d 0
        darwin_oasim_waves(12) = 675 _d 0
        darwin_oasim_waves(13) = 700 _d 0
      ENDIF
#endif
#ifdef DAR_CALC_ACDOM
      darwin_Sdom = 0.014 _d 0
#endif
#ifdef DAR_DIAG_ACDOM
c value >= 100 will be converted to index in wavebands_init_fixed      
      darwin_diag_acdom_ilam = 450
#endif
c default periodic forcing to same as for GCHEM
      darwin_forcingPeriod=gchem_ForcingPeriod
      darwin_forcingCycle=gchem_ForcingCycle
C Open and read the data.darwin file
      _BEGIN_MASTER(myThid)
      WRITE(msgBuf,'(A)') ' DARWIN_READPARMS: opening data.darwin'
      CALL PRINT_MESSAGE(msgBuf, standardMessageUnit,
     &                   SQUEEZE_RIGHT , 1)
      CALL OPEN_COPY_DATA_FILE(
     I                   'data.darwin', 'DARWIN_READPARAMS',
     O                   iUnit,
     I                   myThid )
      READ(UNIT=iUnit,NML=DARWIN_FORCING)
#ifdef ALLOW_PAR_DAY
      darwin_PARnav = NINT(darwin_PARavPeriod*nsubtime/dTtracerLev(1))
#endif

#ifdef DAR_DIAG_CHL
C default values
C Geider:  chl:c = max(chl2cmin, chl2cmax/(1+(chl2cmax*alphachl*PARday)/(2*Pcm)))
C          Pcm = mu*limit*phytoTempFunction
      Geider_smallalphachl = 2. _d -6                ! mmol C (mg Chl)-1 m2 (uEin)-1
      Geider_Bigalphachl   = 1. _d -6                ! mmol C (mg Chl)-1 m2 (uEin)-1
      Geider_smallchl2cmax = 0.35 _d 0               ! mg Chl (mmol C)-1
      Geider_Bigchl2cmax   = 0.65 _d 0               ! mg Chl (mmol C)-1
      Geider_smallchl2cmin = 0.003  _d 0 * 12. _d 0  ! mg Chl a/mmol C
      Geider_Bigchl2cmin   = 0.003  _d 0 * 12. _d 0  ! mg Chl a/mmol C

C Doney:  chl:c = (Bmax - (Bmax-Bmin)*MIN(1,PARday/PARstar))*limit
      Doney_Bmax    = 12. _d 0 / 37. _d 0     ! mg Chl a/mmol C
      Doney_Bmin    = 12. _d 0 / 90. _d 0     ! mg Chl a/mmol C
      Doney_PARstar = 90. _d 0 / 0.2174 _d 0  ! uEin/m2/s

C Cloern:  chl:c = chl2cmin + A*exp(B*T)*exp(-C*PARday)*limit
      Cloern_chl2cmin = 0.003  _d 0 * 12. _d 0               ! mg Chl a/mmol C
      Cloern_A        = 0.0154 _d 0 * 12. _d 0               ! mg Chl a/mmol C
      Cloern_B        = 0.050  _d 0                          ! (degree C)^{-1}
      Cloern_C        = 0.059  _d 0 * 86400. _d 0 / 1. _d 6  ! m^2 s/uEin

      READ(UNIT=iUnit,NML=DARWIN_CHL)
#endif /* DAR_DIAG_CHL */

#ifdef ALLOW_CARBON
      READ(UNIT=iUnit,NML=DIC_FORCING)
#endif


      WRITE(msgBuf,'(A)')
     &  ' DARWIN_READPARMS: finished reading data.darwin'
      CALL PRINT_MESSAGE(msgBuf, standardMessageUnit,
     &                   SQUEEZE_RIGHT , 1)

C Close the open data file
      CLOSE(iUnit)

#ifdef OASIM
c   Quanta conversion
      planck = 6.6256 _d -34   !Plancks constant J sec
      c = 2.998 _d 8                 !speed of light m/sec
      hc = 1.0/(planck*c)
      oavo = 1.0/6.023 _d 23   ! 1/Avogadros number
      hcoavo = hc*oavo
      do ilam = 1,tlam
       rlamm = darwin_oasim_waves(ilam)*1 _d -9  !lambda in m
       WtouEins(ilam) = 1 _d 6*rlamm*hcoavo      !Watts to uEin/s conversion
      enddo
#endif OASIM

      _END_MASTER(myThid)

C Everyone else must wait for the parameters to be loaded
      _BARRIER

#endif /* ALLOW_DARWIN */

      RETURN
      END
