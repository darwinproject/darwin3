#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "DARWIN_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

#ifdef ALLOW_CARBON

CBOP
C !ROUTINE: DIC_SURFFORCING_INIT

C !INTERFACE: ==========================================================
      SUBROUTINE DIC_SURFFORCING_INIT(
     I          myThid)

C !DESCRIPTION:
C  Calculate first guess of pH

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "DYNVARS.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "FFIELDS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PTRACERS_FIELDS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_IO.h"
#include "DARWIN_FLUX.h"
#include "DIC_ATMOS.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER  myThid


C !LOCAL VARIABLES: ====================================================
       INTEGER i,j, k, kLev, it
       INTEGER intime0,intime1
       _RL otime
       _RL aWght,bWght,rdt
       INTEGER nForcingPeriods,Imytm,Ifprd,Ifcyc,Iftm
C Number of iterations for pCO2 solvers...
C Solubility relation coefficients
C local variables for carbon chem
      INTEGER iMin,iMax,jMin,jMax, bi, bj
      _RL surfdic(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL surfalk(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL surfphos(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL surfsi(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL surfsalt(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL surftemp(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      INTEGER iprt,jprt
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER iUnit
      CHARACTER*(MAX_LEN_FNAM) iName
      integer ilo,ihi
      integer  ilnblnk,ifnblnk
      external ilnblnk,ifnblnk
      LOGICAL pH_isLoaded
CEOP

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      kLev=1

      CALL DIC_ATMOS(0, startTime, nIter0, myThid )

      _BEGIN_MASTER(myThid)

C set up coefficients for DIC chemistry
C define Schmidt no. coefficients for CO2
      sca1 = 2073.1 _d 0
      sca2 = -125.62 _d 0
      sca3 =    3.6276 _d 0
      sca4 =   -0.043219 _d 0
C define Schmidt no. coefficients for O2
C based on Keeling et al [GBC, 12, 141, (1998)]
      sox1 = 1638.0 _d 0
      sox2 = -81.83 _d 0
      sox3 =    1.483 _d 0
      sox4 =   -0.008004 _d 0

C coefficients for determining saturation O2
      oA0=  2.00907 _d 0
      oA1=  3.22014 _d 0
      oA2=  4.05010 _d 0
      oA3=  4.94457 _d 0
      oA4= -2.56847 _d -1
      oA5=  3.88767 _d 0
      oB0= -6.24523 _d -3
      oB1= -7.37614 _d -3
      oB2= -1.03410 _d -2
      oB3= -8.17083 _d -3
      oC0= -4.88682 _d -7
C     Set other constant/flag

#ifndef USE_ATMOSCO2

#ifndef USE_EXFCO2
      if (dic_int1.eq.2) then
        call mdsfindunit( iUnit, mythid )
        open(UNIT=iUnit,FILE='co2atmos.dat',STATUS='old')
        do k=1,dic_int2
          read(iUnit,*) co2atmos(k)
          print*,'co2atmos',co2atmos(k)
        enddo
        close(iUnit)
      endif

      if (dic_int1.eq.3) then
        write(iName,'(A,I10.10)') 'dic_atmos.',nIter0
        ilo = ifnblnk(iName)
        ihi = ilnblnk(iName)
        call mdsfindunit( iUnit, mythid )
        open(UNIT=iUnit,FILE=iname(ilo:ihi),STATUS='old')
        read(iUnit,*) total_atmos_carbon_ini,
     &              atpco2_ini
        close(iUnit)
      endif
#endif

#endif
      _END_MASTER(myThid)

ccccccccccccccccccccccccccccccccccccccccc
      IF ( periodicExternalForcing ) THEN


       rdt = 1. _d 0 / deltaTclock
       nForcingPeriods = NINT(externForcingCycle/externForcingPeriod)
cswd QQ change for placement of chem forcing (ie. after timestep)
       Imytm = NINT(startTime*rdt)
       Ifprd = NINT(externForcingPeriod*rdt)
       Ifcyc = NINT(externForcingCycle*rdt)
       Iftm  = MOD( Imytm+Ifcyc-Ifprd/2, Ifcyc)

       intime0 = 1 + INT(Iftm/Ifprd)
       intime1 = 1 + MOD(intime0,nForcingPeriods)
c      aWght = DFLOAT( Iftm-Ifprd*(intime0 - 1) ) / DFLOAT( Ifprd )
       aWght = FLOAT( Iftm-Ifprd*(intime0 - 1) )
       bWght = FLOAT( Ifprd )
       aWght =  aWght / bWght
       bWght = 1. _d 0 - aWght

       _BARRIER
       _BEGIN_MASTER(myThid)

       _END_MASTER(myThid)

#ifdef ALLOW_OFFLINE
       IF ( useOffLine ) THEN
         otime=nIter0*deltaTclock
         CALL OFFLINE_FIELDS_LOAD( otime, nIter0, myThid )
       ENDIF
#endif

c end periodicExternalForcing
      ENDIF

C =================================================================

      jMin=1
      jMax=sNy
      iMin=1
      iMax=sNx

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
         DO j=1-OLy,sNy+OLy
          DO i=1-Olx,sNx+OLx
            pH(i,j,bi,bj) = 8. _d 0
          ENDDO
         ENDDO
       ENDDO
      ENDDO

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
        DO j=1-OLy,sNy+OLy
         DO i=1-OLx,sNx+OLx
          ak0(i,j,bi,bj)=0. _d 0
          ak1(i,j,bi,bj)=0. _d 0
          ak2(i,j,bi,bj)=0. _d 0
          akw(i,j,bi,bj)=0. _d 0
          akb(i,j,bi,bj)=0. _d 0
          akf(i,j,bi,bj)=0. _d 0
          ak1p(i,j,bi,bj)=0. _d 0
          ak2p(i,j,bi,bj)=0. _d 0
          ak3p(i,j,bi,bj)=0. _d 0
          aksi(i,j,bi,bj)=0. _d 0
          fugf(i,j,bi,bj)=0. _d 0
          ff(i,j,bi,bj)=0. _d 0
          ft(i,j,bi,bj)=0. _d 0
          st(i,j,bi,bj)=0. _d 0
          bt(i,j,bi,bj)=0. _d 0
         ENDDO
        ENDDO
       ENDDO
      ENDDO

      pH_isLoaded = .FALSE.
      IF ( nIter0.GT.PTRACERS_Iter0 ) THEN
C       Read pH from a pickup file if needed
        CALL DIC_READ_PICKUP(
     O                        pH_isLoaded,
     I                        nIter0, myThid )
      ENDIF

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)

C determine inorganic carbon chem coefficients
        DO j=jMin,jMax
         DO i=iMin,iMax

c use surface layer values and convert to mol/m3
c and put bounds on tracers so pH solver doesn't blow up
             surfdic(i,j) =
     &            max(10. _d 0 , 
     &                min(4000. _d 0, Ptracer(i,j,1,bi,bj,iDIC)))*1e-3
     &                          * maskC(i,j,kLev,bi,bj)
             surfalk(i,j) =
     &            max(10. _d 0 , 
     &                min(4000. _d 0, Ptracer(i,j,1,bi,bj,iALK)))*1e-3
     &                          * maskC(i,j,kLev,bi,bj)
             surfphos(i,j)  =
     &            max(1. _d -10, 
     &                min(10. _d 0, Ptracer(i,j,1,bi,bj,iPO4)))*1e-3
     &                          * maskC(i,j,kLev,bi,bj)
             surfsi(i,j)   =
     &            max(1. _d -8, 
     &                min(500. _d 0, Ptracer(i,j,1,bi,bj,iSi)))*1e-3
     &                          * maskC(i,j,kLev,bi,bj)
             surfsalt(i,j) =
     &            max(4. _d 0, min(50. _d 0, salt(i,j,kLev,bi,bj)))
             surftemp(i,j) =
     &            max(-4. _d 0, min(39. _d 0, theta(i,j,kLev,bi,bj)))
c
             WIND(i,j,bi,bj)   = 5. _d 0*maskC(i,j,1,bi,bj)
             AtmosP(i,j,bi,bj) = 1. _d 0*maskC(i,j,1,bi,bj)
         ENDDO
        ENDDO

        CALL CARBON_COEFFS(
     I                       surftemp,surfsalt,
     I                       bi,bj,iMin,iMax,jMin,jMax,myThid)

C====================================================================

        IF ( .NOT.pH_isLoaded ) THEN
C set guess of pH for first step here

          print*,'QQ: pCO2 approximation method'
c first approximation
C$TAF LOOP = parallel
          DO j=jMin,jMax
C$TAF LOOP = parallel
           DO i=iMin,iMax
            IF ( maskC(i,j,kLev,bi,bj) .NE. 0. _d 0) THEN
C$TAF init dic_surf = static, 10
             DO it=1,10
C$TAF STORE pH(i,j,bi,bj), PTR_CO2(i,j,kLev)           = dic_surf
C$TAF STORE surfalk(i,j), surfphos(i,j), surfsi(i,j)   = dic_surf
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
             ENDDO
            ENDIF
           ENDDO
          ENDDO
          iprt = MIN(20,sNx)
          jprt = MIN(20,sNy)
          print*,'QQ first guess pH', pH(iprt,jprt,bi,bj),
     &        theta(iprt,jprt,1,bi,bj), salt(iprt,jprt,1,bi,bj),
     &        surfdic(iprt,jprt), surfphos(iprt,jprt),
     &        surfsi(iprt,jprt),surfalk(iprt,jprt)

        ENDIF

C     end bi,bj loops
       ENDDO
      ENDDO

      RETURN
      END
#endif  /*ALLOW_CARBON*/

#endif  /*DARWIN*/
#endif  /*ALLOW_PTRACERS*/
c ==================================================================
