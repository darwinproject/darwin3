#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_CONSERVE_SURFACE
C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_CONSERVE_SURFACE(myTime,myIter,myThid)

C !DESCRIPTION:
C     Fix conservation violation due to linear free surface

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PTRACERS_FIELDS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"
#include "DARWIN_FIELDS.h"

C !INPUT PARAMETERS: ===================================================
      _RL myTime
      INTEGER myIter
      INTEGER myThid
CEOP

#ifdef ALLOW_DARWIN

C !LOCAL VARIABLES: ====================================================
      INTEGER i,j,k,bi,bj
      INTEGER np, iTr
      _RL totflxC
      _RL totflxP
      _RL totflxN
      _RL totflxFe
      _RL totflxSi
#ifdef DARWIN_ALLOW_CARBON
      _RL totflxA
      _RL totflxO
#endif
      _RL vol, voltot
      _RL tilevol(nSx,nSy)

      IF ( DARWIN_linFSConserve ) THEN

      totflxC = 0. _d 0
      totflxP = 0. _d 0
      totflxN = 0. _d 0
      totflxFe = 0. _d 0
      totflxSi = 0. _d 0
#ifdef DARWIN_ALLOW_CARBON
      totflxA = 0. _d 0
      totflxO = 0. _d 0
#endif

c carbon budget
      totflxC=totflxC+totSurfCorPtr(iDIC)
      totflxC=totflxC+totSurfCorPtr(iDOC)
      totflxC=totflxC+totSurfCorPtr(iPOC)
      totflxC=totflxC+totSurfCorPtr(iPIC)
      DO np=1,nplank
        iTr=ic+np-1
        totflxC=totflxC+totSurfCorPtr(iTr)*(1+R_PICPOC(np))
      ENDDO
#ifdef DARWIN_ALLOW_CSTORE
      DO np=1,nPhoto
        iTr=ich+np-1
        totflxC=totflxC+totSurfCorPtr(iTr)
      ENDDO
#endif
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
      totflxC=totflxC+totSurfCorPtr(iCDOM)
# else
      totflxC=totflxC+totSurfCorPtr(iCDOM)*R_CP_CDOM
# endif
#endif

c Phosphorus budget
      totflxP=totflxP+totSurfCorPtr(iPO4)
      totflxP=totflxP+totSurfCorPtr(iDOP)
      totflxP=totflxP+totSurfCorPtr(iPOP)
      DO np=1,nplank
#ifdef DARWIN_ALLOW_PQUOTA
        iTr=ip+np-1
        totflxP=totflxP+totSurfCorPtr(iTr)
#else
        iTr=ic+np-1
        totflxP=totflxP+totSurfCorPtr(iTr)*R_PC(np)
#endif
      ENDDO
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
      totflxP=totflxP+totSurfCorPtr(iCDOM)*R_PC_CDOM
# else
      totflxP=totflxP+totSurfCorPtr(iCDOM)
# endif
#endif

c Nitrogen budget
      totflxN=totflxN+totSurfCorPtr(iNO3)
      totflxN=totflxN+totSurfCorPtr(iNH4)
      totflxN=totflxN+totSurfCorPtr(iNO2)
      totflxN=totflxN+totSurfCorPtr(iDON)
      totflxN=totflxN+totSurfCorPtr(iPON)
      DO np=1,nplank
#ifdef DARWIN_ALLOW_NQUOTA
        iTr=in+np-1
        totflxN=totflxN+totSurfCorPtr(iTr)
#else
        iTr=ic+np-1
        totflxN=totflxN+totSurfCorPtr(iTr)*R_NC(np)
#endif
      ENDDO
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
      totflxN=totflxN+totSurfCorPtr(iCDOM)*R_NC_CDOM
# else
      totflxN=totflxN+totSurfCorPtr(iCDOM)*R_NP_CDOM
# endif
#endif

c Iron budget
      totflxFe=totflxFe+totSurfCorPtr(iFeT)
      totflxFe=totflxFe+totSurfCorPtr(iDOFe)
      totflxFe=totflxFe+totSurfCorPtr(iPOFe)
      DO np=1,nplank
#ifdef DARWIN_ALLOW_FEQUOTA
        iTr=ife+np-1
        totflxFe=totflxFe+totSurfCorPtr(iTr)
