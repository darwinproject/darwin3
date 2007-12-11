C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/DARWIN.h,v 1.2 2007/12/11 21:32:46 jahn Exp $
C $Name:  $

c DARWIN.h 
c description: Key parameter arrays for generalized ecosystem model
c      Mick Follows, Scott Grant Fall/Winter 2005
c      Stephanie Dutkiewicz Spring/Summer 2006
c
c
c npmax = no of "functional groups" of phytoplankton
c nzmax = no of "functional groups" of zooplankton
c
c
c NOTE: list not complete!!
c mu = max growth rate (s-1)
c ksat = half sat coeff, phyto specific for each nutrient
c ksatlight = half sat coeff wrt light, phyto specific 
c graze = grazing rate, phyto specific for each zooplankton
c mortzoo = mortality rate for each zooplankton
c wsink = sinking speed, phyto specific
c R_XY = stoichiometric ratios of nutrients in phytoplankton
c        specific to each functional group, relative to Phos
c physize = size class of phytoplankton; 0.0="small", 1.0="big"
c diatom: 1.0 uses silica, 0.0 does not use silica
c diazotrph: 1.0 fixes nitrogen, 0.0 does not fix nitrogen
c zoosize = size class of zooplankton; 0.0="small", 1.0="big"
c ExportFracZ(nzmax) = fraction of Z mortality sinking out:
c                      rest remineralizes locally 
c Kpremin_xx = remin rate constant for particulate detritus
c ngroups = tracks how many different "functional groups" of phyto
c           have been tried


         COMMON/darwin_ecoparam/mu,ksatPO4,ksatNO3,ksatNO2,ksatNH4,
     &          ksatSi,ksatFeT,ksatPAR,
     &          mortzoo,wsink,R_NP,R_FeP,R_SiP,physize,
     &          diatom,diazotroph,zoosize,ExportFracZ,
     &          Kpremin_P, Kpremin_N, Kpremin_Fe, Kpremin_Si,
     &          sig1,sig2,sig3,
     &          phytoTempCoeff, phytoTempExp1, 
     &          phytoTempExp2, phytoTempOptimum, phytoDecayPower,
     &          zooTempCoeff, zooTempExp, zooTempOptimum, kinhib,
     &          diatomgraz, olargegraz,
     &          mortphy, ExportFracP,
     &          Smallgrow, Biggrow, Smallmort, Bigmort,
     &          Smallgrowrange, Biggrowrange, Smallmortrange, 
     &          Bigmortrange,
     &          Smallexport, Bigexport,
     &          smallksatpar, smallksatparstd,
     &          smallkinhib, smallkinhibstd,
     &          Bigksatpar, Bigksatparstd,
     &          Bigkinhib, Bigkinhibstd,
     &          tempcoeff1, tempcoeff2_small, 
     &          tempcoeff2_big, tempcoeff3,
     &          tempmax, temprange, tempnorm, tempdecay,
     &          SmallPsat, BigPsat, ProcPsat,
     &          SmallPsatrange, BigPsatrange, ProcPsatrange,
     &          prochlPsat,
#ifdef OLD_GRAZE
     &          graze,
     &          kgrazesat,
     &          GrazeEffsmall, GrazeEffbig, GrazeFast, GrazeSlow,
#else
     &          grazemax, palat, asseff,
     &          kgrazesat,
     &          GrazeEfflow, GrazeEffmod, GrazeEffhi,
     &          GrazeFast, GrazeSlow,
     &          palathi, palatlo,
     &          phygrazmin,
     &          ExportFracGraz,
     &          ExGrazfracbig, ExGrazfracsmall,
