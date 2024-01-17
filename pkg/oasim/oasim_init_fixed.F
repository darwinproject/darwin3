#include "OASIM_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_INIT_FIXED

C     !INTERFACE:
      SUBROUTINE OASIM_INIT_FIXED(myThid)

C     !DESCRIPTION:
C     Computes constants for global irradiance calculations, reads in
C     required data files, and otherwise obtains one-time-only information
C     necessary for the run.
C
C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "OASIM_SIZE.h"
#include "OASIM_PARAMS.h"
#include "OASIM_INTERNAL.h"
#ifdef ALLOW_CAL
#include "cal.h"
#endif

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      INTEGER l
      _RL pi1,h,c,hc,oavo,hcoavo,rlamm

      _BEGIN_MASTER( myThid )

c  Degrees to radians conversion
      pi1 = ACOS(-1.0D0)
      pi2 = pi1*2.0 _d 0
      rad = 180.0D0/pi1
c
c  Obtain Light data
      CALL OASIM_INIT_ATMOW( myThid )
c
c  Quanta conversion W to uEin/s
c     Plancks constant J sec
      h = 6.6256 _d -34
c     speed of light m/sec
      c = 2.998 _d 8
      hc = 1.0 _d 0/(h*c)
c     1/Avogadros number
      oavo = 1.0 _d 0/6.023 _d 23
      hcoavo = hc*oavo
      DO l = 1,nlt
c      lambda in m
       rlamm = FLOAT(lam(l))*1.0 _d -9
c      Watts to quanta conversion
       WtouEins(l) = 1.0 _d 6*rlamm*hcoavo
      ENDDO
c
      o24 = 1. _d 0/24 _d 0

      CALL OASIM_INIT_CLEAR( myThid )

C for aerosol data
      lamaer( 1) =  250
      lamaer( 2) =  325
      lamaer( 3) =  350
      lamaer( 4) =  375
      lamaer( 5) =  400
      lamaer( 6) =  425
      lamaer( 7) =  450
      lamaer( 8) =  475
      lamaer( 9) =  500
      lamaer(10) =  525
      lamaer(11) =  550
      lamaer(12) =  575
      lamaer(13) =  600
      lamaer(14) =  625
      lamaer(15) =  650
      lamaer(16) =  675
      lamaer(17) =  700
      lamaer(18) =  725
      lamaer(19) =  775
      lamaer(20) =  850
      lamaer(21) =  950
      lamaer(22) = 1050
      lamaer(23) = 1150
      lamaer(24) = 1250
      lamaer(25) = 1350
      lamaer(26) = 1450
      lamaer(27) = 1550
      lamaer(28) = 1650
      lamaer(29) = 1750
      lamaer(30) = 1900
      lamaer(31) = 2200
      lamaer(32) = 2900
      lamaer(33) = 3700
      CALL OASIM_INIT_AER( myThid )

C for light:
      ozfac1 = 44.0 _d 0/6370.0 _d 0
      ozfac2 = 1.0 _d 0 + 22.0 _d 0/6370.0 _d 0
      p0 = 1013.25 _d 0

C for cloud model
      CALL OASIM_INIT_SLINGO( myThid )

      _END_MASTER( myThid )
      _BARRIER

      CALL OASIM_INIT_VEC( myThid )

#ifndef OASIM_READ_UNFORMATTED
      CALL OASIM_EXF_INIT_FIXED( myThid )
#endif

#ifdef ALLOW_DIAGNOSTICS
      IF ( useDiagnostics ) THEN
        CALL OASIM_DIAGNOSTICS_INIT( myThid )
      ENDIF
#endif

#endif /* ALLOW_OASIM */

      RETURN
      END


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_INIT_ATMOW

C     !INTERFACE:
      SUBROUTINE OASIM_INIT_ATMOW( myThid)

C     !DESCRIPTION:
c     Reads in radiative transfer data: specifically atmospheric data
c     (Extraterrestrial irradiance and atmospheric optical data), and
c     water data (seawater absorption and total scattering coefficients,
c     and chl-specific absorption and total scattering data for
c     several phytoplankton groups).  PAR (350-700) begins at index 3,
c     and ends at index 17.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "OASIM_SIZE.h"
#include "OASIM_INTERNAL.h"
#include "OASIM_PARAMS.h"
#include "OASIM_FIELDS.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      character*80 title
      INTEGER i, l, ilam, iUnit
      _RL sFobar,sthray,soza,sawv,sao,saco2
      _RL lambda,saw,sbw,sac,sbc
