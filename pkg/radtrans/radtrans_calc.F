#include "RADTRANS_OPTIONS.h"
#ifdef ALLOW_SEAICE
#include "SEAICE_OPTIONS.h"
#endif

CBOP
C !ROUTINE: RADTRANS_CALC
C !INTERFACE: ==========================================================
      SUBROUTINE RADTRANS_CALC(
     I                         a, bt, bb,
     O                         E0F,
     I                         bi, bj, iMin, iMax, jMin, jMax,
     I                         myTime, myIter, myThid )

C !DESCRIPTION:

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "GRID.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"
#include "RADTRANS_FIELDS.h"
#ifdef ALLOW_SEAICE
#include "SEAICE_SIZE.h"
#include "SEAICE.h"
#endif

C !INPUT PARAMETERS: ===================================================
C  myTime :: time at end of (sub)timestep
C  myThid :: thread number
      _RL a(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL bt(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL bb(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL myTime
      INTEGER bi, bj, iMin, iMax, jMin, jMax, myIter, myThid

C !OUTPUT PARAMETERS: =================================================
C  E0F :: spectral scalar irradiance at top of grid cell
      _RL E0F(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr+1, nlam)
CEOP

#ifdef ALLOW_RADTRANS

C!LOCAL VARIABLES: ====================================================
C  i,j                  :: loop indices
C  k                    :: vertical level
      LOGICAL  DIAGNOSTICS_IS_ON
      EXTERNAL DIAGNOSTICS_IS_ON
      CHARACTER*8 diagname
      INTEGER i,j,k,l,jp,klow
      INTEGER iyr,imon,iday,isec,lp,wd,mydate(4)
      _RL rad2deg
      _RL delta
      _RL solz(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
      _RL rmud(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
      _RL dz_k(Nr)
      _RL a_k(Nr)
      _RL bt_k(Nr)
      _RL bb_k(Nr)
      _RL Edwsf,Eswsf,Edown
      _RL Edbot(Nr),Esbot(Nr),Eubot(Nr)
      _RL Estop(Nr),Eutop(Nr)
      _RL amp1_k(Nr), amp2_k(Nr)
      _RL x_k(Nr), y_k(Nr)
      _RL r1_k(Nr), r2_k(Nr)
      _RL kappa1_k(Nr), kappa2_k(Nr)

      _RL Ed(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL Es(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL Eu(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL Ef(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)

#ifdef ALLOW_DIAGNOSTICS
      _RL Rirr(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, nlam)
#ifdef RADTRANS_DIAG_SOLUTION
      _RL Est(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL Eub(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL amp1(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL amp2(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL x3d(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL y3d(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL r1(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL r2(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL kap1(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL kap2(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
#endif
#endif

      rad2deg = 180 _d 0 / PI

C ======================================================================

#ifdef ALLOW_SEAICE
      IF (RT_useSEAICE) THEN
       DO j=jMin,jMax
        DO i=iMin,iMax
         RT_iceFrac(i,j,bi,bj) = AREA(i,j,bi,bj)
        ENDDO
       ENDDO
      ENDIF
#endif

C ======================================================================
C--   compute solar zenith angles

      IF (RT_useMeanCosSolz) THEN
C     from day-time average of cosine of zenith angle

        CALL RADTRANS_DECLINATION_SPENCER(delta, myTime, myIter, myThid)
        CALL RADTRANS_SOLZ_DAYTIME(solz, delta, bi, bj,
     &                             iMin, iMax, jMin, jMax, myThid)

      ELSE
C     compute zenith angle at local noon

#ifdef ALLOW_SUN
        isec = 12*3600
        CALL SUN_SFCSOLZ(
     O                    solz,
     I                    isec, bi, bj, iMin, iMax, jMin, jMax,
     I                    myTime, myIter, myThid )
#endif

      ENDIF

c     compute 1/cos(zenith) for direct light below surface
      CALL RADTRANS_RMUD_BELOW(rmud,solz,iMin,iMax,jMin,jMax,myThid)

C ======================================================================
      DO j=jMin,jMax
       DO i=iMin,iMax
C ----------------------------------------------------------------------
        DO k=1,Nr
         dz_k(k) = drF(k)*HFacC(i,j,k,bi,bj)
        ENDDO

        klow = MIN(RT_kmax, kLowC(i,j,bi,bj))

        DO l = 1,nlam

C use read-in light
          Edwsf = RT_Ed_sfc(i,j,bi,bj,l)
          Eswsf = RT_Es_sfc(i,j,bi,bj,l)

          IF (myiter .ge. 0) THEN
           Edwsf = Edwsf*(1.0 _d 0 - RT_iceFrac(i,j,bi,bj))
           Eswsf = Eswsf*(1.0 _d 0 - RT_iceFrac(i,j,bi,bj))
          ENDIF

         DO k=1,Nr
          a_k(k) = a(i,j,k,l)
          bt_k(k) = bt(i,j,k,l)
          bb_k(k) = bb(i,j,k,l)
         ENDDO

         CALL RADTRANS_SOLVE(
     I                dz_k,rmud(i,j),Edwsf,Eswsf,a_k,bt_k,bb_k,klow,
     O                Edbot,Esbot,Eubot,Estop,Eutop,
     O                amp1_k,amp2_k, x_k, y_k,
     O                r1_k,r2_k,kappa1_k,kappa2_k,
     I                myThid)

         Ed(i,j,1,l) = Edwsf
         Es(i,j,1,l) = Eswsf
         DO k=1,Nr-1
          Ed(i,j,k+1,l) = Edbot(k)
          Es(i,j,k+1,l) = Esbot(k)
         ENDDO
         DO k=1,Nr
          Eu(i,j,k,l) = Eutop(k)
         ENDDO

         DO k=1,Nr
C convert to scalar irradiance in quanta
          E0F(i,j,k,l) = rmud(i,j)*Ed(i,j,k,l) + RT_rmus*Es(i,j,k,l)
     &                 + RT_rmuu*Eu(i,j,k,l)
         ENDDO
         E0F(i,j,Nr+1,l) = rmud(i,j)*Edbot(Nr) + RT_rmus*Esbot(Nr)
     &                   + RT_rmuu*Eubot(Nr)

#ifdef ALLOW_DIAGNOSTICS
         Edown = Edwsf + Eswsf
         IF (Edown.GT.0 _d 0)THEN
          Rirr(i,j,l) = Eutop(1)/Edown
         ELSE
          Rirr(i,j,l) = 0 _d 0
         ENDIF
#ifdef RADTRANS_DIAG_SOLUTION
         Eub(i,j,1,l) = 0.0 _d 0
#endif
         DO k=1,Nr-1
#ifdef RADTRANS_DIAG_SOLUTION
          Eub(i,j,k+1,l) = Eubot(k)
#endif
         ENDDO
         DO k=1,Nr
#ifdef RADTRANS_DIAG_SOLUTION
          Est(i,j,k,l) = Estop(k)
          amp1(i,j,k,l) = amp1_k(k)
          amp2(i,j,k,l) = amp2_k(k)
          x3d(i,j,k,l) = x_k(k)
          y3d(i,j,k,l) = y_k(k)
          r1(i,j,k,l) = r1_k(k)
          r2(i,j,k,l) = r2_k(k)
          kap1(i,j,k,l) = kappa1_k(k)
          kap2(i,j,k,l) = kappa2_k(k)
#endif
         ENDDO
#endif

C       l
        ENDDO

C      i,j
       ENDDO
      ENDDO
C ======================================================================

#ifdef ALLOW_DIAGNOSTICS
      IF (useDIAGNOSTICS .AND. myIter .GE.0) THEN
       CALL DIAGNOSTICS_FILL(rmud,'rmud    ',1,1,2,bi,bj,myThid)
       DO l=1,nlam
        WRITE(diagname, '(A,I3.3)') 'Rirr', l
        CALL DIAGNOSTICS_FILL(
     &             Rirr(1-OLx,1-OLy,l),diagname,0,1,2,bi,bj,myThid)
        WRITE(diagname, '(A,I3.3)') 'Ed', l
        CALL DIAGNOSTICS_FILL(
     &             Ed(1-OLx,1-OLy,1,l),diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I3.3)') 'Es', l
        CALL DIAGNOSTICS_FILL(
     &             Es(1-OLx,1-OLy,1,l),diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I3.3)') 'Eu', l
        CALL DIAGNOSTICS_FILL(
     &             Eu(1-OLx,1-OLy,1,l),diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I3.3)') 'E0F', l
        CALL DIAGNOSTICS_FILL(
     &             E0F(1-OLx,1-OLy,1,l),diagname,0,Nr,2,bi,bj,myThid)
#ifdef RADTRANS_DIAG_SOLUTION
        WRITE(diagname, '(A,I3.3)') 'Estop', l
        CALL DIAGNOSTICS_FILL(
     &             Est(1-OLx,1-OLy,1,l),diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I3.3)') 'Eubot', l
        CALL DIAGNOSTICS_FILL(
     &             Eub(1-OLx,1-OLy,1,l),diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I3.3)') 'amp1_', l
        CALL DIAGNOSTICS_FILL(
     &             amp1(1-OLx,1-OLy,1,l),diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I3.3)') 'amp2_', l
        CALL DIAGNOSTICS_FILL(
     &             amp2(1-OLx,1-OLy,1,l),diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I3.3)') 'x_', l
        CALL DIAGNOSTICS_FILL(
     &             x3d(1-OLx,1-OLy,1,l),diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I3.3)') 'y_', l
        CALL DIAGNOSTICS_FILL(
     &             y3d(1-OLx,1-OLy,1,l),diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I3.3)') 'r1_', l
        CALL DIAGNOSTICS_FILL(
     &             r1(1-OLx,1-OLy,1,l),diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I3.3)') 'r2_', l
        CALL DIAGNOSTICS_FILL(
     &             r2(1-OLx,1-OLy,1,l),diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I3.3)') 'att1_', l
        CALL DIAGNOSTICS_FILL(
     &             kap1(1-OLx,1-OLy,1,l),diagname,0,Nr,2,bi,bj,myThid)
        WRITE(diagname, '(A,I3.3)') 'att2_', l
        CALL DIAGNOSTICS_FILL(
     &             kap2(1-OLx,1-OLy,1,l),diagname,0,Nr,2,bi,bj,myThid)
#endif
       ENDDO
      ENDIF
#endif

#endif /* ALLOW_RADTRANS */

      RETURN
      END
