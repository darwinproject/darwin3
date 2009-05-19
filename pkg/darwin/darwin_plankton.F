C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_plankton.F,v 1.17 2009/05/19 20:28:08 stephd Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "DARWIN_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

c ====================================================================
c SUBROUTINE DARWIN_PLANKTON
c 1. Local ecological interactions for models with many phytoplankton
c    "functional groups"
c 2. Timestep plankton and nutrients locally
c 3. Includes explicit DOM and POM
c 4. Remineralization of detritus also determined in routine
c 5. Sinking particles and phytoplankton
c 6. NOT in this routine: iron chemistry
c
c       Mick Follows, Scott Grant, Fall/Winter 2005
c       Stephanie Dutkiewicz Spring/Summer 2006
c
c - add extra diagnostics, including R* (#define DAR_DIAG_RSTAR) - Stephanie, Spring 2007
c - add check for conservation (#define CHECK_CONS) - Stephanie, Spring 2007
c - improve grazing (#undef OLD_GRAZING) - Stephanie, Spring 2007
c - add diazotrophy (#define ALLOW_DIAZ) - Stephanie, Spring 2007
c - add mutation code (#define ALLOW_MUTANTS) - Jason Bragg, Spring/Summer 2007
c - new nitrogen limiting scheme (#undef OLD_NSCHEME) - Jason Bragg, Summer 2007
c - fix bug in diazotroph code  - Stephanie, Fall 2007
c - add additional r* diagnostic for (no3+no2) - Stephanie, Winter 2007
c - add diversity diagnostics - Stephanie, Winter 2007
c - add geider chl:c ratio and growth rate dependence,
c   though has no photo-inhibtion at this point - Stephanie, Spring 2008
c - add waveband dependence of light attenuation and absorption,
c   NOTE: need to have geider turned on too  - Anna Hickman, Summer 2008
c ====================================================================

c ANNA pass extra variables if WAVEBANDS
         SUBROUTINE DARWIN_PLANKTON(
     U                       phyto,
     I                       zooP, zooN, zooFe, zooSi,
     O                       PP, Chl, Nfix,
     I                       PO4local, NO3local, FeTlocal, Silocal,
     I                       NO2local, NH4local, 
     I                       DOPlocal, DONlocal, DOFelocal,
     I                       POPlocal, PONlocal, POFelocal, PSilocal,
     I                       phytoup, popuplocal, ponuplocal, 
     I                       pofeuplocal, psiuplocal,
     I                       PARlocal,Tlocal, Slocal,
     I                       freefelocal, inputFelocal,
     I                       bottom, dzlocal,
     O                       Rstarlocal, RNstarlocal,
     O                       dphytodt, dzooPdt, dzooNdt, dzooFedt,
     O                       dzooSidt,
     O                       dPO4dt, dNO3dt, dFeTdt, dSidt,
     O                       dNH4dt, dNO2dt,
     O                       dDOPdt, dDONdt, dDOFedt, 
     O                       dPOPdt, dPONdt, dPOFedt, dPSidt,
#ifdef ALLOW_CARBON
     I                       DIClocal, DOClocal, POClocal, PIClocal,
     I                       ALKlocal, ZooClocal,
     I                       POCuplocal, PICuplocal,
     O                       dDICdt, dDOCdt, dPOCdt, dPICdt,
     O                       dALKdt, dO2dt, dZOOCdt,
#endif
#ifdef GEIDER
     O                       phychl,
#ifdef WAVEBANDS
     O                       PARwlocal,PARwuplocal,
     O                       dz,
#endif
#endif
#ifdef ALLOW_PAR_DAY
     I                       PARdaylocal,
#endif
#ifdef DAR_DIAG_CHL
     O                       ChlGeiderlocal, ChlDoneylocal,
     O                       ChlCloernlocal,
#endif
     I                       debug,
     I                       runtim,
     I                       MyThid) 
                  

         implicit none
#include "DARWIN_SIZE.h"
#include "DARWIN.h"
#include "DARWIN_PARAMS.h"

c ANNA set wavebands params
#ifdef WAVEBANDS
#include "WAVEBANDS_PARAMS.h"
#endif


C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid
CEOP
c === GLOBAL VARIABLES =====================
c npmax = no of phyto functional groups
c nzmax = no of grazer species
c phyto = phytoplankton
c zoo   = zooplankton
         _RL phyto(npmax)
         _RL zooP(nzmax)
         _RL zooN(nzmax)
         _RL zooFe(nzmax)
         _RL zooSi(nzmax)
         _RL PP
         _RL Nfix
         _RL Chl
         _RL PO4local
         _RL NO3local
         _RL FeTlocal
         _RL Silocal
         _RL NO2local
         _RL NH4local
         _RL DOPlocal
         _RL DONlocal
         _RL DOFelocal
         _RL POPlocal 
         _RL PONlocal
         _RL POFelocal
         _RL PSilocal
         _RL phytoup(npmax)
         _RL POPuplocal
         _RL PONuplocal
         _RL POFeuplocal
         _RL PSiuplocal 
         _RL PARlocal
         _RL Tlocal
         _RL Slocal
         _RL freefelocal
         _RL inputFelocal
         _RL bottom
         _RL dzlocal
         _RL Rstarlocal(npmax)
         _RL RNstarlocal(npmax)
         INTEGER debug
         _RL dphytodt(npmax)
         _RL dzooPdt(nzmax)
         _RL dzooNdt(nzmax)
         _RL dzooFedt(nzmax)
         _RL dzooSidt(nzmax)
         _RL dPO4dt
         _RL dNO3dt
         _RL dNO2dt
         _RL dNH4dt
         _RL dFeTdt
         _RL dSidt
         _RL dDOPdt
         _RL dDONdt
         _RL dDOFedt
         _RL dPOPdt
         _RL dPONdt
         _RL dPOFedt
         _RL dPSidt
#ifdef ALLOW_CARBON
         _RL DIClocal
         _RL DOClocal
         _RL POClocal
         _RL PIClocal
         _RL ALKlocal
         _RL O2local
         _RL ZooClocal(nzmax)
         _RL POCuplocal
         _RL PICuplocal
         _RL dDICdt
         _RL dDOCdt
         _RL dPOCdt
         _RL dPICdt
         _RL dALKdt
         _RL dO2dt
         _RL dZOOCdt(nzmax)
#endif
#ifdef GEIDER
         _RL phychl(npmax)
         _RL alpha_I_tmp(npmax)
#endif
#ifdef ALLOW_PAR_DAY
         _RL PARdaylocal
#endif
#ifdef DAR_DIAG_CHL
         _RL ChlGeiderlocal, ChlDoneylocal, ChlCloernlocal
#endif
         _RL runtim

c ANNA Global variables for WAVEBANDS
c ANNA these variables are passed in/out of darwin_forcing.F
#ifdef WAVEBANDS
         _RL PARwuplocal(tlam)    !PAR at top(in) of local gridcell at each wavelength 
                                  !reset to bottom of local gridcell on way out
         _RL PARwlocal(tlam)      !PAR at midpoint of previous(in) and local(out) gridcell
         _RL dz                   !layer thickness 
#endif
c ANNA endif





c LOCAL VARIABLES
c -------------------------------------------------------------

c WORKING VARIABLES
c np = phytoplankton index
         integer np
c nz = zooplankton index
         integer nz

c variables for phytoplankton growth rate/nutrient limitation
c phytoplankton specific nutrient limitation term
         _RL limit(npmax)
c phytoplankton light limitation term
         _RL ilimit(npmax)
         _RL ngrow(npmax)
         _RL grow(npmax)
         _RL PspecificPO4(npmax)
         _RL phytoTempFunction(npmax)
         _RL dummy
         _RL Ndummy
         _RL Nsourcelimit(npmax)
         _RL Nlimit(npmax)
         _RL NO3limit(npmax)
         _RL NO2limit(npmax)
         _RL NH4limit(npmax)

c for check N limit scheme
         _RL Ndiff
         _RL NO3limcheck
         _RL NO2limcheck
         _RL Ndummy1
         LOGICAL check_nlim

#ifndef OLD_NSCHEME
c [jbmodif] some new N terms
         integer N2only
         integer noNOdadv
         integer NOreducost
         _RL NO2zoNH4
         _RL NOXzoNH4
#endif

c varible for mimumum phyto
         _RL phytomin(npmax)

#ifdef OLD_GRAZE
c  variables for zooplankton grazing rates
         _RL zooTempFunction(nzmax)
         _RL grazing_phyto(npmax)
         _RL grazingP(nzmax)
         _RL grazingN(nzmax)
         _RL grazingFe(nzmax)
         _RL grazingSi(nzmax)
#else
c  variables for zooplankton grazing rates
         _RL zooTempFunction(nzmax)
         _RL allphyto(nzmax)
         _RL grazphy(npmax,nzmax)
         _RL sumgrazphy(npmax)
         _RL sumgrazzoo(nzmax)
         _RL sumgrazzooN(nzmax)
         _RL sumgrazzooFe(nzmax)
         _RL sumgrazzooSi(nzmax)
         _RL sumgrazloss(nzmax)
         _RL sumgrazlossN(nzmax)
         _RL sumgrazlossFe(nzmax)
         _RL sumgrazlossSi(nzmax)
#endif

#ifdef GEIDER
        _RL pcarbon(npmax)
        _RL pcm(npmax)
        _RL chl2c(npmax)
#endif

#ifdef DAR_DIAG_CHL
         _RL tmppcm
         _RL tmpchl2c
#endif
c variables for nutrient uptake
         _RL consumpPO4
         _RL consumpNO3
         _RL consumpNO2
         _RL consumpNH4
         _RL consumpFeT
         _RL consumpSi

c variables for reminerlaization of DOM and POM
         _RL DOPremin
         _RL DONremin
         _RL DOFeremin
         _RL preminP
         _RL preminN
         _RL preminFe
         _RL preminSi

c for sinking matter
         _RL psinkP
         _RL psinkN
         _RL psinkFe
         _RL psinkSi
         _RL psinkphy(npmax)

#ifdef ALLOW_CARBON
         _RL consumpDIC
         _RL consumpDIC_PIC
         _RL preminC
         _RL DOCremin
         _RL totphy_doc
         _RL totzoo_doc
         _RL totphy_poc
         _RL totzoo_poc
         _RL totphy_pic
         _RL psinkC
         _RL psinkPIC
         _RL disscPIC
#ifdef OLD_GRAZE
         _RL grazingC(nzmax)
#else
c  variables for zooplankton grazing rates
         _RL sumgrazzooC(nzmax)
         _RL sumgrazlossC(nzmax)
#endif

#endif

c variables for conversions from phyto and zoo to DOM and POM
         _RL totphy_dop
         _RL totphy_pop
         _RL totphy_don
         _RL totphy_pon
         _RL totphy_dofe
         _RL totphy_pofe
         _RL totphy_dosi
         _RL totphy_posi

         _RL totzoo_dop
         _RL totzoo_pop
         _RL totzoo_don
         _RL totzoo_pon
         _RL totzoo_dofe
         _RL totzoo_pofe
         _RL totzoo_posi

         _RL NO2prod
         _RL NO3prod
  
         _RL facpz

         _RL kpar, kinh

         _RL tmpr,tmpz, tmpgrow, tmp1, tmp2

         integer ITEST

c ANNA local variables for WAVEBANDS
#ifdef WAVEBANDS 
         integer i,ilam
         integer nl

c ANNA for interpolation
         _RL cu_area
         _RL waves_diff
         _RL light_diff
         _RL alphaI_diff
         _RL squ_part
         _RL tri_part
         _RL seg_area

c ANNA inportant but local variables that can be fogotten
         _RL PARwdn(tlam)         !light at bottom of local gridcell
         _RL attenwl(tlam)        !attenuation (m-1)
         _RL sumaphy_nl(tlam)     !total phyto absorption at each wavelength
         _RL alpha_I_local_nl(tlam) !temporary variable
         _RL alpha_I_local(npmax)   !value of alpha * PARlocal for use in Geider growth
#endif
c ANNA endif

c ANNA_INHIB 
#ifdef INHIB_GEID
         _RL Ek
         _RL EkoverE
#endif
#ifdef INHIB_WAVES
c local variables for inhibition tests
         _RL Ek
         _RL EkoverE
         _RL alpha_mean(npmax)
         _RL alpha_diff
#endif
c end this bit ANNA_INHIB

c.................................................................

#ifdef ALLOW_MUTANTS
c -m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-
c mutation variables [jbmodif]
         INTEGER nsisone
         INTEGER nsistwo  
         INTEGER nsisthree
         INTEGER nsisfour
         INTEGER npro
         INTEGER taxind         
         _RL mutfor, mutback
         _RL grow1
         _RL grow2
         _RL grow3
         _RL grow4
#endif

         INTEGER numtax
         _RL oneyr,threeyr

#ifdef  ALLOW_MUTANTS
c compile time options -- could maybe be moved to
c run time and set in data.gchem???
c QQQQQQQ
c Initialize sister taxon mutation scheme 
c if numtax = 1, mutation is off
         numtax = 4
c number of plankton types to assign for 
c wild and mutants types
         npro = 60
#else
         numtax=1
#endif

         oneyr = 86400.0 _d 0*360.0 _d 0 
         threeyr = oneyr*3. _d 0

c end mutation variables [jbmodif]
c -m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-

#ifndef OLD_NSCHEME
c [jbmodif] init new N terms
c  if those not using NO3 has 
c  N limit with denominator with NO3 or not: 0=NO3 in denom; 1=NO2 only
         N2only = 1
c ??
         noNOdadv = 1
c energetic disadvantage of using NO2/No3: off=0, on=1
         NOreducost =0
#endif

#ifdef GEIDER
         do np=1,npmax
           pcarbon(np) = 0. _d 0
           pcm(np)=0. _d 0
           chl2c(np)=0. _d 0
         enddo
#endif
         

c set sum totals to zero
         totphy_pop = 0. _d 0
         totphy_dop = 0. _d 0
         totphy_don = 0. _d 0
         totphy_pon = 0. _d 0
         totphy_dofe = 0. _d 0
         totphy_pofe = 0. _d 0
         totphy_posi = 0. _d 0

         totzoo_dop = 0. _d 0
         totzoo_pop = 0. _d 0
         totzoo_don = 0. _d 0
         totzoo_pon = 0. _d 0
         totzoo_dofe = 0. _d 0
         totzoo_pofe = 0. _d 0
         totzoo_posi = 0. _d 0

         consumpPO4 = 0.0 _d 0
         consumpNO3 = 0.0 _d 0
         consumpNO2 = 0.0 _d 0
         consumpNH4 = 0.0 _d 0
         consumpFeT = 0.0 _d 0
         consumpSi  = 0.0 _d 0

#ifdef ALLOW_CARBON
         totphy_doc = 0. _d 0
         totphy_poc = 0. _d 0
         totphy_pic = 0. _d 0
         totzoo_doc = 0. _d 0
         totzoo_poc = 0. _d 0
         consumpDIC = 0.0 _d 0
         consumpDIC_PIC = 0.0 _d 0
#endif

c zeros for diagnostics
        PP=0. _d 0
        Nfix=0. _d 0
        Chl=0. _d 0

c set up phtyoplankton array to be used for grazing and mortality
c set up other variable used more than once to zero
         do np = 1, npmax
           dummy = phyto(np)-phymin
           phytomin(np)=max(dummy,0. _d 0)
           NH4limit(np)=0. _d 0
           NO2limit(np)=0. _d 0
           NO3limit(np)=0. _d 0
         enddo


#ifdef ALLOW_MUTANTS
c SWD if parent population is zero (ie. negative) treat all mutants
c as zeros too
       if(runtim .gt. threeyr) then
       if(numtax .gt. 1)then
        do np=1,npro
          if(mod(np,numtax).eq. 1. _d 0)then
             nsisone   = np
             nsistwo   = np+1
             nsisthree = np+2
             nsisfour  = np+3

             if (phyto(nsisone).le.0. _d 0) then
                if (numtax.gt.1) phyto(nsistwo)=0. _d 0
                if (numtax.gt.2) phyto(nsisthree)=0. _d 0
                if (numtax.gt.3) phyto(nsisfour)=0. _d 0
             endif
           endif
        enddo
       endif
       endif
ccccccccccccccccccccccccccccccc
#endif

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Determine ZooPlankton Temp Dep. Function: will affect maximum
c grazing rates
          do nz = 1,nzmax  
c              zooTempFunction(nz) = zooTempCoeff(nz)*EXP(
c    &             zooTempExp(nz)*(Tlocal - zooTempOptimum(nz)))
            zooTempFunction(nz) = 1.0 _d 0
          end do   
Ccccccccccccccccccccccccccccccccccc ccccccccccccccccccccccccccccccc


c..........................................................
c ANNA do light attenuation for wavebands 
c.......................................................... 
#ifdef WAVEBANDS
          do nl = 1,tlam     
           sumaphy_nl(nl) = 0.d0      
            do np = 1,npmax   
c get total attenuation (absorption) by phyto at each wavelength
            sumaphy_nl(nl) = sumaphy_nl(nl) +
     &                         (phychl(np)*aphy_chl(np,nl))
            enddo
           attenwl(nl) = (aw(nl)+sumaphy_nl(nl)+acdom(nl))*(dz) 
           PARwdn(nl) = PARwuplocal(nl)*exp(-attenwl(nl))
          enddo

c find for the midpoint of the gridcell (gridcell mean)
          do nl = 1,tlam
C          PARwlocal(nl)=exp((log(PARwuplocal(nl))+log(PARwdn(nl)))*0.5)
           PARwlocal(nl)=sqrt(PARwuplocal(nl)*PARwdn(nl))
          enddo

c re-assign PARwlocalup
          do nl=1,tlam
           PARwuplocal(nl) = PARwdn(nl)
          enddo

c sum wavebands for total PAR        
          cu_area = 0.d0;
          do nl = 1,(tlam-1) 
           waves_diff = pwaves(nl+1)-pwaves(nl)
           light_diff = PARwlocal(nl+1)-PARwlocal(nl)
           squ_part = waves_diff * PARwlocal(nl+1)
           tri_part = waves_diff * light_diff * 5.D-1
           seg_area = squ_part - tri_part
           cu_area = cu_area + seg_area
          enddo

c update the total PAR at the mid point of the gridcell (PARlocal)
          PARlocal = cu_area

#endif
c ANNA endif


c ******************** GROWTH OF PHYTO ****************************
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
#ifndef GEIDER
c ANNA also if not wavebands
#ifndef WAVEBANDS
c Determine phytoplantkon light limitation: will affect growth rate
c using Platt-like equations with inhibition
          do np = 1, npmax
           if (PARlocal.gt.1. _d 0) then
             kpar=ksatPAR(np)/10. _d 0;
             kinh=kinhib(np)/1000. _d 0;
             ilimit(np)=(1.0 _d 0 - EXP(-PARlocal*kpar))
     &                  *(EXP(-PARlocal*kinh)) / 
     &       ( kpar/(kpar+kinh)*EXP(kinh/kpar*LOG(kinh/(kpar+kinh))) )
             ilimit(np)=min(ilimit(np),1. _d 0)
           else
             ilimit(np)=0. _d 0
           endif
          enddo
          if (debug.eq.1) print*,'ilimit',ilimit, PARlocal
#endif
#endif
c ANNA endif

c cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Determine temperature Dependent Growth function for Phyto
          do np=1, npmax
c steph's version
             phytoTempFunction(np) = (
     &                      (phytoTempExp1(np)**Tlocal)*
     &                      exp(- phytoTempExp2(np)*
     &                      (abs(Tlocal - phytoTempOptimum(np)))**
     &                                         phytoDecayPower(np))) -
     &                      tempnorm
             phytoTempFunction(np) = phytoTempCoeff(np)*
     &                  max(phytoTempFunction(np), 1. _d -10)
             phytoTempFunction(np) = min(phytoTempFunction(np),1. _d 0)

c no temp limitation
c             phytoTempFunction(np) = 1.0 _d 0
          enddo
          if (debug.eq.1) print*,'phytoTempFunction',
     &                          phytoTempFunction, Tlocal
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Determine phytoplankton nutrient limitation as mimimum of 
c P,N,Si,Fe. However N can be utilized in several forms, so
c also determine which is used
          do np=1, npmax
            limit(np) = 1.0 _d 0
c P limitation
            if (ksatPO4(np).gt.0. _d 0) then
              dummy = PO4local/(PO4local+ksatPO4(np))
              if (dummy .lt. limit(np)) limit(np) = dummy
            endif
c Fe limitation
            if (ksatFeT(np).gt.0. _d 0) then
              dummy = FeTlocal/(FeTlocal+ksatFeT(np))
              if (dummy .lt. limit(np))limit(np) = dummy
            endif
c Si limiation
            if (R_SiP(np) .ne. 0. _d 0.and.ksatSi(np).gt.0. _d 0) then
              dummy = Silocal/(Silocal+ksatSi(np))
              if (dummy .lt. limit(np))limit(np) = dummy
            endif

c N limitation [jbmodif]
c nsource: genetic preference for {1:NH4&NO2 2:NH4 3:ALL Sources}
c Nsourcelimit marker for which nsource will be consumed {1:NO3 2:NO2 3:NH4}
c (Note: very different to way 1-D model does this)
            if(diazotroph(np) .ne. 1.0 _d 0)then

c NH4, all nsource
               if (ksatNH4(np).gt.0. _d 0) then
                   NH4limit(np) = NH4local/(NH4local+ksatNH4(np))
               endif

#ifdef OLD_NSCHEME
               if (ksatNO2(np).gt.0. _d 0) then
c NO2, if nsource is 1 or 3
                   NO2limit(np) = NO2local/(NO2local+ksatNO2(np))*
     &                    EXP(-sig1*NH4local)
                   NO2limcheck = NO2local/(NO2local+ksatNO2(np))
               endif
c NO3, if nsource is 3
               if (ksatNO3(np).gt.0. _d 0) then
                   NO3limit(np) = NO3local/(NO3local+ksatNO3(np))*
     &                    EXP(-sig2*NH4local - sig3*NO2local)
                   NO3limcheck = NO3local/(NO3local+ksatNO3(np))
               endif
#else
c [jbmodif]
c NO2, if nsource is 1 or 3
               if (ksatNO2(np).gt.0. _d 0 .and. nsource(np).ne.2) then
                 if (N2only.eq.1 .and. nsource(np).eq.1) then
c                if (nsource(np).eq.1) then
                  NO2limit(np) = NO2local/(NO2local+ksatNO2(np))
     &                    *EXP(-sig1*NH4local)
                  NO2limcheck = NO2local/(NO2local+ksatNO2(np))
                 else
                  if (ksatNO3(np).gt.0. _d 0) then
                   NO2limit(np)=NO2local/(NO3local+NO2local+ksatNO3(np))
     &                    *EXP(-sig1*NH4local)
                   NO2limcheck=NO2local/(NO3local+NO2local+ksatNO3(np))
                  endif
                 endif
               endif
c NO3, if nsource is 3
               if (ksatNO3(np).gt.0. _d 0 .and. nsource(np).eq.3) then
                  NO3limit(np)=NO3local/(NO3local+NO2local+ksatNO3(np))
     &                    *EXP(-sig1*NH4local)
                  NO3limcheck=NO3local/(NO3local+NO2local+ksatNO3(np))
               endif

#endif

               if (nsource(np).eq.2) then
                  NO2limit(np) = 0. _d 0
                  NO3limit(np) = 0. _d 0
                  NO2limcheck  = 0. _d 0
                  NO3limcheck  = 0. _d 0
               endif
               if (nsource(np).eq.1) then
                 NO3limit(np) = 0. _d 0
                 NO3limcheck  = 0. _d 0
               endif
               if (nsource(np).eq.3) then
c don't do anything
               endif

               Ndummy = NO3limit(np)+NO2limit(np)+NH4limit(np)
c
c make sure no Nlim disadvantage;
c check that limit doesn't decrease at high NH4 levels
               check_nlim=.FALSE.
               if (check_nlim) then
                  Ndummy1=NO3limcheck+NO2limcheck
                  if (Ndummy.gt.0. _d 0.and.Ndummy.lt.Ndummy1) then
c                   print*,'QQ N limit WARNING',Ndummy, Ndummy1,
c    &                             NO3local,NO2local,NH4local
                    Ndiff=Ndummy1-NH4limit(np)
                    NO2limit(np)=Ndiff * 
     &                     NO2limit(np)/(NO2limit(np)+NO3limit(np))
                    NO3limit(np)=Ndiff *
     &                     NO3limit(np)/(NO2limit(np)+NO3limit(np))
                    Ndummy = NO3limit(np)+NO2limit(np)+NH4limit(np)
                  endif
               endif

               if (Ndummy.gt.1. _d 0) then
                 NO3limit(np) = NO3limit(np)/Ndummy
                 NO2limit(np) = NO2limit(np)/Ndummy
                 NH4limit(np) = NH4limit(np)/Ndummy 
               endif
               Nlimit(np)=NO3limit(np)+NO2limit(np)+NH4limit(np)
               if (Nlimit(np).gt.1.01 _d 0) then
                print*,'QQ Nlimit', Nlimit(np), NO3limit(np), 
     &                              NO2limit(np), NH4limit(np)
               endif
               if (Nlimit(np).le.0. _d 0) then
c                if (np.eq.1) then
c                 print*,'QQ Nlimit', Nlimit(np), NO3limit(np),
c    &                              NO2limit(np), NH4limit(np)
c                 print*,'QQ limit',limit(np), np
c                endif
                 Nlimit(np)=0. _d 0   !1 _d -10
               endif

#ifdef OLD_NSCHEME
c lower growth for higher NO3 consumption at higher light
               if (Nlimit(np).le.0. _d 0) then
                 ngrow(np)=1. _d 0
               else
                if (parlocal.gt.ilight) then
                  ngrow(np)=ngrowfac+(1. _d 0-ngrowfac)*
     &                      (NH4limit(np)+NO2limit(np))/Nlimit(np)
                else
                  ngrow(np)=1. _d 0
                endif
                ngrow(np)=min(ngrow(np),1. _d 0)
               endif
#else
c disadvantage of oxidized inorganic N
c for now, ignore - a first attempt is included below
              ngrow(np) = 1.0 _d 0

cc lower growth for higher NO3 consumption at higher light
c one possible way of counting cost of reducing NOX
               if (NOreducost .eq. 1)then 
                if (Nlimit(np).le.0. _d 0) then
                  ngrow(np)=1. _d 0
                else
                 ngrow(np)= (10. _d 0*4. _d 0 +2. _d 0)   /
     &              (10. _d 0*4. _d 0 +2. _d 0*NH4limit(np)/Nlimit(np)
     &                           +8. _d 0*NO2limit(np)/Nlimit(np)
     &                           +10. _d 0*NO3limit(np)/Nlimit(np))
                 ngrow(np)=min(ngrow(np),1. _d 0)
                endif
               endif
c
c might consider other costs, too
c             if (NOironcost .eq. 1)then 
c
c             endif
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
#endif

c Now Check Against General Nutrient Limiting Tendency
               if (ksatNH4(np).gt.0. _d 0.or.ksatNO2(np).gt.0. _d 0
     &              .or.ksatNO3(np).gt.0. _d 0) then
                 if(Nlimit(np) .lt. limit(np)) limit(np) = Nlimit(np)
               endif
             else
                ngrow(np)=1. _d 0
                Nlimit(np)=1. _d 0
                NO3limit(np)=0. _d 0
                NO2limit(np)=0. _d 0
                NH4limit(np)=0. _d 0
             endif   ! diaz
             limit(np)=min(limit(np),1. _d 0)
           enddo    !np
          if (debug.eq.1) print*,'nut limit',
     &                          limit, PO4local, FeTlocal, Silocal
          if (debug.eq.1) print*,'Nlimit',
     &                 Nlimit
          if (debug.eq.1) print*,'NH4limit',
     &                  NH4limit, NH4local
          if (debug.eq.1) print*,'NO2limit',
     &                   NO2limit, NO2local
          if (debug.eq.1) print*,'NO3limit',
     &                  NO3limit, NO3local
          if (debug.eq.1) print*,'ngrow',
     &                  ngrow


#ifdef GEIDER

#ifdef WAVEBANDS
c ANNA if wavebands then uses spectral alphachl derived from spectral alpha * I
c so first get value for alphachl_nl * PARwlocal
c value will depend on matchup between spectra of alphachl_nl (ie. aphy_chl) and PARwlocal
          do np = 1,npmax
           do nl = 1,tlam
            alpha_I_local_nl(nl) = alphachl_nl(np,nl) * PARwlocal(nl)
           end do

c interpolate for sum of alphachl_nl * PARwlocal
           cu_area = 0.d0
           do nl = 1,(tlam-1)
            waves_diff = pwaves(nl+1)-pwaves(nl)
            alphaI_diff = alpha_I_local_nl(nl+1)-alpha_I_local_nl(nl)
            squ_part = waves_diff * alpha_I_local_nl(nl+1)
            tri_part = waves_diff * alphaI_diff * 5.D-1
            seg_area = squ_part - tri_part
            cu_area = cu_area + seg_area
           end do

c           alpha_I_local(np) = cu_area / (pwaves(tlam) - pwaves(1))
           alpha_I_local(np) = cu_area
           alpha_I_tmp(np) = alpha_I_local(np)
          end do
c Geider growth (and chl2c) now depends on this (sinlge) value of alpha_chl * I

c ANNA_INHIB INHIB_FINAL photoinhibition for wavebands requires mean alphachl_nl and PARwlocal
#ifdef INHIB_WAVES
          do np = 1,npmax
           cu_area = 0.d0
           do nl = 1,(tlam-1)
            waves_diff = pwaves(nl+1)-pwaves(nl)
            alpha_diff = alphachl_nl(np,nl+1)-alphachl_nl(np,nl)
            squ_part = waves_diff * alphachl_nl(np,nl+1)
            tri_part = waves_diff * alpha_diff * 5.D-1
            seg_area = squ_part - tri_part
            cu_area = cu_area + seg_area
           end do
           alpha_mean(np) = cu_area / (pwaves(tlam) - pwaves(1))
          end do
#endif
c end this bit of ANNA_INHIB
#else
c ANNA if not wavebands uses alphachl derived from mQyield * aphy_chl_ave
c for use with generic geider equation need to use alpha_I_tmp (ie. alphachl*PARlocal)
          do np = 1, npmax
            alpha_I_tmp(np)=alphachl(np)*PARlocal
          enddo
c ANNA endif
#endif

          do np = 1, npmax
           pcm(np)=pcmax(np)*limit(np)*phytoTempFunction(np)
           if (pcm(np).gt.0.d0) then
             chl2c(np)=chl2cmax(np)/
     &            (1+(chl2cmax(np)*alpha_I_tmp(np))/
     &               (2*pcm(np)))
             chl2c(np)=min(chl2c(np),chl2cmax(np))
             chl2c(np)=max(chl2c(np),chl2cmin(np))
             if (PARlocal.gt.1. _d -1) then
               pcarbon(np)=pcm(np)*( 1 -
     &          exp((-alpha_I_tmp(np)*chl2c(np))/(pcm(np))) )
c ANNA_INHIB INHIB_FINAL
#ifdef INHIB_GEID
            Ek = pcm(np)/(chl2c(np)*(alpha_I_tmp(np)*PARlocal))
            EkoverE = Ek / PARlocal
            if (PARlocal .ge. Ek) then !photoinhibition begins
               pcarbon(np) = pcarbon(np)*(EkoverE*inhibcoef_geid)
            endif
#endif
#ifdef INHIB_WAVES
c NB there is a spectral consideration here!
c but it is ignored through use of mean alphachl_nl and PARwlocal
            Ek = pcm(np)/(chl2c(np)*alpha_mean(np))
            EkoverE = Ek / PARlocal
            if (PARlocal .ge. Ek) then !photoinhibition begins
              if (ap_type(np) .eq. 4) then
               pcarbon(np) = pcarbon(np)*(EkoverE*inhibcoef_ap4)
c              elseif (ap_type(np) .eq. 2) then
c               pcarbon(np) = pcarbon(np)*(EkoverE*inhibcoef_ap2)
c              elseif (ap_type(np) .eq. 3) then
c               pcarbon(np) = pcarbon(np)*(EkoverE*inhibcoef_ap3)
c              elseif (ap_type(np) .eq. 4) then
c               pcarbon(np) = pcarbon(np)*(EkoverE*inhibcoef_ap1)
              endif
            endif
#endif
c end ANNA_INHIB 
                if (pcarbon(np).lt. 0. _d 0) 
     &                 print*,'QQ ERROR pc=',np,pcarbon(np)
               if (pcm(np).gt.0. _d 0) then
                 ilimit(np)=pcarbon(np)/pcm(np)
               else
                 ilimit(np)= 0. _d 0
               endif
             else
               ilimit(np)=0. _d 0
               pcarbon(np)=0. _d 0
             endif
           else ! if pcm 0
             pcm(np)=0.d0
             chl2c(np)=chl2cmin(np)
             pcarbon(np)=0.d0
             ilimit(np)=0.d0
           endif
           phychl(np)=phyto(np)*R_PC(np)*chl2c(np)
          enddo
          if (debug.eq.14) print*,'ilimit',ilimit, PARlocal
          if (debug.eq.14) print*,'chl:c',chl2c
          if (debug.eq.14) print*,'chl',phychl
#endif /* GEIDER */

#ifdef DAR_DIAG_CHL
c diagnostic version of the above that does not feed back to growth
          ChlGeiderlocal = 0. _d 0
          do np = 1, npmax
           tmppcm = mu(np)*limit(np)*phytoTempFunction(np)
           if (tmppcm.gt.0.d0) then
             tmpchl2c = Geider_chl2cmax(np)/
     &         (1+(Geider_chl2cmax(np)*Geider_alphachl(np)*PARdaylocal)/
     &            (2*tmppcm))
             tmpchl2c = min(tmpchl2c, Geider_chl2cmax(np))
             tmpchl2c = max(tmpchl2c, Geider_chl2cmin(np))
           else
             tmpchl2c = Geider_chl2cmin(np)
           endif
           ChlGeiderlocal = ChlGeiderlocal + phyto(np)*R_PC(np)*tmpchl2c
          enddo
C Chl a la Doney
          ChlDoneylocal = 0. _d 0
          do np = 1, npmax
            tmpchl2c = (Doney_Bmax - (Doney_Bmax-Doney_Bmin)*
     &                          MIN(1. _d 0,PARdaylocal/Doney_PARstar))
     &                    *limit(np)
            ChlDoneylocal = ChlDoneylocal +
     &                      tmpchl2c*R_PC(np)*phyto(np)
          enddo
C Chl a la Cloern
          ChlCloernlocal = 0. _d 0
          do np = 1, npmax
            tmpchl2c = Cloern_chl2cmin +
     &                     Cloern_A*exp(Cloern_B*Tlocal)
     &                             *exp(-Cloern_C*PARdaylocal)
     &                    *limit(np)
            ChlCloernlocal = ChlCloernlocal +
     &                       tmpchl2c*R_PC(np)*phyto(np)
          enddo
#endif /* DAR_DIAG_CHL */


cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c ******************* END GROWTH PHYTO ******************************* 


#ifdef OLD_GRAZE
c------------------------------------------------------------------------
c GRAZING sum contributions of all zooplankton
           do np=1,npmax
              grazing_phyto(np) = 0.0 _d 0
              do nz = 1, nzmax
                   grazing_phyto(np) = grazing_phyto(np)
     &               + graze(np,nz)*zooP(nz)*zooTempFunction(nz)
              enddo
           enddo
           if (debug.eq.2) print*,'grazing_phyto',grazing_phyto
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
#else
c------------------------------------------------------------------------
c sum all palatability*phyto and find phyto specific grazing rate
          do nz=1,nzmax
           allphyto(nz)=0. _d 0
           do np=1,npmax
            allphyto(nz)=allphyto(nz)+palat(np,nz)*phyto(np)
           enddo
           if (allphyto(nz).le.0. _d 0) allphyto(nz)=phygrazmin
           do np=1,npmax
            tmpz=max(0. _d 0,(allphyto(nz)-phygrazmin) )
            grazphy(np,nz)=grazemax(nz)*
     &           (palat(np,nz)*phyto(np)/allphyto(nz))*
     &           ( tmpz/
     &             (tmpz+kgrazesat) )
           enddo
          enddo
          if (debug.eq.2) print*,'allphyto',allphyto
c         if (debug.eq.2) print*,'grazephy',grazphy
c sum over zoo for impact on phyto
          do np=1,npmax
           sumgrazphy(np)=0. _d 0
           do nz=1,nzmax
             sumgrazphy(np)=sumgrazphy(np)+
     &           grazphy(np,nz)*zooP(nz)
           enddo
          enddo
          if (debug.eq.2) print*,'sumgrazephy',sumgrazphy
c sum over phy for impact on zoo, and all remainder to go to POM
          do nz=1,nzmax
           sumgrazzoo(nz)=0. _d 0
           sumgrazzooN(nz)=0. _d 0
           sumgrazzooFe(nz)=0. _d 0
           sumgrazzooSi(nz)=0. _d 0
           sumgrazloss(nz)=0. _d 0
           sumgrazlossN(nz)=0. _d 0
           sumgrazlossFe(nz)=0. _d 0
           sumgrazlossSi(nz)=0. _d 0
#ifdef ALLOW_CARBON
           sumgrazzooC(nz)=0. _d 0
           sumgrazlossC(nz)=0. _d 0
#endif
           do np=1,npmax
              sumgrazzoo(nz)=sumgrazzoo(nz)+
     &             asseff(np,nz)*grazphy(np,nz)*zooP(nz)
              sumgrazloss(nz)=sumgrazloss(nz)+
     &             (1. _d 0-asseff(np,nz))*grazphy(np,nz)*zooP(nz)
              sumgrazzooN(nz)=sumgrazzooN(nz)+
     &             asseff(np,nz)*grazphy(np,nz)*zooP(nz)*R_NP(np)
              sumgrazlossN(nz)=sumgrazlossN(nz)+
     &             (1. _d 0-asseff(np,nz))*grazphy(np,nz)*
     &                                      zooP(nz)*R_NP(np)
              sumgrazzooFe(nz)=sumgrazzooFe(nz)+
     &             asseff(np,nz)*grazphy(np,nz)*
     &                                      zooP(nz)*R_FeP(np)
              sumgrazlossFe(nz)=sumgrazlossFe(nz)+
     &             (1. _d 0-asseff(np,nz))*grazphy(np,nz)*
     &                                      zooP(nz)*R_FeP(np)
              sumgrazzooSi(nz)=sumgrazzooSi(nz)+
     &             asseff(np,nz)*grazphy(np,nz)*
     &                                     zooP(nz)*R_SiP(np)
              sumgrazlossSi(nz)=sumgrazlossSi(nz)+
     &             (1. _d 0-asseff(np,nz))*grazphy(np,nz)*
     &                                     zooP(nz)*R_SiP(np)
#ifdef ALLOW_CARBON
              sumgrazzooC(nz)=sumgrazzooC(nz)+
     &             asseff(np,nz)*grazphy(np,nz)*zooP(nz)*R_PC(np)
              sumgrazlossC(nz)=sumgrazlossC(nz)+
     &             (1. _d 0-asseff(np,nz))*grazphy(np,nz)*
     &                                      zooClocal(nz)*R_PC(np)
#endif
           enddo
          enddo
          if (debug.eq.2) print*,'sumgrazzoo',sumgrazzoo
          if (debug.eq.2) print*,'sumgrazloss',sumgrazloss
          if (debug.eq.2) print*,'sumgrazzooN',sumgrazzooN
          if (debug.eq.2) print*,'sumgrazlossN',sumgrazlossN
          if (debug.eq.2) print*,'sumgrazzooFe',sumgrazzooFe
          if (debug.eq.2) print*,'sumgrazlossFe',sumgrazlossFe
          if (debug.eq.2) print*,'sumgrazzooSi',sumgrazzooSi
          if (debug.eq.2) print*,'sumgrazlossSi',sumgrazlossSi
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
#endif

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c accumulate particulate and dissolved detritus
           do np=1, npmax
               totphy_pop=totphy_pop+
     &                ExportFracP(np)*mortphy(np)*phytomin(np)
               totphy_dop=totphy_dop+
     &                (1. _d 0-ExportFracP(np))*mortphy(np)*phytomin(np)
               totphy_pon=totphy_pon+ R_NP(np)*
     &                ExportFracP(np)*mortphy(np)*phytomin(np)
               totphy_don=totphy_don+ R_NP(np)*
     &               (1. _d 0-ExportFracP(np))*mortphy(np)*phytomin(np)
               totphy_pofe=totphy_pofe+ R_FeP(np)*
     &                ExportFracP(np)*mortphy(np)*phytomin(np)
               totphy_dofe=totphy_dofe+ R_FeP(np)*
     &               (1. _d 0-ExportFracP(np))*mortphy(np)*phytomin(np)
               totphy_posi=totphy_posi+ R_SiP(np)*
     &                mortphy(np)*phytomin(np)
#ifdef ALLOW_CARBON
               totphy_poc=totphy_poc+ R_PC(np)*
     &                ExportFracP(np)*mortphy(np)*phytomin(np)
               totphy_doc=totphy_doc+ R_PC(np)*
     &               (1. _d 0-ExportFracP(np))*mortphy(np)*phytomin(np)
               totphy_pic=totphy_pic+ R_PC(np)*R_PICPOC(np)*
     &                mortphy(np)*phytomin(np)
#endif
            enddo 
            if (debug.eq.3) print*,'tot_phy_pop',totphy_pop
            if (debug.eq.3) print*,'tot_phy_dop',totphy_dop
            if (debug.eq.3) print*,'tot_phy_pon',totphy_pon
            if (debug.eq.3) print*,'tot_phy_don',totphy_don
            if (debug.eq.3) print*,'tot_phy_pofe',totphy_pofe
            if (debug.eq.3) print*,'tot_phy_dofe',totphy_dofe
            if (debug.eq.3) print*,'tot_phy_posi',totphy_posi


c cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


#ifdef OLD_GRAZE
c ****************** ZOO GRAZING RATE ****************************
c determine zooplankton grazing rates 
            do nz = 1, nzmax
c grazing: sum contribution from all phytoplankton
              grazingP(nz) = 0.0 _d 0
              grazingN(nz) = 0.0 _d 0
              grazingFe(nz) = 0.0 _d 0
              grazingSi(nz) = 0.0 _d 0
#ifdef ALLOW_CARBON
              grazingC(nz) = 0.0 _d 0
#endif
              do np = 1, npmax
               facpz = (phytomin(np)/(phytomin(np) + kgrazesat))
     &                  *zooTempFunction(nz)
               grazingP(nz) = grazingP(nz) + 
     &                         graze(np,nz)*facpz
               grazingN(nz) = grazingN(nz) + 
     &                         graze(np,nz)*R_NP(np)*facpz
               grazingFe(nz) = grazingFe(nz) + 
     &                          graze(np,nz)*R_FeP(np)*facpz
               grazingSi(nz) = grazingSi(nz) + 
     &                          graze(np,nz)*R_SiP(np)*facpz
#ifdef ALLOW_CARBON
               grazingC(nz) = grazingC(nz) +
     &                         graze(np,nz)*R_PC(np)*facpz
#endif
              enddo
            enddo
            if (debug.eq.4) print*,'grazingP', grazingP
            if (debug.eq.4) print*,'grazingN', grazingN
            if (debug.eq.4) print*,'grazingFe', grazingFe
            if (debug.eq.4) print*,'grazingSi', grazingSi
c *************  END ZOO GRAZING *********************************
#endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c accumulate particulate and dissolved detritus
            do nz=1, nzmax
               totzoo_pop=totzoo_pop+
     &                     ExportFracZ(nz)*mortzoo(nz)*zooP(nz)
               totzoo_dop=totzoo_dop+
     &                    (1. _d 0-ExportFracZ(nz))*mortzoo(nz)*zooP(nz)
               totzoo_pon=totzoo_pon+ 
     &                     ExportFracZ(nz)*mortzoo(nz)*zooN(nz)
               totzoo_don=totzoo_don+
     &                    (1. _d 0-ExportFracZ(nz))*mortzoo(nz)*zooN(nz)
               totzoo_pofe=totzoo_pofe+
     &                     ExportFracZ(nz)*mortzoo(nz)*zooFe(nz)
               totzoo_dofe=totzoo_dofe+
     &                   (1. _d 0-ExportFracZ(nz))*mortzoo(nz)*zooFe(nz)
               totzoo_posi=totzoo_posi+ 
     &                     mortzoo(nz)*zooSi(nz)
#ifdef ALLOW_CARBON
               totzoo_poc=totzoo_poc+
     &                    ExportFracZ(nz)*mortzoo(nz)*zooClocal(nz)
               totzoo_doc=totzoo_doc+
     &           (1. _d 0-ExportFracZ(nz))*mortzoo(nz)*zooClocal(nz)
#endif
            enddo

#ifndef OLD_GRAZE
            do nz=1, nzmax
               totzoo_pop=totzoo_pop+
     &                    +ExportFracGraz(nz)*sumgrazloss(nz)
               totzoo_dop=totzoo_dop+
     &                 +(1. _d 0-ExportFracGraz(nz))*sumgrazloss(nz)
               totzoo_pon=totzoo_pon+
     &                    +ExportFracGraz(nz)*sumgrazlossN(nz)
               totzoo_don=totzoo_don+
     &                 +(1. _d 0-ExportFracGraz(nz))*sumgrazlossN(nz)
               totzoo_pofe=totzoo_pofe+
     &                    +ExportFracGraz(nz)*sumgrazlossFe(nz)
               totzoo_dofe=totzoo_dofe+
     &                 +(1. _d 0-ExportFracGraz(nz))*sumgrazlossFe(nz)
               totzoo_posi=totzoo_posi+
     &                     +sumgrazlossSi(nz)
#ifdef ALLOW_CARBON
               totzoo_poc=totzoo_poc+
     &                    +ExportFracGraz(nz)*sumgrazlossC(nz)
               totzoo_doc=totzoo_doc+
     &                 +(1. _d 0-ExportFracGraz(nz))*sumgrazlossC(nz)
#endif
            enddo
#endif
            if (debug.eq.5) print*,'totzoo_pop',totzoo_pop
            if (debug.eq.5) print*,'totzoo_dop',totzoo_dop
            if (debug.eq.5) print*,'totzoo_pon',totzoo_pon
            if (debug.eq.5) print*,'totzoo_don',totzoo_don
            if (debug.eq.5) print*,'totzoo_pofe',totzoo_pofe
            if (debug.eq.5) print*,'totzoo_dofe',totzoo_dofe
            if (debug.eq.5) print*,'totzoo_posi',totzoo_posi
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

c ********************* NUTRIENT UPTAKE *******************************
c determine nutrient uptake
c consumption - sum of phytoplankton contributions
            do np = 1, npmax
c phospate uptake by each phytoplankton
#ifndef GEIDER
               grow(np)=ngrow(np)*mu(np)*limit(np)*ilimit(np)*
     &                            phytoTempFunction(np)
#endif
#ifdef GEIDER
               grow(np)=ngrow(np)*pcarbon(np)
               if (debug.eq.1) print*,'grow', grow(np)
#endif
               PspecificPO4(np) = grow(np)*phyto(np)
c        write(6,*)'np =',np, ' PspecificPO4 ='
c     &              ,PspecificPO4(np)
               consumpPO4 = consumpPO4 + PspecificPO4(np)
               consumpFeT = consumpFeT + PspecificPO4(np)*R_FeP(np)
               consumpSi  = consumpSi  + PspecificPO4(np)*R_SiP(np)
cswd should have O2prod as function of np?
c New Way of doing Nitrogen Consumption .......................
               if(diazotroph(np) .ne. 1.0 _d 0)then
                if (Nlimit(np).le.0. _d 0) then
                 consumpNO3 = consumpNO3
                 consumpNO2 = consumpNO2
                 consumpNH4 = consumpNH4
                else 
                 consumpNO3 = consumpNO3 + 
     &              NO3limit(np)/Nlimit(np)*PspecificPO4(np)*R_NP(np)
                 consumpNO2 = consumpNO2 +
     &              NO2limit(np)/Nlimit(np)* PspecificPO4(np)*R_NP(np)
                 consumpNH4 = consumpNH4 + 
     &              NH4limit(np)/Nlimit(np)*PspecificPO4(np)*R_NP(np)
                endif
               else
                 consumpNO3 = consumpNO3
                 consumpNO2 = consumpNO2
                 consumpNH4 = consumpNH4
                 Nfix=Nfix+PspecificPO4(np)*R_NP(np)
               endif
#ifdef ALLOW_CARBON
               consumpDIC  = consumpDIC  + PspecificPO4(np)*R_PC(np)
               consumpDIC_PIC = consumpDIC_PIC + 
     &                           PspecificPO4(np)*R_PC(np)*R_PICPOC(np)
#endif
            enddo
           if (debug.eq.7) print*,'local', parlocal,tlocal,po4local,
     &                  no3local, no2local,nh4local,fetlocal,silocal
           if (debug.eq.7) print*,'grow',grow
           if (debug.eq.6) print*,'pspecificpo4', PspecificPO4
           if (debug.eq.6) print*,'consumpPO4', consumpPO4
           if (debug.eq.6) print*,'consumpFeT', consumpFeT
           if (debug.eq.6) print*,'consumpSi ', consumpsi 
           if (debug.eq.6) print*,'consumpNO3', consumpNO3
           if (debug.eq.6) print*,'consumpNO2', consumpNO2
           if (debug.eq.6) print*,'consumpNH4', consumpNH4
c ****************** END NUTRIENT UPTAKE ****************************

c sinking phytoplankton and POM
             if(bottom .eq. 1.0 _d 0)then
              psinkP  = (wp_sink*POPuplocal)/(dzlocal)
              psinkN  = (wn_sink*PONuplocal)/(dzlocal)
              psinkFe = (wfe_sink*POFeuplocal)/(dzlocal)
              psinkSi = (wsi_sink*PSiuplocal)/(dzlocal)
              do np=1,npmax
               psinkPhy(np) =
     &                     (wsink(np)*Phytoup(np))/(dzlocal)
              enddo
#ifdef ALLOW_CARBON
              psinkC  = (wc_sink*POCuplocal)/(dzlocal)
              psinkPIC = (wpic_sink*PICuplocal)/(dzlocal)
#endif
            else
              psinkP  = (wp_sink*(POPuplocal-POPlocal))/(dzlocal)
              psinkN  = (wn_sink*(PONuplocal-PONlocal))/(dzlocal)
              psinkFe = (wfe_sink*(POFeuplocal-POFelocal))/(dzlocal)
              psinkSi = (wsi_sink*(PSiuplocal-PSilocal))/(dzlocal)
              do np=1,npmax
               psinkPhy(np) =
     &                  (wsink(np))*(Phytoup(np)-Phyto(np))/(dzlocal)
              enddo
#ifdef ALLOW_CARBON
              psinkC  = (wc_sink*(POCuplocal-POClocal))/(dzlocal)
              psinkPIC  = (wpic_sink*(PICuplocal-PIClocal))/(dzlocal)
#endif
            endif

c DOM remineralization rates
            DOPremin =  Kdop * DOPlocal
            DONremin =  Kdon * DONlocal
            DOFeremin =  KdoFe * DOFelocal

c remineralization of sinking particulate
            preminP  = Kpremin_P*POPlocal
            preminN  = Kpremin_N*PONlocal
            preminFe = Kpremin_Fe*POFelocal
            preminSi = Kpremin_Si*PSilocal

#ifdef ALLOW_CARBON
           DOCremin =  Kdoc * DOClocal
           preminC  = Kpremin_C*POClocal
c dissolution
           disscPIC = Kdissc*PIClocal
#endif

c chemistry
c NH4 -> NO2 -> NO3 by bacterial action
            NO2prod = knita*( 1. _d 0-min(PARlocal/PAR0,1. _d 0) )
     &                *NH4local
            NO3prod = knitb*( 1. _d 0-min(PARlocal/PAR0,1. _d 0) )
     &                *NO2local 
c           NO2prod = knita*NH4local
c           NO3prod = knitb*NO2local

c -------------------------------------------------------------------
c calculate tendency terms (and some diagnostics)
c ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c phytoplankton
            do np=1,npmax
              dphytodt(np) =   PspecificPO4(np)
#ifdef OLD_GRAZE
     &                        - grazing_phyto(np)*
     &              (phytomin(np)/(phytomin(np) + kgrazesat))
#else
     &                        - sumgrazphy(np)
#endif
     &                        - mortphy(np)*phytomin(np)
     &                        + psinkphy(np)
              PP = PP + PspecificPO4(np)
#ifdef GEIDER
              Chl=Chl + phychl(np)
#endif
#ifdef OLD_GRAZE
              tmpr=grazing_phyto(np)*
     &              (phytomin(np)/(phytomin(np) + kgrazesat)) 
     &                        + mortphy(np)*phytomin(np)
     &                        - psinkphy(np)
#else
              tmpr=sumgrazphy(np)
     &                        + mortphy(np)*phytomin(np)
     &                        - psinkphy(np)
#endif
#ifdef DAR_DIAG_RSTAR
#ifndef GEIDER
              tmpgrow=ngrow(np)*mu(np)*ilimit(np)*
     &              phytoTempFunction(np)
#endif
#ifdef GEIDER
              tmpgrow=grow(np)/limit(np)
#endif
              tmp1=tmpgrow*phyto(np)-tmpr
              tmp2=tmpgrow*phyto(np)*(exp(-sig1*nh4local)+NH4limit(np))
     &                 -tmpr 
              if (tmp1.ne.0. _d 0) then 
                Rstarlocal(np)=ksatPO4(np)*tmpr/tmp1
              else
                Rstarlocal(np)=-9999. _d 0
              endif
              if (tmp2.ne.0. _d 0) then 
                RNstarlocal(np)=ksatNO3(np)*
     &                 (tmpr-tmpgrow*NH4limit(np)*phyto(np))/tmp2
              else
                RNstarlocal(np)=-9999. _d 0
              endif
#endif
            enddo
            if (debug.eq.10) print*,'dphytodt',dphytodt
#ifdef OLD_GRAZE
c zooplankton growth by grazing
            do nz=1,nzmax
c zoo in P currency
              dzooPdt(nz)  = grazingP(nz)*zooP(nz) 
C zooplankton stoichiometry varies according to food source
              dzooNdt(nz)  = grazingN(nz)*zooP(nz) 
              dzooFedt(nz) = grazingFe(nz)*zooP(nz) 
              dzooSidt(nz) = grazingSi(nz)*zooP(nz) 
            enddo
#else
            do nz=1,nzmax
c zoo in P currency
              dzooPdt(nz)  = sumgrazzoo(nz)
C zooplankton stoichiometry varies according to food source
              dzooNdt(nz)  = sumgrazzooN(nz)
              dzooFedt(nz) = sumgrazzooFe(nz)
              dzooSidt(nz) = sumgrazzooSi(nz)
            enddo
#endif
            if (debug.eq.10) print*,'dZooPdt',dZooPdt

c zooplankton mortality
            do nz=1,nzmax
c zoo in P currency
              dzooPdt(nz)  = dzooPdt(nz)
     &                           - mortzoo(nz)*zooP(nz)
c zooplankton in other currencies
C zooplankton stoichiometry varies according to food source
              dzooNdt(nz)  = dzooNdt(nz)
     &                           - mortzoo(nz)*zooN(nz)
              dzooFedt(nz) = dzooFedt(nz)
     &                           - mortzoo(nz)*zooFe(nz)
              dzooSidt(nz) = dzooSidt(nz)
     &                           - mortzoo(nz)*zooSi(nz)
            enddo


c sum contributions to inorganic nutrient tendencies
            dPO4dt =  - consumpPO4 +  preminP  + DOPremin
            dNH4dt =  - consumpNH4 +  preminN  + DONremin 
     &                                   - NO2prod
            dNO2dt =  - consumpNO2                        
     &                                   + NO2prod - NO3prod
            dNO3dt =  - consumpNO3             
     &                                   + NO3prod
c-ONLYNO3   dNO3dt =  - consumpNO3 +  preminN  + DONremin
            dFeTdt =  - consumpFeT +  preminFe + DOFeremin
     &                 - scav*freefelocal + alpfe*inputFelocal/dzlocal
            dSidt  =  - consumpSi  +  preminSi

c tendency of dissolved organic pool
            dDOPdt  = totphy_dop  + totzoo_dop  - DOPremin 
            dDONdt  = totphy_don  + totzoo_don  - DONremin 
            dDOFedt = totphy_dofe + totzoo_dofe - DOFeremin 
c tendency of particulate detritus pools
            dpopdt  = totphy_pop  + totzoo_pop   - preminP + psinkP
            dpondt  = totphy_pon  + totzoo_pon   - preminN + psinkN
            dpofedt = totphy_pofe + totzoo_pofe  - preminFe + psinkFe
            dpSidt  = totphy_posi + totzoo_posi  - preminSi + psinkSi
#ifdef ALLOW_CARBON
            dDICdt =  - consumpDIC - consumpDIC_PIC 
     &                                         +  preminC  + DOCremin
     &                                         + disscPIC
            dDOCdt  = totphy_doc  + totzoo_doc  - DOCremin
            dPOCdt  = totphy_poc  + totzoo_poc  - preminC + psinkC
            dPICdt  = totphy_pic                - disscPIC + psinkPIC
            dALKdt  = - dNO3dt    - 2.d0 * dPICdt
c should be = O2prod - preminP - DOPremin?
            dO2dt   = - R_OP*dPO4dt
#ifdef OLD_GRAZE
            do nz=1,nzmax
              dzooCdt(nz)  = grazingC(nz)*zooClocal(nz)
     &                           - mortzoo(nz)*zooClocal(nz)
            enddo
#else
            do nz=1,nzmax
              dzooCdt(nz)  = sumgrazzooc(nz)
     &                           - mortzoo(nz)*zooClocal(nz)
            enddo
#endif

#endif

            if (debug.eq.10) print*,'dDOPdt', dDOPdt
            if (debug.eq.10) print*,'dpopdt',dpopdt
            if (debug.eq.10) print*,'dDONdt',dDONdt
            if (debug.eq.10) print*,'dpondt',dpondt
c
c -------------------------------------------------------------------
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c --------------------------------------------------------------------------

c -m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-
c  Mutation - apply mutation to tendencies [jbmodif]

#ifdef ALLOW_MUTANTS
c apply to all sisters when first sister is encountered
       if(runtim .gt. threeyr) then
       mutfor=1 _d -8
       mutback=1 _d -12
       if(numtax .gt. 1)then
        do np=1,npro
          if(mod(np,numtax).eq. 1. _d 0)then
             nsisone   = np
             nsistwo   = np+1 
             nsisthree = np+2             
             nsisfour  = np+3 
              
             grow1 = PspecificPO4(nsisone)
             grow2 = PspecificPO4(nsistwo)

             if(numtax.eq.2)grow3 = 0.0 _d 0
             if(numtax.eq.2)grow4 = 0.0 _d 0

             if(numtax.eq.3)grow4 = 0.0 _d 0
             if(numtax.ge.3)grow3 = PspecificPO4(nsisthree)
             
             if(numtax.eq.4)grow4 = PspecificPO4(nsisfour)
                        


                dphytodt(nsisone)  = dphytodt(nsisone)
     &                - grow1 *1.4427 _d 0*mutfor
     &                - grow1 *1.4427 _d 0*mutfor
     &                - grow1 *1.4427 _d 0*mutfor
     &                + grow2 *1.4427 _d 0*mutback
     &                + grow3 *1.4427 _d 0*mutback
     &                + grow4 *1.4427 _d 0*mutback

                dphytodt(nsistwo)  = dphytodt(nsistwo)
     &                - grow2 *1.4427 _d 0*mutback
     &                + grow1 *1.4427 _d 0*mutfor

                if(numtax .ge. 3)then
                  dphytodt(nsisthree)  = dphytodt(nsisthree)
     &                - grow3 *1.4427 _d 0*mutback
     &                + grow1 *1.4427 _d 0*mutfor
                endif
        
                if(numtax .eq. 4)then
                  dphytodt(nsisfour)  = dphytodt(nsisfour)
     &                - grow4 *1.4427 _d 0*mutback
     &                + grow1 *1.4427 _d 0*mutfor
c QQQQQQQQQQ FIX FOR NIT RUNS ONLY!!!
                  if (phyto(nsisfour).eq.0. _d 0) then
                    if (phyto(nsistwo).eq.0. _d 0) then
                     if (dphytodt(nsistwo).gt.dphytodt(nsisfour)) then
                         dphytodt(nsisfour)=dphytodt(nsistwo)
                     endif
                    endif
                    if (phyto(nsisthree).eq.0. _d 0) then
                     if (dphytodt(nsisthree).gt.dphytodt(nsisfour)) then
                         dphytodt(nsisfour)=dphytodt(nsisthree)
                     endif
                    endif
                  endif
c QQQQQQQQQQQQQ
                endif

c QQQQQQQQQQQQTEST
         if (debug.eq.11) then
         if (PARlocal.gt.1. _d 0) then
          if (dphytodt(nsistwo).gt.dphytodt(nsisfour).and.
     &                             dphytodt(nsisfour).gt.0. _d 0) then
                print*,'QQQQ nsistwo>nsisfour',nsistwo,nsisfour, 
     &               dphytodt(nsistwo),  dphytodt(nsisfour),
     &               phyto(nsistwo), phyto(nsisfour),  
     &               phyto(nsisone)
          endif
          if (dphytodt(nsisthree).gt.dphytodt(nsisfour).and.
     &                             dphytodt(nsisfour).gt.0. _d 0) then
                 print*,'QQQQ nsisthree>nsisfour',nsisthree,nsisfour,
     &                dphytodt(nsisthree), dphytodt(nsisfour),
     &               phyto(nsisthree), phyto(nsisfour),  
     &               phyto(nsisone)
          endif
          if (dphytodt(nsisfour).gt.dphytodt(nsisone).and.
     &                            dphytodt(nsisone).gt.0. _d 0) then
                 print*,' BIG QQQQ nsisfour>nsisone',nsisone,nsisfour,
     &                dphytodt(nsisfour), dphytodt(nsisone),
     &               phyto(nsisfour), phyto(nsisone)
          endif
         endif
         endif
c QQQQQQQQQTEST
             endif
          enddo
        endif
        endif 

c mutation is finished
c -m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-m-
#endif



         RETURN
         END
#endif  /*DARWIN*/
#endif  /*ALLOW_PTRACERS*/
c ==================================================================
