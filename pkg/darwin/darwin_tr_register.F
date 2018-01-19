C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_tr_register.F,v 1.1 2018/01/19 22:15:20 jahn Exp $
C $Name:  $

#include "DARWIN_OPTIONS.h"

CBOP
C     !ROUTINE: DARWIN_TR_REGISTER
C     !INTERFACE:
      SUBROUTINE DARWIN_TR_REGISTER(
     U                            tracer_num, sepFTr_num,
     I                            myThid )

C     !DESCRIPTION:
C     *==========================================================*
C     | SUBROUTINE DARWIN_TR_REGISTER
C     | o Register DARWIN tracer indices
C     *==========================================================*

C     !USES:
      IMPLICIT NONE

C     == GLobal variables ==
#include "EEPARAMS.h"
#include "DARWIN_SIZE.h"

C     !INPUT/OUTPUT PARAMETERS:
C     tracer_num :: current number of registered tracers
C     sepFTr_num :: number of registered tracers that use Separate Forcing
C     myThid     :: my Thread Id number
      INTEGER tracer_num
      INTEGER sepFTr_num
      INTEGER myThid

C     !LOCAL VARIABLES:
C     msgBuf     :: message buffer
      CHARACTER*(MAX_LEN_MBUF) msgBuf
CEOP

      WRITE(msgBuf,'(2A,2I5)') '  DARWIN_TR_REGISTER: ',
     &     ' number of DARWIN tracers=', nDarwin
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(2A,2I5)') '  DARWIN_TR_REGISTER: ',
     &     '  starting at pTrc num=', tracer_num + 1
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )

      tracer_num = tracer_num + nDarwin
      sepFTr_num = sepFTr_num + nDarwin

      WRITE(msgBuf,'(2A,2I5)') '  DARWIN_TR_REGISTER: ',
     &     ' Numb. Trac & SepForc Trac:', tracer_num, sepFTr_num
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )

      RETURN
      END
