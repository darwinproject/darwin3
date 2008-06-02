C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_forcing.F,v 1.6 2008/06/02 16:17:51 jahn Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "GCHEM_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

c=============================================================
c subroutine DARWIN_forcing
c step forward bio-chemical tracers in time
C==============================================================
         SUBROUTINE DARWIN_Forcing(PO4,NO3,FeT,Si,
     &                  DOP,DON,DOFe,
     &                  Zoo1P,Zoo1N,Zoo1Fe,Zoo1Si,
     &                  Zoo2P,Zoo2N,Zoo2Fe,Zoo2Si,
     &                  POP,PON,POFe,PSi,
     &                  NH4,NO2,
     &                  Phy1,Phy2,Phy3,Phy4,Phy5,Phy6,
     &                  Phy7,Phy8,Phy9,Phy10,Phy11,Phy12,
     &                  Phy13,Phy14,Phy15,Phy16,Phy17,Phy18,
     &                  Phy19,Phy20,Phy21,Phy22,Phy23,Phy24,
     &                  Phy25,Phy26,Phy27,Phy28,Phy29,Phy30,
     &                  Phy31,Phy32,Phy33,Phy34,Phy35,
     &                  Phy36,Phy37,Phy38,Phy39,
     &                  Phy40,Phy41,Phy42,Phy43,Phy44,
     &                  Phy45,Phy46,Phy47,Phy48,Phy49,
     &                  Phy50,Phy51,Phy52,Phy53,Phy54,
     &                  Phy55,Phy56,Phy57,Phy58,Phy59,
     &                  Phy60,Phy61,Phy62,Phy63,Phy64,
     &                  Phy65,Phy66,Phy67,Phy68,Phy69,
     &                  Phy70,Phy71,Phy72,Phy73,Phy74,
     &                  Phy75,Phy76,Phy77,Phy78,
     &                  bi,bj,imin,imax,jmin,jmax,
     &                  myIter,myTime,myThid)
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DARWIN_IO.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "GCHEM.h"
#include "DARWIN_SIZE.h"
#include "DARWIN.h"
#include "DYNVARS.h"
#ifdef USE_QSW
#include "FFIELDS.h"
#endif

