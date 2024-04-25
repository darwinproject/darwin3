#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_GENERATE_RANDOM

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_GENERATE_RANDOM( myThid )

C !DESCRIPTION:
C     Generate parameters for plankton types using a "Monte Carlo"
C     approach.
C
C     Mick Follows, Scott Grant Fall/Winter 2005
C     Stephanie Dutkiewicz Spring/Summer 2005
C     Anna Hickman Summer 2008
C
C     DARWIN_TWO_SPECIES_SETUP
C      1=large, 2=small
C     DARWIN_NINE_SPECIES_SETUP
C      1=diatom, 2=other large, 3=syn, 4=hl pro, 5=ll pro, 6=trich, 
C      7=uni diaz, 8=small euk, 9=cocco

C !USES: ===============================================================
      IMPLICIT NONE
#include "EEPARAMS.h"
#ifdef ALLOW_RADTRANS
#include "RADTRANS_SIZE.h"
#endif
#ifdef ALLOW_DARWIN
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_RADTRANS.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITPARAMS.h"
#include "DARWIN_TRAITS.h"
#endif

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid
CEOP

#ifdef ALLOW_DARWIN

C !FUNCTIONS: ==========================================================
      _RL DARWIN_RANDOM
      EXTERNAL DARWIN_RANDOM
      _RL DARWIN_RANDOM_NORMAL
      EXTERNAL DARWIN_RANDOM_NORMAL

C !LOCAL VARIABLES: ====================================================
C     msgBuf    - Informational/error meesage buffer
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      integer iUnit1, iUnit2
      INTEGER iMinPrey, iMaxPrey, iMinPred, iMaxPred
      _RL RandNoSize
      _RL RandNoDiatom
      _RL RandNoDiazo
      _RL RandNoGrow
      _RL RandNoMort
      _RL RandNoNsrc
      _RL RandNoAPType3
      _RL RandNoAPType2
      _RL RandNoAPType1
      _RL RandNoAPType4
      _RL RandNoTemp
      _RL RandNoKsat
      _RL RandNoKsatPAR
      _RL RandNoKinhPAR
      _RL RandNoDummy
      _RL RandNoGrowGeider
      _RL RandNoYield
      _RL RandNoChl2C

      _RL growthdays
      _RL mortdays
      _RL pday
      _RL year
      _RL month
      _RL fiveday
      _RL rtime
      _RL dm
      _RL dmzoo(nplank)
      _RL volp
      _RL sm
      _RL PI
      INTEGER np,nz,l,i,iopt
      INTEGER signvar
      PARAMETER ( PI    = 3.14159265358979323844D0   )

C     used to be global in monod pkg
      _RL phyto_esd(nplank)
      _RL phyto_vol(nplank)

      INTEGER physize(nplank)
      INTEGER nsource(nplank)
      INTEGER diacoc(nplank)

C ======================================================================

c length of day (seconds)
      pday = 86400.0 _d 0

      DO np = 1, nPlank
       kexcc(np) = 0.0 _d 0
       kexcn(np) = 0.0 _d 0
       kexcp(np) = 0.0 _d 0
       kexcsi(np) = 0.0 _d 0
       kexcfe(np) = 0.0 _d 0

       Qnmax(np) = 0.0 _d 0
       Qnmin(np) = 0.0 _d 0
       Qpmax(np) = 0.0 _d 0
       Qpmin(np) = 0.0 _d 0
       Qsimax(np) = 0.0 _d 0
       Qsimin(np) = 0.0 _d 0
       Qfemax(np) = 0.0 _d 0
       Qfemin(np) = 0.0 _d 0

       vmaxFeT(np) = 0.0 _d 0
       vmaxNH4(np) = 0.0 _d 0
       vmaxNO2(np) = 0.0 _d 0
       vmaxNO3(np) = 0.0 _d 0
       vmaxN(np) = 0.0 _d 0
       vmaxPO4(np) = 0.0 _d 0
       vmaxSiO2(np) = 0.0 _d 0

C      initialize discrete traits to "unset"
       physize(np)    = -1
       diacoc(np)     = -1
       diazo(np) = -1
       nsource(np)    = -1

       isPhoto(np) = 0
       isPrey(np) = 0
       isPred(np) = 0
      ENDDO

C ======================================================================
c     phytoplankton
C ======================================================================

      DO np = 1, nPhoto

      isPhoto(np) = 1
      isPrey(np) = 1

      Xmin(np) = phymin

C ======================================================================
C RANDOM NUMBERS

C pre-compute random numbers and discrete traits

C phyto either "small" (physize(np)=0.0) or "big" (physize(np)=1.0)
C at this point independent of whether diatom or coccolithophor or not
      RandNoSize = darwin_random(myThid)
      IF (physize(np).LT.0) THEN
       IF(RandNoSize .GT. 0.500 _d 0)then
        physize(np) = 1
       ELSE
        physize(np) = 0
       ENDIF
      ENDIF
