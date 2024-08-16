#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_LIGHT_RADTRANS
C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_LIGHT_RADTRANS(
     O                         PAR,
     I                         solTime,
     I                         bi, bj, iMin, iMax, jMin, jMax,
     I                         myTime, myIter, myThid )

C !DESCRIPTION:

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "GRID.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
C#include "DYNVARS.h"
#include "FFIELDS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_FIELDS.h"
#ifdef ALLOW_RADTRANS
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"
#endif
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_EXF_FIELDS.h"
#include "DARWIN_RADTRANS.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"
#include "DARWIN_FIELDS.h"

C !INPUT PARAMETERS: ===================================================
C  myTime :: time at end of (sub)timestep
C  myThid :: thread number
      _RL solTime
      _RL myTime
      INTEGER bi, bj, iMin, iMax, jMin, jMax, myIter, myThid

C !OUTPUT PARAMETERS: ==================================================
      _RL PAR(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
CEOP

#ifdef ALLOW_DARWIN
#ifdef ALLOW_RADTRANS

C!LOCAL VARIABLES: ====================================================
C  i,j                  :: loop indices
C  k                    :: vertical level
      LOGICAL  DIAGNOSTICS_IS_ON
      EXTERNAL DIAGNOSTICS_IS_ON
      CHARACTER*8 diagname
      INTEGER i,j,k,l,jp
      _RL part
      _RL aCDOM(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL phychl(nPhoto)
      _RL plankcar(nPlank)
#ifdef DARWIN_ALLOW_CDOM
      _RL CDOM
#else
      _RL actotref, atotref
#endif
      _RL E0F(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr+1, nlam)
      _RL PARF(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr+1, nlam)
      _RL actot
      _RL bctot
      _RL bbctot
C
      _RL aprt
      _RL btprt
      _RL bbprt

      _RL a3d(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL bt3d(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL bb3d(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
#ifdef ALLOW_DIAGNOSTICS
#ifdef DARWIN_DIAG_IOP
      _RL aplk3d(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL btplk3d(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL bbplk3d(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL aprt3d(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL btprt3d(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
      _RL bbprt3d(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr, nlam)
#endif
#endif

C ======================================================================
      DO j=jMin,jMax
       DO i=iMin,iMax
        DO k=1,Nr

         part = MAX(Ptracer(i,j,k,bi,bj,iPOP), 0 _d 0)
         part = part + (darwin_RPOC/120 _d 0)
         DO jp=1,nPhoto
#ifdef DARWIN_ALLOW_CHLQUOTA
          phychl(jp)=MAX(Ptracer(i,j,k,bi,bj,iChl+jp-1),0 _d 0)
#else
          phychl(jp)=MAX(chlPrev(i,j,k,bi,bj,jp), 0 _d 0)
#endif
         ENDDO
         DO jp=1,nPlank
          plankcar(jp)=MAX(Ptracer(i,j,k,bi,bj,ic+jp-1),0 _d 0)
         ENDDO

#ifdef DARWIN_ALLOW_CDOM
c use cdom-like tracer
         CDOM = MAX(Ptracer(i,j,k,bi,bj,iCDOM), 0 _d 0)
         CDOM = CDOM + darwin_rCDOM
         DO l = 1,nlam
          aCDOM(i,j,k,l) = CDOMcoeff*CDOM*exCDOM(l)
         ENDDO
#else
         actotref = 0.0 _d 0
         atotref = 0.0 _d 0
         DO jp = 1,nPhoto
c         nb. n,k swapped from WG
          actotref = actotref +
     &          phychl(jp)*aphy_chl(jp,laCDOM)
         ENDDO
         atotref = aw(laCDOM) + actotref
         DO l = 1,nlam
          aCDOM(i,j,k,l) = darwin_aCDOM_fac*atotref*exCDOM(l)
         ENDDO
#endif

         DO l = 1,nlam
c         absorption by phyto
          actot = 0.0
          bctot = 0.0
          bbctot = 0.0
          DO jp = 1, nPhoto
           actot  = actot  + phychl(jp)*aphy_chl(jp,l)
#ifdef DARWIN_SCATTER_CHL
           bctot  = bctot  + phychl(jp)*bphy_mgC(jp,l)
           bbctot = bbctot + phychl(jp)*bbphy_mgC(jp,l)
#endif
          ENDDO
          DO jp = 1, nPlank
           actot  = actot  + plankcar(jp)*aphy_mgC(jp,l)*12
#ifndef DARWIN_SCATTER_CHL
c          convert mmol C to mg C
           bctot  = bctot  + plankcar(jp)*bphy_mgC(jp,l)*12
           bbctot = bbctot + plankcar(jp)*bbphy_mgC(jp,l)*12
#endif
          ENDDO
c         add water, CDOM and particles
          aprt =  part*apart_P(l)
          btprt = part*bpart_P(l)
          bbprt = part*bbpart_P(l)
          a3d(i,j,k,l) = aw(l) + aCDOM(i,j,k,l) + actot  + aprt
          bt3d(i,j,k,l) = bw(l)                 + bctot  + btprt
          bb3d(i,j,k,l) = darwin_bbw*bw(l)         + bbctot + bbprt
          bb3d(i,j,k,l) = MAX(darwin_bbmin, bb3d(i,j,k,l))
#ifdef ALLOW_DIAGNOSTICS
#ifdef DARWIN_DIAG_IOP
          aplk3d(i,j,k,l) = actot
          btplk3d(i,j,k,l) = bctot
          bbplk3d(i,j,k,l) = bbctot
          aprt3d(i,j,k,l) = aprt
          btprt3d(i,j,k,l) = btprt
          bbprt3d(i,j,k,l) = bbprt
#endif
#endif
         ENDDO

C       k
        ENDDO

C      i,j
       ENDDO
      ENDDO
C ======================================================================

      CALL RADTRANS_CALC(
     I                   a3d, bt3d, bb3d,
     O                   E0F,
     I                   bi, bj, iMin, iMax, jMin, jMax,
     I                   myTime, myIter, myThid)

      DO l=1,nlam
       DO k=1,Nr+1
        DO j=jMin,jMax
         DO i=iMin,iMax
          PARF(i,j,k,l) = E0F(i,j,k,l)*RT_WtouEins(l)
         ENDDO
        ENDDO
       ENDDO
       DO k=1,Nr
        DO j=jMin,jMax
         DO i=iMin,iMax
          PAR(i,j,k,l) = SQRT(PARF(i,j,k,l)*PARF(i,j,k+1,l))
         ENDDO
        ENDDO
       ENDDO
      ENDDO

C ======================================================================

#ifdef ALLOW_DIAGNOSTICS
      IF (useDIAGNOSTICS .AND. myIter .GE.0) THEN
      DO l = 1, nlam
       WRITE(diagname, '(A,I3.3)') 'PARF', l
       CALL DIAGNOSTICS_FILL(PARF(1-OLx,1-OLy,1,l),diagname,0,Nr,2,
     &       bi,bj,myThid)
#ifdef DARWIN_DIAG_IOP
       WRITE(diagname, '(A,I3.3)') 'a', l
       CALL DIAGNOSTICS_FILL(a3d(1-OLx,1-OLy,1,l),diagname,0,Nr,2,
     &       bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'bt', l
       CALL DIAGNOSTICS_FILL(bt3d(1-OLx,1-OLy,1,l),diagname,0,Nr,2,
     &       bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'bb', l
       CALL DIAGNOSTICS_FILL(bb3d(1-OLx,1-OLy,1,l),diagname,0,Nr,2,
     &       bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'aplk', l
       CALL DIAGNOSTICS_FILL(aplk3d(1-OLx,1-OLy,1,l),diagname,0,Nr,2,
     &     bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'btplk', l
       CALL DIAGNOSTICS_FILL(btplk3d(1-OLx,1-OLy,1,l),diagname,0,Nr,2,
     &     bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'bbplk', l
       CALL DIAGNOSTICS_FILL(bbplk3d(1-OLx,1-OLy,1,l),diagname,0,Nr,2,
     &     bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'aprt', l
       CALL DIAGNOSTICS_FILL(aprt3d(1-OLx,1-OLy,1,l),diagname,0,Nr,2,
     &     bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'btprt', l
       CALL DIAGNOSTICS_FILL(btprt3d(1-OLx,1-OLy,1,l),diagname,0,Nr,2,
     &     bi,bj,myThid)
       WRITE(diagname, '(A,I3.3)') 'bbprt', l
       CALL DIAGNOSTICS_FILL(bbprt3d(1-OLx,1-OLy,1,l),diagname,0,Nr,2,
     &     bi,bj,myThid)
#endif
       WRITE(diagname, '(A,I3.3)') 'aCDOM', l
       CALL DIAGNOSTICS_FILL(aCDOM(1-OLx,1-OLy,1,l),diagname,0,Nr,2,
     &     bi,bj,myThid)
      ENDDO
       IF (DIAGNOSTICS_IS_ON('PARF    ', myThid)) THEN
        DO l=2,nlam
         DO k=1,Nr
          DO j=jMin,jMax
           DO i= iMin,iMax
            PARF(i,j,k,1) = PARF(i,j,k,1) + PARF(i,j,k,l)
           ENDDO
          ENDDO
         ENDDO
        ENDDO
        WRITE(diagname, '(A)') 'PARF'
        CALL DIAGNOSTICS_FILL(PARF,diagname,0,Nr,2,bi,bj,myThid)
       ENDIF
C PAR is done in darwin_forcing
      ENDIF
#endif

#endif /* ALLOW_RADTRANS */
#endif /* ALLOW_DARWIN */

      RETURN
      END
