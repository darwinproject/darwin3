#include "RADTRANS_OPTIONS.h"

CBOP
C     !ROUTINE: RADTRANS_DIAGNOSTICS_INIT

C     !INTERFACE:
      SUBROUTINE RADTRANS_DIAGNOSTICS_INIT( myThid )

C     !DESCRIPTION:
C     Routine to initialize diagnostics for the radtrans package

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "RADTRANS_SIZE.h"

C     !INPUT PARAMETERS:
C     myThid :: Number of this instance of RADTRANS_DIAGNOSTICS_INIT
      INTEGER myThid
CEOP

#ifdef ALLOW_RADTRANS
#ifdef ALLOW_DIAGNOSTICS

C     !FUNCTIONS:
      INTEGER     ILNBLNK
      EXTERNAL    ILNBLNK
      CHARACTER*16 DIAGS_MK_UNITS
      EXTERNAL     DIAGS_MK_UNITS

C     !LOCAL VARIABLES:
C     msgBuf :: Informational/error meesage buffer
c     CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER j
      INTEGER        diagNum
      CHARACTER*8    diagName
      CHARACTER*16   diagCode
      CHARACTER*16   diagUnits
      CHARACTER*(80) diagTitle
      INTEGER      ilnb
      CHARACTER*7  trcUnits
      CHARACTER*30 locName
      CHARACTER*4  diagSufx

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

      WRITE(diagName,'(A)')'rmud'
      WRITE(diagTitle,'(A)')'inverse cosine of solar zenith angle'
      diagUnits = '1               '
      diagCode  = 'SM P    L1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I           diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      DO j = 1, nlam
        WRITE(diagName,'(A,I3.3)')'Rirr', j
        WRITE(diagTitle,'(A, I3)')
     &        'irradiance reflectance for waveband ', j
        diagUnits = '1               '
        diagCode  = 'SM P    L1      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I           diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A,I3.3)')'Ed',j
        WRITE(diagTitle,'(A,I3)')'direct irradiance for waveband ',j
        diagUnits = 'W/m^2           '
        diagCode  = 'SMRP    LR      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A,I3.3)')'Es',j
        WRITE(diagTitle,'(A,I3)')
     &        'diffuse downwelling irradiance for waveband ',j
        diagUnits = 'W/m^2           '
        diagCode  = 'SMRP    LR      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A,I3.3)')'Eu',j
        WRITE(diagTitle,'(A,I3)')
     &        'diffuse upwelling irradiance for waveband ',j
        diagUnits = 'W/m^2           '
        diagCode  = 'SMRP    LR      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A,I3.3)')'E',j
        WRITE(diagTitle,'(A,I3)')'vector irradiance waveband ',j
        diagUnits = 'W/m^2           '
        diagCode  = 'SMRP    MR      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A,I3.3)')'E0F',j
        WRITE(diagTitle,'(A,I3)')
     &        'scalar irradiance at W point waveband ',j
        diagUnits = 'W/m^2           '
        diagCode  = 'SMRP    LR      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

#ifdef RADTRANS_DIAG_SOLUTION
        WRITE(diagName,'(A,I3.3)')'Estop',j
        WRITE(diagTitle,'(A,I3)')
     &        'diffuse downwelling irradiance for waveband ',j
        diagUnits = 'W/m^2           '
        diagCode  = 'SMRP    LR      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A,I3.3)')'Eubot',j
        WRITE(diagTitle,'(A,I3)')
     &        'diffuse upwelling irradiance for waveband ',j
        diagUnits = 'W/m^2           '
        diagCode  = 'SMRP    LR      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A,I3.3)')'amp1_',j
        WRITE(diagTitle,'(A,I3)')
     &        'amplitude of d-w increasing mode for waveband ',j
        diagUnits = 'W/m^2           '
        diagCode  = 'SMR     MR      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A,I3.3)')'amp2_',j
        WRITE(diagTitle,'(A,I3)')
     &        'amplitude of d-w decreasing mode for waveband ',j
        diagUnits = 'W/m^2           '
        diagCode  = 'SMR     MR      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A,I3.3)')'x_',j
        WRITE(diagTitle,'(A,I3)')
     &        'amplitude of direct in diffuse for waveband ',j
        diagUnits = 'W/m^2           '
        diagCode  = 'SMR     MR      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A,I3.3)')'y_',j
        WRITE(diagTitle,'(A,I3)')
     &        'amplitude of direct in upward for waveband ',j
        diagUnits = 'W/m^2           '
        diagCode  = 'SMR     MR      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A,I3.3)')'r1_',j
        WRITE(diagTitle,'(A,I3)')
     &        'R coefficient of d-w increasing mode for waveband ',j
        diagUnits = '1               '
        diagCode  = 'SMRP    MR      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A,I3.3)')'r2_',j
        WRITE(diagTitle,'(A,I3)')
     &        'R coefficient of d-w decreasing mode for waveband ',j
        diagUnits = '1               '
        diagCode  = 'SMRP    MR      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A,I3.3)')'att1_',j
        WRITE(diagTitle,'(A,I3)')
     &        'attenuation of d-w increasing mode for waveband ',j
        diagUnits = '1/m             '
        diagCode  = 'SMRP    MR      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A,I3.3)')'att2_',j
        WRITE(diagTitle,'(A,I3)')
     &        'attenuation of d-w decreasing mode for waveband ',j
        diagUnits = '1/m             '
        diagCode  = 'SMRP    MR      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
#endif
      ENDDO

#ifdef ALLOW_EXF
      WRITE(diagName,'(A)')'RTice'
      WRITE(diagTitle,'(A)')'ice area fraction in radtrans package'
      diagUnits = 'm^2/m^2         '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I           diagName, diagCode, diagUnits, diagTitle, 0, myThid )
#endif

#endif /* ALLOW_DIAGNOSTICS */
#endif /* ALLOW_RADTRANS */

      RETURN
      END

