#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_GENERATE_ALLOMETRIC

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_GENERATE_ALLOMETRIC( myThid )

C !DESCRIPTION:
C     Generate parameters for plankton types using an allometric approach

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#ifdef ALLOW_RADTRANS
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"
#endif
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_RADTRANS.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITPARAMS.h"
#include "DARWIN_TRAITS.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid
CEOP

#ifdef ALLOW_DARWIN

C !LOCAL VARIABLES: ====================================================
C     msgBuf   :: Informational/error meesage buffer
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER jpg(nGroup)
      INTEGER jp,jp2,jz,g,gz,l,gmin,iopt
      _RL logvol, vol, volmin
      _RL pp_opt, pp_sig, prd_pry
      _RL kappa
      _RL volmeas, dmmeas
      _RL dmint, dmac
      _RL scalefac, dmratio, slope
      _RL carpcellmeas, carpcellac
      _RL bphy_cell_type
      _RL bmean, bbmean
      _RL bbbratiomeas, bbbratioac


C ======================================================================
C compute cell volumes in micrometer^3
C
C in decreasing precedence (if bold quantity is set):
C
C   V = GRP_BIOVOL(j,g)
C   V = 10**(logvolbase+(GRP_BIOVOLIND(j,g)-1)*logvolinc)
C   V = 10**(logvolbase+(LOGVOL0IND(g)+j-2)*logvolinc)
C   V = BIOVOL0(g)*biovolfac(g)**(j-1)
C
C     if logvol0ind is set, use it to compute biovol0
      DO g=1,nGroup
        IF (logvol0ind(g) .GT. 0) THEN
          IF (biovol0(g) .NE. 0.0 _d 0) THEN
            WRITE(msgBuf,'(2A)') 'DARWIN_GENERATE_ALLOMETRIC: ',
     &      'cannot set both biovol0 and logvol0ind'
            CALL PRINT_ERROR( msgBuf, myThid )
            STOP 'ABNORMAL END: S/R DARWIN_GENERATE_ALLOMETRIC'
          ENDIF
          logvol = logvolbase + (logvol0ind(g)-1)*logvolinc
          biovol0(g) = 10 _d 0 ** logvol
          biovolfac(g) = 10 _d 0 ** logvolinc
        ENDIF
      ENDDO

      DO g=1,nGroup
       DO jp=1,grp_nplank(g)
        IF (grp_logvolind(jp,g) .GT. 0 .AND.
     &      grp_biovol(jp,g) .GT. 0.0 _d 0) THEN
          WRITE(msgBuf,'(2A)') 'DARWIN_GENERATE_ALLOMETRIC: ',
     &    'cannot set both grp_biovol and grp_logvolind'
          CALL PRINT_ERROR( msgBuf, myThid )
          STOP 'ABNORMAL END: S/R DARWIN_GENERATE_ALLOMETRIC'
        ELSEIF (grp_logvolind(jp,g) .GT. 0) THEN
