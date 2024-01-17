#include "OASIM_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C !ROUTINE: OASIM_DIAGNOSTICS_INIT

C !INTERFACE:
      SUBROUTINE OASIM_DIAGNOSTICS_INIT( myThid )

C     !DESCRIPTION:
C     Initialize list of all available diagnostics

C     !USES:
      IMPLICIT NONE
#include "EEPARAMS.h"
#include "SIZE.h"
#include "OASIM_SIZE.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      INTEGER myThid
CEOP

#ifdef ALLOW_DIAGNOSTICS
C     !LOCAL VARIABLES:
C     === Local variables ===
C     diagNum   :: diagnostics number in the (long) list of available diag.
C     diagMate  :: diag. mate number in the (long) list of available diag.
C     diagName  :: local short name (8c) of a diagnostics
C     diagCode  :: local parser field with characteristics of the diagnostics
C              cf head of S/R DIAGNOSTICS_INIT_EARLY or DIAGNOSTICS_MAIN_INIT
C     diagUnits :: local string (16c): physical units of a diagnostic field
C     diagTitle :: local string (80c): description of field in diagnostic
      INTEGER       diagNum
      INTEGER       diagMate
      CHARACTER*8   diagName
      CHARACTER*16  diagCode
      CHARACTER*16  diagUnits
      CHARACTER*(80) diagTitle
      INTEGER l

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

      diagName  = 'OASIMsol'
      diagTitle = 'solar zenith angle above water'
      diagUnits = '                '
      diagCode  = 'SM      L1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I        diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName  = 'OASIMrmd'
      diagTitle = 'inverse cosine of solar zenith angle below water'
      diagUnits = '                '
      diagCode  = 'SM      L1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I        diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      DO l=1,nlt
        WRITE(diagName,'(A4,I3.3)'), 'taua', l
        WRITE(diagTitle,'(A,X,I3)')
     &       'aerosol optical thickness used in waveband', l
        diagUnits = '                '
        diagCode  = 'SM      L1      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I          diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A5,I3.3)'), 'asymp', l
        WRITE(diagTitle,'(A,X,I3)')
     &       'aerosol asymmetry parameter used in waveband', l
        diagUnits = '                '
        diagCode  = 'SM      L1      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I          diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A5,I3.3)'), 'ssalb', l
        WRITE(diagTitle,'(A,X,I3)')
     &       'aerosol single-scattering albedo used in waveband', l
        diagUnits = '                '
        diagCode  = 'SM      L1      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I          diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A5,I3.3)'), 'Edclr', l
        WRITE(diagTitle,'(A,X,I3)')
     &       'direct-beam clear-sky irradiance in waveband', l
        diagUnits = 'W/m2            '
        diagCode  = 'SM      L1      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I          diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A5,I3.3)'), 'Esclr', l
        WRITE(diagTitle,'(A,X,I3)')
     &       'diffuse clear-sky irradiance in waveband', l
        diagUnits = 'W/m2            '
        diagCode  = 'SM      L1      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I          diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A5,I3.3)'), 'Edcld', l
        WRITE(diagTitle,'(A,X,I3)')
     &       'direct-beam cloudy-sky irradiance in waveband', l
        diagUnits = 'W/m2            '
        diagCode  = 'SM      L1      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I          diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A5,I3.3)'), 'Escld', l
        WRITE(diagTitle,'(A,X,I3)')
     &       'diffuse cloudy-sky irradiance in waveband', l
        diagUnits = 'W/m2            '
        diagCode  = 'SM      L1      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I          diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A5,I3.3)'), 'Edabv', l
        WRITE(diagTitle,'(A,X,I3)')
     &       'direct-beam irradiance above sea surface in waveband', l
        diagUnits = 'W/m2            '
        diagCode  = 'SM      L1      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I          diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A5,I3.3)'), 'Esabv', l
        WRITE(diagTitle,'(A,X,I3)')
     &       'diffuse irradiance above sea surface in waveband', l
        diagUnits = 'W/m2            '
        diagCode  = 'SM      L1      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I          diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A5,I3.3)'), 'Edblw', l
        WRITE(diagTitle,'(A,X,I3)')
     &       'direct-beam irradiance below sea surface in waveband', l
        diagUnits = 'W/m2            '
        diagCode  = 'SM      L1      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I          diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A5,I3.3)'), 'Esblw', l
        WRITE(diagTitle,'(A,X,I3)')
     &       'diffuse irradiance below sea surface in waveband', l
        diagUnits = 'W/m2            '
        diagCode  = 'SM      L1      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I          diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A5,I3.3)'), 'E0blw', l
        WRITE(diagTitle,'(A,X,I3)')
     &       'scalar irradiance below sea surface in waveband', l
        diagUnits = 'W/m2            '
        diagCode  = 'SM      L1      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I          diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A5,I3.3)'), 'OArod', l
        WRITE(diagTitle,'(A,X,I3)')
     &       'sea-surface reflectance for direct beam in waveband', l
        diagUnits = '                '
        diagCode  = 'SM      L1      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I          diagName, diagCode, diagUnits, diagTitle, 0, myThid )

        WRITE(diagName,'(A5,I3.3)'), 'OAros', l
        WRITE(diagTitle,'(A,X,I3)')
     &       'sea-surface reflectance for diffuse light in waveband', l
        diagUnits = '                '
        diagCode  = 'SM      L1      '
        CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I          diagName, diagCode, diagUnits, diagTitle, 0, myThid )
      ENDDO

      diagName = 'sPARblw'
      diagTitle = 'downwelling scalar irradiance below surface'
      diagUnits = 'uEin/m2/s       '
      diagCode  = 'SM      L1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I          diagName, diagCode, diagUnits, diagTitle, 0, myThid )

#endif /* ALLOW_DIAGNOSTICS */

      RETURN
      END
