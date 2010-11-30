C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_readparams.F,v 1.18 2010/11/30 19:08:35 jahn Exp $
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
#include "DARWIN.h"
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
C  darwin_waves         :: 'central' wavelengths of wavebands (nm)
C                          for OASIM and WAVEBANDS
      INTEGER iUnit,errIO
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER darwin_waves(tlam)
#if defined(WAVEBANDS) || defined(OASIM)
      INTEGER ilam,i
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
#endif
     &           darwin_relaxscale,
     &           darwin_ForcingPeriod, darwin_ForcingCycle,
#ifdef ALLOW_PAR_DAY
     &           darwin_PARavPeriod,
#endif
     &           darwin_seed

      NAMELIST /DARWIN_SPECTRAL_PARM/
     &           darwin_waves
#ifdef WAVEBANDS
#ifdef DAR_CALC_ACDOM
     &          ,darwin_Sdom
#endif
#ifdef DAR_DIAG_ACDOM
     &          ,darwin_diag_acdom_ilam
#endif
#ifdef DAR_RADTRANS
     &          ,darwin_PAR_ilamLo
     &          ,darwin_PAR_ilamHi
     &          ,darwin_radmodThresh
     &          ,darwin_Dmax
     &          ,darwin_rmus
     &          ,darwin_rmuu 
     &          ,darwin_bbw 
     &          ,darwin_bbphy
     &          ,darwin_bbmin
     &          ,darwin_radtrans_kmax
     &          ,darwin_radtrans_niter
#endif
#endif /* WAVEBANDS */

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
c default periodic forcing to same as for GCHEM
      darwin_forcingPeriod=gchem_ForcingPeriod
      darwin_forcingCycle=gchem_ForcingCycle

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

#if defined(WAVEBANDS) || defined(OASIM)
      DO ilam=1,tlam
        darwin_waves(ilam) = 0
      ENDDO
      IF (tlam.EQ.13) THEN
        darwin_waves(1) = 400
        darwin_waves(2) = 425
        darwin_waves(3) = 450
        darwin_waves(4) = 475
        darwin_waves(5) = 500
        darwin_waves(6) = 525
        darwin_waves(7) = 550
        darwin_waves(8) = 575
        darwin_waves(9) = 600
        darwin_waves(10) = 625
        darwin_waves(11) = 650
        darwin_waves(12) = 675
        darwin_waves(13) = 700
      ENDIF
#endif

#ifdef WAVEBANDS
#ifdef DAR_CALC_ACDOM
      darwin_Sdom = 0.014 _d 0
#endif
#ifdef DAR_DIAG_ACDOM
c value >= 100 will be converted to index in wavebands_init_fixed      
      darwin_diag_acdom_ilam = 450
#endif
#ifdef DAR_RADTRANS
      darwin_PAR_ilamLo = 1
      darwin_PAR_ilamHi = tlam
      darwin_radmodThresh = 1 _d -4
      darwin_Dmax = 500 _d 0
      darwin_rmus = 1.0/0.83 _d 0
      darwin_rmuu = 1.0/0.4 _d 0
      darwin_bbmin = 0.0002 _d 0
      darwin_bbw = 0.5 _d 0
      do i=1,tnabp
        darwin_bbphy(i) = 0 _d 0
      enddo
      darwin_radtrans_kmax = Nr
      darwin_radtrans_niter = 1
#endif
#endif /* WAVEBANDS */

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

#ifdef DAR_RADTRANS
#ifndef DAR_NONSPECTRAL_BACKSCATTERING_RATIO
      DO i=1,tnabp
       IF ( darwin_bbphy(i) .NE. 0 _d 0 ) THEN
        WRITE(msgBuf,'(2A)') 'S/R DARWIN_READPARMS:',
     &   'darwin_bbphy is obsolete.'
        CALL PRINT_ERROR( msgBuf , 1)
        WRITE(msgBuf,'(2A)') 'S/R DARWIN_READPARMS:',
     &   'Backscattering coefficients are now read from'
        CALL PRINT_ERROR( msgBuf , 1)
        WRITE(msgBuf,'(2A)') 'S/R DARWIN_READPARMS:',
     &   'darwin_phytoabsorbFile.'
        CALL PRINT_ERROR( msgBuf , 1)
       ENDIF
      ENDDO
#endif
#endif

#if defined(WAVEBANDS) || defined(OASIM)
      READ(UNIT=iUnit,NML=DARWIN_SPECTRAL_PARM,IOSTAT=errIO)
      IF ( errIO .LT. 0 ) THEN
       WRITE(msgBuf,'(A)')
     &  'S/R DARWIN_READPARMS'
       CALL PRINT_ERROR( msgBuf , 1)
       WRITE(msgBuf,'(A)')
     &  'Error reading darwin package'
       CALL PRINT_ERROR( msgBuf , 1)
       WRITE(msgBuf,'(A)')
     &  'parameter file "data.darwin"'
       CALL PRINT_ERROR( msgBuf , 1)
       WRITE(msgBuf,'(A)')
     &  'Problem in namelist DARWIN_SPECTRAL_PARM'
       CALL PRINT_ERROR( msgBuf , 1)
       STOP 'ABNORMAL END: S/R DARWIN_READPARMS'
      ENDIF
