C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_diagnostics_init.F,v 1.4 2008/07/02 19:07:36 jahn Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "GCHEM_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

CBOP
C     !ROUTINE: DARWIN_DIAGNOSTICS_INIT
C     !INTERFACE:
      SUBROUTINE DARWIN_DIAGNOSTICS_INIT( myThid )
C     !DESCRIPTION:
C     Routine to initialize Darwin diagnostics

C     !USES:
      IMPLICIT NONE
C     === Global variables ===
#include "SIZE.h"
#include "PTRACERS_SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GCHEM.h"
#include "DARWIN_SIZE.h"
#include "DARWIN.h"
#include "DARWIN_IO.h"

C     !INPUT/OUTPUT PARAMETERS:
C     === Routine arguments ===
C     myThid -  Number of this instance of DARWIN_DIAGNOSTICS_INIT
      INTEGER myThid
CEOP

#ifdef ALLOW_DIAGNOSTICS
C     !LOCAL VARIABLES:
C     === Local variables ===
C     msgBuf      - Informational/error meesage buffer
c     CHARACTER*(MAX_LEN_MBUF) msgBuf

      INTEGER       diagNum
      CHARACTER*8   diagName
      CHARACTER*16  diagCode
      CHARACTER*16  diagUnits
      CHARACTER*(80) diagTitle

      INTEGER      np

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

C--   Add diagnostics to the (long) list

C--   Add diagnostic PAR, PP and Nfix
      diagName = 'PAR     '
      WRITE(diagTitle, '(A)') 'PAR'
      diagUnits = 'uEin/m^2/s      '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADD2LIST( diagNum,
     I              diagName, diagCode, diagUnits, diagTitle, myThid )

      diagName = 'PP      '
      WRITE(diagTitle, '(A)') 'Primary Production'
      diagUnits = 'mmol P/m^3/s    '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADD2LIST( diagNum,
     I              diagName, diagCode, diagUnits, diagTitle, myThid )

      diagName = 'Nfix    '
      WRITE(diagTitle, '(A)') 'N fixation'
      diagUnits = 'mmol N/m^3/s    '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADD2LIST( diagNum,
     I              diagName, diagCode, diagUnits, diagTitle, myThid )

#ifdef DAR_DIAG_RSTAR
      DO np=1,MIN(99,npmax)
C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
C--    Add diagnostics of Rstar
       WRITE(diagName,'(A,I2.2,A)') 'Rstar',np,' '
       WRITE(diagTitle,'(A,I2.2)') 'Rstar^PO4 of Phy', np
       diagUnits = 'mmol P/m^3      '
       diagCode  = 'SM P    MR      '
       CALL DIAGNOSTICS_ADD2LIST( diagNum,
     I              diagName, diagCode, diagUnits, diagTitle, myThid )

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
      ENDDO /* np */
#endif /* DAR_DIAG_RSTAR */

#ifdef DAR_DIAG_DIVER
      diagName = 'Diver1  '
      WRITE(diagTitle, '(A)')
     &    '# Phy species over absolute threshold'
      diagUnits = '1               '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADD2LIST( diagNum,
     I              diagName, diagCode, diagUnits, diagTitle, myThid )
      
      diagName = 'Diver2  '
      WRITE(diagTitle, '(A)')
     &    '# Phy species over threshold for proportion of biomass'
      diagUnits = '1               '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADD2LIST( diagNum,
     I              diagName, diagCode, diagUnits, diagTitle, myThid )
      
      diagName = 'Diver3  '
      WRITE(diagTitle, '(A)') 
     &    '# Phy species constituting bulk of biomass'
      diagUnits = '1               '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADD2LIST( diagNum,
     I              diagName, diagCode, diagUnits, diagTitle, myThid )
      
      diagName = 'Diver4  '
      WRITE(diagTitle, '(A)')
     &    '# Phy species over threshold for ratio to maximum species'
      diagUnits = '1               '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADD2LIST( diagNum,
     I              diagName, diagCode, diagUnits, diagTitle, myThid )
#endif /* DAR_DIAG_DIVER */

#endif /* ALLOW_DIAGNOSTICS */

      RETURN
      END
C============================================================================
#endif
#endif

