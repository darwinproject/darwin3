#include "DARWIN_OPTIONS.h"
#include "EXF_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: DARWIN_INIT_VARIA

C     !INTERFACE:
      SUBROUTINE DARWIN_INIT_VARIA( myThid )

C     !DESCRIPTION:
C     Initialize DARWIN constants

C     !USES:
      IMPLICIT NONE
#include "EEPARAMS.h"
#include "SIZE.h"
#include "GRID.h"
#include "PARAMS.h"
#include "EXF_FIELDS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PTRACERS_FIELDS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"
#include "DARWIN_EXF_FIELDS.h"
#include "DARWIN_FIELDS.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

#ifdef ALLOW_DARWIN
C     !LOCAL VARIABLES:
      _RL dTsub(Nr)
      INTEGER i,j,k,l,bi,bj,jp
      CHARACTER*(MAX_LEN_FNAM) fnam

      CALL DARWIN_EXF_INIT_VARIA(myThid)

      IF (DARWIN_useEXFwind) THEN
       DO bj=myByLo(mythid),myByHi(myThid)
        DO bi=myBxLo(mythid),myBxHi(myThid)
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
           windSpeed(i,j,bi,bj) = wspeed(i,j,bi,bj)
          ENDDO
         ENDDO
        ENDDO
       ENDDO
      ENDIF

#ifdef DARWIN_ALLOW_CARBON
      DO bj=myByLo(mythid),myByHi(myThid)
       DO bi=myBxLo(mythid),myBxHi(myThid)
        DO j=1-OLy,sNy+OLy
         DO i=1-OLx,sNx+OLx
          AtmosP(i,j,bi,bj) = 1.0 _d 0
         ENDDO
        ENDDO
       ENDDO
      ENDDO
#endif

#ifndef DARWIN_ALLOW_CHLQUOTA
      chlPrev = 0.0 _d 0
#endif

      IF (nIter0.EQ.PTRACERS_Iter0) THEN
       DO bj=myByLo(mythid),myByHi(myThid)
       DO bi=myBxLo(mythid),myBxHi(myThid)
        DO jp=1,nplank
        IF (diazo(jp) .EQ. 1) THEN
         DO k=1,Nr
         DO j=1-OLy,sNy+OLy
         DO i=1-OLx,sNx+OLx
          Ptracer(i,j,k,bi,bj,ic+jp-1)=Ptracer(i,j,k,bi,bj,ic+jp-1)*
     &                                 diaz_ini_fac
#ifdef DARWIN_ALLOW_NQUOTA
          Ptracer(i,j,k,bi,bj,in+jp-1)=Ptracer(i,j,k,bi,bj,in+jp-1)*
     &                                 diaz_ini_fac
#endif
#ifdef DARWIN_ALLOW_PQUOTA
          Ptracer(i,j,k,bi,bj,ip+jp-1)=Ptracer(i,j,k,bi,bj,ip+jp-1)*
     &                                 diaz_ini_fac
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
          Ptracer(i,j,k,bi,bj,ife+jp-1)=Ptracer(i,j,k,bi,bj,ife+jp-1)*
     &                                  diaz_ini_fac
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
          Ptracer(i,j,k,bi,bj,isi+jp-1)=Ptracer(i,j,k,bi,bj,isi+jp-1)*
     &                                  diaz_ini_fac
#endif
         ENDDO
         ENDDO
         ENDDO
        ENDIF
        ENDDO
       ENDDO
       ENDDO
#ifdef DARWIN_ALLOW_CHLQUOTA
       DO bj=myByLo(mythid),myByHi(myThid)
       DO bi=myBxLo(mythid),myBxHi(myThid)
        DO jp=1,nPhoto
        IF (diazo(jp) .EQ. 1) THEN
         DO k=1,Nr
         DO j=1-OLy,sNy+OLy
         DO i=1-OLx,sNx+OLx
          Ptracer(i,j,k,bi,bj,ichl+jp-1)=Ptracer(i,j,k,bi,bj,ichl+jp-1)*
     &                                   diaz_ini_fac
         ENDDO
         ENDDO
         ENDDO
        ENDIF
        ENDDO
       ENDDO
       ENDDO
