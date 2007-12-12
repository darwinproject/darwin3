C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_init_fixed.F,v 1.3 2007/12/12 18:44:28 jahn Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "GCHEM_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

c===============================================================================
C===============================================================================
CStartofinterface
      SUBROUTINE DARWIN_INIT_FIXED(myThid)                        
C     =============== Global data ==========================================
C     === Global variables ===
         implicit none
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS.h"
#include "DARWIN_IO.h"
#include "GCHEM.h"
#include "DARWIN_SIZE.h"
#include "DARWIN.h"

        INTEGER myThid
C============== Local variables ============================================
C     msgBuf    - Informational/error meesage buffer
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      _RL pday
      INTEGER i,j,k,bi,bj
      INTEGER tmp
      INTEGER prec
      CHARACTER*(MAX_LEN_MBUF) fn
C     /--------------------------------------------------------------\
C     |  initialise common block biochemical parameters               |
C     \--------------------------------------------------------------/

      WRITE(msgBuf,'(A)')
     &'// ======================================================='
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') '// Darwin loading parameters'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)')
     &'// ======================================================='
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )


c c define 1 day in seconds
         pday = 86400.0d0

c attenuation coefficients
      k0=        4.d-2                   !atten coefficient water(m^-1)
      kc=        4.d-2*16.d0*1.d0        !atten coefficient phy((uM m)-1)
c par parameters
      parfrac=  0.4d0                    !fraction Qsw that is PAR
      parconv= 1.d0/0.2174               !conversion from W/m2 to uEin/m2/s
c for chl
      chlpmax=40.d0                      ! mg Chl/mmolP
      chlpmin=16.d0                      ! mg Chl/mmolP
      istar=90                           ! w/m2
c iron related
      alpfe=     0.04                    !solubility of Fe dust
      scav=      0.4/(360.d0*86400.d0)  !iron chem scavenging rate (s-1)
      ligand_tot=1.d-3                   !total ligand (uM)
      ligand_stab=2.d5                   !ligand stability rate ratio
      freefemax = .4e-3                  ! max free fe
c
c oxidation rates for ammonium and nitrite
c i.e. Knita ...    NH4 -> NO2
c i.e. Knitb ...    NO2 -> NO3
       Knita = 1.0d0/(.50*pday)
       Knitb = 1.0d0/(10.0*pday)
c critical light level (muEin/m2/s) after which oxidation starts
       PAR0 = 10
c
c set growth days ...small or big organism?
       Smallgrow = .7d0
       Biggrow   = .4d0
       Smallgrowrange = 0.d0
       Biggrowrange = 0.d0
       diaz_growfac = 2.d0
c set mort days ...small or big organism?
       Smallmort = 10.d0
       Bigmort   = 10.d0
       Smallmortrange = 0.d0
       Bigmortrange = 0.d0
c set export fraction ...small or big organism?
       Smallexport = 0.2d0
       Bigexport   = 0.5d0
c set sinking rates (m/s)... small or big organism?
       SmallSink = 0.0d0/pday
       BigSink =  0.5d0/pday   !0.5d0/pday
c set parameters for light function for phyto growth
       smallksatpar =    0.12d0 ! 0.8d0
       smallksatparstd = 0.20    ! 0.3d0
       smallkinhib =     6.0     ! 2.0d0
       smallkinhibstd =  0.10    ! 0.5d0
       Bigksatpar =      0.12d0  ! 0.35d0
       Bigksatparstd =   0.06d0  ! 0.1d0
       Bigkinhib =       1.0d0   ! 0.5d0
       Bigkinhibstd =    0.05d0   ! 0.1d0
c set temperature function
       tempcoeff1 = 1.d0/3.d0
       tempcoeff2_small = 0.001d0
       tempcoeff2_big   = 0.0003d0
       tempcoeff3 = 1.04d0
       tempmax = 30.d0      ! 32.d0
       temprange = 32.d0    ! 30.d0
       tempnorm = 0.3  ! 1.d0
       tempdecay = 4.d0
c set phosphate half stauration constants .. small or big organism
       SmallPsat=0.015d0
       BigPsat=0.035d0
       ProcPsat=0.01d0
       SmallPsatrange=0.02d0
       BigPsatrange=0.02d0
       ProcPsatrange=0.005d0
