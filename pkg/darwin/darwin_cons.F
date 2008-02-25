C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_cons.F,v 1.3 2008/02/25 21:09:57 jahn Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "GCHEM_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

c=============================================================
c subroutine DARWIN_cons
c check conservation in the model
C==============================================================
         SUBROUTINE DARWIN_Cons(
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
       INTEGER myIter
       _RL myTime
       INTEGER myThid

#ifdef CHECK_CONS
C============== Local variables ============================================
       _RL tmptotP
       _RL tmptotN
       _RL tmptotSi
       _RL tmptotFe
       _RL vol, voltot

       INTEGER i,j,k,bi,bj
       INTEGER np, nz, npnum


      _BEGIN_MASTER(myThid)
c
         tmptotP=0. _d 0
         tmptotN=0. _d 0
         tmptotFe=0. _d 0
         tmptotSi=0. _d 0
         voltot=0. _d 0

        DO bj=myByLo(myThid),myByHi(myThid)
        DO bi=myBxLo(myThid),myBxHi(myThid)
 
         DO i=1,sNx
         DO j=1,sNy
          do k= 1, NR
c-----------------------------------------------------------------
           vol=rA(i,j,bi,bj)*drF(k)
           voltot=voltot+vol
c Phosphorus budget
           tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,1)*vol    !PO4
           tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,5)*vol    !DOP
           tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,16)*vol   !POP
           tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,8)*vol    !ZOO1P
           tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,12)*vol   !ZOO2P
           do np=1,npmax
              npnum=21+np
              tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,npnum)*vol  !Phy 
           enddo
c Nitrogen budget
           tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,2)*vol    !NO3
           tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,20)*vol   !NH4
           tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,21)*vol   !NO2
           tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,6)*vol    !DON
           tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,17)*vol   !PON
           tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,9)*vol    !ZOO1N
           tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,13)*vol   !ZOO2N
           do np=1,npmax
              npnum=21+np
              tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,npnum)*R_NP(np)*vol  !Phy
           enddo
c Iron budget
           tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,3)*vol    !Fet
           tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,7)*vol    !DOFe
           tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,18)*vol   !POFe
           tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,10)*vol   !ZOO1Fe
           tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,14)*vol   !ZOO2Fe
           do np=1,npmax
              npnum=21+np
              tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,npnum)*R_FeP(np)*vol  !Phy
           enddo
c Silica budget
           tmptotSi=tmptotSi+Ptracer(i,j,k,bi,bj,4)*vol    !Si
           tmptotSi=tmptotSi+Ptracer(i,j,k,bi,bj,19)*vol   !POSi
           tmptotSi=tmptotSi+Ptracer(i,j,k,bi,bj,11)*vol   !ZOO1Si
           tmptotSi=tmptotSi+Ptracer(i,j,k,bi,bj,15)*vol   !ZOO2Si
           do np=1,npmax
              npnum=21+np
              tmptotSi=tmptotSi+Ptracer(i,j,k,bi,bj,npnum)*R_SiP(np)*vol  !Phy
           enddo
c------------------------------------------------------------
          enddo
         ENDDO
         ENDDO
        ENDDO
        ENDDO

        _GLOBAL_SUM_R8(tmptotP,myThid)
        _GLOBAL_SUM_R8(tmptotN,myThid)
        _GLOBAL_SUM_R8(tmptotFe,myThid)
        _GLOBAL_SUM_R8(tmptotSi,myThid)

        print*,'tmptotP',tmptotP
        print*,'tmptotN',tmptotN
        print*,'tmptotFe',tmptotFe
        print*,'tmptotSi',tmptotSi

        write(DAR_cons_unit1,*), myIter, tmptotP, tmptotP/voltot
        write(DAR_cons_unit2,*), myIter, tmptotN, tmptotN/voltot
        write(DAR_cons_unit3,*), myIter, tmptotFe, tmptotFe/voltot
        write(DAR_cons_unit4,*), myIter, tmptotSi, tmptotSi/voltot

      _END_MASTER(myThid)

C--   Everyone else must wait
      _BARRIER
#endif
c
c -----------------------------------------------------
        RETURN
        END
#endif  /*DARWIN*/
#endif  /*ALLOW_PTRACERS*/

C============================================================================
