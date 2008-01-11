C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/gchem/Attic/gchem_fields_load.F,v 1.1 2008/01/11 21:28:02 jahn Exp $
C $Name:  $

#include "GCHEM_OPTIONS.h"

CBOP
C !ROUTINE: GCHEM_FIELDS_LOAD

C !INTERFACE: ==========================================================
      SUBROUTINE GCHEM_FIELDS_LOAD (
     I           myTime, myIter, myThid)

C !DESCRIPTION:
C  calls routines which read in fields needed for any tracer experiment
C !USES: ===============================================================
      IMPLICIT NONE

C !INPUT PARAMETERS: ===================================================
C  myTime               :: current time
C  myIter               :: current iteration
C  myThid               :: thread number
      _RL myTime
      INTEGER myIter
      INTEGER myThid

C !LOCAL VARIABLES: ====================================================
CEOP

#ifdef ALLOW_GCHEM

cccccccccccccccccccccccccc
c load external data     c
cccccccccccccccccccccccccc
#ifdef ALLOW_DIC
       CALL DIC_FIELDS_LOAD (myIter,myTime,myThid)
#endif


#ifdef ALLOW_CFC
       CALL CFC_FIELDS_LOAD(myIter,myTime,myThid)
#endif

#ifdef ALLOW_DARWIN
       call DARWIN_FIELDS_LOAD(myIter,myTime,myThid)
#endif

#ifdef ALLOW_NPZDCAR
       call NPZDCAR_FIELDS_LOAD(myIter,myTime,myThid)
#endif


#endif /* ALLOW_GCHEM */

      RETURN
      END

