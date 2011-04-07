#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "DARWIN_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

#ifdef ALLOW_CARBON
#ifdef ALLOW_MNC

CBOP
C     !ROUTINE: DIC_MNC_INIT

C     !INTERFACE:
      SUBROUTINE DIC_MNC_INIT( myThid )

C     !DESCRIPTION:
C     Initialize MNC for DIC

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP
      IF ( useMNC ) THEN
      CALL MNC_CW_ADD_VNAME(
     &     'dic_SUR_ave', 'Cen_xy_Hn__-__t', 3,4, myThid)
      CALL MNC_CW_ADD_VATTR_TEXT(
     &     'dic_SUR_ave','units','--', myThid)
      CALL MNC_CW_ADD_VATTR_TEXT('dic_SUR_ave','description',
     &     '', myThid)

      CALL MNC_CW_ADD_VNAME(
     &     'dic_SURC_ave', 'Cen_xy_Hn__-__t', 3,4, myThid)
      CALL MNC_CW_ADD_VATTR_TEXT(
     &     'dic_SURC_ave','units','--', myThid)
      CALL MNC_CW_ADD_VATTR_TEXT('dic_SURC_ave','description',
     &     '', myThid)

      CALL MNC_CW_ADD_VNAME(
     &     'dic_SURO_ave', 'Cen_xy_Hn__-__t', 3,4, myThid)
      CALL MNC_CW_ADD_VATTR_TEXT(
     &     'dic_SURO_ave','units','--', myThid)
      CALL MNC_CW_ADD_VATTR_TEXT('dic_SURO_ave','description',
     &     '', myThid)

      CALL MNC_CW_ADD_VNAME(
     &     'dic_pH_ave', 'Cen_xy_Hn__-__t', 3,4, myThid)
      CALL MNC_CW_ADD_VATTR_TEXT(
     &     'dic_pH_ave','units','--', myThid)
      CALL MNC_CW_ADD_VATTR_TEXT('dic_pH_ave','description',
     &     '', myThid)

      CALL MNC_CW_ADD_VNAME(
     &     'dic_pCO2_ave', 'Cen_xy_Hn__-__t', 3,4, myThid)
      CALL MNC_CW_ADD_VATTR_TEXT(
     &     'dic_pCO2_ave','units','--', myThid)
      CALL MNC_CW_ADD_VATTR_TEXT('dic_pCO2_ave','description',
     &     '', myThid)


      ENDIF
        RETURN
        END
#endif  /*ALLOW_MNC*/
#endif  /*ALLOW_CARBON*/

#endif  /*DARWIN*/
#endif  /*ALLOW_PTRACERS*/
c ==================================================================

