#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_INIT_CHL
C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_INIT_CHL( bi, bj, myTime, myIter, myThid )

C !DESCRIPTION:
C     Make sure Chl/C is bounded by chl2cmin and chl2cmax.
C     If not DARWIN_ALLOW_CHLQUOTA, assign ChlPrev.
C     If darwin_chlInitBalanced is true, initialize Chl from c assuming
C     balanced growth following Geider, Macintyre, Kana 1997.
C     If DARWIN_CHL_INIT_LEGACY,
C     - with radtrans, use zero light for backwards compatibility
C       (code for using radtrans lite is included).
C     - without radtrans, use PARfile if given, else use 200 uEin/m2/s
C       and attenuate assuming pure water (no orgamic matter)
C     If not DARWIN_CHL_INIT_LEGACY, compute light using initial Chl
C     (usually 0 if darwin_chlInitBalanced).
C     For backwards compatibility, ice is taken into account only
C     without radtrans and without DARWIN_CHL_INIT_LEGACY.

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "GRID.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DYNVARS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_FIELDS.h"
#ifdef ALLOW_RADTRANS
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"
#include "RADTRANS_FIELDS.h"
#endif
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_EXF_FIELDS.h"
#include "DARWIN_RADTRANS.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"
#include "DARWIN_FIELDS.h"

C !INPUT PARAMETERS: ===================================================
      _RL myTime
      INTEGER bi, bj, myIter, myThid
CEOP

#ifdef ALLOW_DARWIN

C!LOCAL VARIABLES: ====================================================
      INTEGER i,j,k,l,jp
      _RL PAR(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL alpha_I, chltmp
      _RL lite, atten

C ======================================================================
C compute light
      IF (darwin_chlInitBalanced) THEN

#ifdef DARWIN_CHL_INIT_LEGACY

# ifdef ALLOW_RADTRANS
       DO j=1-OLy,sNy+OLy
        DO i=1-OLx,sNx+OLx
         lite = 0 _d 0
         DO l=1,nlam
          lite = lite + RT_WtouEins(l)*(RT_Ed_sfc(i,j,bi,bj,l)+
     &                                  RT_Es_sfc(i,j,bi,bj,l))
         ENDDO
         atten = 0 _d 0
         DO k=1,nR
          IF (HFacC(i,j,k,bi,bj).GT.0. _d 0) THEN
           atten= atten + katten_w*5. _d -1*drF(k)
           IF (k.gt.1)THEN
            atten = atten + katten_w*5. _d -1*drF(k-1)
           ENDIF
           PAR(i,j,k,1) = lite*EXP(-atten)
          ENDIF
         ENDDO
        ENDDO
       ENDDO
# else
       IF (PARfile .NE. ' ') THEN
C!!!!!  do not take ice into account for backwards compatibility
        j = -99
        CALL DARWIN_LIGHT(PAR,myTime,bi,bj,1-OLx,sNx+OLx,1-OLy,sNy+OLy,
     &                    myTime,j,myThid)
       ELSE
        DO j=1-OLy,sNy+OLy
         DO i=1-OLx,sNx+OLx
          lite = 200 _d 0
          atten = 0 _d 0
          DO k=1,nR
           IF (HFacC(i,j,k,bi,bj).GT.0. _d 0) THEN
            atten= atten + katten_w*5. _d -1*drF(k)
            IF (k.gt.1)THEN
             atten = atten + katten_w*5. _d -1*drF(k-1)
            ENDIF
            PAR(i,j,k,1) = lite*EXP(-atten)
           ENDIF
          ENDDO
         ENDDO
        ENDDO
       ENDIF
# endif

#else /* not DARWIN_CHL_INIT_LEGACY */

C      compute PAR from current Chl
C      (usually initialized to 0 if darwin_chlInitBalanced)
C      do not fill diagnostics,
C      do not take ice into account for backwards compatibility
# ifdef ALLOW_RADTRANS
#  ifdef ALLOW_OASIM
       IF ( useOASIM ) THEN
#   ifdef ALLOW_DEBUG
        IF (debugMode) CALL DEBUG_CALL('OASIM_FIELDS_LOAD',myThid)
#   endif /* ALLOW_DEBUG */
        CALL TIMER_START('OASIM_FIELDS_LOAD  [DARWIN_INIT_CHL]',myThid)
        CALL OASIM_FIELDS_LOAD( .FALSE., myTime, myIter, myThid )
        CALL TIMER_STOP ('OASIM_FIELDS_LOAD  [DARWIN_INIT_CHL]',myThid)
       ENDIF
#  endif /* ALLOW_OASIM */
       j = -1
       CALL DARWIN_LIGHT_RADTRANS(PAR,myTime,bi,bj,1-OLx,sNx+OLx,
     &                            1-OLy,sNy+OLy,myTime,j,myThid)
# else
       j = -99
       CALL DARWIN_LIGHT(PAR,myTime,bi,bj,1-OLx,sNx+OLx,1-OLy,sNy+OLy,
     &                   myTime,j,myThid)
# endif

#endif /* not DARWIN_CHL_INIT_LEGACY */

C     endif not darwin_chlInitBalanced
      ENDIF

C ======================================================================
C compute Chlorophyll

      DO jp=1,nPhoto
       DO k=1,Nr
        DO j=1-OLy,sNy+OLy
         DO i=1-OLx,sNx+OLx
#ifdef DARWIN_ALLOW_CHLQUOTA
          chltmp = Ptracer(i,j,k,bi,bj,iChl+jp-1)
#else
          chltmp = 0.0 _d 0
#endif
          IF (darwin_chlInitBalanced) THEN
#if defined(ALLOW_RADTRANS) && defined(DARWIN_CHL_INIT_LEGACY)
           alpha_I = alpha_mean(jp) * PAR(i,j,k,1)
           alpha_I = 0 _d 0
#else
           alpha_I = 0.0
           DO l = 1, nlam
            alpha_I = alpha_I + alphachl(jp,l) * PAR(i,j,k,l)
           ENDDO
#endif
           chltmp = Ptracer(i,j,k,bi,bj,ic+jp-1)*
     &              chl2cmax(jp)/(1+chl2cmax(jp)*alpha_I/(2*PCmax(jp)))
          ENDIF
          chltmp = MAX(Ptracer(i,j,k,bi,bj,ic+jp-1)*chl2cmin(jp),
     &                 chltmp)
          chltmp = MIN(Ptracer(i,j,k,bi,bj,ic+jp-1)*chl2cmax(jp),
     &                 chltmp)
#ifdef DARWIN_ALLOW_CHLQUOTA
          Ptracer(i,j,k,bi,bj,iChl+jp-1) = chltmp
#else
# ifdef ALLOW_RADTRANS
          ChlPrev(i,j,k,bi,bj,jp) = chltmp
# else
          ChlPrev(i,j,k,bi,bj)=ChlPrev(i,j,k,bi,bj)+chltmp
# endif
#endif
         ENDDO
        ENDDO
       ENDDO
      ENDDO

#endif /* ALLOW_DARWIN */

      RETURN
      END