#ifdef DARWIN_TWO_SPECIES_SETUP
      IF (np.EQ.1) physize(np) = 1
      IF (np.EQ.2) physize(np) = 0
#endif
#ifdef DARWIN_NINE_SPECIES_SETUP
      IF (np.LT.3.or.np.EQ.6.or.np.EQ.9) then
        physize(np) = 1
      ELSE
        physize(np) = 0
      ENDIF
#endif
c
c phyto either diatoms (diacoc=1.0) and use silica or cocolithophor
c (diacoc=2.0) and produce PIC or neither (diacoc=0.0)
c if they are large
      IF (physize(np).EQ.1) then
        RandNoDiatom = darwin_random(myThid)
        IF (diacoc(np) .LT. 0) THEN
         IF(RandNoDiatom .GT. 0.500 _d 0)then
          diacoc(np) = 1
         ELSE
          diacoc(np) = 0
         ENDIF
c         IF(RandNo .GT. 0.670 _d 0)then
c           diacoc(np) = 1
c         ENDIF
c         IF(RandNo .GT. 0.330 _d 0 .AND. RandNo. le. 0.67 _d 0)then
c           diacoc(np) = 2
c         ENDIF
c         IF (RandNo .LE. 0.330 _d 0) then
c           diacoc(np) = 0
c         ENDIF
        ENDIF
      ELSE
         diacoc(np) = 0
      ENDIF
#ifdef DARWIN_TWO_SPECIES_SETUP
      diacoc(np) = 0
#endif
#ifdef DARWIN_NINE_SPECIES_SETUP
      IF (np.EQ.1) then
        diacoc(np) = 1
      ELSE
        diacoc(np) = 0
      ENDIF
      IF (np.EQ.9) then
        diacoc(np) = 2
      ENDIF
#endif

c phyto either diazotrophs (diazo=1.0) or not (diazo=0.0)
      RandNoDiazo = darwin_random(myThid)
      IF (diazo(np) .LT. 0) THEN
       IF(RandNoDiazo .GT. 0.6700 _d 0)then
        diazo(np) = 1
       ELSE
        diazo(np) = 0
       ENDIF
      ENDIF
c TEST ...........................................
#ifndef DARWIN_ALLOW_DIAZ
      diazo(np) = 0
#endif
c TEST ...........................................
#ifdef DARWIN_TWO_SPECIES_SETUP
      diazo(np) = 0
#endif
#ifdef DARWIN_NINE_SPECIES_SETUP
      IF (np.GT.5.AND.np.LT.8) then
         diazo(np) = 1
      ELSE
         diazo(np) = 0
      ENDIF
#endif

      RandNoGrow = darwin_random(myThid)
      RandNoMort = darwin_random(myThid)
c nutrient source 
      IF(diazo(np) .ne. 1)then
         RandNoNsrc = darwin_random(myThid)
         IF (nsource(np) .LT. 0) THEN
          IF (physize(np).EQ.1) then   
           nsource(np) = 3
          ELSE
           IF(RandNoNsrc .GT. 0.670 _d 0)then
             nsource(np) = 1
           ELSEif(RandNoNsrc .LT. 0.33 _d 0)then
             nsource(np) = 2
           ELSE
             nsource(np) = 3
           ENDIF
c ANNA shift bias away from pros. Now equal chance of being HL, LL, Syn, Euk.
c ANNA i.e. now 50% chance of being Pro (nsource 1 or 2, with 50% change of each being HL)
c ANNA i.e. and 50% chance of being non-Pro (nsource 3, with 50% chance of non-pro being Syn)
c           IF(RandNo .GT. 0.50 _d 0)then
c             nsource(np) = 3
c           ELSEif(RandNo .LT. 0.25 _d 0)then
c             nsource(np) = 2
c           ELSE
c             nsource(np) = 1
c           ENDIF 
          ENDIF
         ENDIF
      ELSE
         nsource(np) = 0
      ENDIF 
#ifdef DARWIN_TWO_SPECIES_SETUP
      nsource(np) = 3
#endif
#ifdef DARWIN_NINE_SPECIES_SETUP
      IF (np.LT.4) then
        nsource(np) = 3
      ENDIF
      nsource(4)=2
      nsource(5)=1
      IF (np.GT.5.AND.np.LT.8) then
        nsource(np) = 0
      ENDIF
      IF (np.GT.7) then
        nsource(np) = 3
      ENDIF
#endif

c.....................................................
c ANNA make selections for RADTRANS 
c.....................................................
#ifdef ALLOW_RADTRANS
c for now, choice of four absorption spectra types
c pros get either 'HL' or 'LL'
c small others get 'syn' or 'euk'
c large get 'euk'
c each 'type', once assigned, gets given actual values in wavebands_init_vari.F