C         pick from logrange
          logvol = logvolbase + (grp_logvolind(jp,g)-1)*logvolinc
          grp_biovol(jp,g) = 10 _d 0 ** logvol
        ELSEIF (grp_biovol(jp,g) .EQ. 0) THEN
          IF (biovol0(g) .GT. 0.0 _d 0) THEN
           grp_biovol(jp,g) = biovol0(g) * biovolfac(g)**(jp-1)
          ELSE
           WRITE(msgBuf,'(3A)') 'DARWIN_GENERATE_ALLOMETRIC: ',
     &     'Need to set one of grp_biovol, grp_logvolind, ',
     &     'biovol0, logvol0ind'
           CALL PRINT_ERROR( msgBuf, myThid )
           STOP 'ABNORMAL END: S/R DARWIN_GENERATE_ALLOMETRIC'
          ENDIF
        ENDIF
        biovol_bygroup(jp,g) = grp_biovol(jp,g)
       ENDDO
       DO jp=grp_nplank(g)+1,nplank
        IF (grp_biovol(jp,g) .NE. 0.0 _d 0) THEN
          WRITE(msgBuf,'(2A,I5,A,I5,A)') 'DARWIN_GENERATE_ALLOMETRIC: ',
     &    'index',jp,'group',g,'out of range for grp_biovol'
          CALL PRINT_ERROR( msgBuf, myThid )
          STOP 'ABNORMAL END: S/R DARWIN_GENERATE_ALLOMETRIC'
        ENDIF
        IF (grp_logvolind(jp,g) .NE. 0) THEN
          WRITE(msgBuf,'(2A,I5,A,I5,A)') 'DARWIN_GENERATE_ALLOMETRIC: ',
     &    'index',jp,'group',g,'out of range for grp_logvolind'
          CALL PRINT_ERROR( msgBuf, myThid )
          STOP 'ABNORMAL END: S/R DARWIN_GENERATE_ALLOMETRIC'
        ENDIF
        biovol_bygroup(jp,g) = 0.0 _d 0
       ENDDO
      ENDDO

C set up single list of plankton types from groups
C type order is either by group or, if darwin_sort_biovol, by biovol.

      IF (darwin_sort_biovol) THEN
c      sort by volume

       DO g=1,nGroup
        jpg(g) = 1
       ENDDO
       DO jp=1,nplank
        volmin = 1 _d 38
        gmin = 0
C       first check phototrophs
        DO g=1,ngroup
         IF (grp_photo(g).NE.0) THEN
          vol = grp_biovol(jpg(g),g)
          IF (jpg(g).LE.grp_nplank(g) .AND. vol.LT.volmin) THEN
           gmin = g
           volmin = vol
          ENDIF
         ENDIF
        ENDDO
C       then pure heterotrophs
        IF (gmin.EQ.0) THEN
         DO g=1,ngroup
          IF (grp_photo(g).EQ.0) THEN
           vol = grp_biovol(jpg(g),g)
           IF (jpg(g).LE.grp_nplank(g) .AND. vol.LT.volmin) THEN
            gmin = g
            volmin = vol
           ENDIF
          ENDIF
         ENDDO
        ENDIF
        IF (gmin.EQ.0) THEN
         STOP 'gmin'
        ENDIF
        group(jp) = gmin
        biovol(jp) = volmin
        igroup(jp) = jpg(gmin)
        jpg(gmin) = jpg(gmin) + 1
       ENDDO
       DO g=1,ngroup
        IF (jpg(g).NE.grp_nplank(g)+1) THEN
         STOP 'grp_nplank'
        ENDIF
       ENDDO

      ELSE
C      sort by group

       jp = 1
       DO g=1,ngroup
        DO jp2=1,grp_nplank(g)
         IF (jp .GT. nPlank) THEN
          WRITE(msgBuf,'(2A)') 'DARWIN_GENERATE_ALLOMETRIC: ',
     &     'need SUM(grp_nplank) = nPlank, nPlank too small'
          CALL PRINT_ERROR( msgBuf, myThid )
          STOP 'ABNORMAL END: S/R DARWIN_GENERATE_ALLOMETRIC'
         ENDIF
         group(jp)  = g
         igroup(jp) = jp2
         biovol(jp) = grp_biovol(jp2,g)
         jp = jp + 1
        ENDDO
       ENDDO
       IF (jp .NE. nPlank + 1) THEN
        WRITE(msgBuf,'(2A,2I4)') 'DARWIN_GENERATE_ALLOMETRIC: ',
     &   'need SUM(grp_nplank) = nPlank, not ',jp-1,nPlank
        CALL PRINT_ERROR( msgBuf, myThid )
        STOP 'ABNORMAL END: S/R DARWIN_GENERATE_ALLOMETRIC'
       ENDIF

C      endif sort order
      ENDIF

C ======================================================================
C compute traits from trait parameters
      DO jp=1,nplank
        g = group(jp)

