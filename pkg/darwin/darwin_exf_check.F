#include "DARWIN_OPTIONS.h"
#include "EXF_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: DARWIN_EXF_CHECK( myThid )
C     !INTERFACE:

      SUBROUTINE DARWIN_EXF_CHECK( myThid )

C     !USES:
      IMPLICIT NONE

C     === Global variables ===
#include "EEPARAMS.h"
#include "SIZE.h"
#include "EXF_PARAM.h"
#include "EXF_CONSTANTS.h"
#include "EXF_INTERP_SIZE.h"
#include "EXF_INTERP_PARAM.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_EXF_PARAMS.h"
#include "DARWIN_EXF_FIELDS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid  :: My thread Id number
      INTEGER myThid

C     !LOCAL VARIABLES:
      INTEGER errCount
      CHARACTER*(MAX_LEN_MBUF) msgBuf
CEOP

      _BEGIN_MASTER( myThid )

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

      errCount = 0

#ifdef USE_EXF_INTERPOLATION

      IF ( PARfile.NE.' ' ) THEN
       IF ( PAR_interpMethod .GT. 0 .AND.
     &      PAR_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'PAR_interpMethod ', PAR_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( ironfile.NE.' ' ) THEN
       IF ( iron_interpMethod .GT. 0 .AND.
     &      iron_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'iron_interpMethod ', iron_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( icefile.NE.' ' ) THEN
       IF ( ice_interpMethod .GT. 0 .AND.
     &      ice_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'ice_interpMethod ', ice_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( windfile.NE.' ' ) THEN
       IF ( wind_interpMethod .GT. 0 .AND.
     &      wind_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'wind_interpMethod ', wind_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( pCO2file.NE.' ' ) THEN
       IF ( pCO2_interpMethod .GT. 0 .AND.
     &      pCO2_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'pCO2_interpMethod ', pCO2_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( ventHe3file.NE.' ' ) THEN
       IF ( ventHe3_interpMethod .GT. 0 .AND.
     &      ventHe3_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'ventHe3_interpMethod ', ventHe3_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( DOCrunofffile.NE.' ' ) THEN
       IF ( DOCrunoff_interpMethod .GT. 0 .AND.
     &      DOCrunoff_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'DOCrunoff_interpMethod ', DOCrunoff_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( DONrunofffile.NE.' ' ) THEN
       IF ( DONrunoff_interpMethod .GT. 0 .AND.
     &      DONrunoff_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'DONrunoff_interpMethod ', DONrunoff_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( DOPrunofffile.NE.' ' ) THEN
       IF ( DOPrunoff_interpMethod .GT. 0 .AND.
     &      DOPrunoff_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'DOPrunoff_interpMethod ', DOPrunoff_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( DINrunofffile.NE.' ' ) THEN
       IF ( DINrunoff_interpMethod .GT. 0 .AND.
     &      DINrunoff_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'DINrunoff_interpMethod ', DINrunoff_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( NO3runofffile.NE.' ' ) THEN
       IF ( NO3runoff_interpMethod .GT. 0 .AND.
     &      NO3runoff_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'NO3runoff_interpMethod ', NO3runoff_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( NO2runofffile.NE.' ' ) THEN
       IF ( NO2runoff_interpMethod .GT. 0 .AND.
     &      NO2runoff_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'NO2runoff_interpMethod ', NO2runoff_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( NH4runofffile.NE.' ' ) THEN
       IF ( NH4runoff_interpMethod .GT. 0 .AND.
     &      NH4runoff_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'NH4runoff_interpMethod ', NH4runoff_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( IPrunofffile.NE.' ' ) THEN
       IF ( IPrunoff_interpMethod .GT. 0 .AND.
     &      IPrunoff_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'IPrunoff_interpMethod ', IPrunoff_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( DSirunofffile.NE.' ' ) THEN
       IF ( DSirunoff_interpMethod .GT. 0 .AND.
     &      DSirunoff_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'DSirunoff_interpMethod ', DSirunoff_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( POCrunofffile.NE.' ' ) THEN
       IF ( POCrunoff_interpMethod .GT. 0 .AND.
     &      POCrunoff_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'POCrunoff_interpMethod ', POCrunoff_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( POPrunofffile.NE.' ' ) THEN
       IF ( POPrunoff_interpMethod .GT. 0 .AND.
     &      POPrunoff_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'POPrunoff_interpMethod ', POPrunoff_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( PONrunofffile.NE.' ' ) THEN
       IF ( PONrunoff_interpMethod .GT. 0 .AND.
     &      PONrunoff_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'PONrunoff_interpMethod ', PONrunoff_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

      IF ( DICrunofffile.NE.' ' ) THEN
       IF ( DICrunoff_interpMethod .GT. 0 .AND.
     &      DICrunoff_lat0 .EQ. halfRL*UNSET_RL ) THEN
        WRITE(msgBuf,'(2A,I2,A)') 'DARWIN_EXF_CHECK: ',
     &   'DICrunoff_interpMethod ', DICrunoff_interpMethod,
     &   ' requires input grid params.'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF

#endif /* USE_EXF_INTERPOLATION */

      IF ( errCount.GE.1 ) THEN
       WRITE(msgBuf,'(A,I3,A)')
     &     'DARWIN_EXF_CHECK: detected', errCount,' fatal error(s)'
       CALL PRINT_ERROR( msgBuf, myThid )
       CALL ALL_PROC_DIE( 0 )
       STOP 'ABNORMAL END: S/R DARWIN_EXF_CHECK'
      ENDIF

      _END_MASTER( myThid )
      _BARRIER

      RETURN
      END
