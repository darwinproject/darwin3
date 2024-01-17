#include "OASIM_OPTIONS.h"

CBOP
C !ROUTINE: OASIM_MONITOR

C !INTERFACE: ==========================================================
      SUBROUTINE OASIM_MONITOR(
     I                    myTime, myIter, myThid )

C !DESCRIPTION:
C writes out oasim statistics

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "OASIM_SIZE.h"
#include "OASIM_PARAMS.h"
#include "OASIM_FIELDS.h"
#ifdef ALLOW_MONITOR
#include "MONITOR.h"
#endif

C !INPUT PARAMETERS: ===================================================
C  myTime               :: current time
C  myIter               :: current timestep
C  myThid               :: thread number
      _RL     myTime
      INTEGER myIter
      INTEGER myThid

C     === Functions ====
      LOGICAL  DIFFERENT_MULTIPLE
      EXTERNAL DIFFERENT_MULTIPLE
      LOGICAL  MASTER_CPU_IO
      EXTERNAL MASTER_CPU_IO

#ifdef ALLOW_OASIM
#ifdef ALLOW_MONITOR

C !LOCAL VARIABLES: ====================================================
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      CHARACTER*(MAX_LEN_MBUF) suff
      INTEGER l,i,j,bi,bj
      _RL dummyRL(6)
      _RS onearr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
CEOP

      IF ( DIFFERENT_MULTIPLE( oasim_monitorFreq,myTime,deltaTClock )
     &   ) THEN

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

C--   OASIM field monitor start
       IF ( MASTER_CPU_IO(myThid) ) THEN
C--   only the master thread is allowed to switch On/Off mon_write_stdout
C     & mon_write_mnc (since it is the only thread that uses those flags):

          IF (monitor_stdio) THEN
            mon_write_stdout = .TRUE.
          ELSE
            mon_write_stdout = .FALSE.
          ENDIF
          mon_write_mnc    = .FALSE.

          IF ( mon_write_stdout ) THEN
            WRITE(msgBuf,'(2A)') '// ==========================',
     &             '============================='
            CALL PRINT_MESSAGE( msgBuf, mon_ioUnit, SQUEEZE_RIGHT , 1)
            WRITE(msgBuf,'(A)')
     &             '// Begin MONITOR oasim field statistics'
            CALL PRINT_MESSAGE( msgBuf, mon_ioUnit, SQUEEZE_RIGHT , 1)
            WRITE(msgBuf,'(2A)') '// ==========================',
     &             '============================='
            CALL PRINT_MESSAGE( msgBuf, mon_ioUnit, SQUEEZE_RIGHT , 1)
          ENDIF

C--   endif master cpu io
       ENDIF

       DO bj=myByLo(myThid),myByHi(myThid)
        DO bi=myBxLo(myThid),myBxHi(myThid)
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
           onearr(i,j,bi,bj) = oneRS
          ENDDO
         ENDDO
        ENDDO
       ENDDO

C--   OASIM field monitor : compute stats & write
       IF ( OASIM_monitorFreq .NE. monitorFreq ) THEN
C      repeat printing of time to make grepping easier, default is not
C      to do this, because the default is to use the same monitorFreq
C      for oasim as for the dynamics variables.
         CALL MON_SET_PREF('oasim',myThid)
         CALL MON_OUT_I( '_tsnumber', myIter,mon_string_none,myThid)
         CALL MON_OUT_RL('_secondsf', myTime,mon_string_none,myThid)
       ENDIF
       CALL MON_SET_PREF('OASIM_',myThid)
C      Print some statistics about input forcing fields

       CALL MON_WRITESTATS_RL( 1, ccov, 'ccov',
     &           onearr, onearr, rA , drF, dummyRL, myThid )

       CALL MON_WRITESTATS_RL( 1, rlwp, 'rlwp',
     &           onearr, onearr, rA , drF, dummyRL, myThid )

       CALL MON_WRITESTATS_RL( 1, cdre, 'cdre',
     &           onearr, onearr, rA , drF, dummyRL, myThid )

       CALL MON_WRITESTATS_RL( 1, slp, 'slp',
     &           onearr, onearr, rA , drF, dummyRL, myThid )

       CALL MON_WRITESTATS_RL( 1, wsm, 'wsm',
     &           onearr, onearr, rA , drF, dummyRL, myThid )

       CALL MON_WRITESTATS_RL( 1, rh, 'rh',
     &           onearr, onearr, rA , drF, dummyRL, myThid )

       CALL MON_WRITESTATS_RL( 1, oz, 'oz',
     &           onearr, onearr, rA , drF, dummyRL, myThid )

       CALL MON_WRITESTATS_RL( 1, wv, 'wv',
     &           onearr, onearr, rA , drF, dummyRL, myThid )

       DO l = 1, nlt
         WRITE(suff,'(A7,I3.3)') 'taua',l
         CALL MON_WRITESTATS_RL(
     &            1, taua(1-OLx,1-OLy,1,1,l), suff,
     &            onearr, onearr, rA ,drF, dummyRL, myThid )
       ENDDO