C ----------------------------------------------------------------------
C non-allometric traits (same within group)

C flags
        isPhoto(jp)    = grp_photo(g)
        isPrey(jp)     = grp_prey(g)
        isPred(jp)     = grp_pred(g)
        hasSi(jp)      = grp_hasSi(g)
        hasPIC(jp)     = grp_hasPIC(g)
        diazo(jp)      = grp_diazo(g)
        useNH4(jp)     = grp_useNH4(g)
        useNO2(jp)     = grp_useNO2(g)
        useNO3(jp)     = grp_useNO3(g)
        combNO(jp)     = grp_combNO(g)
        tempMort(jp)   = grp_tempMort(g)
        tempMort2(jp)  = grp_tempMort2(g)
        tempGraz(jp)   = grp_tempGraz(g)

C traits
        Xmin(jp)       = a_Xmin(g)
        amminhib(jp)   = a_amminhib(g)
        acclimtimescl(jp) = a_acclimtimescl(g)

C mortality
        mort(jp) = a_mort(g)
        mort2(jp) = a_mort2(g)
C       if 0, temperature dependent, if 1, not.
        ExportFracMort(jp) = a_ExportFracMort(g)
        ExportFracMort2(jp) = a_ExportFracMort2(g)
        ExportFracExude(jp) = a_ExportFracExude(g)
        FracExudeC(jp) = a_FracExudeC(g)

C temperature function parameters
        phytoTempCoeff(jp)   = a_phytoTempCoeff(g)
        phytoTempExp1(jp)    = a_phytoTempExp1(g)
        phytoTempAe(jp)      = a_phytoTempAe(g)
        phytoTempExp2(jp)    = a_phytoTempExp2(g)
        phytoTempOptimum(jp) = a_phytoTempOptimum(g)
        phytoDecayPower(jp)  = a_phytoDecayPower(g)

        hetTempAe(jp)        = a_hetTempAe(g)
        hetTempExp2(jp)      = a_hetTempExp2(g)
        hetTempOptimum(jp)   = a_hetTempOptimum(g)
        hetDecayPower(jp)    = a_hetDecayPower(g)

        grazTempAe(jp)       = a_grazTempAe(g)
        grazTempExp2(jp)     = a_grazTempExp2(g)
        grazTempOptimum(jp)  = a_grazTempOptimum(g)
        grazDecayPower(jp)   = a_grazDecayPower(g)

C plankton elemental ratios
        R_NC(jp)       = a_R_NC(g)
        R_PC(jp)       = a_R_PC(g)
        R_SiC(jp)      = a_R_SiC(g)
        R_FeC(jp)      = a_R_FeC(g)
        R_ChlC(jp)     = a_R_ChlC(g)
        R_PICPOC(jp)   = a_R_PICPOC(g)

C plankton sinking and swimming
        biosink(jp) = a_biosink(g) * biovol(jp)**b_biosink(g)
        bioswim(jp) = a_bioswim(g) * biovol(jp)**b_bioswim(g)

C respRate rate is given in terms of carbon content
        qcarbon(jp) = a_qcarbon(g) * biovol(jp)**b_qcarbon(g)
        respRate(jp) = a_respRate_c(g)
     &                 * (12. _d 9 * qcarbon(jp))**b_respRate_c(g)
     &                 / qcarbon(jp)

