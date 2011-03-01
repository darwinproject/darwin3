C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_diagnostics_init.F,v 1.11 2011/03/01 17:04:33 stephd Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "DARWIN_OPTIONS.h"

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
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'PP      '
      WRITE(diagTitle, '(A)') 'Primary Production'
      diagUnits = 'mmol P/m^3/s    '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'Nfix    '
      WRITE(diagTitle, '(A)') 'N fixation'
      diagUnits = 'mmol N/m^3/s    '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'Denit    '
      WRITE(diagTitle, '(A)') 'Denitrification'
      diagUnits = 'mmol N/m^3/s    '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I              diagName, diagCode, diagUnits, diagTitle, myThid )

c ANNA_TAVE 
#ifdef WAVES_DIAG_PCHL
      DO np=1,MIN(99,npmax)
C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
C--    Add diagnostics of Pchl
c ANNA_Q format to allow more Ptracers I2.3 ??
       WRITE(diagName,'(A,I2.2,A)') 'Pchl',np,' '
       WRITE(diagTitle,'(A,I2.2)') 'Chl of Phy', np
       diagUnits = 'mg chl/m^3      '
       diagCode  = 'SM P    MR      '
       CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
      ENDDO /* np */
#endif /* WAVES_DIAG_PCHL */
c ANNA end TAVE

#ifdef DAR_DIAG_RSTAR
      DO np=1,MIN(99,npmax)
C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
C--    Add diagnostics of Rstar
       WRITE(diagName,'(A,I2.2,A)') 'Rstar',np,' '
       WRITE(diagTitle,'(A,I2.2)') 'Rstar^PO4 of Phy', np
       diagUnits = 'mmol P/m^3      '
       diagCode  = 'SM P    MR      '
       CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
      ENDDO /* np */
#endif /* DAR_DIAG_RSTAR */

#ifdef DAR_DIAG_DIVER
      diagName = 'Diver1  '
      WRITE(diagTitle, '(A)')
     &    '# Phy species over absolute threshold'
      diagUnits = '1               '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
      
      diagName = 'Diver2  '
      WRITE(diagTitle, '(A)')
     &    '# Phy species over threshold for proportion of biomass'
      diagUnits = '1               '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
      
      diagName = 'Diver3  '
      WRITE(diagTitle, '(A)') 
     &    '# Phy species constituting bulk of biomass'
      diagUnits = '1               '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
      
      diagName = 'Diver4  '
      WRITE(diagTitle, '(A)')
     &    '# Phy species over threshold for ratio to maximum species'
      diagUnits = '1               '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
#endif /* DAR_DIAG_DIVER */

#ifdef ALLOW_DIAZ
#ifdef DAR_DIAG_NFIXP
      DO np=1,MIN(99,npmax)
C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|C--    Add diagnostics of NFix
       WRITE(diagName,'(A,I2.2,A)') 'NfixP',np,' '
       WRITE(diagTitle,'(A,I2.2)') 'Nfix of Phy', np
       diagUnits = 'mmol N/m^3      '
       diagCode  = 'SM P    MR      '
       CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|      ENDDO /* np */
      ENDDO /* np */
#endif /* DAR_DIAG_NFIXP */
#endif

#ifdef ALLOW_PAR_DAY
      diagName = 'PARday  '
      WRITE(diagTitle, '(A)') 'daily-averaged PAR'
      diagUnits = 'uEin/m^2/s      '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
#endif /* ALLOW_PAR_DAY */

#ifdef DAR_DIAG_CHL
      diagName = 'ChlGeide'
      WRITE(diagTitle, '(A)') 'Chlorophyll a concentration a la Geider'
      diagUnits = 'mg Chla/m^3     '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
      diagName = 'Chl2CGei'
      WRITE(diagTitle, '(A)')'Chlorophyll a to carbon ratio a la Geider'
      diagUnits = 'mg Chla/mmol C  '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'ChlDoney'
      WRITE(diagTitle, '(A)') 'Chlorophyll a concentration a la Doney'
      diagUnits = 'mg Chla/m^3     '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'Chl2CDon'
      WRITE(diagTitle, '(A)') 'Chlorophyll a to carbon ratio a la Doney'
      diagUnits = 'mg Chla/mmol C  '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName = 'ChlCloer'
      WRITE(diagTitle, '(A)') 'Chlorophyll a concentration a la Cloern'
      diagUnits = 'mg Chla/m^3     '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
      diagName = 'Chl2CClo'
      WRITE(diagTitle, '(A)')'Chlorophyll a to carbon ratio a la Cloern'
      diagUnits = 'mg Chla/mmol C  '
      diagCode  = 'SM P    MR      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I             diagName, diagCode, diagUnits, diagTitle, 0, myThid )
#endif /* DAR_DIAG_CHL */

#endif /* ALLOW_DIAGNOSTICS */

      RETURN
      END
C============================================================================
#endif
#endif

