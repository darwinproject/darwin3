C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_forcing.F,v 1.30 2010/05/18 17:43:54 jahn Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "DARWIN_OPTIONS.h"

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
#include "DARWIN_FLUX.h"
#include "DYNVARS.h"
#ifdef USE_QSW
#include "FFIELDS.h"
#endif
#ifdef ALLOW_LONGSTEP
#include "LONGSTEP.h"
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

C     !FUNCTIONS:
C     ==  Functions ==
#ifdef ALLOW_PAR_DAY
      LOGICAL  DIFF_PHASE_MULTIPLE
      EXTERNAL DIFF_PHASE_MULTIPLE
#endif

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
#ifdef DYNAMIC_CHL
      _RL dphychl(npmax)
#endif
#endif

#ifdef ALLOW_DIAGNOSTICS
COJ for diagnostics
      _RL  PParr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  Nfixarr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
c ANNA_TAVE
#ifdef WAVES_DIAG_PCHL
      _RL  Pchlarr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,npmax)
#endif
c ANNA end TAVE
#ifdef DAR_DIAG_RSTAR
      _RL  Rstararr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,npmax)
#endif
#ifdef ALLOW_DIAZ
#ifdef DAR_DIAG_NFIXP
      _RL  NfixParr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,npmax)
#endif
#endif
#endif


      _RL  totphyC
#ifdef ALLOW_PAR_DAY
      LOGICAL itistime
      INTEGER PARiprev, PARiaccum, iperiod, nav
      _RL phase
      _RL dtsubtime
#endif
#ifdef DAR_DIAG_CHL
      _RL ChlGeiderlocal, ChlDoneylocal, ChlCloernlocal
#ifdef ALLOW_DIAGNOSTICS
      _RL GeiderChlarr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL GeiderChl2Carr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL DoneyChlarr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL DoneyChl2Carr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL CloernChlarr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL CloernChl2Carr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
#endif
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
       _RL Qswlocal
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
#ifdef DAR_DIAG_GROW
       _RL Growl(npmax)
       _RL Growsql(npmax)
#endif
#ifdef ALLOW_DIAZ
#ifdef DAR_DIAG_NFIXP
       _RL NfixPl(npmax)
#endif
#endif

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

#ifdef ALLOW_CARBON
       _RL dicl
       _RL docl
       _RL pocl
       _RL picl
       _RL alkl
       _RL o2l
       _RL ZooCl(nzmax)
       _RL pocupl
       _RL picupl
c tendencies
       _RL ddicl
       _RL ddocl
       _RL dpocl
       _RL dpicl
       _RL dalkl
       _RL do2l
       _RL dZooCl(nzmax)
