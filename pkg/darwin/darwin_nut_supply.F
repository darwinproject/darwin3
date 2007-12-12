C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_nut_supply.F,v 1.2 2007/12/12 21:19:01 jahn Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "GCHEM_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

c=============================================================
c subroutine DARWIN_forcing
c step forward nut supply of nutrients
C==============================================================
         SUBROUTINE DARWIN_Nut_Supply(Nut,
     &                  bi,bj,imin,imax,jmin,jmax,
     &                  myIter,myTime,myThid)
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DARWIN_IO.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS.h"
#include "GCHEM.h"
#include "DARWIN_SIZE.h"
#include "DARWIN.h"
#include "DYNVARS.h"

C     === Global variables ===
c tracers
      _RL  Nut(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx, nSy)
       INTEGER myIter
       _RL myTime
       INTEGER myThid
       INTEGER bi,bj,imin,imax,jmin,jmax

C============== Local variables ============================================
       _RL dnut(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
       _RL tmp
       _RL nuttmp

      INTEGER i,j,k
c
#ifdef NUT_SUPPLY
c
       DO j=1-OLy,sNy+OLy
       DO i=1-OLx,sNx+OLx
        do k=1,Nr
          dnut(i,j,k)=0. _d 0
        enddo
       ENDDO
       ENDDO
c
       DO j=1-OLy,sNy+OLy
       DO i=1-OLx,sNx+OLx
        do k=1,Nr-1
         if (HFacC(i,j,k,bi,bj).gt.0. _d 0.and.
     &                          HFacC(i,j,k+1,bi,bj).gt.0. _d 0) then
c         nuttmp=( drF(k+1)*Nut(i,j,k,bi,bj) + 
c    &              drF(k)*Nut(i,j,k+1,bi,bj) )/( drF(k)+drF(k+1) )
#ifdef CONS_SUPP
c note only works for 2 layer
          if (nut_wvel(i,j,k+1,bi,bj).gt.0. _d 0) then
            tmp= nut_wvel(i,j,k+1,bi,bj)*Nut(i,j,k+1,bi,bj)
          else
            tmp= nut_wvel(i,j,k+1,bi,bj)*0. _d 0 !Nut(i,j,k,bi,bj)
          endif
          dnut(i,j,k)=dnut(i,j,k)+ tmp/ drF(k)
          dnut(i,j,k+1)=0. _d 0
#else
          if (nut_wvel(i,j,k+1,bi,bj).gt.0. _d 0) then
            tmp= nut_wvel(i,j,k+1,bi,bj)*Nut(i,j,k+1,bi,bj)
          else
            tmp= nut_wvel(i,j,k+1,bi,bj)*Nut(i,j,k,bi,bj)
          endif
          dnut(i,j,k)=dnut(i,j,k)+ tmp/ drF(k)
          dnut(i,j,k+1)=dnut(i,j,k+1)- tmp/ drF(k+1)
#endif
         endif
c       if (i.eq.1) print*,'dnut',j,dnut(i,j,k),nut_wvel(i,j,k,bi,bj),
c    &                      Nut(i,j,k,bi,bj)
        enddo
       ENDDO
       ENDDO
c
       DO j=1-OLy,sNy+OLy
       DO i=1-OLx,sNx+OLx
        do k=1,Nr
             Nut(i,j,k,bi,bj) = Nut(i,j,k,bi,bj)+
     &                          dTtracerLev(k)*dnut(i,j,k)
        enddo
c end layer loop
       ENDDO
       ENDDO
c 
#endif /*NUT_SUPPLY*/
        RETURN
        END
#endif  /*DARWIN*/
#endif  /*ALLOW_PTRACERS*/

C============================================================================