c ANNA_Q could use tricho abs and scattering spectra (Subramanian et al. 1999)
c ANNA_Q think diaz is turned off for now
c Diaz will be 0 if not defined, and will have nsource = 0. 
      print*,'nopt',nopt,np,nsource(np),aptype(np)
      IF (nOpt.EQ.4) then
       RandNoAPType3 = darwin_random(myThid)
       RandNoAPType2 = darwin_random(myThid)
       RandNoAPType1 = darwin_random(myThid)
       IF (nsource(np).EQ.0) then   !if diazo
        IF (physize(np).EQ.1.0d0) then !if BIG
        aptype(np) = 1                !euk (assume diatom association)
        ELSE                           !or
        aptype(np) = 2                !syn (for now - tricho has billins)
        ENDIF
       ENDIF        

       IF (nsource(np).EQ.3) then !if all three sources (NO3)
        IF (physize(np).EQ.1.0d0) then !if BIG 
        aptype(np) = 1                !euk
        ELSE                           !if SMALL
         IF (RandNoAPType3.GT.0.500d0) then
         aptype(np) = 1               !euk
         ELSE                          !or
         aptype(np) = 2               !Syn       
         ENDIF
        ENDIF
       ENDIF
 
       IF (nsource(np).EQ.2) then !if NH4 only
        IF (RandNoAPType2.GT.0.500d0) then
        aptype(np) = 3               !Pro HL   
        ELSE                          !or
        aptype(np) = 4               !Pro LL                 
        ENDIF
       ENDIF

       IF (nsource(np).EQ.1) then !if NH4 & NO2
        IF (RandNoAPType1.GT.0.500d0) then
        aptype(np) = 3               !Pro HL   
        ELSE                          !or
        aptype(np) = 4               !Pro LL                 
        ENDIF
       ENDIF
       print*,'ap',np,nsource(np),aptype(np)
      ENDIF
c
      IF (nOpt.EQ.12) then
       RandNoAPType4 = darwin_random(myThid)
       IF (nsource(np).EQ.0) then   !if diazo
        IF (physize(np).EQ.1.0d0) then !if BIG
         IF (diacoc(np).EQ.1.0d0) then
           aptype(np) = 5                !diatom association
         ENDIF
         IF (diacoc(np).EQ.0.0d0) then
           aptype(np) = 7                !tricho
         ENDIF
         IF (diacoc(np).EQ.2.0d0) then
           aptype(np) = 6                !coccolithopher(?)
         ENDIF
        ELSE                           !or
         aptype(np) = 1                !unicellular (whould be 8 -
                                        !but currently zero)
        ENDIF
       ENDIF

       IF (nsource(np).EQ.3) then !if all three sources (NO3)
        IF (physize(np).EQ.1.0d0) then !if BIG
         IF (diacoc(np).EQ.1.0d0) then
           aptype(np) = 5                !diatom
         ENDIF
         IF (diacoc(np).EQ.0.0d0) then
           aptype(np) = 9                !Lg Euk
         ENDIF
         IF (diacoc(np).EQ.2.0d0) then
           aptype(np) = 6                !coccolithopher
         ENDIF
        ELSE                           !if SMALL
         IF (RandNoAPType4.GT.0.500d0) then
         aptype(np) = 1               !euk
         ELSE                          !or
         aptype(np) = 2               !Syn
         ENDIF
        ENDIF
       ENDIF
      ENDIF

#ifdef DARWIN_TWO_SPECIES_SETUP
      IF (np.EQ.1) aptype(np) = 10
      IF (np.EQ.2) aptype(np) = 10
#endif
#ifdef DARWIN_NINE_SPECIES_SETUP
      IF (np.EQ.1) aptype(np) = 5
      IF (np.EQ.2) aptype(np) = 9
      IF (np.EQ.3) aptype(np) = 2
      IF (np.EQ.4) aptype(np) = 3
      IF (np.EQ.5) aptype(np) = 4
      IF (np.EQ.6) aptype(np) = 7
      IF (np.EQ.7) aptype(np) = 8
      IF (np.EQ.8) aptype(np) = 1
      IF (np.EQ.9) aptype(np) = 6
      aptype(np) = 10
#endif

      print*,'aptype',np,aptype(np)
      iopt = aptype(np)
      IF (1 .LE. iopt .AND. iopt .LE. nOpt) THEN
        DO l = 1, nlam
         aphy_chl(np,l) = aphy_chl_type(iopt,l)
         aphy_chl_ps(np,l) = aphy_chl_ps_type(iopt,l)
         aphy_mgC(np,l) = aphy_mgC_type(iopt,l)
         bphy_mgC(np,l) = bphy_mgC_type(iopt,l)
         bbphy_mgC(np,l) = bbphy_mgC_type(iopt,l)
        ENDDO
      ELSE
        WRITE(msgBuf,'(A,2I4)')'invalid optical phyto type:',np,iopt
        CALL PRINT_ERROR( msgBuf, myThid )
        STOP 'ABNORMAL END: S/R DARWIN_READTRAITS'
      ENDIF

