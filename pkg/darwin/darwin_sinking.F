#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_SINKING
C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_SINKING(
     I     Ptr,
     U     gTr,
     I     dTsub,bi,bj,iMin,iMax,jMin,jMax,myTime,myIter,myThid)

C !DESCRIPTION:
C     compute tendencies from sinking of particulate organic matter

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "SURFACE.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"
#include "DARWIN_FIELDS.h"

C !INPUT PARAMETERS: ===================================================
C  myThid :: thread number
C  Ptr    :: darwin model tracers
C  dT     :: time step (for fake tendency with useEquilibriumC)
      _RL Ptr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,nDarwin)
      _RL dTsub(Nr)
      INTEGER bi,bj,iMin,iMax,jMin,jMax
      INTEGER myThid, myIter
      _RL myTime

C !INPUT/OUTPUT PARAMETERS: ============================================
C  gTr    :: computed tendencies
      _RL gTr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nDarwin)
CEOP

#ifdef ALLOW_DARWIN

c !LOCAL VARIABLES: ====================================================
      INTEGER i,j,k,l
      _RL upfc, dnfc, flux, hFacCdn
      _RL upf(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL dnf(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)

      DO k=1,Nr-1
       DO j=jMin,jMax
        DO i=iMin,iMax
         IF (maskC(i,j,k,bi,bj) .NE. zeroRS .AND.
             maskC(i,j,k+1,bi,bj) .NE. zeroRS) THEN
          upf(i,j,k)=recip_drF(k)*recip_hFacC(i,j,k,bi,bj)
          dnf(i,j,k+1)=recip_drF(k+1)*recip_hFacC(i,j,k+1,bi,bj)
         ELSE
          upf(i,j,k) = 0 _d 0
          dnf(i,j,k+1) = 0 _d 0
         ENDIF
        ENDDO
       ENDDO
#ifdef NONLIN_FRSURF
C-    Account for change in level thickness
       IF (nonlinFreeSurf.GT.0) THEN
         CALL FREESURF_RESCALE_G(
     I                            bi, bj, k,
     U                            upf,
     I                            myThid )
         CALL FREESURF_RESCALE_G(
     I                            bi, bj, k+1,
     U                            dnf,
     I                            myThid )
       ENDIF
#endif /* NONLIN_FRSURF */
       DO j=jMin,jMax
        DO i=iMin,iMax
         upfc = upf(i,j,k)
         dnfc = dnf(i,j,k+1)
         IF (dnfc .GT. 0 _d 0) THEN
          flux = wPIC_sink*MAX(0.0, Ptr(i,j,k,bi,bj,iPIC))
          gTr(i,j,k  ,iPIC ) = gTr(i,j,k  ,iPIC ) - flux*upfc
          gTr(i,j,k+1,iPIC ) = gTr(i,j,k+1,iPIC ) + flux*dnfc
          flux = wC_sink*MAX(0.0, Ptr(i,j,k,bi,bj,iPOC))
          gTr(i,j,k  ,iPOC ) = gTr(i,j,k  ,iPOC ) - flux*upfc
          gTr(i,j,k+1,iPOC ) = gTr(i,j,k+1,iPOC ) + flux*dnfc
          flux = wN_sink*MAX(0.0, Ptr(i,j,k,bi,bj,iPON))
          gTr(i,j,k  ,iPON ) = gTr(i,j,k  ,iPON ) - flux*upfc
          gTr(i,j,k+1,iPON ) = gTr(i,j,k+1,iPON ) + flux*dnfc
          flux = wP_sink*MAX(0.0, Ptr(i,j,k,bi,bj,iPOP))
          gTr(i,j,k  ,iPOP ) = gTr(i,j,k  ,iPOP ) - flux*upfc
          gTr(i,j,k+1,iPOP ) = gTr(i,j,k+1,iPOP ) + flux*dnfc
          flux = wSi_sink*MAX(0.0, Ptr(i,j,k,bi,bj,iPOSi))
          gTr(i,j,k  ,iPOSi) = gTr(i,j,k  ,iPOSi) - flux*upfc
          gTr(i,j,k+1,iPOSi) = gTr(i,j,k+1,iPOSi) + flux*dnfc
          flux = wFe_sink*MAX(0.0, Ptr(i,j,k,bi,bj,iPOFe))
          gTr(i,j,k  ,iPOFe) = gTr(i,j,k  ,iPOFe) - flux*upfc
          gTr(i,j,k+1,iPOFe) = gTr(i,j,k+1,iPOFe) + flux*dnfc
          DO l = 1, nplank
           flux = biosink(l)*MAX(0.0, Ptr(i,j,k,bi,bj,ic+l-1))
           gTr(i,j,k  ,ic+l-1 )=gTr(i,j,k  ,ic+l-1 ) - flux*upfc
           gTr(i,j,k+1,ic+l-1 )=gTr(i,j,k+1,ic+l-1 ) + flux*dnfc
           flux = bioswim(l)*MAX(0.0, Ptr(i,j,k+1,bi,bj,ic+l-1))
           gTr(i,j,k  ,ic+l-1 )=gTr(i,j,k  ,ic+l-1 ) + flux*upfc
           gTr(i,j,k+1,ic+l-1 )=gTr(i,j,k+1,ic+l-1 ) - flux*dnfc
#ifdef DARWIN_ALLOW_NQUOTA
           flux = biosink(l)*MAX(0.0, Ptr(i,j,k,bi,bj,in+l-1))
           gTr(i,j,k  ,in+l-1 )=gTr(i,j,k  ,in+l-1 ) - flux*upfc
           gTr(i,j,k+1,in+l-1 )=gTr(i,j,k+1,in+l-1 ) + flux*dnfc
           flux = bioswim(l)*MAX(0.0, Ptr(i,j,k+1,bi,bj,in+l-1))
           gTr(i,j,k  ,in+l-1 )=gTr(i,j,k  ,in+l-1 ) + flux*upfc
           gTr(i,j,k+1,in+l-1 )=gTr(i,j,k+1,in+l-1 ) - flux*dnfc
#endif
#ifdef DARWIN_ALLOW_PQUOTA
           flux = biosink(l)*MAX(0.0, Ptr(i,j,k,bi,bj,ip+l-1))
           gTr(i,j,k  ,ip+l-1 )=gTr(i,j,k  ,ip+l-1 ) - flux*upfc
           gTr(i,j,k+1,ip+l-1 )=gTr(i,j,k+1,ip+l-1 ) + flux*dnfc
           flux = bioswim(l)*MAX(0.0, Ptr(i,j,k+1,bi,bj,ip+l-1))
           gTr(i,j,k  ,ip+l-1 )=gTr(i,j,k  ,ip+l-1 ) + flux*upfc
           gTr(i,j,k+1,ip+l-1 )=gTr(i,j,k+1,ip+l-1 ) - flux*dnfc
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
           flux = biosink(l)*MAX(0.0, Ptr(i,j,k,bi,bj,isi+l-1))
           gTr(i,j,k  ,isi+l-1)=gTr(i,j,k  ,isi+l-1) - flux*upfc
           gTr(i,j,k+1,isi+l-1)=gTr(i,j,k+1,isi+l-1) + flux*dnfc
           flux = bioswim(l)*MAX(0.0, Ptr(i,j,k+1,bi,bj,isi+l-1))
           gTr(i,j,k  ,isi+l-1)=gTr(i,j,k  ,isi+l-1) + flux*upfc
           gTr(i,j,k+1,isi+l-1)=gTr(i,j,k+1,isi+l-1) - flux*dnfc
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
           flux = biosink(l)*MAX(0.0, Ptr(i,j,k,bi,bj,ife+l-1))
           gTr(i,j,k  ,ife+l-1)=gTr(i,j,k  ,ife+l-1) - flux*upfc
           gTr(i,j,k+1,ife+l-1)=gTr(i,j,k+1,ife+l-1) + flux*dnfc
           flux = bioswim(l)*MAX(0.0, Ptr(i,j,k+1,bi,bj,ife+l-1))
           gTr(i,j,k  ,ife+l-1)=gTr(i,j,k  ,ife+l-1) + flux*upfc
           gTr(i,j,k+1,ife+l-1)=gTr(i,j,k+1,ife+l-1) - flux*dnfc
#endif
          ENDDO
#ifdef DARWIN_ALLOW_CHLQUOTA
          DO l = 1, nPhoto
           flux = biosink(l)*MAX(0.0, Ptr(i,j,k,bi,bj,iChl+l-1))
           gTr(i,j,k  ,iChl+l-1)=gTr(i,j,k  ,iChl+l-1)-flux*upfc
           gTr(i,j,k+1,iChl+l-1)=gTr(i,j,k+1,iChl+l-1)+flux*dnfc
           flux = bioswim(l)*MAX(0.0, Ptr(i,j,k+1,bi,bj,iChl+l-1))
           gTr(i,j,k  ,iChl+l-1)=gTr(i,j,k  ,iChl+l-1)+flux*upfc
           gTr(i,j,k+1,iChl+l-1)=gTr(i,j,k+1,iChl+l-1)-flux*dnfc
          ENDDO
#endif
         ENDIF
        ENDDO
       ENDDO
      ENDDO

#ifdef DARWIN_BOTTOM_SINK
      DO k=1,Nr
       DO j=jMin,jMax
        DO i=iMin,iMax
         IF (k.LT.Nr) THEN
          hFacCdn = hFacC(i,j,k+1,bi,bj)
         ELSE
          hFacCdn = 0 _d 0
         ENDIF
         IF (hFacC(i,j,k,bi,bj).GT.0 _d 0 .AND. hFacCdn.EQ.0 _d 0) THEN
          upf(i,j,k)=recip_drF(k)*recip_hFacC(i,j,k,bi,bj)
         ELSE
          upf(i,j,k)=0 _d 0
         ENDIF
        ENDDO
       ENDDO
#ifdef NONLIN_FRSURF
C-    Account for change in level thickness
       IF (nonlinFreeSurf.GT.0) THEN
         CALL FREESURF_RESCALE_G(
     I                            bi, bj, k,
     U                            upf,
     I                            myThid )
       ENDIF
#endif /* NONLIN_FRSURF */
       DO j=jMin,jMax
        DO i=iMin,iMax
         upfc = upf(i,j,k)
         IF (upfc .GT. 0 _d 0) THEN
          flux = wPIC_sink*MAX(0.0, Ptr(i,j,k,bi,bj,iPIC))
          gTr(i,j,k  ,iPIC ) = gTr(i,j,k  ,iPIC ) - flux*upfc
#ifdef DARWIN_ALLOW_CONS
          botSnkC(i,j,bi,bj) = botSnkC(i,j,bi,bj) + dTsub(k)*flux
#endif
C
          flux = wC_sink*MAX(0.0, Ptr(i,j,k,bi,bj,iPOC))
          gTr(i,j,k  ,iPOC ) = gTr(i,j,k  ,iPOC ) - flux*upfc
#ifdef DARWIN_ALLOW_CONS
          botSnkC(i,j,bi,bj) = botSnkC(i,j,bi,bj) + dTsub(k)*flux
#endif
C
          flux = wN_sink*MAX(0.0, Ptr(i,j,k,bi,bj,iPON))
          gTr(i,j,k  ,iPON ) = gTr(i,j,k  ,iPON ) - flux*upfc
#ifdef DARWIN_ALLOW_CONS
          botSnkN(i,j,bi,bj) = botSnkN(i,j,bi,bj) + dTsub(k)*flux
#endif
C
          flux = wP_sink*MAX(0.0, Ptr(i,j,k,bi,bj,iPOP))
          gTr(i,j,k  ,iPOP ) = gTr(i,j,k  ,iPOP ) - flux*upfc
#ifdef DARWIN_ALLOW_CONS
          botSnkP(i,j,bi,bj) = botSnkP(i,j,bi,bj) + dTsub(k)*flux
#endif
C
          flux = wFe_sink*MAX(0.0, Ptr(i,j,k,bi,bj,iPOFe))
          gTr(i,j,k  ,iPOFe) = gTr(i,j,k  ,iPOFe) - flux*upfc
#ifdef DARWIN_ALLOW_CONS
          botSnkFe(i,j,bi,bj) = botSnkFe(i,j,bi,bj) + dTsub(k)*flux
#endif
C
          flux = wSi_sink*MAX(0.0, Ptr(i,j,k,bi,bj,iPOSi))
          gTr(i,j,k  ,iPOSi) = gTr(i,j,k  ,iPOSi) - flux*upfc
#ifdef DARWIN_ALLOW_CONS
          botSnkSi(i,j,bi,bj) = botSnkSi(i,j,bi,bj) + dTsub(k)*flux
#endif
          DO l = 1, nplank
           flux = biosink(l)*MAX(0.0, Ptr(i,j,k,bi,bj,ic+l-1))
           gTr(i,j,k  ,ic+l-1 )=gTr(i,j,k  ,ic+l-1 ) - flux*upfc
#ifdef DARWIN_ALLOW_CONS
           botSnkC(i,j,bi,bj) = botSnkC(i,j,bi,bj) + dTsub(k)*flux
     &                                         *(1 _d 0 + R_PICPOC(l))
# ifndef DARWIN_ALLOW_NQUOTA
           botSnkN(i,j,bi,bj) = botSnkN(i,j,bi,bj)
     &                        + dTsub(k)*flux*R_NC(l)
# endif
# ifndef DARWIN_ALLOW_PQUOTA
           botSnkP(i,j,bi,bj) = botSnkP(i,j,bi,bj)
     &                        + dTsub(k)*flux*R_PC(l)
# endif
# ifndef DARWIN_ALLOW_FEQUOTA
           botSnkFe(i,j,bi,bj) = botSnkFe(i,j,bi,bj)
     &                         + dTsub(k)*flux*R_FeC(l)
# endif
# ifndef DARWIN_ALLOW_SIQUOTA
           botSnkSi(i,j,bi,bj) = botSnkSi(i,j,bi,bj)
     &                         + dTsub(k)*flux*R_SiC(l)
# endif
#endif
C
#ifdef DARWIN_ALLOW_NQUOTA
           flux = biosink(l)*MAX(0.0, Ptr(i,j,k,bi,bj,in+l-1))
           gTr(i,j,k  ,in+l-1 )=gTr(i,j,k  ,in+l-1 ) - flux*upfc
# ifdef DARWIN_ALLOW_CONS
           botSnkN(i,j,bi,bj) = botSnkN(i,j,bi,bj) + dTsub(k)*flux
# endif
#endif
C
#ifdef DARWIN_ALLOW_PQUOTA
           flux = biosink(l)*MAX(0.0, Ptr(i,j,k,bi,bj,ip+l-1))
           gTr(i,j,k  ,ip+l-1 )=gTr(i,j,k  ,ip+l-1 ) - flux*upfc
# ifdef DARWIN_ALLOW_CONS
           botSnkP(i,j,bi,bj) = botSnkP(i,j,bi,bj) + dTsub(k)*flux
# endif
#endif
C
#ifdef DARWIN_ALLOW_FEQUOTA
           flux = biosink(l)*MAX(0.0, Ptr(i,j,k,bi,bj,ife+l-1))
           gTr(i,j,k  ,ife+l-1)=gTr(i,j,k  ,ife+l-1) - flux*upfc
# ifdef DARWIN_ALLOW_CONS
           botSnkFe(i,j,bi,bj) = botSnkFe(i,j,bi,bj) + dTsub(k)*flux
# endif
#endif
C
#ifdef DARWIN_ALLOW_SIQUOTA
           flux = biosink(l)*MAX(0.0, Ptr(i,j,k,bi,bj,isi+l-1))
           gTr(i,j,k  ,isi+l-1)=gTr(i,j,k  ,isi+l-1) - flux*upfc
# ifdef DARWIN_ALLOW_CONS
           botSnkSi(i,j,bi,bj) = botSnkSi(i,j,bi,bj) + dTsub(k)*flux
# endif
#endif
          ENDDO
#ifdef DARWIN_ALLOW_CHLQUOTA
          DO l = 1, nPhoto
           flux = biosink(l)*MAX(0.0, Ptr(i,j,k,bi,bj,iChl+l-1))
           gTr(i,j,k  ,iChl+l-1)=gTr(i,j,k  ,iChl+l-1)-flux*upfc
          ENDDO
#endif
         ENDIF
        ENDDO
       ENDDO
      ENDDO
#endif /* DARWIN_BOTTOM_SINK */

#endif /* ALLOW_DARWIN */

      RETURN
      END