#else
        iTr=ic+np-1
        totflxFe=totflxFe+totSurfCorPtr(iTr)*R_FeC(np)
#endif
      ENDDO
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
      totflxFe=totflxFe+totSurfCorPtr(iCDOM)*R_FeC_CDOM
# else
      totflxFe=totflxFe+totSurfCorPtr(iCDOM)*R_FeP_CDOM
# endif
#endif

c Silica budget
      totflxSi=totflxSi+totSurfCorPtr(iSiO2)
      totflxSi=totflxSi+totSurfCorPtr(iPOSi)
      DO np=1,nplank
#ifdef DARWIN_ALLOW_SIQUOTA
        iTr=isi+np-1
        totflxSi=totflxSi+totSurfCorPtr(iTr)
#else
        iTr=ic+np-1
        totflxSi=totflxSi+totSurfCorPtr(iTr)*R_SiC(np)
#endif
      ENDDO
c------------------------------------------------------------
#ifdef DARWIN_ALLOW_CARBON
c alkalinity budget !!!!! NOT FULL BUDGET!!!!!
      totflxA=totflxA+totSurfCorPtr(iALK)
c oxygem budget !!!!!!!! NOT FULL BUDGET !!!!!!!!!!!
      totflxO=totflxO+totSurfCorPtr(iO2)
#endif

      DO bj=myByLo(myThid),myByHi(myThid)
      DO bi=myBxLo(myThid),myBxHi(myThid)
        tilevol(bi,bj) = 0. _d 0
        DO k=1,Nr
        DO i=1,sNx
        DO j=1,sNy
          vol=rA(i,j,bi,bj)*drF(k)*hFacC(i,j,k,bi,bj)
          tilevol(bi,bj) = tilevol(bi,bj) + vol
        ENDDO
        ENDDO
        ENDDO
      ENDDO
      ENDDO
      CALL GLOBAL_SUM_TILE_RL(tilevol,voltot,myThid)

C--   Everyone else must wait
      _BARRIER

C     mean tracer change
      totflxC  = ptracers_dTLev(1)*totflxC /voltot
      totflxN  = ptracers_dTLev(1)*totflxN /voltot
      totflxP  = ptracers_dTLev(1)*totflxP /voltot
      totflxFe = ptracers_dTLev(1)*totflxFe/voltot
      totflxSi = ptracers_dTLev(1)*totflxSi/voltot
#ifdef DARWIN_ALLOW_CARBON
      totflxA  = ptracers_dTLev(1)*totflxA /voltot
      totflxO  = ptracers_dTLev(1)*totflxO /voltot
#endif

C     add neglected flux to tracer globally
      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
        DO k=1,Nr
         DO i=1,sNx
          DO j=1,sNy
           Ptracer(i,j,k,bi,bj,iDIC)=Ptracer(i,j,k,bi,bj,iDIC)+
     &                               totflxC*maskC(i,j,k,bi,bj)
           Ptracer(i,j,k,bi,bj,iPO4)=Ptracer(i,j,k,bi,bj,iPO4)+
     &                               totflxP *maskC(i,j,k,bi,bj)
           Ptracer(i,j,k,bi,bj,iNO3)=Ptracer(i,j,k,bi,bj,iNO3)+
     &                               totflxN *maskC(i,j,k,bi,bj)
           Ptracer(i,j,k,bi,bj,iFeT)=Ptracer(i,j,k,bi,bj,iFeT)+
     &                               totflxFe*maskC(i,j,k,bi,bj)
           Ptracer(i,j,k,bi,bj,iSiO2)=Ptracer(i,j,k,bi,bj,iSiO2)+
     &                               totflxSi*maskC(i,j,k,bi,bj)
#ifdef DARWIN_ALLOW_CARBON
           Ptracer(i,j,k,bi,bj,iALK)=Ptracer(i,j,k,bi,bj,iALK)+
     &                               totflxA*maskC(i,j,k,bi,bj)
           Ptracer(i,j,k,bi,bj,iO2 )=Ptracer(i,j,k,bi,bj,iO2 )+
     &                               totflxO*maskC(i,j,k,bi,bj)
#endif
          ENDDO
         ENDDO
        ENDDO
       ENDDO
      ENDDO

C     DARWIN_linFSConserve
      ENDIF

#endif /* ALLOW_DARWIN */

      RETURN
      END