#else
c ANNA number of RandNo's carreid out MUST MATCH regardless of wavebands or not.
C ANNA the number of RandNo statements here MUST MATCH the number done above

c        RandNo = darwin_random(myThid)
c        RandNo = darwin_random(myThid)
c        RandNo = darwin_random(myThid)

#endif
c ANNA ENDIF


      RandNoTemp = darwin_random(myThid)
      RandNoKsat = darwin_random(myThid)
#ifndef DARWIN_ALLOW_GEIDER
      IF(physize(np) .EQ. 1)then
         RandNoKsatPAR = darwin_random_normal(myThid)
         RandNoKinhPAR = darwin_random_normal(myThid)
      ELSE
c QQ remove someday
         RandNoDummy = darwin_random(myThid)
         RandNoKsatPAR = darwin_random_normal(myThid)
         RandNoKinhPAR = darwin_random_normal(myThid)
      ENDIF
#endif
#ifdef DARWIN_ALLOW_GEIDER
      RandNoGrowGeider = darwin_random(myThid)
      RandNoYield = darwin_random(myThid)
      RandNoChl2C = darwin_random(myThid)
#endif

C ======================================================================

c size of phytoplankton
      IF(physize(np).EQ. 1)then
        dm = 10. _d 0  ! diameter (micrometer)
      ELSE
        dm = 1. _d 0  ! diameter (micrometer)
      ENDIF
c phytoplankton volume in micrometers cubed
      volp=4. _d 0/3. _d 0 *PI*(dm/2. _d 0)**3 _d 0
c
c common block variables (in m and m3)
      phyto_esd(np)=dm* 1. _d -6
      phyto_vol(np)=volp* 1. _d -18

c growth rates
c big/small phyto growth rates..
      IF(physize(np) .EQ. 1)then
        growthdays = Biggrow +RandNoGrow*Biggrowrange
      ELSE
        growthdays = Smallgrow +RandNoGrow*Smallgrowrange
      ENDIF
#ifdef DARWIN_TWO_SPECIES_SETUP
      IF(physize(np) .EQ. 1)then
        growthdays = Biggrow 
      ELSE
        growthdays = Smallgrow
      ENDIF
#endif
#ifdef DARWIN_NINE_SPECIES_SETUP
      IF(physize(np) .EQ. 1)then
        growthdays = Biggrow
      ELSE
        growthdays = Smallgrow
      ENDIF
#endif
c but diazotrophs always slower due to energetics
      IF(diazo(np) .EQ. 1) then
          growthdays = growthdays * diaz_growfac
      ENDIF
c cocco have slower growth than other large
      IF (diacoc(np).EQ.2. _d 0) then
         growthdays= growthdays * cocco_growfac
      ENDIF
c diatom has faster thatn other large
      IF (diacoc(np).EQ.1. _d 0) then
         growthdays= growthdays * diatom_growfac
      ENDIF
c now convert to a growth rate
      IF (growthdays.GT.0. _d 0) then
       PCmax(np) = 1.0 _d 0/(growthdays*pday)
      ELSE
       PCmax(np) = 0. _d 0
      ENDIF

c mortality and export fraction rates
c big/small phyto mortality rates..
      IF(physize(np) .EQ. 1)then
        mortdays = Bigmort +RandnoMort*Bigmortrange
        ExportFracMort(np)=Bigexport
        ExportFracMort2(np)=Bigexport
#ifdef DARWIN_ALLOW_EXUDE
        ExportFracExude(np)=Bigexport
#else
        ExportFracExude(np)=DARWIN_UNINIT_RL
#endif
      ELSE
        mortdays = Smallmort +RandNoMort*Smallmortrange
        ExportFracMort(np)=Smallexport
        ExportFracMort2(np)=Smallexport
#ifdef DARWIN_ALLOW_EXUDE
        ExportFracExude(np)=Smallexport
#else
        ExportFracExude(np)=DARWIN_UNINIT_RL
#endif
      ENDIF
      FracExudeC(np) = 0.3 _d 0
#ifdef DARWIN_TWO_SPECIES_SETUP
      IF(physize(np) .EQ. 1)then
        mortdays = Bigmort
      ELSE
        mortdays = Smallmort
      ENDIF
#endif
#ifdef DARWIN_NINE_SPECIES_SETUP
      IF(physize(np) .EQ. 1)then
        mortdays = Bigmort
      ELSE
        mortdays = Smallmort
      ENDIF
#endif

c now convert to a mortality rate
      IF (mortdays.GT.0. _d 0) then
        mort(np) = 1.0 _d 0/(mortdays*pday)
      ELSE
        mort(np) = 0. _d 0
      ENDIF
      mort2(np) = 0.0 _d 0

C phytoplankton do not have temperature-dependent mortality
      tempMort(np) = 0
      tempMort2(np) = 0

      respRate(np) = 0.0 _d 0


