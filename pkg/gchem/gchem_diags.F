C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/gchem/Attic/gchem_diags.F,v 1.1 2008/01/11 21:28:02 jahn Exp $
C $Name:  $

#include "GCHEM_OPTIONS.h"

C !INTERFACE: ==========================================================
      SUBROUTINE GCHEM_DIAGS(myTime,myIter, myThid )

C !DESCRIPTION:
C calls subroutine that calculate diagnostic specific to
C any tracer epxperiment
C also calls gchem monitor 

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid, myIter
      _RL myTime
CEOP

#ifdef ALLOW_GCHEM
cccccccccccccccccccccc
c diagnostics        c
cccccccccccccccccccccc

#ifdef ALLOW_DIC
#ifdef ALLOW_TIMEAVE
       IF (myIter.NE.nIter0)
     & call dic_biotic_diags( myTime, myIter, myThid )
#endif /* ALLOW_TIMEAVE */
#endif /* ALLOW_DIC */

#ifdef ALLOW_DARWIN
#ifdef ALLOW_TIMEAVE
       call darwin_diags( myTime, myIter, myThid )
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