C parameters relating to inorganic nutrients
        PCmax(jp)= a_PCmax(g) * biovol(jp)**b_PCmax(g)

        vmaxNH4(jp)  = a_vmaxNH4(g)  * biovol(jp)**b_vmaxNH4(g)
        vmaxNO2(jp)  = a_vmaxNO2(g)  * biovol(jp)**b_vmaxNO2(g)
        vmaxNO3(jp)  = a_vmaxNO3(g)  * biovol(jp)**b_vmaxNO3(g)
        vmaxN(jp)    = a_vmaxN(g)    * biovol(jp)**b_vmaxN(g)
        vmaxPO4(jp)  = a_vmaxPO4(g)  * biovol(jp)**b_vmaxPO4(g)
        vmaxSiO2(jp) = a_vmaxSiO2(g) * biovol(jp)**b_vmaxSiO2(g)
        vmaxFeT(jp)  = a_vmaxFeT(g)  * biovol(jp)**b_vmaxFeT(g)

        Qnmin(jp)    = a_Qnmin(g)  * biovol(jp)**b_Qnmin(g)
        Qnmax(jp)    = a_Qnmax(g)  * biovol(jp)**b_Qnmax(g)
                                                      
        Qpmin(jp)    = a_Qpmin(g)  * biovol(jp)**b_Qpmin(g)
        Qpmax(jp)    = a_Qpmax(g)  * biovol(jp)**b_Qpmax(g)
                                                      
        Qsimin(jp)   = a_Qsimin(g) * biovol(jp)**b_Qsimin(g)
        Qsimax(jp)   = a_Qsimax(g) * biovol(jp)**b_Qsimax(g)
                                                      
        Qfemin(jp)   = a_Qfemin(g) * biovol(jp)**b_Qfemin(g)
        Qfemax(jp)   = a_Qfemax(g) * biovol(jp)**b_Qfemax(g)

        ksatNH4(jp)  = a_ksatNH4(g)  * biovol(jp)**b_ksatNH4(g)
        ksatNO2(jp)  = a_ksatNO2(g)  * biovol(jp)**b_ksatNO2(g)
        ksatNO3(jp)  = a_ksatNO3(g)  * biovol(jp)**b_ksatNO3(g)
        ksatPO4(jp)  = a_ksatPO4(g)  * biovol(jp)**b_ksatPO4(g)
        ksatSiO2(jp) = a_ksatSiO2(g) * biovol(jp)**b_ksatSiO2(g)
        ksatFeT(jp)  = a_ksatFeT(g)  * biovol(jp)**b_ksatFeT(g)

C parameters relating to quota nutrients
c EXCRETION
        kexcc(jp)  = a_kexcc(g)  * biovol(jp)**b_kexcc(g)
        kexcn(jp)  = a_kexcn(g)  * biovol(jp)**b_kexcn(g)
        kexcp(jp)  = a_kexcp(g)  * biovol(jp)**b_kexcp(g)
        kexcsi(jp) = a_kexcsi(g) * biovol(jp)**b_kexcsi(g)
        kexcfe(jp) = a_kexcfe(g) * biovol(jp)**b_kexcfe(g)

        IF (darwin_effective_ksat) THEN
c        compute effective half sat for uptake of non-quota elements
C        we compute it for NO3 and scale for others
         IF (darwin_select_kn_allom.EQ.1) THEN
C         following Ward et al.
          kappa=(ksatNO3(jp)*PCmax(jp)*Qnmin(jp)*(Qnmax(jp)-Qnmin(jp)))/
     &          (vmaxNO3(jp)*Qnmax(jp) +
     &                       PCmax(jp)*Qnmin(jp)*(Qnmax(jp)-Qnmin(jp)))
         ELSEIF (darwin_select_kn_allom.EQ.2) THEN
C         following Follett et al.
          kappa = (ksatNO3(jp)*PCmax(jp)*Qnmin(jp))/vmaxNO3(jp)
         ELSE
          WRITE(msgBuf,'(2A)')'DARWIN_GENERATE_ALLOMETRIC: ',
     &      'illegal value for darwin_select_kn_allom'
          CALL PRINT_ERROR( msgBuf, myThid )
          STOP 'ABNORMAL END: S/R DARWIN_GENERATE_ALLOMETRIC'
         ENDIF
#ifndef DARWIN_ALLOW_NQUOTA
         ksatNO3(jp) = kappa
         ksatNO2(jp) = kappa*a_ksatNO2fac(g)
         ksatNH4(jp) = kappa*a_ksatNH4fac(g)