c..........................................................
c generate phyto Temperature Function parameters  
c.......................................................
      phytoTempCoeff(np) = tempcoeff1
      phytoTempExp1(np) = tempcoeff3
      phytoTempAe(np) = 0.0438 _d 0
      IF(physize(np) .EQ. 1)then
        phytoTempExp2(np) = tempcoeff2_big
      ELSE
        phytoTempExp2(np) = tempcoeff2_small
      ENDIF

#ifdef DARWIN_TEMP_RANGE
cswd    phytoTempOptimum(np) = 30.0 _d 0 - RandNo*28.0 _d 0 
      phytoTempOptimum(np) = tempmax - RandNoTemp*temprange
      phytoDecayPower(np) = tempdecay
#else
      phytoTempOptimum(np) = 0. _d 0
      phytoDecayPower(np) = 0. _d 0
#endif
      
c stoichiometric ratios for each functional group of phyto 
c relative to phosphorus  - the base currency nutrient
c set Si:P
      IF(diacoc(np) .EQ. 1)then
        R_SiC(np) =  val_R_SiC_diatom
      ELSE
        R_SiC(np) = 0.0 _d 0
      ENDIF
      IF(diacoc(np) .EQ. 2)then
        R_PICPOC(np) =  val_R_PICPOC
      ELSE
        R_PICPOC(np) = 0.0 _d 0
      ENDIF
c set N:P and iron requirement according to diazotroph status
      IF(diazo(np) .EQ. 1)then
        R_NC(np) = val_R_NC_diaz
        R_FeC(np) =  val_R_FeC_diaz
      ELSE
        R_NC(np) = val_R_NC
        R_FeC(np) = val_R_FeC
      ENDIF
c set C:P ratio
        R_PC(np) = val_R_PC
c set sinking rates according to allometry
      IF(physize(np) .EQ. 1)then
         biosink(np) = BigSink
      ELSE 
         biosink(np) = SmallSink
      ENDIF 
      bioswim(np) = 0.0 _d 0
c half-saturation coeffs 

      IF(physize(np) .EQ. 1)then
         ksatPO4(np) = BigPsat + RandNoKsat*BigPsatrange
      ELSE
c          ksatPO4(np) = SmallPsat + RandNoKsat*SmallPsatrange
c          if (nsource(np).LT.3) then
c            ksatPO4(np) = ksatPO4(np)*prochlPsat
c           ENDIF
         IF (nsource(np).EQ.3) then
           ksatPO4(np) = SmallPsat + RandNoKsat*SmallPsatrange
         ENDIF
         IF (nsource(np).EQ..0) then
c            ksatPO4(np) = SmallPsat + RandNoKsat*SmallPsatrange
           ksatPO4(np) = UniDzPsat + RandNoKsat*UniDzPsatrange 
         ENDIF
         IF (nsource(np).EQ.2.or.nsource(np).EQ.1) then
           ksatPO4(np) = ProcPsat + RandNoKsat*ProcPsatrange
         ENDIF
      ENDIF
      IF (diacoc(np) .EQ. 2) THEN
         ksatPO4(np) = CoccoPsat + RandNoKsat*CoccoPsatrange
      ENDIF
#ifdef DARWIN_TWO_SPECIES_SETUP
      IF(physize(np) .EQ. 1)then
         ksatPO4(np) = BigPsat 
      ELSE
         ksatPO4(np) = SmallPsat
      ENDIF
#endif
#ifdef DARWIN_NINE_SPECIES_SETUP
      IF(physize(np) .EQ. 1)then
         ksatPO4(np) = BigPsat
      ELSE
         ksatPO4(np) = SmallPsat
      ENDIF
      IF (nsource(np).EQ.2.or.nsource(np).EQ.1) then
         ksatPO4(np) = ProcPsat 
      ENDIF
      IF (diacoc(np) .EQ. 2) then
         ksatPO4(np) = ksatPO4(np)/0.8 _d 0 
      ENDIF
#endif

      ksatNO3(np) = ksatPO4(np)*R_NC(np)/R_PC(np)
      ksatNO2(np) = ksatNO3(np)*ksatNO2fac 
c Made ksatNH4 smaller since it is the preferred source
      ksatNH4(np) = ksatNO3(np)*ksatNH4fac
      ksatFeT(np) = ksatPO4(np)*R_FeC(np)/R_PC(np)
      ksatSiO2(np) = val_ksatsio2
      amminhib(np) = val_amminhib

      acclimtimescl(np) = val_acclimtimescl

#ifndef DARWIN_ALLOW_GEIDER
      R_ChlC(np) = val_R_ChlC

cNEW Light parameters:
c     ksatPAR {0.1 - 1.3}
c     0.35=Av High Light Adapted, 0.8=Av Low Light Adapted
c     kinhPAR  {0.0 - 3.0}
c     0.5 =Av High Light Adapted, 2.0=Av Low Light Adapted
c High Light Groups for Large size:
      IF(physize(np) .EQ. 1)then
         ksatPAR(np) = abs(Bigksatpar+Bigksatparstd*RandNoKsatPAR)

         kinhPAR(np) = abs(BigkinhPAR+BigkinhPARstd*RandNoKinhPAR)
      ELSE