c air-sea fluxes
       _RL flxCO2(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
       _RL flxALK(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
       _RL flxO2(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
#endif

       _RL tot_Nfix

       _RL tmp

       _RL phytmp, chltmp

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
c ANNA_TAVE
#ifdef WAVES_DIAG_PCHL
           DO np=1,npmax
             Pchlarr(i,j,k,np) = 0. _d 0
           ENDDO
#endif
c ANNA end TAVE
#ifdef DAR_DIAG_RSTAR
           DO np=1,npmax
             Rstararr(i,j,k,np) = 0. _d 0
           ENDDO
#endif
COJ
#ifdef ALLOW_DIAZ
#ifdef DAR_DIAG_NFIXP
           DO np=1,npmax
             NfixParr(i,j,k,np) = 0. _d 0
           ENDDO
#endif
#endif
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
#ifdef ALLOW_CARBON
c air-sea flux and dilution of CO2
         call dic_surfforcing(Ptr(1-OLx,1-OLy,1,bi,bj,iDIC),
     &                        Ptr(1-OLx,1-OLy,1,bi,bj,iALK),
     &                        Ptr(1-OLx,1-OLy,1,bi,bj,iPO4),
     &                        Ptr(1-OLx,1-OLy,1,bi,bj,iSi),
     &                        flxCO2,
     &                    bi,bj,imin,imax,jmin,jmax,
     &                    myIter,myTime,myThid)
c air-sea flux of O2
         call dic_o2_surfforcing(Ptr(1-OLx,1-OLy,1,bi,bj,iO2),
     &                       flxO2,
     &                    bi,bj,imin,imax,jmin,jmax,
     &                    myIter,myTime,myThid)
c dilusion of alkalinity
         call dic_alk_surfforcing(Ptr(1-OLx,1-OLy,1,bi,bj,iALK),
     &                       flxALK,
     &                    bi,bj,imin,imax,jmin,jmax,
     &                    myIter,myTime,myThid)
#endif

 
c find light in each grid cell
c ---------------------------
c determine incident light
#ifndef  READ_PAR
#ifdef USE_QSW
         DO j=1-OLy,sNy+OLy
         DO i=1-OLx,sNx+OLx
#ifdef ALLOW_LONGSTEP
           Qswlocal=LS_Qsw(i,j,bi,bj)
#else
           Qswlocal=Qsw(i,j,bi,bj)
#endif
           sur_par(i,j,bi,bj)=-parfrac*Qswlocal*
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

#ifdef ALLOW_PAR_DAY
C find out which slot of PARday has previous day's average
         dtsubtime = dTtracerLev(1)/float(nsubtime)
C        running index of averaging period
C        myTime has already been incremented in this iteration,
C        go back half a substep to avoid roundoff problems
         iperiod = FLOOR((newtime-0.5 _d 0*dtsubtime)
     &                   /darwin_PARavPeriod)
C        0 -> 1, 1->2, 2->0, ...
         PARiprev = MOD(iperiod, 2) + 1
         
#ifdef   ALLOW_DIAGNOSTICS
C        always fill; this will be the same during PARavPeriod, but this
C        way it won't blow up for weird diagnostics periods.
C        we fill before updating, so the diag is the one used in this time
C        step
         CALL DIAGNOSTICS_FILL(
     &         PARday(1-Olx,1-Oly,1,bi,bj,PARiprev),'PARday  ',
     &         0,Nr,2,bi,bj,myThid )
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
#ifdef OASIM
          sfPAR(ilam) = oasim_ed(i,j,ilam,bi,bj)+
     &                      oasim_es(i,j,ilam,bi,bj)
#else
          sfPAR(ilam) = sf(ilam)*lite
#endif
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
#ifdef DYNAMIC_CHL
               phychl(np) = max(Ptr(i,j,k,bi,bj,iChl+np-1),0. _d 0)
#else
               phychl(np) = max(Chl_phy(i,j,k,bi,bj,np), 0. _d 0)
#endif
#endif
             ENDDO
             popl  = max(Ptr(i,j,k,bi,bj,iPOP  ),0. _d 0)
             ponl  = max(Ptr(i,j,k,bi,bj,iPON  ),0. _d 0)
             pofel = max(Ptr(i,j,k,bi,bj,iPOFe ),0. _d 0)
             psil  = max(Ptr(i,j,k,bi,bj,iPOSi ),0. _d 0)
             NH4l  = max(Ptr(i,j,k,bi,bj,iNH4  ),0. _d 0)
             NO2l  = max(Ptr(i,j,k,bi,bj,iNO2  ),0. _d 0)
#ifdef ALLOW_CARBON
             dicl  = max(Ptr(i,j,k,bi,bj,iDIC  ),0. _d 0)
             docl  = max(Ptr(i,j,k,bi,bj,iDOC  ),0. _d 0)
             pocl  = max(Ptr(i,j,k,bi,bj,iPOC  ),0. _d 0)
             picl  = max(Ptr(i,j,k,bi,bj,iPIC  ),0. _d 0)
             alkl  = max(Ptr(i,j,k,bi,bj,iALK  ),0. _d 0)
             o2l   = max(Ptr(i,j,k,bi,bj,iO2   ),0. _d 0)
             DO nz = 1,nzmax
               ZooCl(nz)  = max(Ptr(i,j,k,bi,bj,iZooC (nz)),0. _d 0)
             ENDDO
#endif

             totphyC = 0. _d 0
             DO np=1,npmax
              totphyC = totphyC + R_PC(np)*Ptr(i,j,k,bi,bj,iPhy+np-1)
             ENDDO

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
#ifdef ALLOW_CARBON
                pocupl = 0. _d 0
                picupl = 0. _d 0
#endif
             endif

c ANNA only define PARl here if not WAVEBANDS
#ifndef WAVEBANDS
             PARl = PAR(i,j,k)
#endif

#ifdef ALLOW_LONGSTEP
             Tlocal = LS_theta(i,j,k,bi,bj)
             Slocal = LS_salt(i,j,k,bi,bj)
#else
             Tlocal = theta(i,j,k,bi,bj)
             Slocal = salt(i,j,k,bi,bj)
#endif

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
#ifdef DYNAMIC_CHL
             do np=1,npmax
               dphychl(np)=0. _d 0
             enddo
#endif
#ifdef ALLOW_CARBON
             ddicl=0. _d 0
             ddocl=0. _d 0
             dpocl=0. _d 0
             dpicl=0. _d 0
             dalkl=0. _d 0
             do2l=0. _d 0
             do nz=1,nzmax
               dzoocl(nz)=0. _d 0
             enddo
#endif
c set other arguments to zero
             PP=0. _d 0
             Nfix=0. _d 0
             do np=1,npmax
                Rstarl(np)=0. _d 0
                RNstarl(np)=0. _d 0
#ifdef DAR_DIAG_GROW
                Growl(np)=0.  _d 0
                Growsql(np)=0. _d 0
#endif
#ifdef ALLOW_DIAZ
#ifdef DAR_DIAG_NFIXP
                NfixPl(np)=0. _d 0
#endif
#endif
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
#ifdef DAR_DIAG_GROW
     O                       Growl, Growsql,
#endif
#ifdef ALLOW_DIAZ
#ifdef DAR_DIAG_NFIXP
     O                       NfixPl,
#endif
#endif
     O                       dphy, dzooP, dzooN, dzooFe,
     O                       dzooSi,
     O                       dPO4l, dNO3l, dFeTl, dSil,
     O                       dNH4l, dNO2l,
     O                       dDOPl, dDONl, dDOFel, 
     O                       dPOPl, dPONl, dPOFel, dPSil,
#ifdef ALLOW_CARBON
     I                       dicl, docl, pocl, picl,
     I                       alkl, zoocl,
     I                       pocupl, picupl,
     O                       ddicl, ddocl, dpocl, dpicl,
     O                       dalkl, do2l, dzoocl,
#endif
#ifdef GEIDER
     O                       phychl,
#ifdef DYNAMIC_CHL
     I                       dphychl,
#endif
#ifdef WAVEBANDS
     O                       PARwl,PARwupl,
     O                       drF(k),
#endif
#endif
#ifdef ALLOW_PAR_DAY
     I                       PARday(i,j,k,bi,bj,PARiprev),
#endif
#ifdef DAR_DIAG_CHL
     O                       ChlGeiderlocal, ChlDoneylocal,
     O                       ChlCloernlocal,
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
#ifdef IRON_SED_SOURCE
c only above minimum depth (continental shelf)
             if (rF(k).lt.depthfesed) then
c only if bottom layer
               if (HFacC(i,j,k+1,bi,bj).eq.0. _d 0) then
#ifdef IRON_SED_SOURCE_VARIABLE
c calculate sink of POP into bottom layer
                tmp=(wp_sink*POPupl)/(dzlocal)
c convert to dPOCl
                dFetl=dFetl+fesedflux_pcm*(tmp*106. _d 0)
#else
                 dFetl=dFetl+fesedflux/
     &                   (drF(k)*hFacC(i,j,k,bi,bj))
#endif
               endif
             endif
#endif


             popupl = POPl
             ponupl = PONl
             pofeupl = POFel
             psiupl = PSil
             do np=1,npmax
               Phyup(np) = Phy(np) 
             enddo


c
#ifdef ALLOW_CARBON
             pocupl = POCl
             picupl = PICl
c include surface forcing
             if (k.eq.1) then
              ddicl  =  ddicl  + flxCO2(i,j,bi,bj)
              dalkl  =  dalkl  + flxALK(i,j,bi,bj)
              do2l   =  do2l   + flxO2(i,j,bi,bj)
             endif
#endif
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
#ifdef RELAX_NUTS
#ifdef DENIT_RELAX
           if (rF(k).gt.depthdenit) then
            if (darwin_relaxscale.gt.0. _d 0) then
             IF ( darwin_NO3_RelaxFile .NE. ' '  ) THEN
c Fanny's formulation
              tmp=(Ptr(i,j,k,bi,bj,iNO3 )-no3_obs(i,j,k,bi,bj))
              if (tmp.gt.0. _d 0) then
                dno3l=dno3l-(tmp/
     &                      darwin_relaxscale)
              endif
c --- end fanny's formulation
             ENDIF
c steph's alternative
c            tmp=(Ptr(i,j,k,bi,bj,iNO3 )-
c    &                16. _d 0 * Ptr(i,j,k,bi,bj,iPO4 ))
c            if (tmp.gt.0. _d 0) then
c               dno3l=dno3l-(tmp/
c    &                      darwin_relaxscale)
c             endif
c ---- end steph's alternative
            endif
           endif
#else
            if (darwin_relaxscale.gt.0. _d 0) then
             IF ( darwin_PO4_RelaxFile .NE. ' '  ) THEN
              tmp=(Ptr(i,j,k,bi,bj,iPO4 )-po4_obs(i,j,k,bi,bj))
              if (tmp.lt.0. _d 0) then
                dpo4l=dpo4l-(tmp/
     &                      darwin_relaxscale)
              endif
             ENDIF
             IF ( darwin_NO3_RelaxFile .NE. ' '  ) THEN
              tmp=(Ptr(i,j,k,bi,bj,iNO3 )-no3_obs(i,j,k,bi,bj))
              if (tmp.lt.0. _d 0) then
                dno3l=dno3l-(tmp/
     &                      darwin_relaxscale)
              endif
             ENDIF
             IF ( darwin_Fet_RelaxFile .NE. ' '  ) THEN
              tmp=(Ptr(i,j,k,bi,bj,iFeT )-fet_obs(i,j,k,bi,bj))
              if (tmp.lt.0. _d 0) then
                dfetl=dfetl-(tmp/
     &                      darwin_relaxscale)
              endif
             ENDIF
             IF ( darwin_Si_RelaxFile .NE. ' '  ) THEN
              tmp=( Ptr(i,j,k,bi,bj,iSi  )-si_obs(i,j,k,bi,bj))
              if (tmp.lt.0. _d 0) then
                dsil=dsil-(tmp/
     &                    darwin_relaxscale)
              endif
             ENDIF
            endif
#endif
#endif
#ifdef FLUX_NUTS
                dpo4l=dpo4l+po4_flx(i,j,k,bi,bj)
                dno3l=dno3l+no3_flx(i,j,k,bi,bj)
                dfetl=dfetl+fet_flx(i,j,k,bi,bj)
                dsil=dsil+si_flx(i,j,k,bi,bj)
#endif
c
c now update main tracer arrays
          dtplankton = PTRACERS_dTLev(k)/float(nsubtime)
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
#ifdef DYNAMIC_CHL
           if (np.eq.1) Chl=0. _d 0
           Ptr(i,j,k,bi,bj,iChl+np-1) = Ptr(i,j,k,bi,bj,iChl+np-1) +
     &                                       dtplankton*dphychl(np)
           chltmp=Ptr(i,j,k,bi,bj,iChl+np-1)
           phytmp=Ptr(i,j,k,bi,bj,iPhy+np-1)
           Ptr(i,j,k,bi,bj,iChl+np-1)=
     &         max(chltmp,phytmp*R_PC(np)*chl2cmin(np))
c          if (np.eq.1.and.i.eq.1.and.j.eq.1.and.k.eq.1)
c    &     print*,chltmp,phytmp,phytmp*R_PC(np)*chl2cmin(np),
c    &                   phytmp*R_PC(np)*chl2cmax(np)
c in darwin_plankton this is stored for previous timestep. Reset here.
           Chl=Chl+Ptr(i,j,k,bi,bj,iChl+np-1)
#else
           Chl_phy(i,j,k,bi,bj,np)=phychl(np)
#endif
#endif
         ENDDO
#ifdef ALLOW_CARBON
          Ptr(i,j,k,bi,bj,iDIC ) = Ptr(i,j,k,bi,bj,iDIC ) +
     &                                  dtplankton*ddicl
          Ptr(i,j,k,bi,bj,iDOC ) = Ptr(i,j,k,bi,bj,iDOC ) +
     &                                  dtplankton*ddocl
          Ptr(i,j,k,bi,bj,iPOC ) = Ptr(i,j,k,bi,bj,iPOC ) +
     &                                  dtplankton*dpocl
          Ptr(i,j,k,bi,bj,iPIC ) = Ptr(i,j,k,bi,bj,iPIC ) +
     &                                  dtplankton*dpicl
          Ptr(i,j,k,bi,bj,iALK ) = Ptr(i,j,k,bi,bj,iALK ) +
     &                                  dtplankton*dalkl
          Ptr(i,j,k,bi,bj,iO2  ) = Ptr(i,j,k,bi,bj,iO2  ) +
     &                                  dtplankton*do2l
          DO nz = 1,nzmax
           Ptr(i,j,k,bi,bj,iZooC (nz)) = Ptr(i,j,k,bi,bj,iZooC (nz)) +
     &                                        dtplankton*dzoocl (nz)
          ENDDO
#endif
c
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
c ANNA_TAVE
#ifdef WAVES_DIAG_PCHL
             DO np = 1,npmax
               Pchlarr(i,j,k,np) = phychl(np)
             ENDDO
#endif
c ANNA end TAVE
#ifdef DAR_DIAG_RSTAR
             DO np = 1,npmax
               Rstararr(i,j,k,np) = Rstarl(np)
             ENDDO
#endif
#ifdef ALLOW_DIAZ
#ifdef DAR_DIAG_NFIXP
             DO np = 1,npmax
               NfixParr(i,j,k,np) = NfixPl(np)
             ENDDO
#endif
#endif
#ifdef DAR_DIAG_CHL
             GeiderChlarr(i,j,k) = ChlGeiderlocal
             DoneyChlarr(i,j,k) = ChlDoneylocal
             CloernChlarr(i,j,k) = ChlCloernlocal
             IF (totphyC .NE. 0. _d 0) THEN
               GeiderChl2Carr(i,j,k) = ChlGeiderlocal/totphyC
               DoneyChl2Carr(i,j,k) = ChlDoneylocal/totphyC
               CloernChl2Carr(i,j,k) = ChlCloernlocal/totphyC
             ELSE
               GeiderChl2Carr(i,j,k) = 0. _d 0
               DoneyChl2Carr(i,j,k) = 0. _d 0
               CloernChl2Carr(i,j,k) = 0. _d 0
             ENDIF
#endif
COJ
#endif /* ALLOW_DIAGNOSTICS */

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
c ANNA_TAVE
#ifdef WAVES_DIAG_PCHL
             do np=1,npmax
               Pchlave(i,j,k,bi,bj,np)=Pchlave(i,j,k,bi,bj,np)+
     &                           phychl(np)*dtplankton
             enddo
#endif
c ANNA end TAVE
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
#ifdef DAR_DIAG_GROW
             do np=1,npmax
               Growave(i,j,k,bi,bj,np)=Growave(i,j,k,bi,bj,np)+
     &                           Growl(np)*dtplankton
               Growsqave(i,j,k,bi,bj,np)=Growsqave(i,j,k,bi,bj,np)+
     &                           Growsql(np)*dtplankton
             enddo
#endif

#ifdef ALLOW_DIAZ
#ifdef DAR_DIAG_NFIXP
             do np=1,npmax
               NfixPave(i,j,k,bi,bj,np)=NfixPave(i,j,k,bi,bj,np)+
     &                           NfixPl(np)*dtplankton
             enddo
#endif
#endif
#endif

#ifdef ALLOW_CARBON
             if (k.eq.1) then
              SURave(i,j,bi,bj)    =SURave(i,j,bi,bj)+
     &                              flxCO2(i,j,bi,bj)*dtplankton
              SURCave(i,j,bi,bj)    =SURCave(i,j,bi,bj)+
     &                              FluxCO2(i,j,bi,bj)*dtplankton
              SUROave(i,j,bi,bj)   =SUROave(i,j,bi,bj)+
     &                              flxO2(i,j,bi,bj)*dtplankton
              pCO2ave(i,j,bi,bj)   =pCO2ave(i,j,bi,bj)+
     &                              pCO2(i,j,bi,bj)*dtplankton
              pHave(i,j,bi,bj)     =pHave(i,j,bi,bj)+
     &                              pH(i,j,bi,bj)*dtplankton
             endif
#endif
          endif  
c end if hFac>0

         enddo ! k
c end layer loop
c

       ENDDO ! i
       ENDDO ! j

#ifdef ALLOW_PAR_DAY
C      1 <-> 2
       PARiaccum  = 3 - PARiprev

       DO k=1,nR
        DO j=1,sNy
         DO i=1,sNx
           PARday(i,j,k,bi,bj,PARiaccum) =
     &     PARday(i,j,k,bi,bj,PARiaccum) + PAR(i,j,k)
         ENDDO
        ENDDO
       ENDDO

       phase = 0. _d 0
       itistime = DIFF_PHASE_MULTIPLE( phase, darwin_PARavPeriod,
     &              newtime, dtsubtime)

       IF ( itistime ) THEN
C       compute average
        nav = darwin_PARnav
        IF (newtime - baseTime .LT. darwin_PARavPeriod) THEN
C         incomplete period at beginning of run
          nav = NINT((newtime-baseTime)/dtsubtime)
        ENDIF
        DO k=1,nR
         DO j=1,sNy
          DO i=1,sNx
            PARday(i,j,k,bi,bj,PARiaccum) =
     &      PARday(i,j,k,bi,bj,PARiaccum) / nav
          ENDDO
         ENDDO
        ENDDO
C       reset the other slot for averaging
        DO k=1,nR
         DO j=1,sNy
          DO i=1,sNx
            PARday(i,j,k,bi,bj,PARiprev) = 0. _d 0
          ENDDO
         ENDDO
        ENDDO
       ENDIF
C itistime
#endif

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
c ANNA_TAVE
#ifdef WAVES_DIAG_PCHL
        DO np=1,MIN(99,npmax)
         WRITE(diagname,'(A5,I2.2,A1)') 'Pchl',np,' '
         CALL DIAGNOSTICS_FILL( Pchlarr(1-Olx,1-Oly,1,np), diagname,
     &                          0,Nr,2,bi,bj,myThid )
        ENDDO
#endif
c ANNA end TAVE
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
#ifdef ALLOW_DIAZ
#ifdef DAR_DIAG_NFIXP
        DO np=1,MIN(99,npmax)
         WRITE(diagname,'(A5,I2.2,A1)') 'NfixP',np,' '
         CALL DIAGNOSTICS_FILL( NfixParr(1-Olx,1-Oly,1,np), diagname,
     &                          0,Nr,2,bi,bj,myThid )
        ENDDO
#endif
#endif
#ifdef DAR_DIAG_CHL
        CALL DIAGNOSTICS_FILL( GeiderChlarr(1-Olx,1-Oly,1), 'ChlGeide',
     &                         0,Nr,2,bi,bj,myThid )
        CALL DIAGNOSTICS_FILL( GeiderChl2Carr(1-Olx,1-Oly,1),'Chl2CGei',
     &                         0,Nr,2,bi,bj,myThid )
        CALL DIAGNOSTICS_FILL( DoneyChlarr(1-Olx,1-Oly,1), 'ChlDoney',
     &                         0,Nr,2,bi,bj,myThid )
        CALL DIAGNOSTICS_FILL( DoneyChl2Carr(1-Olx,1-Oly,1), 'Chl2CDon',
     &                         0,Nr,2,bi,bj,myThid )
        CALL DIAGNOSTICS_FILL( CloernChlarr(1-Olx,1-Oly,1), 'ChlCloer',
     &                         0,Nr,2,bi,bj,myThid )
        CALL DIAGNOSTICS_FILL( CloernChl2Carr(1-Olx,1-Oly,1),'Chl2CClo',
     &                         0,Nr,2,bi,bj,myThid )
#endif
#ifdef ALLOW_CARBON
        CALL DIAGNOSTICS_FILL( flxCO2(1-Olx,1-Oly,bi,bj), 'DICTFLX ',
     &                         0,1,2,bi,bj,myThid )
        CALL DIAGNOSTICS_FILL( FluxCO2(1-Olx,1-Oly,bi,bj), 'DICCFLX ',
     &                         0,1,2,bi,bj,myThid )
        CALL DIAGNOSTICS_FILL( flxO2(1-Olx,1-Oly,bi,bj), 'DICOFLX ',
     &                         0,1,2,bi,bj,myThid )
        CALL DIAGNOSTICS_FILL( pCO2(1-Olx,1-Oly,bi,bj), 'DICPCO2 ',
     &                         0,1,2,bi,bj,myThid )
        CALL DIAGNOSTICS_FILL( pH(1-Olx,1-Oly,bi,bj), 'DICPHAV ',
     &                         0,1,2,bi,bj,myThid )
#endif /* ALLOW_CARBON */
       ENDIF
#endif /* ALLOW_DIAGNOSTICS */
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
#ifdef ALLOW_CARBON
         dic_timeave(bi,bj,k)=dic_timeave(bi,bj,k)
     &                         +dtplankton
#endif
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