C     === Global variables ===
c tracers
      _RL  PO4(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  NO3(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  FeT(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Si(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  DOP(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  DON(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  DOFe(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Zoo1P(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Zoo1N(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Zoo1Fe(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Zoo1Si(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Zoo2P(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Zoo2N(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Zoo2Fe(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Zoo2Si(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy2(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy3(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy4(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy5(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy6(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy7(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy8(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy9(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy10(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy11(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy12(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy13(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy14(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy15(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy16(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy17(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy18(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy19(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy20(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy21(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy22(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy23(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy24(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy25(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy26(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy27(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy28(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy29(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy30(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy31(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy32(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy33(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy34(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy35(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy36(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy37(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy38(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy39(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy40(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy41(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy42(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy43(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy44(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy45(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy46(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy47(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy48(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy49(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy50(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy51(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy52(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy53(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy54(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy55(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy56(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy57(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy58(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy59(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy60(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy61(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy62(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy63(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy64(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy65(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy66(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy67(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy68(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy69(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy70(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy71(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy72(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy73(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy74(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy75(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy76(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy77(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Phy78(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  POP(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  PON(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  POFe(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  PSi(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  NH4(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  NO2(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
       INTEGER myIter
       _RL myTime
       INTEGER myThid
       INTEGER bi,bj,imin,imax,jmin,jmax

C============== Local variables ============================================
c plankton arrays
      _RL  ZooP(nzmax)
      _RL  ZooN(nzmax)
      _RL  ZooFe(nzmax)
      _RL  ZooSi(nzmax)
      _RL  Phy(npmax)
      _RL  Phyup(npmax)
c iron partitioning
      _RL  freefe(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
c some working variables
      _RL  sumpy
      _RL  sumpyup
c light variables
      _RL  PAR(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  sfac(1-OLy:sNy+OLy)
      _RL  atten,lite
      _RL  newtime     ! for sub-timestepping
      _RL  runtim      ! time from tracer initialization

#ifdef DAR_DIAG_DIVER
      _RL  Diver1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Diver2(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Diver3(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Diver4(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)

      _RL  tmpphy(npmax)
      _RL  totphy, biotot, maxphy, phymax
#endif

#ifdef ALLOW_DIAGNOSTICS
COJ for diagnostics
      _RL  PParr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Nfixarr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
#ifdef DAR_DIAG_RSTAR
      _RL  Rstararr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,npmax)
#endif
COJ
#endif

c   
      _RL freefu
      _RL inputFel

c some local variables
       _RL PO4l
       _RL NO3l
       _RL FeTl
       _RL Sil
       _RL DOPl
       _RL DONl
       _RL DOFel
       _RL POPl
       _RL PONl
       _RL POFel
       _RL PSil
       _RL POPupl
       _RL PONupl
       _RL POFeupl
       _RL PSiupl
       _RL Tlocal
       _RL Slocal
       _RL NH4l
       _RL NO2l
       _RL PARl
       _RL dzlocal
       _RL dtplankton
       _RL bottom
       _RL PP
       _RL Nfix
       _RL Rstarl(npmax)
       _RL RNstarl(npmax)

c local tendencies
       _RL dphy(npmax)
       _RL dzoop(nzmax)
       _RL dzoon(nzmax)
       _RL dzoofe(nzmax)
       _RL dzoosi(nzmax)
       _RL dPO4l
       _RL dNO3l
       _RL dFeTl
       _RL dSil
       _RL dDOPl
       _RL dDONl
       _RL dDOFel
       _RL dPOPl
       _RL dPONl
       _RL dPOFel
       _RL dPSil
       _RL dNH4l
       _RL dNO2l

       _RL tot_Nfix

      INTEGER i,j,k,it, ktmp
      INTEGER np, nz, np2, npsave
      INTEGER debug
      CHARACTER*8 diagname


c
       DO j=1-OLy,sNy+OLy
       DO i=1-OLx,sNx+OLx
        do k=1,Nr
           freefe(i,j,k)=0. _d 0
           PAR(i,j,k) = 0. _d 0
#ifdef DAR_DIAG_DIVER
           Diver1(i,j,k)=0. _d 0
           Diver2(i,j,k)=0. _d 0
           Diver3(i,j,k)=0. _d 0
           Diver4(i,j,k)=0. _d 0
#endif

#ifdef ALLOW_DIAGNOSTICS
COJ for diagnostics
           PParr(i,j,k) = 0. _d 0
           Nfixarr(i,j,k) = 0. _d 0
#ifdef DAR_DIAG_RSTAR
           DO np=1,npmax
             Rstararr(i,j,k,np) = 0. _d 0
           ENDDO
#endif
COJ
#endif
        enddo
       ENDDO
       ENDDO
c
c bio-chemical time loop
c--------------------------------------------------
       DO it=1,nsubtime
c -------------------------------------------------
         tot_Nfix=0. _d 0
COJ cannot use dfloat because of adjoint
COJ division will be double precision anyway because of dTtracerLev
         newtime=myTime-dTtracerLev(1)+
     &           float(it)*dTtracerLev(1)/float(nsubtime)
c        print*,'it  ',it,newtime,nsubtime,myTime
         runtim=myTime-float(PTRACERS_Iter0)*dTtracerLev(1)

c determine iron partitioning  - solve for free iron
c ---------------------------
         call darwin_fe_chem(bi,bj,iMin,iMax,jMin,jMax, FeT, freefe,
     &                       myIter, mythid)
c --------------------------

 
c find light in each grid cell
c ---------------------------
c determine incident light
#ifndef  READ_PAR
#ifdef USE_QSW
         DO j=1-OLy,sNy+OLy
         DO i=1-OLx,sNx+OLx
           sur_par(i,j,bi,bj)=-parfrac*Qsw(i,j,bi,bj)*
     &                         parconv*maskC(i,j,1,bi,bj)
         ENDDO
         ENDDO
#else
         DO j=1-OLy,sNy+OLy
          sfac(j)=0. _d 0
         ENDDO
         call darwin_insol(newTime,sfac,bj)
         DO j=1-OLy,sNy+OLy
         DO i=1-OLx,sNx+OLx
           sur_par(i,j,bi,bj)=sfac(j)*maskC(i,j,1,bi,bj)/86400*1 _d 6
c          if (i.eq.1.and.j.ge.1.and.j.le.sNy) 
c    &                write(24,*) sur_par(i,j,bi,bj)
         ENDDO
         ENDDO
#endif
#endif

C.................................................................
C.................................................................


         DO j=1,sNy 
          DO i=1,sNx

c surface PAR
c take ice coverage into account
#if (defined (ALLOW_SEAICE) && defined (USE_QSW))
COJ ice coverage already taken into account by seaice package
           lite=sur_par(i,j,bi,bj)
#else
#if (defined (ALLOW_SEAICE) && defined (USE_QSW))
c if using Qsw and seaice, then ice fraction is already
c taken into account
           lite=sur_par(i,j,bi,bj)
#else
           lite=sur_par(i,j,bi,bj)*(1. _d 0-fice(i,j,bi,bj))
#endif
#endif
           atten=0. _d 0
           sumpy = 0.0 _d 0

c for each layer ...   
          do k= 1, NR   
           if (HFacC(i,j,k,bi,bj).gt.0. _d 0) then

c make sure we only deal with positive definite numbers
c brute force...
             po4l = max(PO4(i,j,k),0. _d 0)
             no3l = max(NO3(i,j,k),0. _d 0)
             fetl = max(FeT(i,j,k),0. _d 0)
             sil  = max(Si(i,j,k),0. _d 0)
             dopl = max(DOP(i,j,k),0. _d 0)
             donl = max(DON(i,j,k),0. _d 0)
             doFel   = max(DOFe(i,j,k),0. _d 0)
             zoop(1)  = max(Zoo1P(i,j,k),0. _d 0)
             zoon(1)  = max(Zoo1N(i,j,k),0. _d 0)
             zooFe(1) = max(Zoo1Fe(i,j,k),0. _d 0)
             zooSi(1)  = max(Zoo1Si(i,j,k),0. _d 0)
             zoop(2)  = max(Zoo2P(i,j,k),0. _d 0)
             zoon(2)  = max(Zoo2N(i,j,k),0. _d 0)
             zooFe(2) = max(Zoo2Fe(i,j,k),0. _d 0)
             zooSi(2)  = max(Zoo2Si(i,j,k),0. _d 0)
             Phy(1) = max(Phy1(i,j,k),0. _d 0)
             Phy(2)  = max(Phy2(i,j,k),0. _d 0)
             Phy(3)  = max(Phy3(i,j,k),0. _d 0)
             Phy(4)  = max(Phy4(i,j,k),0. _d 0)
             Phy(5)  = max(Phy5(i,j,k),0. _d 0)
             Phy(6)  = max(Phy6(i,j,k),0. _d 0)
             Phy(7)  = max(Phy7(i,j,k),0. _d 0)
             Phy(8)  = max(Phy8(i,j,k),0. _d 0)
             Phy(9)  = max(Phy9(i,j,k),0. _d 0)
             Phy(10)  = max(Phy10(i,j,k),0. _d 0)
             Phy(11)  = max(Phy11(i,j,k),0. _d 0)
             Phy(12)  = max(Phy12(i,j,k),0. _d 0)
             Phy(13)  = max(Phy13(i,j,k),0. _d 0)
             Phy(14)  = max(Phy14(i,j,k),0. _d 0)
             Phy(15)  = max(Phy15(i,j,k),0. _d 0)
             Phy(16)  = max(Phy16(i,j,k),0. _d 0)
             Phy(17)  = max(Phy17(i,j,k),0. _d 0)
             Phy(18)  = max(Phy18(i,j,k),0. _d 0)
             Phy(19)  = max(Phy19(i,j,k),0. _d 0)
             Phy(20)  = max(Phy20(i,j,k),0. _d 0)
             Phy(21)  = max(Phy21(i,j,k),0. _d 0)
             Phy(22)  = max(Phy22(i,j,k),0. _d 0)
             Phy(23)  = max(Phy23(i,j,k),0. _d 0)
             Phy(24)  = max(Phy24(i,j,k),0. _d 0)
             Phy(25)  = max(Phy25(i,j,k),0. _d 0)
             Phy(26)  = max(Phy26(i,j,k),0. _d 0)
             Phy(27)  = max(Phy27(i,j,k),0. _d 0)
             Phy(28)  = max(Phy28(i,j,k),0. _d 0)
             Phy(29)  = max(Phy29(i,j,k),0. _d 0)
             Phy(30)  = max(Phy30(i,j,k),0. _d 0)
             Phy(31)  = max(Phy31(i,j,k),0. _d 0)
             Phy(32)  = max(Phy32(i,j,k),0. _d 0)
             Phy(33)  = max(Phy33(i,j,k),0. _d 0)
             Phy(34)  = max(Phy34(i,j,k),0. _d 0)
             Phy(35)  = max(Phy35(i,j,k),0. _d 0)
             Phy(36)  = max(Phy36(i,j,k),0. _d 0)
             Phy(37)  = max(Phy37(i,j,k),0. _d 0)
             Phy(38)  = max(Phy38(i,j,k),0. _d 0)
             Phy(39)  = max(Phy39(i,j,k),0. _d 0)
             Phy(40)  = max(Phy40(i,j,k),0. _d 0)
             Phy(41)  = max(Phy41(i,j,k),0. _d 0)
             Phy(42)  = max(Phy42(i,j,k),0. _d 0)
             Phy(43)  = max(Phy43(i,j,k),0. _d 0)
             Phy(44)  = max(Phy44(i,j,k),0. _d 0)
             Phy(45)  = max(Phy45(i,j,k),0. _d 0)
             Phy(46)  = max(Phy46(i,j,k),0. _d 0)
             Phy(47)  = max(Phy47(i,j,k),0. _d 0)
             Phy(48)  = max(Phy48(i,j,k),0. _d 0)
             Phy(49)  = max(Phy49(i,j,k),0. _d 0)
             Phy(50)  = max(Phy50(i,j,k),0. _d 0)
             Phy(51)  = max(Phy51(i,j,k),0. _d 0)
             Phy(52)  = max(Phy52(i,j,k),0. _d 0)
             Phy(53)  = max(Phy53(i,j,k),0. _d 0)
             Phy(54)  = max(Phy54(i,j,k),0. _d 0)
             Phy(55)  = max(Phy55(i,j,k),0. _d 0)
             Phy(56)  = max(Phy56(i,j,k),0. _d 0)
             Phy(57)  = max(Phy57(i,j,k),0. _d 0)
             Phy(58)  = max(Phy58(i,j,k),0. _d 0)
             Phy(59)  = max(Phy59(i,j,k),0. _d 0)
             Phy(60)  = max(Phy60(i,j,k),0. _d 0)
             Phy(61)  = max(Phy61(i,j,k),0. _d 0)
             Phy(62)  = max(Phy62(i,j,k),0. _d 0)
             Phy(63)  = max(Phy63(i,j,k),0. _d 0)
             Phy(64)  = max(Phy64(i,j,k),0. _d 0)
             Phy(65)  = max(Phy65(i,j,k),0. _d 0)
             Phy(66)  = max(Phy66(i,j,k),0. _d 0)
             Phy(67)  = max(Phy67(i,j,k),0. _d 0)
             Phy(68)  = max(Phy68(i,j,k),0. _d 0)
             Phy(69)  = max(Phy69(i,j,k),0. _d 0)
             Phy(70)  = max(Phy70(i,j,k),0. _d 0)
             Phy(71)  = max(Phy71(i,j,k),0. _d 0)
             Phy(72)  = max(Phy72(i,j,k),0. _d 0)
             Phy(73)  = max(Phy73(i,j,k),0. _d 0)
             Phy(74)  = max(Phy74(i,j,k),0. _d 0)
             Phy(75)  = max(Phy75(i,j,k),0. _d 0)
             Phy(76)  = max(Phy76(i,j,k),0. _d 0)
             Phy(77)  = max(Phy77(i,j,k),0. _d 0)
             Phy(78)  = max(Phy78(i,j,k),0. _d 0)
             POPl = max(POP(i,j,k),0. _d 0)
             PONl = max(PON(i,j,k),0. _d 0)
             POFel = max(POFe(i,j,k),0. _d 0)
             PSil = max(Psi(i,j,k),0. _d 0)
             NH4l = max(NH4(i,j,k),0. _d 0)
             NO2l = max(NO2(i,j,k),0. _d 0)

#ifdef DAR_DIAG_DIVER
            Diver1(i,j,k)=0. _d 0
            Diver2(i,j,k)=0. _d 0
            Diver3(i,j,k)=0. _d 0
            Diver4(i,j,k)=0. _d 0
            totphy=0. _d 0
            do np=1,npmax
              totphy=totphy + Phy(np)
              tmpphy(np)=Phy(np)
            enddo
            if (totphy.gt.diver_thresh0) then
              do np=1,npmax
c simple threshhold
               if (Phy(np).gt.diver_thresh1) then
                 Diver1(i,j,k)=Diver1(i,j,k)+1. _d 0
               endif
c proportion of total biomass
               if (Phy(np)/totphy.gt.diver_thresh2) then
                 Diver2(i,j,k)=Diver2(i,j,k)+1. _d 0
               endif
              enddo
c majority of biomass by finding rank order
               biotot=0. _d 0
               do np2=1,npmax
                 phymax=0. _d 0
                 do np=1,npmax
                   if (tmpphy(np).gt.phymax) then
                     phymax=tmpphy(np)
                     npsave=np
                   endif
                 enddo
                 if (biotot.lt.totphy*diver_thresh3) then
                    Diver3(i,j,k)=Diver3(i,j,k)+1. _d 0
                 endif
                 biotot=biotot+tmpphy(npsave)
                 tmpphy(npsave)=0. _d 0
                 if (np2.eq.1) then
                    maxphy=phymax
                 endif
               enddo
c ratio of maximum species
               do np=1,npmax
                 if (Phy(np).gt.diver_thresh4*maxphy) then
                    Diver4(i,j,k)=Diver4(i,j,k)+1. _d 0
                 endif
               enddo
            endif
#endif

c find local light
             sumpyup = sumpy
             sumpy = 0. _d 0
             do np=1,npmax
                sumpy = sumpy + Phy(np)
             enddo
             atten= atten + (k0 + kc*sumpy)*5. _d -1*drF(k)
             if (k.gt.1)then
               atten = atten + (k0+kc*sumpyup)*5. _d -1*drF(k-1)
             endif
             PAR(i,j,k) = lite*exp(-atten)


c for explicit sinking of particulate matter and phytoplankton
             if (k.eq.1) then
                popupl =0. _d 0
                ponupl =0. _d 0
                pofeupl = 0. _d 0
                psiupl = 0. _d 0
                do np=1,npmax
                  Phyup(np)=0. _d 0
                enddo
             endif


             PARl = PAR(i,j,k)
             
             Tlocal = theta(i,j,k,bi,bj)
             Slocal = salt(i,j,k,bi,bj)

             freefu = max(freefe(i,j,k),0. _d 0)
             if (k.eq.1) then
               inputFel = inputFe(i,j,bi,bj)
             else
               inputFel = 0. _d 0
             endif

             dzlocal = drF(k)*HFacC(i,j,k,bi,bj)
c set bottom=1.0 if the layer below is not ocean
             ktmp=min(nR,k+1)
             if(hFacC(i,j,ktmp,bi,bj).eq.0. _d 0.or.k.eq.Nr) then
               bottom = 1.0 _d 0
             else
               bottom = 0.0 _d 0
             endif

c set tendencies to 0
             do np=1,npmax
               dphy(np)=0. _d 0
             enddo
             do nz=1,nzmax
               dzoop(nz)=0. _d 0
               dzoon(nz)=0. _d 0
               dzoofe(nz)=0. _d 0
               dzoosi(nz)=0. _d 0
             enddo
             dPO4l=0. _d 0
             dNO3l=0. _d 0
             dFeTl=0. _d 0
             dSil=0. _d 0
             dDOPl=0. _d 0
             dDONl=0. _d 0
             dDOFel=0. _d 0
             dPOPl=0. _d 0
             dPONl=0. _d 0
             dPOFel=0. _d 0
             dPSil=0. _d 0
             dNH4l=0. _d 0
             dNO2l=0. _d 0
c set other arguments to zero
             PP=0. _d 0
             Nfix=0. _d 0
             do np=1,npmax
                Rstarl(np)=0. _d 0
                RNstarl(np)=0. _d 0
             enddo


            debug=0
c           if (i.eq.20.and.j.eq.20.and.k.eq.1) debug=8
c           if (i.eq.10.and.j.eq.10.and.k.eq.1) debug=100
c           if (i.eq.1.and.j.eq.10.and.k.eq.1) debug=10

            if (debug.eq.7) print*,'PO4, DOP, POP, ZooP',
     &                       PO4l,  DOPl, POPl, zooP
            if (debug.eq.7) print*,'NO3, NO2, NH4, DON, PON, ZooN', 
     &                       NO3l,NO2l,NH4l, DONl, PONl, ZooN
            if (debug.eq.7) print*,'FeT, DOFe, POFe, Zoofe', 
     &                       FeTl,  DOFel, POFel, zooFe
            if (debug.eq.7) print*,'Si, Psi, zooSi', 
     &                       Sil, PSil, zooSi
            if (debug.eq.7) print*,'Total Phy', sumpy, PARl, lite
            if (debug.eq.7) print*,'Phy', Phy

            if (debug.eq.8) print*,'k, PARl, inputFel, dzlocal',
     &                        PARl, inputFel, dzlocal

c           if (NO3l.eq.0. _d 0.or.NO2l.eq.0. _d 0
c    &          .or.NH4l.eq.0. _d 0) then
c            print*,'QQ N zeros',i,j,k,NO3l,NO2l,NH4l
c           endif

             CALL DARWIN_PLANKTON(
     &                     Phy, zooP, zooN, zooFe, zooSi, PP,
     &                     Nfix,
     &                     PO4l, NO3l, FeTl, Sil,
     &                     NO2l, NH4l,
     &                     DOPl, DONl, DOFel,
     &                     POPl,PONl,POFel,PSil,
     &                     Phyup, popupl, ponupl, pofeupl, psiupl,
     &                     PARl,Tlocal,Slocal, 
     &                     freefu, inputFel,
     &                     bottom, dzlocal,
     &                     Rstarl, RNstarl,
     &                     dphy, dzoop, dzoon, dzoofe, dzoosi,
     &                     dPO4l, dNO3l, dFeTl, dSil, 
     &                     dNH4l, dNO2l,
     &                     dDOPl, dDONl, dDOFel,
     &                     dPOPl, dPONl, dPOFel, dPSil,
     &                     debug,
     &                     runtim,
     &                     MyThid)
c
c            if (i.eq.1.and.k.eq.1.and.j.eq.5) then
c              print*,i,j,k
c              print*,'NO3,No2,NH4',  NO3l, NO2l, NH4l
c              print*,'dNO3 etc',dNO3l,dNH4l, dNO2l
c              print*,'PO4',PO4l,dPO4l
c            endif
c
             popupl = POPl
             ponupl = PONl
             pofeupl = POFel
             psiupl = PSil
             do np=1,npmax
               Phyup(np) = Phy(np) 
             enddo
c
#ifdef CONS_SUPP
c only works for two layer model
            if (k.eq.2) then
              dpo4l=0. _d 0
              dno3l=0. _d 0
              dfetl=0. _d 0
              dsil=0. _d 0
            endif
#endif
c
c now update main tracer arrays
             dtplankton = dTtracerLev(k)/float(nsubtime)
             PO4(i,j,k) = PO4(i,j,k)+
     &                                dtplankton*dpo4l
             NO3(i,j,k) = NO3(i,j,k) +
     &                                dtplankton*dno3l
             FeT(i,j,k) = FeT(i,j,k) +
     &                                dtplankton*dfetl
             Si(i,j,k) = Si(i,j,k) +
     &                                dtplankton*dsil
             DOP(i,j,k) = DOP(i,j,k) +
     &                                dtplankton*ddopl
             DON(i,j,k) = DON(i,j,k) +
     &                                dtplankton*ddonl
             DOFe(i,j,k) = DOFe(i,j,k) +
     &                                dtplankton*ddoFel
             Zoo1P(i,j,k) = Zoo1P(i,j,k) +
     &                                dtplankton*dzoop(1)
             Zoo1N(i,j,k) = Zoo1N(i,j,k) +
     &                                dtplankton*dzoon(1)
             Zoo1Fe(i,j,k) = Zoo1Fe(i,j,k) +
     &                                dtplankton*dzooFe(1)
             Zoo1Si(i,j,k) = Zoo1Si(i,j,k) +
     &                                dtplankton*dzooSi(1)
             Zoo2P(i,j,k) = Zoo2P(i,j,k) +
     &                                dtplankton*dzoop(2)
             Zoo2N(i,j,k) = Zoo2N(i,j,k) +
     &                                dtplankton*dzoon(2)
             Zoo2Fe(i,j,k) = Zoo2Fe(i,j,k) +
     &                                dtplankton*dzooFe(2)
             Zoo2Si(i,j,k) = Zoo2Si(i,j,k) +
     &                                dtplankton*dzooSi(2)
             Phy1(i,j,k) = Phy1(i,j,k) +
     &                                dtplankton*dPhy(1)
             Phy2(i,j,k) = Phy2(i,j,k) +
     &                                dtplankton*dPhy(2)
             Phy3(i,j,k) = Phy3(i,j,k) +
     &                                dtplankton*dPhy(3)
             Phy4(i,j,k) = Phy4(i,j,k) +
     &                                dtplankton*dPhy(4)
             Phy5(i,j,k) = Phy5(i,j,k) +
     &                                dtplankton*dPhy(5)
             Phy6(i,j,k) = Phy6(i,j,k) +
     &                                dtplankton*dPhy(6)
             Phy7(i,j,k) = Phy7(i,j,k) +
     &                                dtplankton*dPhy(7)
             Phy8(i,j,k) = Phy8(i,j,k) +
     &                                dtplankton*dPhy(8)
             Phy9(i,j,k) = Phy9(i,j,k) +
     &                                dtplankton*dPhy(9)
             Phy10(i,j,k) = Phy10(i,j,k) +
     &                                dtplankton*dPhy(10)
             Phy11(i,j,k) = Phy11(i,j,k) +
     &                                dtplankton*dPhy(11)
             Phy12(i,j,k) = Phy12(i,j,k) +
     &                                dtplankton*dPhy(12)
             Phy13(i,j,k) = Phy13(i,j,k) +
     &                                dtplankton*dPhy(13)
             Phy14(i,j,k) = Phy14(i,j,k) +
     &                                dtplankton*dPhy(14)
             Phy15(i,j,k) = Phy15(i,j,k) +
     &                                dtplankton*dPhy(15)
             Phy16(i,j,k) = Phy16(i,j,k) +
     &                                dtplankton*dPhy(16)
             Phy17(i,j,k) = Phy17(i,j,k) +
     &                                dtplankton*dPhy(17)
             Phy18(i,j,k) = Phy18(i,j,k) +
     &                                dtplankton*dPhy(18)
             Phy19(i,j,k) = Phy19(i,j,k) +
     &                                dtplankton*dPhy(19)
             Phy20(i,j,k) = Phy20(i,j,k) +
     &                                dtplankton*dPhy(20)
             Phy21(i,j,k) = Phy21(i,j,k) +
     &                                dtplankton*dPhy(21)
             Phy22(i,j,k) = Phy22(i,j,k) +
     &                                dtplankton*dPhy(22)
             Phy23(i,j,k) = Phy23(i,j,k) +
     &                                dtplankton*dPhy(23)
             Phy24(i,j,k) = Phy24(i,j,k) +
     &                                dtplankton*dPhy(24)
             Phy25(i,j,k) = Phy25(i,j,k) +
     &                                dtplankton*dPhy(25)
             Phy26(i,j,k) = Phy26(i,j,k) +
     &                                dtplankton*dPhy(26)
             Phy27(i,j,k) = Phy27(i,j,k) +
     &                                dtplankton*dPhy(27)
             Phy28(i,j,k) = Phy28(i,j,k) +
     &                                dtplankton*dPhy(28)
             Phy29(i,j,k) = Phy29(i,j,k) +
     &                                dtplankton*dPhy(29)
             Phy30(i,j,k) = Phy30(i,j,k) +
     &                                dtplankton*dPhy(30)
             Phy31(i,j,k) = Phy31(i,j,k) +
     &                                dtplankton*dPhy(31)
             Phy32(i,j,k) = Phy32(i,j,k) +
     &                                dtplankton*dPhy(32)
             Phy33(i,j,k) = Phy33(i,j,k) +
     &                                dtplankton*dPhy(33)
             Phy34(i,j,k) = Phy34(i,j,k) +
     &                                dtplankton*dPhy(34)
             Phy35(i,j,k) = Phy35(i,j,k) +
     &                                dtplankton*dPhy(35)
             Phy36(i,j,k) = Phy36(i,j,k) +
     &                                dtplankton*dPhy(36)
             Phy37(i,j,k) = Phy37(i,j,k) +
     &                                dtplankton*dPhy(37)
             Phy38(i,j,k) = Phy38(i,j,k) +
     &                                dtplankton*dPhy(38)
             Phy39(i,j,k) = Phy39(i,j,k) +
     &                                dtplankton*dPhy(39)
             Phy40(i,j,k) = Phy40(i,j,k) +
     &                                dtplankton*dPhy(40)
             Phy41(i,j,k) = Phy41(i,j,k) +
     &                                dtplankton*dPhy(41)
             Phy42(i,j,k) = Phy42(i,j,k) +
     &                                dtplankton*dPhy(42)
             Phy43(i,j,k) = Phy43(i,j,k) +
     &                                dtplankton*dPhy(43)
             Phy44(i,j,k) = Phy44(i,j,k) +
     &                                dtplankton*dPhy(44)
             Phy45(i,j,k) = Phy45(i,j,k) +
     &                                dtplankton*dPhy(45)
             Phy46(i,j,k) = Phy46(i,j,k) +
     &                                dtplankton*dPhy(46)
             Phy47(i,j,k) = Phy47(i,j,k) +
     &                                dtplankton*dPhy(47)
             Phy48(i,j,k) = Phy48(i,j,k) +
     &                                dtplankton*dPhy(48)
             Phy49(i,j,k) = Phy49(i,j,k) +
     &                                dtplankton*dPhy(49)
             Phy50(i,j,k) = Phy50(i,j,k) +
     &                                dtplankton*dPhy(50)
             Phy51(i,j,k) = Phy51(i,j,k) +
     &                                dtplankton*dPhy(51)
             Phy52(i,j,k) = Phy52(i,j,k) +
     &                                dtplankton*dPhy(52)
             Phy53(i,j,k) = Phy53(i,j,k) +
     &                                dtplankton*dPhy(53)
             Phy54(i,j,k) = Phy54(i,j,k) +
     &                                dtplankton*dPhy(54)
             Phy55(i,j,k) = Phy55(i,j,k) +
     &                                dtplankton*dPhy(55)
             Phy56(i,j,k) = Phy56(i,j,k) +
     &                                dtplankton*dPhy(56)
             Phy57(i,j,k) = Phy57(i,j,k) +
     &                                dtplankton*dPhy(57)
             Phy58(i,j,k) = Phy58(i,j,k) +
     &                                dtplankton*dPhy(58)
             Phy59(i,j,k) = Phy59(i,j,k) +
     &                                dtplankton*dPhy(59)
             Phy60(i,j,k) = Phy60(i,j,k) +
     &                                dtplankton*dPhy(60)
             Phy61(i,j,k) = Phy61(i,j,k) +
     &                                dtplankton*dPhy(61)
             Phy62(i,j,k) = Phy62(i,j,k) +
     &                                dtplankton*dPhy(62)
             Phy63(i,j,k) = Phy63(i,j,k) +
     &                                dtplankton*dPhy(63)
             Phy64(i,j,k) = Phy64(i,j,k) +
     &                                dtplankton*dPhy(64)
             Phy65(i,j,k) = Phy65(i,j,k) +
     &                                dtplankton*dPhy(65)
             Phy66(i,j,k) = Phy66(i,j,k) +
     &                                dtplankton*dPhy(66)
             Phy67(i,j,k) = Phy67(i,j,k) +
     &                                dtplankton*dPhy(67)
             Phy68(i,j,k) = Phy68(i,j,k) +
     &                                dtplankton*dPhy(68)
             Phy69(i,j,k) = Phy69(i,j,k) +
     &                                dtplankton*dPhy(69)
             Phy70(i,j,k) = Phy70(i,j,k) +
     &                                dtplankton*dPhy(70)
             Phy71(i,j,k) = Phy71(i,j,k) +
     &                                dtplankton*dPhy(71)
             Phy72(i,j,k) = Phy72(i,j,k) +
     &                                dtplankton*dPhy(72)
             Phy73(i,j,k) = Phy73(i,j,k) +
     &                                dtplankton*dPhy(73)
             Phy74(i,j,k) = Phy74(i,j,k) +
     &                                dtplankton*dPhy(74)
             Phy75(i,j,k) = Phy75(i,j,k) +
     &                                dtplankton*dPhy(75)
             Phy76(i,j,k) = Phy76(i,j,k) +
     &                                dtplankton*dPhy(76)
             Phy77(i,j,k) = Phy77(i,j,k) +
     &                                dtplankton*dPhy(77)
             Phy78(i,j,k) = Phy78(i,j,k) +
     &                                dtplankton*dPhy(78)
             POP(i,j,k) = POP(i,j,k) +
     &                                dtplankton*dPOPl
             PON(i,j,k) = PON(i,j,k) +
     &                                dtplankton*dPONl
             POFe(i,j,k) = POFe(i,j,k) +
     &                                dtplankton*dPOFel  
             Psi(i,j,k) = Psi(i,j,k) +
     &                                dtplankton*dPSil
             NH4(i,j,k) = NH4(i,j,k) +
     &                                dtplankton*dNH4l   
             NO2(i,j,k) = NO2(i,j,k) +
     &                                dtplankton*dNO2l


#ifdef ALLOW_MUTANTS
cQQQQTEST
            if (debug.eq.11) then
            if (k.lt.8) then
            if (dPhy(2).gt.dPhy(4).and.dPhy(4).gt.0. _d 0) then
              print*,'QQQ dphy2 > dphy4',i,j,k,Phy2(i,j,k),
     &             Phy4(i,j,k), dPhy(2), dPhy(4)
            endif
            if (Phy2(i,j,k).gt.Phy4(i,j,k).and.
     &                           Phy4(i,j,k).gt.0. _d 0) then
              print*,'QQ phy02 > phy04',i,j,k,Phy2(i,j,k),
     &             Phy4(i,j,k), dPhy(2), dPhy(4)
            endif
cc
            if (dPhy(6).gt.dPhy(8).and.dPhy(8).gt.0. _d 0) then
              print*,'QQQ dphy6 > dphy8',i,j,k,Phy6(i,j,k),
     &             Phy8(i,j,k), dPhy(6), dPhy(8)
            endif
            if (Phy6(i,j,k).gt.Phy8(i,j,k).and.
     &                           Phy8(i,j,k).gt.0. _d 0) then
              print*,'QQ phy06 > phy08',i,j,k,Phy6(i,j,k),
     &             Phy8(i,j,k), dPhy(6), dPhy(8)
            endif
cc
            if (dPhy(10).gt.dPhy(12).and.dPhy(12).gt.0. _d 0.and.
     &                           Phy12(i,j,k).gt.0. _d 0) then
              print*,'QQQ dphy10 > dphy12',i,j,k,Phy10(i,j,k),
     &             Phy12(i,j,k), dPhy(10), dPhy(12)
            endif
            if (Phy10(i,j,k).gt.Phy12(i,j,k).and.
     &                           Phy12(i,j,k).gt.0. _d 0) then
              print*,'QQ phy10 > phy12',i,j,k,Phy10(i,j,k),
     &             Phy12(i,j,k), dPhy(10), dPhy(12)
            endif
cc
            if (dPhy(14).gt.dPhy(16).and.dPhy(16).gt.0. _d 0) then
              print*,'QQQ dphy14 > dphy16',i,j,k,Phy14(i,j,k),
     &             Phy16(i,j,k), dPhy(14), dPhy(16)
            endif
            if (Phy14(i,j,k).gt.Phy16(i,j,k).and.
     &                           Phy16(i,j,k).gt.0. _d 0) then
              print*,'QQ phy14 > phy16',i,j,k,Phy14(i,j,k),
     &             Phy16(i,j,k), dPhy(14), dPhy(16)
            endif
cc
            if (dPhy(18).gt.dPhy(20).and.dPhy(20).gt.0. _d 0) then
              print*,'QQQ dphy18 > dphy20',i,j,k,Phy18(i,j,k),
     &             Phy18(i,j,k), dPhy(18), dPhy(20)
            endif
            if (Phy18(i,j,k).gt.Phy20(i,j,k).and.
     &                           Phy20(i,j,k).gt.0. _d 0) then
              print*,'QQ phy18 > phy20',i,j,k,Phy18(i,j,k),
     &             Phy20(i,j,k), dPhy(18), dPhy(20)
            endif
cc
            if (dPhy(22).gt.dPhy(24).and.dPhy(24).gt.0. _d 0) then
              print*,'QQQ dphy22 > dphy24',i,j,k,Phy22(i,j,k),
     &             Phy24(i,j,k), dPhy(22), dPhy(24)
            endif
            if (Phy22(i,j,k).gt.Phy24(i,j,k).and.
     &                           Phy24(i,j,k).gt.0. _d 0) then
              print*,'QQ phy22 > phy24',i,j,k,Phy22(i,j,k),
     &             Phy24(i,j,k), dPhy(22), dPhy(24)
            endif
cc
            if (dPhy(26).gt.dPhy(28).and.dPhy(28).gt.0. _d 0) then
              print*,'QQQ dphy26 > dphy28',i,j,k,Phy26(i,j,k),
     &             Phy28(i,j,k), dPhy(26), dPhy(28)
            endif
            if (Phy26(i,j,k).gt.Phy28(i,j,k).and.
     &                           Phy28(i,j,k).gt.0. _d 0) then
              print*,'QQ phy26 > phy28',i,j,k,Phy26(i,j,k),
     &             Phy28(i,j,k), dPhy(26), dPhy(28)
            endif
cc
            if (dPhy(30).gt.dPhy(32).and.dPhy(32).gt.0. _d 0) then
              print*,'QQQ dphy30 > dphy32',i,j,k,Phy30(i,j,k),
     &             Phy32(i,j,k), dPhy(30), dPhy(32)
            endif
            if (Phy30(i,j,k).gt.Phy32(i,j,k).and.
     &                           Phy32(i,j,k).gt.0. _d 0) then
              print*,'QQ phy30 > phy32',i,j,k,Phy30(i,j,k),
     &             Phy32(i,j,k), dPhy(30), dPhy(32)
            endif
cc
            if (dPhy(34).gt.dPhy(36).and.dPhy(36).gt.0. _d 0) then
              print*,'QQQ dphy34 > dphy36',i,j,k,Phy34(i,j,k),
     &             Phy36(i,j,k), dPhy(34), dPhy(36)
            endif
            if (Phy34(i,j,k).gt.Phy36(i,j,k).and.
     &                           Phy36(i,j,k).gt.0. _d 0) then
              print*,'QQ phy34 > phy36',i,j,k,Phy34(i,j,k),
     &             Phy36(i,j,k), dPhy(34), dPhy(36)
            endif
cc
            if (dPhy(38).gt.dPhy(40).and.dPhy(40).gt.0. _d 0) then
              print*,'QQQ dphy38 > dphy40',i,j,k,Phy38(i,j,k),
     &             Phy40(i,j,k), dPhy(38), dPhy(40)
            endif
            if (Phy38(i,j,k).gt.Phy40(i,j,k).and.
     &                           Phy40(i,j,k).gt.0. _d 0) then
              print*,'QQ phy38 > phy40',i,j,k,Phy38(i,j,k),
     &             Phy40(i,j,k), dPhy(38), dPhy(40)
            endif
cc
            if (dPhy(42).gt.dPhy(44).and.dPhy(44).gt.0. _d 0) then
              print*,'QQQ dphy42 > dphy44',i,j,k,Phy42(i,j,k),
     &             Phy44(i,j,k), dPhy(42), dPhy(44)
            endif
            if (Phy42(i,j,k).gt.Phy44(i,j,k).and.
     &                           Phy44(i,j,k).gt.0. _d 0) then
              print*,'QQ phy42 > phy44',i,j,k,Phy42(i,j,k),
     &             Phy44(i,j,k), dPhy(42), dPhy(44)
            endif
cc
            if (dPhy(46).gt.dPhy(48).and.dPhy(48).gt.0. _d 0) then
              print*,'QQQ dphy46 > dphy48',i,j,k,Phy46(i,j,k),
     &             Phy48(i,j,k), dPhy(46), dPhy(48)
            endif
            if (Phy46(i,j,k).gt.Phy48(i,j,k).and.
     &                           Phy48(i,j,k).gt.0. _d 0) then
              print*,'QQ phy46 > phy48',i,j,k,Phy46(i,j,k),
     &             Phy48(i,j,k), dPhy(46), dPhy(48)
            endif
cc
            if (dPhy(50).gt.dPhy(52).and.dPhy(52).gt.0. _d 0) then
              print*,'QQQ dphy50 > dphy52',i,j,k,Phy50(i,j,k),
     &             Phy52(i,j,k), dPhy(50), dPhy(52)
            endif
            if (Phy50(i,j,k).gt.Phy52(i,j,k).and.
     &                           Phy52(i,j,k).gt.0. _d 0) then
              print*,'QQ phy50 > phy52',i,j,k,Phy50(i,j,k),
     &             Phy52(i,j,k), dPhy(50), dPhy(52)
            endif
cc
            if (dPhy(54).gt.dPhy(56).and.dPhy(56).gt.0. _d 0) then
              print*,'QQQ dphy54 > dphy56',i,j,k,Phy54(i,j,k),
     &             Phy56(i,j,k), dPhy(54), dPhy(56)
            endif
            if (Phy54(i,j,k).gt.Phy56(i,j,k).and.
     &                           Phy56(i,j,k).gt.0. _d 0) then
              print*,'QQ phy54 > phy56',i,j,k,Phy54(i,j,k),
     &             Phy56(i,j,k), dPhy(54), dPhy(56)
            endif
cc
            if (dPhy(58).gt.dPhy(60).and.dPhy(60).gt.0. _d 0) then
              print*,'QQQ dphy58 > dphy60',i,j,k,Phy58(i,j,k),
     &             Phy60(i,j,k), dPhy(58), dPhy(60)
            endif
            if (Phy58(i,j,k).gt.Phy60(i,j,k).and.
     &                           Phy60(i,j,k).gt.0. _d 0) then
              print*,'QQ phy58 > phy60',i,j,k,Phy58(i,j,k),
     &             Phy60(i,j,k), dPhy(58), dPhy(60)
            endif
            endif  ! k
            endif
#endif

#ifdef ALLOW_DIAGNOSTICS
COJ for diagnostics
	     PParr(i,j,k) = PP
	     Nfixarr(i,j,k) = Nfix
#ifdef DAR_DIAG_RSTAR
	     DO np = 1,npmax
	       Rstararr(i,j,k,np) = Rstarl(np)
	     ENDDO
#endif
COJ
#endif

c total fixation (NOTE - STILL NEEDS GLOB SUM)
             tot_Nfix=tot_Nfix+ 
     &             Nfix*rA(i,j,bi,bj)*rF(k)*hFacC(i,j,k,bi,bj)

#ifdef ALLOW_TIMEAVE
c save averages
c            Phygrow1ave(i,j,k,bi,bj)=Phygrow1ave(i,j,k,bi,bj)+
c    &                             mu1*py1*deltaTclock
c    &                       /float(nsubtime)
c            Phygrow2ave(i,j,k,bi,bj)=Phygrow2ave(i,j,k,bi,bj)+
c    &                             mu2*py2*deltaTclock
c    &                       /float(nsubtime)
c            Zoograzave(i,j,k,bi,bj)=Zoograzave(i,j,k,bi,bj)+
c    &                      (gampn1*graz1*zo +gampn2*graz2*zo)*
c    &                       deltaTclock/float(nsubtime)
             PARave(i,j,k,bi,bj)=PARave(i,j,k,bi,bj)+
     &                           PARl*dtplankton
             PPave(i,j,k,bi,bj)=PPave(i,j,k,bi,bj)+
     &                           PP*dtplankton
             Nfixave(i,j,k,bi,bj)=Nfixave(i,j,k,bi,bj)+
     &                           Nfix*dtplankton
#ifdef DAR_DIAG_RSTAR
             do np=1,npmax
               Rstarave(i,j,k,bi,bj,np)=Rstarave(i,j,k,bi,bj,np)+
     &                           Rstarl(np)*dtplankton
               RNstarave(i,j,k,bi,bj,np)=RNstarave(i,j,k,bi,bj,np)+
     &                           RNstarl(np)*dtplankton
             enddo
#endif
#ifdef DAR_DIAG_DIVER
             Diver1ave(i,j,k,bi,bj)=Diver1ave(i,j,k,bi,bj)+
     &                           Diver1(i,j,k)*dtplankton
             Diver2ave(i,j,k,bi,bj)=Diver2ave(i,j,k,bi,bj)+
     &                           Diver2(i,j,k)*dtplankton
             Diver3ave(i,j,k,bi,bj)=Diver3ave(i,j,k,bi,bj)+
     &                           Diver3(i,j,k)*dtplankton
             Diver4ave(i,j,k,bi,bj)=Diver4ave(i,j,k,bi,bj)+
     &                           Diver4(i,j,k)*dtplankton
#endif
c            Chlave(i,j,k,bi,bj)=Chlave(i,j,k,bi,bj)+
c    &           (chlpmax-(chlpmax-chlpmin)*
c    &           min(lite*exp(-atten)/istar, 1. _d 0) )*
c    &           (py1*min(nu/(nu+nlim1),fu/(fu+flim1)) +
c    &            py2*min(fu/(fu+flim2),
c    &                      min(nu/(nu+nlim2),si/(si+slim2)) )  )
c    &                          * deltaTclock/float(nsubtime)
#endif
          endif  
c end if hFac>0

         enddo ! k
c end layer loop
c

       ENDDO ! i
       ENDDO ! j

COJ fill diagnostics
#ifdef ALLOW_DIAGNOSTICS
       IF ( useDiagnostics ) THEN
        diagname = '        '
        WRITE(diagname,'(A8)') 'PAR     '
        CALL DIAGNOSTICS_FILL( PAR(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
        WRITE(diagname,'(A8)') 'PP      '
        CALL DIAGNOSTICS_FILL( PParr(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
        WRITE(diagname,'(A8)') 'Nfix    '
        CALL DIAGNOSTICS_FILL( Nfixarr(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
#ifdef DAR_DIAG_RSTAR
	DO np=1,MIN(99,npmax)
	 WRITE(diagname,'(A5,I2.2,A1)') 'Rstar',np,' '
	 CALL DIAGNOSTICS_FILL( Rstararr(1-Olx,1-Oly,1,np), diagname,
     &                          0,Nr,2,bi,bj,myThid )
	ENDDO
#endif
#ifdef DAR_DIAG_DIVER
        WRITE(diagname,'(A8)') 'Diver1  '
        CALL DIAGNOSTICS_FILL( Diver1(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
        WRITE(diagname,'(A8)') 'Diver2  '
        CALL DIAGNOSTICS_FILL( Diver2(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
        WRITE(diagname,'(A8)') 'Diver3  '
        CALL DIAGNOSTICS_FILL( Diver3(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
        WRITE(diagname,'(A8)') 'Diver4  '
        CALL DIAGNOSTICS_FILL( Diver4(1-Olx,1-Oly,1), diagname,
     &                         0,Nr,2,bi,bj,myThid )
#endif
       ENDIF
#endif
COJ

c determine iron partitioning  - solve for free iron
         call darwin_fe_chem(bi,bj,iMin,iMax,jMin,jMax, FeT, freefe,
     &                       myIter, mythid)
c
#ifdef ALLOW_TIMEAVE
c save averages
       do k=1,nR
         dar_timeave(bi,bj,k)=dar_timeave(bi,bj,k)
     &                         +dtplankton
       enddo
#endif
c
c -----------------------------------------------------
       ENDDO ! it
c -----------------------------------------------------
c end of bio-chemical time loop
c 
        RETURN
        END
#endif  /*DARWIN*/
#endif  /*ALLOW_PTRACERS*/

C============================================================================
