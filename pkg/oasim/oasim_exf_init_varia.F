#include "OASIM_OPTIONS.h"
#ifdef ALLOW_EXF
#include "EXF_OPTIONS.h"
#endif

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: OASIM_EXF_INIT_VARIA

C     !INTERFACE:
      SUBROUTINE OASIM_EXF_INIT_VARIA( myThid )

C     !DESCRIPTION:
C     Initialize OASIM constants

C     !USES:
      IMPLICIT NONE
#include "EEPARAMS.h"
#include "SIZE.h"
#include "GRID.h"
#include "PARAMS.h"
#ifdef ALLOW_EXF
#include "EXF_INTERP_SIZE.h"
#endif
#include "OASIM_SIZE.h"
#include "OASIM_EXF_PARAMS.h"
#include "OASIM_FIELDS.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

#ifdef ALLOW_OASIM
#ifdef ALLOW_EXF

C     !FUNCTIONS:
      INTEGER  ILNBLNK
      EXTERNAL ILNBLNK

      CHARACTER*16 fld
      CHARACTER*(MAX_LEN_FNAM) fnam
      INTEGER l, il

C     these load constant forcing fields

      DO l=1,nlt
       WRITE(fld,'(A,I3.3)') 'aerTau', l
       IF (aerTaufile .NE. ' ') THEN
        il = ILNBLNK( aerTaufile )
        WRITE(fnam,'(A,I3.3)') aerTaufile(1:il), l
       ELSE
        fnam = ' '
       ENDIF
       call exf_init_fld (
     &      fld, fnam, aerTaumask,
     &      aerTauperiod, aerTau_inscal(l), aerTauconst(l),
     &      taua(1-OLx,1-OLy,1,1,l),
     &      aerTau0(1-OLx,1-OLy,1,1,l),
     &      aerTau1(1-OLx,1-OLy,1,1,l),
#ifdef USE_EXF_INTERPOLATION
     &      aerTau_lon0, aerTau_lon_inc,
     &      aerTau_lat0, aerTau_lat_inc,
     &      aerTau_nlon, aerTau_nlat, xC, yC, aerTau_interpMethod,
#endif
     &      mythid )
      ENDDO

      DO l=1,nlt
       WRITE(fld,'(A,I3.3)') 'asymp', l
       IF (asympfile .NE. ' ') THEN
        il = ILNBLNK( asympfile )
        WRITE(fnam,'(A,I3.3)') asympfile(1:il), l
       ELSE
        fnam = ' '
       ENDIF
       call exf_init_fld (
     &      fld, fnam, asympmask,
     &      asympperiod, asymp_inscal(l), asympconst(l),
     &      asymp(1-OLx,1-OLy,1,1,l),
     &      asymp0(1-OLx,1-OLy,1,1,l),
     &      asymp1(1-OLx,1-OLy,1,1,l),
#ifdef USE_EXF_INTERPOLATION
     &      asymp_lon0, asymp_lon_inc,
     &      asymp_lat0, asymp_lat_inc,
     &      asymp_nlon, asymp_nlat, xC, yC, asymp_interpMethod,
#endif
     &      mythid )
      ENDDO

      DO l=1,nlt
       WRITE(fld,'(A,I3.3)') 'ssalb', l
       IF (ssalbfile .NE. ' ') THEN
        il = ILNBLNK( ssalbfile )
        WRITE(fnam,'(A,I3.3)') ssalbfile(1:il), l
       ELSE
        fnam = ' '
       ENDIF
       call exf_init_fld (
     &      fld, fnam, ssalbmask,
     &      ssalbperiod, ssalb_inscal(l), ssalbconst(l),
     &      ssalb(1-OLx,1-OLy,1,1,l),
     &      ssalb0(1-OLx,1-OLy,1,1,l),
     &      ssalb1(1-OLx,1-OLy,1,1,l),
#ifdef USE_EXF_INTERPOLATION
     &      ssalb_lon0, ssalb_lon_inc,
     &      ssalb_lat0, ssalb_lat_inc,
     &      ssalb_nlon, ssalb_nlat, xC, yC, ssalb_interpMethod,
#endif
     &      mythid )
      ENDDO

      call exf_init_fld (
     &     'cldcov', cldcovfile, cldcovmask,
     &     cldcovperiod, cldcov_inscal, cldcovconst,
     &     ccov, cldcov0, cldcov1,
#ifdef USE_EXF_INTERPOLATION
     &     cldcov_lon0, cldcov_lon_inc,
     &     cldcov_lat0, cldcov_lat_inc,
     &     cldcov_nlon, cldcov_nlat, xC, yC, cldcov_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'cldlwp', cldlwpfile, cldlwpmask,
     &     cldlwpperiod, cldlwp_inscal, cldlwpconst,
     &     rlwp, cldlwp0, cldlwp1,
#ifdef USE_EXF_INTERPOLATION
     &     cldlwp_lon0, cldlwp_lon_inc,
     &     cldlwp_lat0, cldlwp_lat_inc,
     &     cldlwp_nlon, cldlwp_nlat, xC, yC, cldlwp_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'cldre', cldrefile, cldremask,
     &     cldreperiod, cldre_inscal, cldreconst,
     &     cdre, cldre0, cldre1,
#ifdef USE_EXF_INTERPOLATION
     &     cldre_lon0, cldre_lon_inc,
     &     cldre_lat0, cldre_lat_inc,
     &     cldre_nlon, cldre_nlat, xC, yC, cldre_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'pres', presfile, presmask,
     &     presperiod, pres_inscal, presconst,
     &     slp, pres0, pres1,
#ifdef USE_EXF_INTERPOLATION
     &     pres_lon0, pres_lon_inc,
     &     pres_lat0, pres_lat_inc,
     &     pres_nlon, pres_nlat, xC, yC, pres_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'oawind', oawindfile, oawindmask,
     &     oawindperiod, oawind_inscal, oawindconst,
     &     wsm, oawind0, oawind1,
#ifdef USE_EXF_INTERPOLATION
     &     oawind_lon0, oawind_lon_inc,
     &     oawind_lat0, oawind_lat_inc,
     &     oawind_nlon, oawind_nlat, xC, yC, oawind_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'relhum', relhumfile, relhummask,
     &     relhumperiod, relhum_inscal, relhumconst,
     &     rh, relhum0, relhum1,
#ifdef USE_EXF_INTERPOLATION
     &     relhum_lon0, relhum_lon_inc,
     &     relhum_lat0, relhum_lat_inc,
     &     relhum_nlon, relhum_nlat, xC, yC, relhum_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'ozone', ozonefile, ozonemask,
     &     ozoneperiod, ozone_inscal, ozoneconst,
     &     oz, ozone0, ozone1,
#ifdef USE_EXF_INTERPOLATION
     &     ozone_lon0, ozone_lon_inc,
     &     ozone_lat0, ozone_lat_inc,
     &     ozone_nlon, ozone_nlat, xC, yC, ozone_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'wv', wvfile, wvmask,
     &     wvperiod, wv_inscal, wvconst,
     &     wv, wv0, wv1,
#ifdef USE_EXF_INTERPOLATION
     &     wv_lon0, wv_lon_inc,
     &     wv_lat0, wv_lat_inc,
     &     wv_nlon, wv_nlat, xC, yC, wv_interpMethod,
#endif
     &     mythid )

#endif /* ALLOW_EXF */
#endif /* ALLOW_OASIM */

      RETURN
      END
