C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/dic_diagnostics_init.F,v 1.1 2010/05/18 17:43:54 jahn Exp $
C $Name:  $

#include "DARWIN_OPTIONS.h"

C !INTERFACE: ==========================================================
      SUBROUTINE DIC_DIAGNOSTICS_INIT(myThid )

C !DESCRIPTION:
C define diagnostics for dic package
C experiment

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid
CEOP

#ifdef ALLOW_CARBON
#ifdef ALLOW_DIAGNOSTICS

C     !LOCAL VARIABLES:
      INTEGER       diagNum
      CHARACTER*8   diagName
      CHARACTER*16  diagCode
      CHARACTER*16  diagUnits
      CHARACTER*(80) diagTitle

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
C     Define diagnostics Names :

      diagName  = 'DICTFLX '
      diagTitle = 
     &'Tendency of DIC due to air-sea exch + oldvirt.flux (mmol/m3/s)'
      diagUnits = 'mmol/m3/sec     '
      diagCode  = 'SM P    L1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I       diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName  = 'DICOFLX '
      diagTitle = 'Tendency of O2 due to air-sea exch (mmol/m3/s)'
      diagUnits = 'mmol/m3/sec     '
      diagCode  = 'SM P    L1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I       diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName  = 'DICCFLX '
      diagTitle = 'Flux of CO2 - air-sea exch (mmol/m2/s)'
      diagUnits = 'mmol/m2/sec     '
      diagCode  = 'SM P    L1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I       diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName  = 'DICPCO2 '
      diagTitle = 'Partial Pressure of CO2 (atm)'
      diagUnits = 'atm             '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I       diagName, diagCode, diagUnits, diagTitle, 0, myThid )

      diagName  = 'DICPHAV '
      diagTitle = 'pH (dimensionless)'
      diagUnits = 'dimensionless   '
      diagCode  = 'SM P    M1      '
      CALL DIAGNOSTICS_ADDTOLIST( diagNum,
     I       diagName, diagCode, diagUnits, diagTitle, 0, myThid )

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

#endif /* ALLOW_DIAGNOSTICS */
#endif /* ALLOW_CARBON */

      RETURN
      END