c QQ remove someday
c Low Light Groups for Small size:
         ksatPAR(np) = abs(smallksatpar+smallksatparstd*RandNoKsatPAR)

         kinhPAR(np) = abs(smallkinhPAR+smallkinhPARstd*RandNoKinhPAR)
      ENDIF
#ifdef DARWIN_TWO_SPECIES_SETUP
      IF(physize(np) .EQ. 1)then
         ksatPAR(np) = abs(Bigksatpar)
         kinhPAR(np) = abs(Bigkinhpar)
      ELSE
         ksatPAR(np) = abs(smallksatpar)
         kinhPAR(np) = abs(smallkinhpar)
      ENDIF
#endif
#ifdef DARWIN_NINE_SPECIES_SETUP
      IF(physize(np) .EQ. 1)then
         ksatPAR(np) = abs(Bigksatpar)
         kinhPAR(np) = abs(BigkinhPAR)
      ELSE
         ksatPAR(np) = abs(smallksatpar)
         kinhPAR(np) = abs(smallkinhPAR)
      ENDIF
      IF (np.EQ.5) then
        kinhPAR(np) = abs(LLProkinhPAR)
      ENDIF
      IF (np.EQ.9) then
        kinhPAR(np) = abs(CoccokinhPAR)
      ENDIF
#endif
#endif

#ifdef DARWIN_ALLOW_GEIDER
c big/small phyto growth rates..
      IF(physize(np) .EQ. 1)then
        growthdays = Biggrow +RandNoGrowGeider*Biggrowrange
      ELSE
        growthdays = Smallgrow +RandNoGrowGeider*Smallgrowrange
      ENDIF
#ifdef DARWIN_TWO_SPECIES_SETUP
      IF(physize(np) .EQ. 1)then
        growthdays = Biggrow 
      ELSE
        growthdays = Smallgrow 
      ENDIF
#endif
#ifdef DARWIN_NINE_SPECIES_SETUP
      IF(physize(np) .EQ. 1)then
        growthdays = Biggrow
      ELSE
        growthdays = Smallgrow
      ENDIF
#endif
c but diazotrophs always slower due to energetics
      IF(diazo(np) .EQ. 1) then
          growthdays = growthdays * diaz_growfac
      ENDIF
c cocco have slower growth than other large
      IF (diacoc(np).EQ.2. _d 0) then
         growthdays= growthdays * cocco_growfac
      ENDIF
c diatom has faster thatn other large
      IF (diacoc(np).EQ.1. _d 0) then
         growthdays= growthdays * diatom_growfac
      ENDIF
c now convert to a growth rate
      IF (growthdays.GT.0. _d 0) then
       pcmax(np) = 1.0 _d 0/(growthdays*pday)
      ELSE
       pcmax(np) = 0. _d 0
      ENDIF
c
c photo-inhibition 
#ifdef ALLOW_RADTRANS
c only LL Pro are inhibited
       IF (aptype(np).EQ.4) then
          inhibGeider(np) = inhibcoef_geid_val
       ELSE
          inhibGeider(np) = 0. _d 0
       ENDIF
#else
c no inhibition
       IF(physize(np) .EQ. 1)then
         inhibGeider(np) = 0. _d 0
       ELSE
         inhibGeider(np) = 0. _d 0  !inhibcoef_geid_val
       ENDIF
#endif
c

c big/small phyto PI slope (chl specific)
c        IF(physize(np) .EQ. 1)then
c          alphachl(np) = Bigalphachl +Randno*Bigalphachlrange
c        ELSE
c          alphachl(np) = Smallalphachl +RandNo*Smallalphachlrange
c        ENDIF

c ANNA gieder via mQyield instead of alpha
c big/small phyto Maximum Quantum Yield
      IF(physize(np) .EQ. 1)then
        mQyield(np) = BigmQyield +RandNoYield*BigmQyieldrange
      ELSE
        mQyield(np) = SmallmQyield +RandNoYield*SmallmQyieldrange
      ENDIF
#ifdef DARWIN_TWO_SPECIES_SETUP
      IF(physize(np) .EQ. 1)then
        mQyield(np) = BigmQyield
      ELSE
        mQyield(np) = SmallmQyield
      ENDIF
#endif
#ifdef DARWIN_NINE_SPECIES_SETUP
      IF(physize(np) .EQ. 1)then
        mQyield(np) = BigmQyield
      ELSE
        mQyield(np) = SmallmQyield
      ENDIF
#endif
#ifdef ALLOW_RADTRANS
c ANNA for wavebands only, re-set mQyield to be constant for all np's
c ANNA i.e. let alpha vary only with aphy_chl_ps
c ANNA value is mean of vals for big and small.
        mQyield(np) = 4.0 _d -5