c
c  Atmospheric data file, atmo25b.dat
      CALL MDSFINDUNIT(iUnit, myThid)
      OPEN(iUnit,FILE=oasim_atmoFile,STATUS='old',FORM='formatted')
      READ(iUnit,'(a80)')title
      READ(iUnit,'(a80)')title
      READ(iUnit,'(a80)')title
      READ(iUnit,'(a80)')title
      WRITE(msgBuf,'(2A)') 'OASIM_INIT_FIXED: ',
     &      'ilam Fobar thray oza awv ao aco2'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , myThid)
      DO l = 1,nlt
       READ(iUnit,10)ilam,sFobar,sthray,soza,sawv,sao,saco2
       WRITE(msgBuf,'(A,i5,6f11.4)') 'OASIM_INIT_FIXED: ',
     &       ilam,sFobar,sthray,soza,sawv,sao,saco2
       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid)
       lam(l) = ilam
       Fobar(l) = sFobar
       thray(l) = sthray
       oza(l) = soza
       awv(l) = sawv
       ao(l) = sao
       aco2(l) = saco2
       OASIM_lam(l) = ilam
      ENDDO
      CLOSE(iUnit)
c
10    FORMAT(i5,6f11.4)
c
c
c  Water data files, abw25b.dat
      OPEN(iUnit,FILE=oasim_waterFile,STATUS='old',FORM='formatted')
      DO i = 1,6
       READ(iUnit,'(a50)')title
c       write(6,'(a50)')title
      ENDDO
      DO l = 1,nlt
       READ(iUnit,20)ilam,saw,sbw
c       write(6,20)lambda,saw,sbw
       IF (ilam .NE. lam(l)) THEN
        WRITE(msgBuf,'(3A)') 'OASIM_INIT_FIXED:',
     &   ' wavebands in OASIM_wasterFile do not match those in',
     &   ' OASIM_atmoFile.'
        CALL PRINT_ERROR( msgBuf , myThid)
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R OASIM_INIT_FIXED'
       ENDIF
       aw(l) = saw
       bw(l) = sbw
      ENDDO
      CLOSE(iUnit)
20    FORMAT(i5,f15.4,f10.4)

#endif /* ALLOW_OASIM */

      RETURN
      END


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_INIT_VEC

C     !INTERFACE:
      SUBROUTINE OASIM_INIT_VEC( myThid )

C     !DESCRIPTION:
C  Create arrays of up, north, and east vectors in earth-fixed coords
C  for OASIM grid locations.
C
C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "GRID.h"
#include "OASIM_SIZE.h"
#include "OASIM_PARAMS.h"
#include "OASIM_FIELDS.h"
#include "OASIM_INTERNAL.h"

C     !INPUT PARAMETERS:
C     myThid   :: my Thread Id number
      INTEGER myThid
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      INTEGER i,j,bi,bj,nv
      _RL xlon,ylat,rlon,rlat,cosx,cosy,sinx,siny,upxy
      _RL up(3), ea(3)

c  Convert geodetic lat/lon to Earth-centered, earth-fixed (ECEF)
c  vector (geodetic unit vector)
      DO bj=myByLo(myThid),myByHi(myThid)
      DO bi=myBxLo(myThid),myBxHi(myThid)
      DO j=1,sNy
      DO i=1,sNx
        ylat = YC(i,j,bi,bj)
        rlat = ylat/rad
        cosy = COS(rlat)
        siny = SIN(rlat)
        IF (oasim_fixedLon .NE. UNSET_RL) THEN
          xlon = oasim_fixedLon
        ELSE
          xlon = XC(i,j,bi,bj)
        ENDIF
        rlon = xlon/rad
        cosx = COS(rlon)
        sinx = SIN(rlon)
        up(1) = cosy*cosx
        up(2) = cosy*sinx
        up(3) = siny
c
c   Compute the local East and North unit vectors
        upxy = SQRT(up(1)*up(1)+up(2)*up(2))
        ea(1) = -up(2)/upxy
        ea(2) = up(1)/upxy
        ea(3) = 0.0 _d 0
c       cross product
        OASIM_no(i,j,bi,bj,1) = up(2)*ea(3) - up(3)*ea(2)
        OASIM_no(i,j,bi,bj,2) = up(3)*ea(1) - up(1)*ea(3)
        OASIM_no(i,j,bi,bj,3) = up(1)*ea(2) - up(2)*ea(1)
        OASIM_up(i,j,bi,bj,1) = up(1)
        OASIM_up(i,j,bi,bj,2) = up(2)
        OASIM_up(i,j,bi,bj,3) = up(3)
        OASIM_ea(i,j,bi,bj,1) = ea(1)
        OASIM_ea(i,j,bi,bj,2) = ea(2)
        OASIM_ea(i,j,bi,bj,3) = ea(3)
      ENDDO
      ENDDO
      ENDDO
      ENDDO

#endif /* ALLOW_OASIM */

      RETURN
      END


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_INIT_CLEAR

C     !INTERFACE:
      SUBROUTINE OASIM_INIT_CLEAR(myThid)

