C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_forcing.F,v 1.10 2008/08/01 21:35:16 stephd Exp $
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
         SUBROUTINE DARWIN_Forcing(
     U                  Ptr,
     I                  bi,bj,imin,imax,jmin,jmax,
     I                  myIter,myTime,myThid)
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "GCHEM.h"
#include "DARWIN_SIZE.h"
#include "DARWIN.h"
#include "DARWIN_IO.h"
#include "DYNVARS.h"
#ifdef USE_QSW
#include "FFIELDS.h"
#endif

c ANNA include wavebands_params.h
#ifdef WAVEBANDS
#include "WAVEBANDS_PARAMS.h"
#endif


C     === Global variables ===
c tracers
       _RL Ptr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy,nDarwin)
       INTEGER bi,bj,imin,imax,jmin,jmax
       INTEGER myIter
       _RL myTime
       INTEGER myThid

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


c ANNA define variables for wavebands 
#ifdef WAVEBANDS
       integer ilam
       _RL sfPAR(tlam)
       _RL PARwl(tlam)
       _RL PARwupl(tlam)
#endif
c ANNA endif


#ifdef DAR_DIAG_DIVER
      _RL  Diver1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Diver2(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Diver3(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Diver4(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)

      _RL  tmpphy(npmax)
      _RL  totphy, biotot, maxphy, phymax
#endif

#ifdef GEIDER
      _RL phychl(npmax)
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
       _RL Chl
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
c
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
         call darwin_fe_chem(bi,bj,iMin,iMax,jMin,jMax, 
     &                       Ptr(1-OLx,1-OLy,1,bi,bj,iFeT), freefe,
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

c ANNA split surface PAR into wavebands
#ifdef WAVEBANDS
         do ilam = 1,tlam
          sfPAR(ilam) = sf(ilam)*lite
          PARwupl(ilam) = sfPAR(ilam)
          PARwl(ilam) = 0. _d 0
         enddo
#endif         
c ANNA endif


c for each layer ...   
        do k= 1, NR   
         if (HFacC(i,j,k,bi,bj).gt.0. _d 0) then

c make sure we only deal with positive definite numbers
c brute force...
             po4l  = max(Ptr(i,j,k,bi,bj,iPO4  ),0. _d 0)
             no3l  = max(Ptr(i,j,k,bi,bj,iNO3  ),0. _d 0)
             fetl  = max(Ptr(i,j,k,bi,bj,iFeT  ),0. _d 0)
             sil   = max(Ptr(i,j,k,bi,bj,iSi   ),0. _d 0)
             dopl  = max(Ptr(i,j,k,bi,bj,iDOP  ),0. _d 0)
             donl  = max(Ptr(i,j,k,bi,bj,iDON  ),0. _d 0)
             dofel = max(Ptr(i,j,k,bi,bj,iDOFe ),0. _d 0)
             DO nz = 1,nzmax
               ZooP(nz)  = max(Ptr(i,j,k,bi,bj,iZooP (nz)),0. _d 0)
               ZooN(nz)  = max(Ptr(i,j,k,bi,bj,iZooN (nz)),0. _d 0)
               ZooFe(nz) = max(Ptr(i,j,k,bi,bj,iZooFe(nz)),0. _d 0)
               ZooSi(nz) = max(Ptr(i,j,k,bi,bj,iZooSi(nz)),0. _d 0)
             ENDDO
             DO np = 1,npmax
               Phy(np) = max(Ptr(i,j,k,bi,bj,iPhy+np-1),0. _d 0)
#ifdef GEIDER
               phychl(np) = max(Chl_phy(i,j,k,bi,bj,np), 0. _d 0)
#endif
             ENDDO
             popl  = max(Ptr(i,j,k,bi,bj,iPOP  ),0. _d 0)
             ponl  = max(Ptr(i,j,k,bi,bj,iPON  ),0. _d 0)
             pofel = max(Ptr(i,j,k,bi,bj,iPOFe ),0. _d 0)
             psil  = max(Ptr(i,j,k,bi,bj,iPOSi ),0. _d 0)
             NH4l  = max(Ptr(i,j,k,bi,bj,iNH4  ),0. _d 0)
             NO2l  = max(Ptr(i,j,k,bi,bj,iNO2  ),0. _d 0)

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
#ifdef GEIDER
                sumpy = sumpy + phychl(np)
#else
                sumpy = sumpy + Phy(np)
#endif             
             enddo
c ANNA attenuation for WAVEBANDS is done in darwin_plankton.F, not here
#ifndef WAVEBANDS
             atten= atten + (k0 + kc*sumpy)*5. _d -1*drF(k)
             if (k.gt.1)then
               atten = atten + (k0+kc*sumpyup)*5. _d -1*drF(k-1)
             endif
             PAR(i,j,k) = lite*exp(-atten)
#endif
c ANNA endif

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

c ANNA only define PARl here if not WAVEBANDS
#ifndef WAVEBANDS
             PARl = PAR(i,j,k)
#endif

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
c           if (i.eq.1.and.j.eq.1.and.k.eq.10) debug=14
 
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


c ANNA pass extra variables if WAVEBANDS
             CALL DARWIN_PLANKTON(
     U                       Phy,
     I                       zooP, zooN, zooFe, zooSi,
     O                       PP, Chl, Nfix,
     I                       PO4l, NO3l, FeTl, Sil,
     I                       NO2l, NH4l, 
     I                       DOPl, DONl, DOFel,
     I                       POPl, PONl, POFel, PSil,
     I                       phyup, popupl, ponupl, 
     I                       pofeupl, psiupl,
     I                       PARl,Tlocal, Slocal,
     I                       freefu, inputFel,
     I                       bottom, dzlocal,
     O                       Rstarl, RNstarl,
     O                       dphy, dzooP, dzooN, dzooFe,
     O                       dzooSi,
     O                       dPO4l, dNO3l, dFeTl, dSil,
     O                       dNH4l, dNO2l,
     O                       dDOPl, dDONl, dDOFel, 
     O                       dPOPl, dPONl, dPOFel, dPSil,
#ifdef GEIDER
     O                       phychl,
#ifdef WAVEBANDS
     O                       PARwl,PARwupl,
     O                       drF(k),
#endif
#endif
     I                       debug,
     I                       runtim,
     I                       MyThid) 

c ANNA assign PARl here for WAVEBANDS
#ifdef WAVEBANDS
              PAR(i,j,k) = PARl
#endif


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
          Ptr(i,j,k,bi,bj,iPO4 ) = Ptr(i,j,k,bi,bj,iPO4) +
     &                                  dtplankton*dpo4l
          Ptr(i,j,k,bi,bj,iNO3 ) = Ptr(i,j,k,bi,bj,iNO3) +
     &                                  dtplankton*dno3l
          Ptr(i,j,k,bi,bj,iFeT ) = Ptr(i,j,k,bi,bj,iFeT) +
     &                                  dtplankton*dfetl
          Ptr(i,j,k,bi,bj,iSi  ) = Ptr(i,j,k,bi,bj,iSi ) +
     &                                  dtplankton*dsil
          Ptr(i,j,k,bi,bj,iDOP ) = Ptr(i,j,k,bi,bj,iDOP) +
     &                                  dtplankton*ddopl
          Ptr(i,j,k,bi,bj,iDON ) = Ptr(i,j,k,bi,bj,iDON) +
     &                                  dtplankton*ddonl
          Ptr(i,j,k,bi,bj,iDOFe) = Ptr(i,j,k,bi,bj,iDOFe) +
     &                                  dtplankton*ddofel
          Ptr(i,j,k,bi,bj,iPOP ) = Ptr(i,j,k,bi,bj,iPOP ) +
     &                                  dtplankton*dpopl
          Ptr(i,j,k,bi,bj,iPON ) = Ptr(i,j,k,bi,bj,iPON ) +
     &                                  dtplankton*dponl
          Ptr(i,j,k,bi,bj,iPOFe) = Ptr(i,j,k,bi,bj,iPOFe) +
     &                                  dtplankton*dpofel
          Ptr(i,j,k,bi,bj,iPOSi) = Ptr(i,j,k,bi,bj,iPOSi) +
     &                                  dtplankton*dpsil
          Ptr(i,j,k,bi,bj,iNH4 ) = Ptr(i,j,k,bi,bj,iNH4 ) +
     &                                  dtplankton*dnh4l
          Ptr(i,j,k,bi,bj,iNO2 ) = Ptr(i,j,k,bi,bj,iNO2 ) +
     &                                  dtplankton*dno2l
          DO nz = 1,nzmax
           Ptr(i,j,k,bi,bj,iZooP (nz)) = Ptr(i,j,k,bi,bj,iZooP (nz)) +
     &                                        dtplankton*dzoop (nz)
           Ptr(i,j,k,bi,bj,iZooN (nz)) = Ptr(i,j,k,bi,bj,iZooN (nz)) +
     &                                        dtplankton*dzoon (nz)
           Ptr(i,j,k,bi,bj,iZooFe(nz)) = Ptr(i,j,k,bi,bj,iZooFe(nz)) +
     &                                        dtplankton*dzoofe(nz)
           Ptr(i,j,k,bi,bj,iZooSi(nz)) = Ptr(i,j,k,bi,bj,iZooSi(nz)) +
     &                                        dtplankton*dzoosi(nz)
          ENDDO
          DO np = 1,npmax
           Ptr(i,j,k,bi,bj,iPhy+np-1) = Ptr(i,j,k,bi,bj,iPhy+np-1) +
     &                                       dtplankton*dPhy(np)
#ifdef GEIDER
           Chl_phy(i,j,k,bi,bj,np)=phychl(np)
#endif
          ENDDO

#ifdef ALLOW_MUTANTS
cQQQQTEST
          if (debug.eq.11) then
          if (k.lt.8) then
          do np=1,60
          if(mod(np,4).eq. 1. _d 0)then
          np2=np+1
          np4=np+3

Coj: couldn't test this part after change Phynp -> Ptr(...,iPhy+np-1)
Coj: used to be many copies of this:
C           if (dPhy(2).gt.dPhy(4).and.dPhy(4).gt.0. _d 0) then
C             print*,'QQQ dphy2 > dphy4',i,j,k,Phy2(i,j,k),
C    &             Phy4(i,j,k), dPhy(2), dPhy(4)
C           endif
C           if (Phy2(i,j,k).gt.Phy4(i,j,k).and.
C    &                           Phy4(i,j,k).gt.0. _d 0) then
C             print*,'QQ phy02 > phy04',i,j,k,Phy2(i,j,k),
C    &             Phy4(i,j,k), dPhy(2), dPhy(4)
C           endif

          if (dPhy(np2).gt.dPhy(np4).and.dPhy(np4).gt.0. _d 0) then
             print*,'QQQ dphy',np2,' > dphy',np4,i,j,k,Phy2(i,j,k),
     &             Ptr(i,j,k,bi,bj,iPhy+np4-1), dPhy(2), dPhy(4)
          endif
          if (Ptr(i,j,k,bi,bj,iphy+np2-1).gt.Ptr(i,j,k,bi,bj,iPhy+np4-1)
     &        .and. Ptr(i,j,k,bi,bj,iPhy+np4-1).gt.0. _d 0) then
            print*,'QQ phy',np2,' > ',np4,i,j,k,
     &             Ptr(i,j,k,bi,bj,iPhy+np2-1),
     &             Ptr(i,j,k,bi,bj,iPhy+np4-1), dPhy(2), dPhy(4)
          endif

          endif
          enddo  ! np
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
#ifdef GEIDER
             Chlave(i,j,k,bi,bj)=Chlave(i,j,k,bi,bj)+
     &                           Chl*dtplankton
#endif
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
         call darwin_fe_chem(bi,bj,iMin,iMax,jMin,jMax,
     &                       Ptr(1-OLx,1-OLy,1,bi,bj,iFeT), freefe,
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