#endif


c big/small phyto C:Chl max
      IF(physize(np) .EQ. 1)then
        chl2cmax(np) = Bigchl2cmax +RandnoChl2C*Bigchl2cmaxrange
      ELSE
        chl2cmax(np) = Smallchl2cmax +RandNoChl2C*Smallchl2cmaxrange
      ENDIF
#ifdef DARWIN_TWO_SPECIES_SETUP
      IF(physize(np) .EQ. 1)then
        chl2cmax(np) = Bigchl2cmax 
      ELSE
        chl2cmax(np) = Smallchl2cmax 
      ENDIF
#endif
#ifdef DARWIN_NINE_SPECIES_SETUP
      IF(physize(np) .EQ. 1)then
        chl2cmax(np) = Bigchl2cmax
      ELSE
        chl2cmax(np) = Smallchl2cmax
      ENDIF
#endif
c ANNA chl2cmin added
c       chl2cmin(np) = 0.003  _d 0 * 12. _d 0  ! mg Chl a/mmol C

#endif /* DARWIN_ALLOW_GEIDER */

      print*,'nsource',np,nsource(np)
      IF (nsource(np) .EQ. 3) THEN
        useNH4(np) = 1
        useNO2(np) = 1
        useNO3(np) = 1
        combNO(np) = 1
      ELSEIF (nsource(np) .EQ. 2) THEN
        useNH4(np) = 1
        useNO2(np) = 0
        useNO3(np) = 0
        combNO(np) = 0
      ELSEIF (nsource(np) .EQ. 1) THEN
        useNH4(np) = 1
        useNO2(np) = 1
        useNO3(np) = 0
        combNO(np) = 0
      ELSE
        useNH4(np) = 0
        useNO2(np) = 0
        useNO3(np) = 0
        combNO(np) = 0
      ENDIF

      IF (diacoc(np) .NE. 1) THEN
        ksatSiO2(np) = 0.0
        vmaxSiO2(np) = 0.0
        R_SiC(np) = 0.0
      ENDIF

      IF (diacoc(np) .EQ. 1) THEN
        hasSi(np) = 1
        hasPIC(np) = 0
      ELSEIF (diacoc(np) .EQ. 2) THEN
        hasSi(np) = 0
        hasPIC(np) = 1
      ELSE
        hasSi(np) = 0
        hasPIC(np) = 0
      ENDIF

      ENDDO  ! np

      DO np = 1, nplank

        bactType(np) = 0
        isAerobic(np) = 0
        isDenit(np) = 0

        yield(np) = 1.0 _d 0
        yieldO2(np) = 1.0 _d 0
        yieldNO3(np) = 1.0 _d 0

        ksatPON(np) = 1.0 _d 0
        ksatPOC(np) = 1.0 _d 0
        ksatPOP(np) = 1.0 _d 0
        ksatPOFe(np) = 1.0 _d 0
        ksatDON(np) = 1.0 _d 0
        ksatDOC(np) = 1.0 _d 0
        ksatDOP(np) = 1.0 _d 0
        ksatDOFe(np) = 1.0 _d 0

        hetTempAe(np) = 0.0438 _d 0
        hetTempExp2(np) = 0.001 _d 0
        hetTempOptimum(np) = 2 _d 0
        hetDecayPower(np) = 4 _d 0

      ENDDO  ! np

#ifdef ALLOW_RADTRANS
      DO np = nPhoto + 1, nplank
        DO l = 1, nlam
         bphy_mgC(np,l) = 0 _d 0
         bbphy_mgC(np,l) = 0 _d 0
        ENDDO
      ENDDO
#endif


C ======================================================================
c     zooplankton
C ======================================================================

      DO nz = 1, nplank
       DO np = 1, nplank
        palat(np,nz) = 0 _d 0
        asseff(np,nz) = 0 _d 0
        ExportFracPreyPred(np,nz) = 0 _d 0
       ENDDO
      ENDDO

      iMinPrey = 1
      iMaxPrey = nPhoto
      iMinPred = nPhoto + 1
      iMaxPred = nplank
      DO nz = iMinPred, iMaxPred
       isPred(nz) = 1
      ENDDO

      IF ( oldTwoGrazers ) THEN
c assume zoo(1) = small, zoo(2) = big

       IF ( iMaxPred-iMinPred .NE. 1 ) THEN
        WRITE(msgBuf,'(2A)') 'DARWIN_GENERATE: ',
     &    'must have exactly 2 predators when oldTwoGrazers=.TRUE.'
        CALL PRINT_ERROR( msgBuf , 1)
        STOP 'ABNORMAL END: S/R DARWIN_GENERATE'
       ENDIF
       physize(iMinPred) = 0
       physize(iMaxPred) = 1
       grazemax(iMinPred) = GrazeFast
       grazemax(iMaxPred) = GrazeFast
       ExportFracMort(iMinPred) = ZooexfacSmall
       ExportFracMort(iMaxPred) = ZooexfacBig
       ExportFracMort2(iMinPred) = ZooexfacSmall
       ExportFracMort2(iMaxPred) = ZooexfacBig
