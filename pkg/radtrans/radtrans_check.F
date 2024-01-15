#include "RADTRANS_OPTIONS.h"
#include "EXF_OPTIONS.h"

CBOP
C !ROUTINE: RADTRANS_CHECK

C !INTERFACE: ==========================================================
      SUBROUTINE RADTRANS_CHECK( myThid )

C !DESCRIPTION:
C     Check radtrans parameters,

C !USES: ===============================================================
      IMPLICIT NONE
#include "EEPARAMS.h"
#include "SIZE.h"
#ifdef ALLOW_EXF
#include "EXF_PARAM.h"
#include "EXF_INTERP_SIZE.h"
#include "EXF_INTERP_PARAM.h"
#endif
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"
#include "RADTRANS_EXF_PARAMS.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid

C !OUTPUT PARAMETERS: ==================================================
C  none
CEOP

#ifdef ALLOW_RADTRANS

C !LOCAL VARIABLES: ====================================================
      integer oUnit, l, errCount
      CHARACTER*(MAX_LEN_MBUF) msgBuf

      _BEGIN_MASTER(myThid)

C ======================================================================
C     write waveband detail to standard output

      WRITE(msgBuf,'(A)') 'RADTRANS_CHECK:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      WRITE(msgBuf,'(A)') 'RADTRANS_CHECK: wavebands:'
      CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                   SQUEEZE_RIGHT,myThid)
      WRITE(msgBuf,'(2A)') 'RADTRANS_CHECK: ',
     &   ' idx       low   rep      high    width'
      CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                   SQUEEZE_RIGHT,myThid)
      DO l=1,nlam
        WRITE(msgBuf,'(A,I4,F10.3,F6.0,F10.3,F9.3)')
     &  'RADTRANS_CHECK: ', l, RT_wbEdges(l),
     &  RT_wbRefWLs(l),RT_wbEdges(l+1),RT_wbWidths(l)
        CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                   SQUEEZE_RIGHT,myThid)
      ENDDO
      WRITE(msgBuf,'(A)') 'RADTRANS_CHECK:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )

      WRITE(msgBuf,'(A)') ' ==================================='
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )

C ----------------------------------------------------------------------
C     and to separate text file
      IF ( myProcId.EQ.0 .AND. myThid.EQ.1 ) THEN
        CALL MDSFINDUNIT( oUnit, myThid )
        OPEN(oUnit,file='pwaves-check.dat',status='unknown')
        WRITE(oUnit,'(F6.0)')RT_wbRefWLs
        CLOSE(oUnit)
      ENDIF

C ======================================================================
C     check for errors in configuration

C ----------------------------------------------------------------------
C     need sun package unless using mean cos(solz)
#ifndef ALLOW_SUN
      IF (.NOT.RT_useMeanCosSolz) THEN
        WRITE(msgBuf,'(2A)') 'RADTRANS_CALC: need to compile the sun ',
     &   'package unless RT_useMeanCosSolz is used.'
        CALL PRINT_ERROR( msgBuf, myThid )
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R RADTRANS_CHECK'
      ENDIF
#endif

      IF (RT_useNoonSolz.AND.RT_useMeanCosSolz)THEN
        WRITE(msgBuf,'(2A)') '** WARNING ** RADTRANS_CHECK: ',
     &       'Only one of RT_useMeanCosSolz, RT_useNoonSolz can be set'
        CALL PRINT_ERROR( msgBuf, myThid )
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R RADTRANS_CHECK'
      ENDIF

C ----------------------------------------------------------------------
C     check for unsupported forcing configurations
      errCount = 0
      IF ( useExfYearlyFields ) THEN
       IF ( RT_E_RepCycle.NE.0. ) THEN
        WRITE(msgBuf,'(2A)') 'RADTRANS_CHECK: The use of ',
     &       'useExfYearlyFields AND RT_E_RepCycle is not implemented'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
       IF ( RT_iceRepCycle.NE.0. ) THEN
        WRITE(msgBuf,'(2A)') 'RADTRANS_CHECK: The use of ',
     &       'useExfYearlyFields AND RT_iceRepCycle is not implemented'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF
      IF ( errCount.GE.1 ) THEN
        WRITE(msgBuf,'(A,I3,A)')
     &     'RADTRANS_CHECK: detected', errCount,' fatal error(s)'
        CALL PRINT_ERROR( msgBuf, myThid )
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R RADTRANS_CHECK'
      ENDIF

C ----------------------------------------------------------------------
      _END_MASTER(myThid)

C Everyone else must wait for the parameters to be loaded
      _BARRIER

#endif /* ALLOW_RADTRANS */

      RETURN
      END
