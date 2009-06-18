C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/gchem/Attic/gchem_output.F,v 1.1 2009/06/18 14:25:25 jahn Exp $
C $Name:  $

#include "GCHEM_OPTIONS.h"
#ifdef ALLOW_DARWIN
#include "DARWIN_OPTIONS.h"
#endif

C !INTERFACE: ==========================================================
      SUBROUTINE GCHEM_OUTPUT(myTime,myIter, myThid )

C !DESCRIPTION:
C calls subroutine that calculate diagnostic specific to
C any tracer epxperiment
C also calls gchem monitor

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GCHEM.h"

C !INPUT PARAMETERS: ===================================================
C  myThid   :: thread number
      _RL     myTime
      INTEGER myIter
      INTEGER myThid
CEOP

#ifdef ALLOW_GCHEM
cccccccccccccccccccccc
c diagnostics        c
cccccccccccccccccccccc

#ifdef ALLOW_DIC
#ifdef ALLOW_TIMEAVE
       IF ( myIter.NE.nIter0 )
     & CALL DIC_BIOTIC_DIAGS( myTime, myIter, myThid )
#endif /* ALLOW_TIMEAVE */
#endif /* ALLOW_DIC */

#ifdef ALLOW_DARWIN
#ifdef ALLOW_TIMEAVE
      IF ( useDARWIN ) THEN
       CALL DARWIN_DIAGS( myTime, myIter, myThid )
#ifdef ALLOW_CARBON
       CALL DIC_DIAGS( myTime, myIter, myThid )
#endif
      ENDIF
#endif
#endif

#ifdef ALLOW_NPZDCAR
#ifdef ALLOW_TIMEAVE
       call npzdcar_diags( myTime, myIter, myThid )
#endif
#endif


#endif /* ALLOW_GCHEM */

      RETURN
      END