#ifdef DARWIN_ALLOW_EXUDE
       ExportFracExude(iMinPred) = ZooexfacSmall
       ExportFracExude(iMaxPred) = ZooexfacBig
#else
       ExportFracExude(iMinPred) = DARWIN_UNINIT_RL
       ExportFracExude(iMaxPred) = DARWIN_UNINIT_RL
#endif
       FracExudeC(iMinPred) = 0.3 _d 0
       FracExudeC(iMaxPred) = 0.3 _d 0
       mort(iMinPred) = ZoomortSmall
       mort(iMaxPred) = ZoomortBig
       mort2(iMinPred) = ZoomortSmall2
       mort2(iMaxPred) = ZoomortBig2
       DO np = iMinPrey, iMaxPrey
        ExportFracPreyPred(np,iMinPred) = ExGrazFracSmall
        ExportFracPreyPred(np,iMaxPred) = ExGrazFracBig
       ENDDO
       dmzoo(iMinPred) = 30. _d 0   ! diameter (micrometer)
       dmzoo(iMaxPred) = 300. _d 0  ! diameter (micrometer)
c palatibity according to "allometry"
c big grazers preferentially eat big phyto etc...
       DO nz = iMinPred, iMaxPred
        DO np = iMinPrey, iMaxPrey
          IF (physize(nz).EQ.physize(np)) then
            palat(np,nz) = palathi
            asseff(np,nz) = GrazeEffmod
          ELSE
            palat(np,nz) = palatlo
            IF (physize(np).EQ.0. _d 0) then
              asseff(np,nz) = GrazeEffhi
            ELSE
              asseff(np,nz) = GrazeEfflow
            ENDIF
          ENDIF
c diatoms even less palatible
          IF (diacoc(np).EQ.1. _d 0) then
            palat(np,nz)= palat(np,nz)*diatomgraz
          ENDIF
c coccolithophes less palatible
          IF (diacoc(np).EQ.2. _d 0) then
            palat(np,nz)= palat(np,nz)*coccograz
          ENDIF
c other large phyto less palatible
          IF (diacoc(np).EQ.0. _d 0 .AND.physize(np).EQ.1. _d 0) then
            palat(np,nz)= palat(np,nz)*olargegraz
          ENDIF
c need something in here for tricho
        ENDDO
       ENDDO

c     not oldTwoGrazers
      ELSE

       DO nz = iMinPred, iMaxPred
        grazemax(nz) = GrazeRate
        ExportFracMort(nz) = Zooexfac
        ExportFracMort2(nz) = Zooexfac
#ifdef DARWIN_ALLOW_EXUDE
        ExportFracExude(nz) = Zooexfac
#else
        ExportFracExude(nz) = DARWIN_UNINIT_RL
#endif
        FracExudeC(nz) = 0.3 _d 0
        mort(nz) = Zoomort
        mort2(nz) = Zoomort2
        dmzoo(nz) = ZooDM
        DO np = iMinPrey, iMaxPrey
         palat(np,nz) = val_palat
         asseff(np,nz) = val_ass_eff
         ExportFracPreyPred(np,nz) = ExGrazFrac
        ENDDO
       ENDDO

c     oldTwoGrazers
      ENDIF

c
      DO nz = iMinPred, iMaxPred
        R_NC(nz) = val_R_NC_zoo
        R_PC(nz) = val_R_PC_zoo
        R_SiC(nz) = val_R_SiC_zoo
        R_FeC(nz) = val_R_FeC_zoo
        R_ChlC(nz) = val_R_ChlC_zoo
        R_PICPOC(nz) = val_R_PICPOC_zoo

        Xmin(nz) = 0.0 _d 0

        kgrazesat(nz) = kgrazesat_val
C zooplankton do have temperature-dependent mortality
        tempMort(nz) = 0
        tempMort2(nz) = 0
        tempGraz(nz) = 0
        grazTempAe(nz) = 0.0438 _d 0
        grazTempExp2(nz) = 0.001 _d 0
        grazTempOptimum(nz) = 2 _d 0
        grazDecayPower(nz) = 4 _d 0

        respRate(nz) = 0.0 _d 0
        biosink(nz) = 0.0 _d 0
        bioswim(nz) = 0.0 _d 0

c zooplankton volume in micrometers cubed
        volp = 4. _d 0/3. _d 0 *PI*(dmzoo(nz)/2. _d 0)**3 _d 0
c
c common block variables (in m and m3)
        phyto_esd(nz) = dmzoo(nz)* 1. _d -6
        phyto_vol(nz) = volp* 1. _d -18
      ENDDO

#endif /* ALLOW_DARWIN */

      RETURN
      END