C
       DO l = 1, nlt
         WRITE(suff,'(A7,I3.3)') 'asymp',l
         CALL MON_WRITESTATS_RL(
     &            1, asymp(1-OLx,1-OLy,1,1,l), suff,
     &            onearr, onearr, rA ,drF, dummyRL, myThid )
       ENDDO
C
       DO l = 1, nlt
         WRITE(suff,'(A7,I3.3)') 'ssalb',l
         CALL MON_WRITESTATS_RL(
     &            1, ssalb(1-OLx,1-OLy,1,1,l), suff,
     &            onearr, onearr, rA ,drF, dummyRL, myThid )
       ENDDO
C
C      Print the basic statistics of oasim variables
       DO l = 1, nlt
         WRITE(suff,'(A7,I2.2)') 'Edabove',l
         CALL MON_WRITESTATS_RL(
     &            1, OASIM_Edabove(1-OLx,1-OLy,1,1,l), suff,
     &            onearr, onearr, rA ,drF, dummyRL, myThid )
       ENDDO
C
       DO l = 1, nlt
         WRITE(suff,'(A7,I2.2)') 'Esabove',l
         CALL MON_WRITESTATS_RL(
     &            1, OASIM_Esabove(1-OLx,1-OLy,1,1,l), suff,
     &            onearr, onearr, rA ,drF, dummyRL, myThid )
       ENDDO
C
       DO l = 1, nlt
         WRITE(suff,'(A7,I2.2)') 'Edbelow',l
         CALL MON_WRITESTATS_RL(
     &            1, OASIM_Edbelow(1-OLx,1-OLy,1,1,l), suff,
     &            maskInC, maskInC, rA ,drF, dummyRL, myThid )
       ENDDO
C
       DO l = 1, nlt
         WRITE(suff,'(A7,I2.2)') 'Esbelow',l
         CALL MON_WRITESTATS_RL(
     &            1, OASIM_Esbelow(1-OLx,1-OLy,1,1,l), suff,
     &            maskInC, maskInC, rA ,drF, dummyRL, myThid )
       ENDDO
C
       CALL MON_WRITESTATS_RL(
     &            1, OASIM_solz(1-OLx,1-OLy,1,1), 'solz',
     &            onearr, onearr, rA ,drF, dummyRL, myThid )
C
       CALL MON_WRITESTATS_RL(
     &            1, OASIM_rmud(1-OLx,1-OLy,1,1), 'rmud',
     &            maskInC, maskInC, rA ,drF, dummyRL, myThid )

C--   OASIM field monitor finish
       IF ( MASTER_CPU_IO(myThid) ) THEN
C-    only the master thread is allowed to switch On/Off mon_write_stdout
C     & mon_write_mnc (since it is the only thread that uses those flags):

        IF ( mon_write_stdout ) THEN
         WRITE(msgBuf,'(2A)') '// ==========================',
     &        '============================='
         CALL PRINT_MESSAGE( msgBuf, mon_ioUnit, SQUEEZE_RIGHT , 1)
         WRITE(msgBuf,'(A)')
     &        '// End MONITOR OASIM field statistics'
         CALL PRINT_MESSAGE( msgBuf, mon_ioUnit, SQUEEZE_RIGHT , 1)
         WRITE(msgBuf,'(2A)') '// ==========================',
     &        '============================='
         CALL PRINT_MESSAGE( msgBuf, mon_ioUnit, SQUEEZE_RIGHT , 1)
        ENDIF

        mon_write_stdout = .FALSE.
        mon_write_mnc    = .FALSE.

C-    endif master cpu io
       ENDIF

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

C---  endif different multiple
      ENDIF

#endif /* ALLOW_MONITOR */
#endif /* ALLOW_OASIM */

      RETURN
      END
