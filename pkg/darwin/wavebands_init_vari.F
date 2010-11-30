C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/wavebands_init_vari.F,v 1.12 2010/11/30 18:50:18 jahn Exp $
C $Name:  $

c ANNA wavebands_init_vari.F assigns actual values to choices made by coin-flips in darwin_generate_phyto.F
c ANNA wavebands_init_vari.F creates output files

#include "DARWIN_OPTIONS.h"

CBOP
C     !ROUTINE: WAVEBANDS_INIT_VARI
C     !INTERFACE:
       SUBROUTINE WAVEBANDS_INIT_VARI(myThid)

C     !DESCRIPTION: \bv
C     *==========================================================*
C     | SUBROUTINE WAVEBANDS_INIT_VARI
C     | o assigns actual values to choices made by coin-flips
C     |   in darwin_generate_phyto.F; creates output files
C     *==========================================================*
C     \ev

C     !USES:
       implicit none
C     == Global variables ===
#include "DARWIN_SIZE.h"
#include "DARWIN.h"
#ifdef WAVEBANDS
#include "WAVEBANDS_PARAMS.h"
#endif

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C     myThid     :: my Thread Id number
       INTEGER myThid
CEOP

#ifdef WAVEBANDS

C     !LOCAL VARIABLES:
C     == Local variables ==
       _RL outfile(npmax,tlam)
       _RL outfile_ps(npmax,tlam)

       INTEGER np,nl,i,ilam, nap
       INTEGER IniUnit1, IniUnit2, IniUnit3
       INTEGER IniUnit4, IniUnit5, IniUnit6
       INTEGER IniUnit7
       

c ANNA associate the pigment / abs choices for phytoplankton with actual absorption spectra
c make sure pigment types and actual spectra match - here keep 1-4 in same order as datafile
         do np = 1, npmax

          do nap=1, tnabp
          if (ap_type(np).eq.nap) then
           do i = 1,tlam
           aphy_chl(np,i) = ap(nap,i)
           aphy_chl_ps(np,i) = ap_ps(nap,i)
#ifdef DAR_RADTRANS
           bphy_chl(np,i) = bp(nap,i)
#ifdef DAR_NONSPECTRAL_BACKSCATTERING_RATIO
           bbphy_chl(np,i) = bp(nap,i)*darwin_bbphy(nap)
#else
           bbphy_chl(np,i) = bbp(nap,i)
#endif
#endif
           enddo
          endif
         enddo

c checking the output .dat file will reveal this
          if(ap_type(np).eq.0) then
           do i=1,tlam
           aphy_chl(np,i) = 9.9d2
           aphy_chl_ps(np,i) = 9.9d2
#ifdef DAR_RADTRANS
           bphy_chl(np,i) = 9.9d2
           bbphy_chl(np,i) = 9.9d2
#endif
           enddo
          endif

         enddo

c ANNA create output files for WAVEBANDS
c ANNA see format_helps folder for more info on file structures

c file for ap_types assigned via coin flips
         CALL MDSFINDUNIT( IniUnit1, mythid )
         open(IniUnit1,file='p-ini-char-aptype.dat',
     &        status='unknown')
         CALL MDSFINDUNIT( IniUnit2, mythid )
         open(IniUnit2,file='p_ini_char_aptype_nohead.dat',
     &        status='unknown')
         write(IniUnit1,*)'np   ap_type' !to have bp_type for backscattering too
         do np = 1,npmax
           write(IniUnit1,120)np,ap_type(np)
           write(IniUnit2,120)np,ap_type(np)
         enddo
         close(IniUnit1)
         close(IniUnit2)
120      format(2i5)

c file of total absorption spectra
c rows = pwaves, columns = np      
          do np=1,npmax
           do ilam=1,tlam
             outfile(np,ilam) = aphy_chl(np,ilam)
           enddo
          enddo
         CALL MDSFINDUNIT( IniUnit3, mythid )
         open(IniUnit3,file='p-ini-char-apspec.dat',
     &        status='unknown')
         CALL MDSFINDUNIT( IniUnit4, mythid )
         open(IniUnit4,file='p_ini_char_aspec_nohead.dat',
     &        status='unknown')
         write(IniUnit3,*)'Rows = pwaves. Columns = np'
         write(IniUnit3,*)'pwaves found in pwaves-check.dat'
         write(IniUnit3,*)'col_1 to col_<npmax>'
         write(IniUnit3,*)'is absorption aphy_chl (m-2 mg chla-1)'
         do ilam=1,tlam
          write(IniUnit3,130)(outfile(np,ilam),np=1,npmax)
          write(IniUnit4,130)(outfile(np,ilam),np=1,npmax)
         enddo
c make sure outfile is defined above with the correct size
         close(IniUnit3)
         close(IniUnit4)

c file for absorption spectra of PS's only
c rows = pwaves, columns = np
          do np=1,npmax
           do ilam=1,tlam
             outfile_ps(np,ilam) = aphy_chl_ps(np,ilam)
           enddo
          enddo
         CALL MDSFINDUNIT( IniUnit5, mythid )
         open( IniUnit5,file='p-ini-char-apspec-psc.dat',
     &         status='unknown')
         CALL MDSFINDUNIT( IniUnit6, mythid )
         open( IniUnit6,file='p_ini_char_aspec_psc_nohead.dat',
     &         status='unknown')
         write(IniUnit5,*)'Rows = pwaves. Columns = np'
         write(IniUnit5,*)'pwaves found in pwaves-check.dat'
         write(IniUnit5,*)'Is absoprtion by photosynthetic'
         write(IniUnit5,*)'pigments only aphy_chl_ps (m-2 mg chla-1)'
         do ilam=1,tlam
          write(IniUnit5,130)(outfile_ps(np,ilam),np=1,npmax)
          write(IniUnit6,130)(outfile_ps(np,ilam),np=1,npmax)
         enddo
         close(IniUnit5)
         close(IniUnit6)
130      format(9999f10.4)


c file for wavebands used
c        open(23,file='pwaves-check.dat',status='new')
         CALL MDSFINDUNIT( IniUnit7, mythid )
         open( IniUnit7,file='pwaves-check.dat',
     &         status='unknown')
         write(IniUnit7,140)pwaves
         close(IniUnit7) 
140      format(i5)


#endif

         return
         end