c set NH4/NO2 frac, so that NH4/NO2 can be preferred nitrogen source
       ksatNH4fac=.50d0
       ksatNO2fac=1.0d0
c set prochl lower half-sat
       prochlPsat=.85d0
c ammonia and nitrite inhibition
       sig1 = 4.6
       sig2 = 4.6
       sig3 = 4.6
       ngrowfac = 1.d0
       ilight = 2.d0
c set si half sat
       val_ksatsi=1.d0
c set nutrient ratios for phyto
       val_R_SiP_diatom=16.0d0
       val_R_NP_diaz=40.0d0
       val_RFeP_diaz=7.5d-3
       val_R_NP=16.0d0
       val_RFeP=1.0d-3
#ifdef OLD_GRAZE
c grazing hlaf saturation
       kgrazesat = 0.1d0
c set grazing rates .. small or big organism?
       GrazeFast = 1.0d0/(5.0d0*pday)
       GrazeSlow = 1.0d0/(30.0d0*pday)
c set grazing effeciency
       GrazeEffsmall=0.6
       GrazeEffbig  =0.2
c set grazing of diatom factor
       diatomgraz = 0.8
       olargegraz = 0.9
#else
c grazing hlaf saturation
c      kgrazesat = 0.1d0
       kgrazesat = 0.1d0
c      phygrazmin = 1e-5
       phygrazmin = 1e-10
c set grazing rates .. small or big organism?
c      GrazeFast = 1.0d0/(5.0d0*pday)
       GrazeFast = 1.0d0/(2.0d0*pday)
c      GrazeSlow = 1.0d0/(30.0d0*pday)
       GrazeSlow = 1.0d0/(7.0d0*pday)
c set grazing effeciency
       GrazeEfflow= 0.2
       GrazeEffmod= 0.5
       GrazeEffhi = 0.7
c set palatibility
       palathi = 1.0
       palatlo = 0.2
c set palatibilty diatom factor
       diatomgraz = 0.7
       olargegraz = 0.9
c set faction graz to POM
       ExGrazfracbig = 0.8
       ExGrazfracsmall = 0.8
#endif
c set zoo mortality
       ZoomortSmall = 1.0d0/(30.0*pday)
       ZoomortBig = 1.0d0/(30.0*pday)
c set zoo exportfrac
       ZooexfacSmall = 0.2d0
       ZooexfacBig = 0.7d0
c minimum phyto (below which grazing and mortality doesn't happen)
c      phymin = 1 _d -10
       phymin = 1d-50
c DOM remin rates
         Kdop = 1.0d0/(100.0d0*pday)
         Kdon = 1.0d0/(100.0d0*pday)
         KdoFe = 1.0d0/(100.0d0*pday)
c Particulate detritus remin rates
c z* = wx_sink/Kremin_X
c for e-folding length scale, z* = 300 m
c choose Kremin_X = 1/30 day-1, wx_sink = 10 m day-1
         Kpremin_P = 1.0d0/(50.0d0*pday)
         Kpremin_N = Kpremin_P
         Kpremin_Fe = Kpremin_P
         Kpremin_Si = 1.0d0/(300.0d0*pday)
c sinking rate for particulate matter (m/s)
         wp_sink = 10.0/pday
         wn_sink = wp_sink
         wfe_sink = wp_sink
         wsi_sink = wp_sink

#ifdef DAR_DIAG_DIVER
c only look at grid point with a minimum biomass
        diver_thresh0=1e-12
c diver1 - if any type greater than
        diver_thresh1=1e-8
c diver2 - if more than this proportion of total biomass
        diver_thresh2=1e-3
c diver3 - fraction of biomass to count
        diver_thresh3=.999
c diver4 - fraction of maximum species
        diver_thresh4=1e-5
#endif

c set up diagnostics
#ifdef ALLOW_MNC
      IF ( useMNC ) THEN
        CALL DARWIN_MNC_INIT( myThid )
      ENDIF
#endif /* ALLOW_MNC */

COJ set up diagnostics
#ifdef ALLOW_DIAGNOSTICS
      IF ( useDIAGNOSTICS ) THEN
        CALL DARWIN_DIAGNOSTICS_INIT( myThid )
      ENDIF
#endif /* ALLOW_DIAGNOSTICS */
COJ



        RETURN
        END
C============================================================================
#endif
#endif