#endif
      ENDIF

      IF (darwin_read_phos .AND. nIter0.EQ.PTRACERS_Iter0) THEN
       DO jp=1,nplank
        DO bj=myByLo(mythid),myByHi(myThid)
        DO bi=myBxLo(mythid),myBxHi(myThid)
        DO k=1,Nr
        DO j=1-OLy,sNy+OLy
        DO i=1-OLx,sNx+OLx
         Ptracer(i,j,k,bi,bj,ic+jp-1) = Ptracer(i,j,k,bi,bj,ic+jp-1)*
     &                                  120 _d 0
        ENDDO
        ENDDO
        ENDDO
        ENDDO
        ENDDO
       ENDDO
      ENDIF
 
      IF ( nIter0.GT.PTRACERS_Iter0 .OR.
     &    (nIter0.EQ.PTRACERS_Iter0 .AND. darwin_pickupSuff.NE.' ')
     &   ) THEN
       CALL DARWIN_READ_PICKUP(nIter0, myThid)
      ENDIF

#ifdef DARWIN_ALLOW_CARBON
      CALL DARWIN_SURFFORCING_INIT( myThid )
#endif

      IF (nIter0 .EQ. darwin_chlIter0) THEN
C      Initialize Chl from balanced-growth Chl:C if requested
C      and check Chl:C bounds.
C      use current time for insol
       DO bj=myByLo(mythid),myByHi(myThid)
       DO bi=myBxLo(mythid),myBxHi(myThid)
        CALL DARWIN_INIT_CHL(bi, bj, startTime, nIter0, myThid)
       ENDDO
       ENDDO

C      exchange (needed with OASIM)
#ifdef DARWIN_ALLOW_CHLQUOTA
       DO jp=1,nPhoto
       _EXCH_XYZ_RL(pTracer(1-OLx,1-OLy,1,1,1,iChl+jp-1),myThid)
       ENDDO
#else
# ifdef ALLOW_RADTRANS
       DO jp=1,nPhoto
        _EXCH_XYZ_RL(chlPrev(1-OLx,1-OLy,1,1,1,jp),myThid)
       ENDDO
# else
       _EXCH_XYZ_RL(chlPrev,myThid)
# endif
#endif
      ENDIF

#ifdef DARWIN_ALLOW_CONS
      IF ( myProcId.EQ.0 .AND. myThid.EQ.1 ) THEN
       WRITE(fnam,'(A,I10.10,A)') 'darwin_cons_C.',nIter0,'.txt'
       CALL MDSFINDUNIT( DAR_cons_c_unit, mythid )
       OPEN(DAR_cons_C_unit,file=fnam,status='unknown')
       WRITE(fnam,'(A,I10.10,A)') 'darwin_cons_N.',nIter0,'.txt'
       CALL MDSFINDUNIT( DAR_cons_n_unit, mythid )
       OPEN(DAR_cons_N_unit,file=fnam,status='unknown')
       WRITE(fnam,'(A,I10.10,A)') 'darwin_cons_P.',nIter0,'.txt'
       CALL MDSFINDUNIT( DAR_cons_p_unit, mythid )
       OPEN(DAR_cons_P_unit,file=fnam,status='unknown')
       WRITE(fnam,'(A,I10.10,A)') 'darwin_cons_Fe.',nIter0,'.txt'
       CALL MDSFINDUNIT( DAR_cons_fe_unit, mythid )
       OPEN(DAR_cons_Fe_unit,file=fnam,status='unknown')
       WRITE(fnam,'(A,I10.10,A)') 'darwin_cons_Si.',nIter0,'.txt'
       CALL MDSFINDUNIT( DAR_cons_si_unit, mythid )
       OPEN(DAR_cons_Si_unit,file=fnam,status='unknown')
#ifdef DARWIN_ALLOW_CARBON
       WRITE(fnam,'(A,I10.10,A)') 'darwin_cons_A.',nIter0,'.txt'
       CALL MDSFINDUNIT( DAR_cons_a_unit, mythid )
       OPEN(DAR_cons_A_unit,file=fnam,status='unknown')
       WRITE(fnam,'(A,I10.10,A)') 'darwin_cons_O.',nIter0,'.txt'
       CALL MDSFINDUNIT( DAR_cons_o_unit, mythid )
       OPEN(DAR_cons_O_unit,file=fnam,status='unknown')
#endif
c     myProcId and myThid
      ENDIF
#endif

#endif /* ALLOW_DARWIN */

      RETURN
      END