C     !DESCRIPTION:

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "OASIM_SIZE.h"
#include "OASIM_INTERNAL.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      INTEGER l
      _RL fac, rlam, t, tlog
      _RL a0,a1,a2,a3,b0,b1,b2,b3
      DATA a0,a1 /0.9976 _d 0, 0.2194 _d 0/
      DATA a2,a3 /5.554 _d -2, 6.7 _d -3/
      DATA b0,b1 /5.026 _d 0, -0.01138 _d 0/
      DATA b2,b3 /9.552 _d -6, -2.698 _d -9/

C for clrtrans
      DO l = 1,nlt
        rlamu(l) = FLOAT(lam(l))*1.0 _d -3    !lambda in um
      ENDDO

C for sfcrfl
      rn = 1.341 _d 0    !index of refraction of pure seawater
      roair = 1.2 _d 3     !density of air g/m3
      DO l = 1,nlt
        rlam = FLOAT(lam(l))
        IF (lam(l) .LT. 900)THEN
         t = EXP(-(aw(l)+0.5 _d 0*bw(l)))
         tlog = LOG(1.0 _d -36+t)
         fac = a0 + a1*tlog + a2*tlog*tlog + a3*tlog*tlog*tlog
         wfac(l) = MIN(fac,1.0 _d 0)
         wfac(l) = MAX(fac,0.0 _d 0)
        ELSE
         fac = b0 + b1*rlam + b2*rlam*rlam + b3*rlam*rlam*rlam
         wfac(l) = MAX(fac,0.0 _d 0)
        ENDIF
      ENDDO

#endif /* ALLOW_OASIM */

      RETURN
      END


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_INIT_AER

C     !INTERFACE:
      SUBROUTINE OASIM_INIT_AER(myThid)

C     !DESCRIPTION:

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "OASIM_SIZE.h"
#include "OASIM_INTERNAL.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      INTEGER l, laer

c     Indices to relate aerosol parameters to other light parameters
      DO l = 1,nlt
        DO laer = 2,nltaer
         IF (lam(l) .LE. lamaer(laer))THEN
          iaer(l) = laer
          waer(l) = (lamaer(laer)-lam(l))/(lamaer(laer)-lamaer(laer-1))
          GO TO 5
         ENDIF
        ENDDO
5       CONTINUE
      ENDDO

#endif /* ALLOW_OASIM */

      RETURN
      END


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_INIT_SLINGO

C     !INTERFACE:
      SUBROUTINE OASIM_INIT_SLINGO(myThid)

C     !DESCRIPTION:
C     read cloud parameters and compute
C
c       ica :: index for translating cloud arrays to light arrays

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "OASIM_SIZE.h"
#include "OASIM_INTERNAL.h"
#include "OASIM_SLINGO.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      INTEGER l, nc, iUnit
      _RL lamcld

      U1 = 7.0 _d 0/4.0 _d 0
      CALL MDSFINDUNIT(iUnit, myThid)
      CALL OASIM_RDSLINGO(iUnit)    !reads cloud parameter file
c     Indices to relate cloud parameters to other light parameters
      DO l = 1,nlt
        DO nc = 1,ncld
         lamcld = NINT(rnl2(nc)*1000.0 _d 0)
         IF (lam(l) .LT. lamcld)THEN
          ica(l) = nc
          GO TO 5
         ENDIF
        ENDDO
5       CONTINUE
      ENDDO
c       ica(nlt) = ncld

#endif /* ALLOW_OASIM */

      RETURN
      END


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_RDSLINGO

C     !INTERFACE:
      SUBROUTINE OASIM_RDSLINGO(iUnit)

C     !DESCRIPTION:
C     Reads cloud parameters by Slingo (1989).

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "OASIM_SIZE.h"
#include "OASIM_SLINGO.h"
#include "OASIM_PARAMS.h"

C     !INPUT PARAMETERS:
      INTEGER iUnit
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      CHARACTER*50 title
      INTEGER n
      REAL*4 rn1,rn2,a4,b4,c4,d4,e4,f4
c
      OPEN(iUnit,FILE=oasim_slingoFile,STATUS='old',FORM='formatted')
      DO n = 1,3
       READ(iUnit,'(a50)')title
      ENDDO
      DO n = 1,ncld
       READ(iUnit,10)rn1,rn2,a4,b4,e4,f4,c4,d4
       rnl1(n) = rn1
       rnl2(n) = rn2
       asl(n) = a4*0.01 _d 0
       bsl(n) = b4
       csl(n) = c4
       dsl(n) = d4
       esl(n) = e4
       fsl(n) = f4*0.001 _d 0
      ENDDO
      CLOSE(iUnit)
c
10    FORMAT(2f5.2,3x,2f6.3,2f6.3,1pe9.2,1pe8.2)

#endif /* ALLOW_OASIM */

      RETURN
      END
C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