#endif
#ifndef DARWIN_ALLOW_PQUOTA
         ksatPO4(jp) = kappa/R_NC(jp)*R_PC(jp)
#endif
#ifndef DARWIN_ALLOW_SIQUOTA
         ksatSiO2(jp) = kappa/R_NC(jp)*R_SiC(jp)
#endif
#ifndef DARWIN_ALLOW_FEQUOTA
         ksatFeT(jp) = kappa/R_NC(jp)*R_FeC(jp)
#endif
        ENDIF

C parameters for bacteria

C flags
        bactType(jp)  = grp_bacttype(g)
        isAerobic(jp) = grp_aerobic(g)
        isDenit(jp)   = grp_denit(g)

C real parameters
        yieldO2(jp) = 1.0
        yieldNO3(jp) = 1.0
        IF (isAerobic(jp) .NE. 0) THEN
          yield(jp) = yod
          yieldO2(jp) = yoe
        ELSEIF (isDenit(jp) .NE. 0) THEN
          yield(jp) = ynd
          yieldNO3(jp) = yne
        ENDIF

        ksatPON(jp)  = a_ksatPON(g)
        ksatDON(jp)  = a_ksatDON(g)
        ksatPOC(jp)  = ksatPON(jp)/R_NC(jp)
        ksatPOP(jp)  = ksatPON(jp)/R_NC(jp)*R_PC(jp)
        ksatPOFe(jp) = ksatPON(jp)/R_NC(jp)*R_FeC(jp)
        ksatDOC(jp)  = ksatDON(jp)/R_NC(jp)
        ksatDOP(jp)  = ksatDON(jp)/R_NC(jp)*R_PC(jp)
        ksatDOFe(jp) = ksatDON(jp)/R_NC(jp)*R_FeC(jp)

#ifdef DARWIN_ALLOW_GEIDER
        mQyield(jp) = a_mQyield(g)
        chl2cmax(jp) = a_chl2cmax(g)
        inhibGeider(jp) = a_inhibGeider(g)
#else
        ksatPAR(jp) = a_ksatPAR(g)
        kinhPAR(jp) = a_kinhPAR(g)
#endif /* DARWIN_ALLOW_GEIDER */

#ifdef ALLOW_RADTRANS
        aptype(jp) = grp_aptype(g)
        iopt = aptype(jp)
        IF (1 .LE. iopt .AND. iopt .LE. nOpt) THEN
         IF (darwin_allomSpectra) THEN

c FOR ABSORPTION
c in terms of volume
           volmeas = PI / 6. _d 0 * asize(iopt)**3
           scalefac = (biovol(jp)/volmeas)**darwin_absorpSlope
c size specific absorption spectra
           DO l = 1, nlam
             aphy_chl(jp,l) = aphy_chl_type(iopt,l)*scalefac
             aphy_chl_ps(jp,l) = aphy_chl_ps_type(iopt,l)*scalefac
           ENDDO

c in terms of mg C
           IF (asize_mgC(iopt).GT.0 _d 0)THEN
            volmeas = PI / 6. _d 0 * asize_mgC(iopt)**3
            scalefac = (biovol(jp)/volmeas)**darwin_absorpSlope
           ELSE
            scalefac = 1 _d 0
           ENDIF
c size specific absorption spectra
           DO l = 1, nlam
             aphy_mgC(jp,l) = aphy_mgC_type(iopt,l)*scalefac
           ENDDO

c TOTAL SCATTER
c in terms of diameter
           volmeas = PI / 6. _d 0 * bsize(iopt)**3
           dmmeas = bsize(iopt)
           dmac = (6. _d 0 * biovol(jp)/PI)**(1. _d 0 / 3. _d 0)
           dmratio = dmac/dmmeas
           carpcellmeas = darwin_aCarCell*volmeas**darwin_bCarCell
           carpcellac = darwin_aCarCell*biovol(jp)**darwin_bCarCell
c size specific scattering spectra
           DO l = 1, nlam