#endif
     &          ZoomortSmall, ZoomortBig, ZooexfacSmall, ZooexfacBig,
     &          val_R_SiP_diatom, val_R_NP_diaz, val_RFeP_diaz,
     &          val_R_NP, val_RFeP, 
     &          ksatNH4fac, ksatNO2fac, val_ksatsi,
     &          ngrowfac, ilight,
     &          phymin, PAR0, diaz_growfac,
     &          nsource,ngroups
    
         real*8 mu(npmax)
         real*8 ksatPO4(npmax)
         real*8 ksatNO3(npmax)
         real*8 ksatNO2(npmax)
         real*8 ksatNH4(npmax)
         real*8 ksatSi(npmax)
         real*8 ksatFeT(npmax)
         real*8 ksatPAR(npmax)
         real*8 mortzoo(nzmax)
         real*8 wsink(npmax)
         real*8 R_NP(npmax)
         real*8 R_FeP(npmax)
         real*8 R_SiP(npmax)
         real*8 physize(npmax)
         real*8 diatom(npmax)
         real*8 diazotroph(npmax)
         real*8 zoosize(nzmax)
         real*8 ExportFracZ(nzmax)
         real*8 Kpremin_P
         real*8 Kpremin_N
         real*8 Kpremin_Fe
         real*8 Kpremin_Si
         real*8 phytoTempCoeff(npmax)
         real*8 phytoTempExp1(npmax)
         real*8 phytoTempExp2(npmax)     
         real*8 phytoTempOptimum(npmax)
         real*8 phytoDecayPower(npmax)
         real*8 zooTempCoeff(nzmax)
         real*8 zooTempExp(nzmax) 
         real*8 zooTempOptimum(nzmax)
         real*8 diatomgraz, olargegraz
         real*8 kinhib(npmax)
         real*8 mortphy(npmax)
         real*8 ExportFracP(npmax)
         real*8 Smallgrow, Biggrow
         real*8 Smallmort, Bigmort
         real*8 Smallgrowrange, Biggrowrange
         real*8 Smallmortrange, Bigmortrange
         real*8 Smallexport, Bigexport
         real*8 smallksatpar, smallksatparstd
         real*8 smallkinhib, smallkinhibstd
         real*8 tempcoeff1, tempcoeff2_big
         real*8 tempcoeff2_small, tempcoeff3
         real*8 tempmax, temprange, tempnorm,tempdecay
         real*8 Bigksatpar, Bigksatparstd
         real*8 Bigkinhib, Bigkinhibstd
         real*8 SmallPsat, BigPsat, ProcPsat
         real*8 SmallPsatrange, BigPsatrange, ProcPsatrange
         real*8 prochlPsat
         real*8 ksatNH4fac, ksatNO2fac
         real*8 sig1,sig2,sig3
         real*8 val_ksatsi
#ifdef OLD_GRAZE
         real*8 graze(npmax,nzmax)
         real*8 kgrazesat
         real*8 GrazeEffsmall, GrazeEffbig, GrazeFast, GrazeSlow
#else
         real*8 grazemax(nzmax)
         real*8 palat(npmax,nzmax)
         real*8 asseff(npmax,nzmax)
         real*8 kgrazesat
         real*8 GrazeEfflow, GrazeEffmod, GrazeEffhi
         real*8 GrazeFast, GrazeSlow
         real*8 palathi, palatlo
         real*8 phygrazmin
         real*8 ExportFracGraz(nzmax)
         real*8 ExGrazfracbig, ExGrazfracsmall
#endif
         real*8 ZoomortSmall, ZoomortBig, ZooexfacSmall, ZooexfacBig
         real*8 val_R_SiP_diatom, val_R_NP_diaz, val_RFeP_diaz,
     &          val_R_NP, val_RFeP
         real*8 ngrowfac,ilight
         real*8 phymin
         real*8 PAR0
         INTEGER nsource(npmax)
         INTEGER ngroups


         COMMON/darwin_detritus/wp_sink,wn_sink,wfe_sink,wsi_sink,
     &          Kdop,Kdon,KdoFe,SmallSink,BigSink,
     &          Knita, Knitb
         real*8 wp_sink
         real*8 wn_sink
         real*8 wfe_sink
         real*8 wsi_sink
         real*8 Kdop
         real*8 Kdon
         real*8 KdoFe
         real*8 SmallSink
         real*8 BigSink
         real*8 Knita
         real*8 Knitb
         real*8 diaz_growfac

c    scav           - chemical scavenging rate for iron
c    ligand_tot     - total organic ligand (assumed constant)
c    ligand_stab    - ligand stability
c    freefemax      - maximum free iron
         COMMON/darwin_ironparam/ alpfe, scav, ligand_tot, ligand_stab,
     &       freefemax
         real*8 alpfe, scav, ligand_tot, ligand_stab
         real*8 freefemax

c    k0, kc         - light coefficients
         COMMON/darwin_lightparam/ k0, kc, parfrac, parconv
         real*8 k0, kc, parfrac, parconv

c    chlpmax        - chl:p max ratio
c    chlpmin        - chl:p min ratio
c    istar          - photoadaptation light limit
         COMMON/darwin_chlparam/ chlpmax, chlpmin, istar
         real*8 chlpmax, chlpmin, istar

         COMMON/darwin_diags_param/
     &          diver_thresh0, diver_thresh1,
     &          diver_thresh2, diver_thresh3,
     &          diver_thresh4

         real*8 diver_thresh0, diver_thresh1
         real*8 diver_thresh2, diver_thresh3
         real*8 diver_thresh4
