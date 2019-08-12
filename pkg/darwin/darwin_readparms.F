#include "EXF_OPTIONS.h"
#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_READPARMS

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_READPARMS( myThid )

C !DESCRIPTION:
C     Initialize DARWIN parameters, read in data.darwin

C !USES: ===============================================================
      IMPLICIT NONE
#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"
#include "EXF_INTERP_SIZE.h"
#ifdef ALLOW_RADTRANS
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"
#endif
#include "DARWIN_SIZE.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_EXF_PARAMS.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid

C !OUTPUT PARAMETERS: ==================================================
C  none
CEOP

#ifdef ALLOW_DARWIN

C !LOCAL VARIABLES: ====================================================
C  iUnit   :: unit number for reading
C  oUnit   :: unit number for writing
C  msgBuf  :: message buffer
      integer iUnit, oUnit
      CHARACTER*(MAX_LEN_MBUF) msgBuf

      _BEGIN_MASTER(myThid)

C Open and read the data.darwin file

      WRITE(msgBuf,'(A)') ' DARWIN_READPARMS: opening data.darwin'
      CALL PRINT_MESSAGE(msgBuf, standardMessageUnit,
     &                   SQUEEZE_RIGHT , 1)

      CALL OPEN_COPY_DATA_FILE(
     I                   'data.darwin', 'DARWIN_READPARMS',
     O                   iUnit,
     I                   myThid )

      IF ( myProcId.EQ.0 .AND. myThid.EQ.1 ) THEN
        CALL MDSFINDUNIT( oUnit, mythid )
        open(oUnit,file='darwin_params.txt',status='unknown')
      ELSE
        oUnit = -1
      ENDIF

      CALL DARWIN_EXF_READPARMS(iUnit, oUnit, myThid)
      CALL DARWIN_READ_PARAMS(iUnit, oUnit, myThid)
      CALL DARWIN_READ_TRAITPARAMS(iUnit, oUnit, myThid)

      IF ( oUnit .GE. 0 ) THEN
        CLOSE(oUnit)
      ENDIF

#ifdef SINGLE_DISK_IO
      CLOSE(iUnit)
#else
      CLOSE(iUnit,STATUS='DELETE')
#endif /* SINGLE_DISK_IO */

C ======================================================================
C     compute dependent parameters
      darwin_loadFieldsEarly = darwin_chlInitBalanced .AND.
     &                         nIter0 .EQ. darwin_chlIter0
#ifdef ALLOW_RADTRANS
      RT_loadFieldsEarly=RT_loadFieldsEarly .OR. darwin_loadFieldsEarly
#endif

      WRITE(msgBuf,'(A)') ' ==================================='
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )

      _END_MASTER(myThid)

C Everyone else must wait for the parameters to be loaded
      _BARRIER

#endif /* ALLOW_DARWIN */

      RETURN
      END