c convert scatter spectrum from m2/mgC to m2/celll
             bphy_cell_type = bphy_mgC_type(iopt,l)*carpcellmeas
             dmint = 10.0 _d 0 ** darwin_scatSwitchSizeLog(l)
             IF (dmmeas.GE.dmint) THEN
               slope = darwin_scatSlopeLarge(l)
             ELSE
               slope = darwin_scatSlopeSmall(l)
             ENDIF
             bphy_mgC(jp,l) = bphy_cell_type*dmratio**slope/carpcellac
           ENDDO

c BACK SCATTER
c calculate mean scatter
           bmean = 0. _d 0
           bbmean = 0. _d 0
           DO l = 1, nlam
             bmean = bmean + bphy_mgC_type(iopt,l)*RT_wbWidths(l)
             bbmean = bbmean + bbphy_mgC_type(iopt,l)*RT_wbWidths(l)
           ENDDO
           bmean = bmean/RT_wbTotalWidth
           bbmean = bbmean/RT_wbTotalWidth
c scale mean backscattering ratio
           bbbratiomeas = bbmean/bmean
           bbbratioac = bbbratiomeas*dmratio**darwin_bbbSlope
           DO l = 1, nlam
             bbphy_mgC(jp,l) = bphy_mgC(jp,l)*bbbratioac
           ENDDO
cc
         ELSE
c OR use read in absorbtion spectra
          DO l = 1, nlam
           aphy_chl(jp,l) = aphy_chl_type(iopt,l)
           aphy_chl_ps(jp,l) = aphy_chl_ps_type(iopt,l)
           aphy_mgC(jp,l) = aphy_mgC_type(iopt,l)
           bphy_mgC(jp,l) = bphy_mgC_type(iopt,l)
           bbphy_mgC(jp,l) = bbphy_mgC_type(iopt,l)
          ENDDO
         ENDIF
        ELSEIF (jp .LE. nPhoto) THEN
          WRITE(msgBuf,'(A,2I4)')'invalid optical phyto type:',jp,iopt
          CALL PRINT_ERROR( msgBuf, myThid )
          STOP 'ABNORMAL END: S/R DARWIN_READTRAITS'
        ENDIF
#endif

C     jp
      ENDDO

C ======================================================================
C grazing

      DO jz=1,nplank
        gz = group(jz)
C       maximum grazing rate
        grazemax(jz) = a_grazemax(gz) * biovol(jz)**b_grazemax(gz)
C       grazing half-saturation
        kgrazesat(jz) = a_kgrazesat(gz) * biovol(jz)**b_kgrazesat(gz)
        DO jp=1,nplank
          g = group(jp)
          IF (grp_pred(gz).GT.0 .AND. grp_prey(g).GT.0) THEN
#ifdef DARWIN_ALLOMETRIC_PALAT
C assign grazing preference according to predator/prey radius ratio
C           grazing size preference ratio
            pp_opt = a_ppOpt(gz) * biovol(jz)**b_ppOpt(gz)
C           standard deviation of size preference
            pp_sig = a_ppSig(gz)
            prd_pry = biovol(jz) / biovol(jp)
            palat(jp,jz) =
     &        EXP(-(LOG(prd_pry/pp_opt)**2) / (2*pp_sig**2))
     &        / pp_sig/2. _d 0
            IF (palat(jp,jz).LT.palat_min) THEN
              palat(jp,jz) = 0. _d 0
            ENDIF
#else
            palat(jp,jz) = 0.0 _d 0
#endif
            asseff(jp,jz) = grp_ass_eff(g,gz)
            ExportFracPreyPred(jp,jz) = grp_ExportFracPreyPred(g,gz)
          ELSE
            palat(jp,jz) = 0. _d 0
            asseff(jp,jz) = 0. _d 0
            ExportFracPreyPred(jp,jz) = 0. _d 0
          ENDIF
        ENDDO
      ENDDO

#endif  /*ALLOW_DARWIN*/

      RETURN
      END