#endif

      WRITE(msgBuf,'(A)')
     &  ' DARWIN_READPARMS: finished reading data.darwin'
      CALL PRINT_MESSAGE(msgBuf, standardMessageUnit,
     &                   SQUEEZE_RIGHT , 1)

C Close the open data file
      CLOSE(iUnit)

#ifdef WAVEBANDS
      do ilam = 1,tlam
        pwaves(ilam) = darwin_waves(ilam)
      enddo
#endif

#if defined(WAVEBANDS) || defined(OASIM)
c   Quanta conversion
      planck = 6.6256 _d -34   !Plancks constant J sec
      c = 2.998 _d 8                 !speed of light m/sec
      hc = 1.0/(planck*c)
      oavo = 1.0/6.023 _d 23   ! 1/Avogadros number
      hcoavo = hc*oavo
      do ilam = 1,tlam
       rlamm = darwin_waves(ilam)*1 _d -9  !lambda in m
       WtouEins(ilam) = 1 _d 6*rlamm*hcoavo      !Watts to uEin/s conversion
      enddo
#endif

C--   Print a summary of parameter values:
      iUnit = standardMessageUnit
      WRITE(msgBuf,'(A)') '// ==================================='
      CALL PRINT_MESSAGE( msgBuf, iUnit, SQUEEZE_RIGHT , myThid )
      WRITE(msgBuf,'(A)') '// darwin parameters '
      CALL PRINT_MESSAGE( msgBuf, iUnit, SQUEEZE_RIGHT , myThid )
      WRITE(msgBuf,'(A)') '// ==================================='
      CALL PRINT_MESSAGE( msgBuf, iUnit, SQUEEZE_RIGHT , myThid )
      CALL WRITE_0D_I( darwin_seed, INDEX_NONE,
     &   'darwin_seed =',
     &   ' /* seed for random number generator */')

      WRITE(msgBuf,'(A)') ' -----------------------------------'
      CALL PRINT_MESSAGE( msgBuf, iUnit, SQUEEZE_RIGHT, myThid )

      CALL WRITE_1D_I( darwin_waves, tlam, 0,
     &   'darwin_waves =',
     &'   /* "central" wavelengths of wavebands */')
#ifdef WAVEBANDS
#ifdef DAR_CALC_ACDOM
      CALL WRITE_0D_RL( darwin_Sdom, INDEX_NONE,
     &   'darwin_Sdom =',
     &'   /* spectral slope for aCDOM */')
#endif
#ifdef DAR_DIAG_ACDOM
      CALL WRITE_0D_I( darwin_diag_acdom_ilam, INDEX_NONE,
     &   'darwin_diag_acdom_ilam =',
     &'   /* waveband to use for aCDOM diagnostic */')
#endif
#ifdef DAR_RADTRANS
      CALL WRITE_0D_I( darwin_PAR_ilamLo, INDEX_NONE,
     &   'darwin_PAR_ilamLo =',
     &'   /* waveband index of PAR lower bound */')
      CALL WRITE_0D_I( darwin_PAR_ilamHi, INDEX_NONE,
     &   'darwin_PAR_ilamHi =',
     &'   /* waveband index of PAR upper bound */')
      CALL WRITE_0D_RL( darwin_radmodThresh, INDEX_NONE,
     &   'darwin_radmodThresh =',
     &'   /* threshold for calling radmod (W/m2/waveband) */')
      CALL WRITE_0D_RL( darwin_Dmax, INDEX_NONE,
     &   'darwin_Dmax =',
     &'   /* depth at which Ed is assumed zero */')
      CALL WRITE_0D_RL( darwin_rmus, INDEX_NONE,
     &   'darwin_rmus =',
     &'   /* inverse average cosine of downward diffuse irradiance */')
      CALL WRITE_0D_RL( darwin_rmuu, INDEX_NONE,
     &   'darwin_rmuu =',
     &'   /* inverse average cosine of upward diffuse irradiance */')
      CALL WRITE_0D_RL( darwin_bbw, INDEX_NONE,
     &   'darwin_bbw =',
     &'   /* backscattering to forward scattering ratio for water */')
      CALL WRITE_0D_RL( darwin_bbmin, INDEX_NONE,
     &   'darwin_bbmin =',
     &'   /* minimum backscattering coefficient (1/m) */')
      CALL WRITE_1D_RL( darwin_bbphy, tnabp, 0,
     &   'darwin_bbphy =',
     &'   /* backscattering to forward scattering ratio for phyto */')
      CALL WRITE_0D_I( darwin_radtrans_kmax, INDEX_NONE,
     &   'darwin_radtrans_kmax =',
     &'   /* deepest level in which to compute irradiances */')
      CALL WRITE_0D_I( darwin_radtrans_niter, INDEX_NONE,
     &   'darwin_radtrans_niter =',
     &'   /* number of "radtrans improvement" iterations */')
#endif /* DAR_RADTRANS */
#endif /* WAVEBANDS */

      WRITE(msgBuf,'(A)') ' ==================================='
      CALL PRINT_MESSAGE( msgBuf, iUnit, SQUEEZE_RIGHT, myThid )

      _END_MASTER(myThid)

C Everyone else must wait for the parameters to be loaded
      _BARRIER

#endif /* ALLOW_DARWIN */

      RETURN
      END
