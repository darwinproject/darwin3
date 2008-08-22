C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/wavebands_init_vari.F,v 1.3 2008/08/22 18:59:50 jahn Exp $
C $Name:  $

c ANNA wavebands_init_vari.F assigns actual values to choices made by coin-flips in darwin_generate_phyto.F
c ANNA wavebands_init_vari.F creates output files

#include "GCHEM_OPTIONS.h"

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
#include "WAVEBANDS_PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C     myThid     :: my Thread Id number
      integer myThid      
CEOP

#ifdef WAVEBANDS

C     !LOCAL VARIABLES:
C     == Local variables ==
       INTEGER np,nl,i,ilam
       INTEGER unit1, unit2
       
       _RL outfile(npmax,tlam)
       _RL outfile_ps(npmax,tlam)

c ANNA associate the pigment / abs choices for phytoplankton with actual absorption spectra
c make sure pigment types and actual spectra match - here keep 1-4 in same order as datafile
         do np = 1, npmax

          if (ap_type(np).eq.1) then
           do i = 1,tlam
           aphy_chl(np,i) = ap(1,i)
           aphy_chl_ps(np,i) = ap_ps(1,i)
           enddo
          endif

          if (ap_type(np).eq.2) then
           do i=1,tlam
           aphy_chl(np,i) = ap(2,i)
           aphy_chl_ps(np,i) = ap_ps(2,i)
           enddo
          endif

          if (ap_type(np).eq.3) then
           do i=1,tlam
           aphy_chl(np,i) = ap(3,i)
           aphy_chl_ps(np,i) = ap_ps(3,i)
           enddo
          endif

          if (ap_type(np).eq.4) then
           do i=1,tlam
           aphy_chl(np,i) = ap(4,i)
           aphy_chl_ps(np,i) = ap_ps(4,i)
           enddo
          endif

c checking the output .dat file will reveal this
          if(ap_type(np).eq.0) then
           do i=1,tlam
           aphy_chl(np,i) = 9.9d2
           aphy_chl_ps(np,i) = 9.9d2
           enddo
          endif

         enddo

c ANNA create output files for WAVEBANDS
c ANNA see format_helps folder for more info on file structures

c file for ap_types assigned via coin flips
         CALL MDSFINDUNIT( unit1, mythid )
         open(unit1,file='p-ini-char-aptype.dat',status='unknown')
         CALL MDSFINDUNIT( unit2, mythid )
         open(unit2,file='p_ini_char_aptype_nohead.dat', 
     &        status='unknown')
         write(unit1,*)'np   ap_type' !to have bp_type for backscattering too
         do np = 1,npmax
           write(unit1,120)np,ap_type(np)
           write(unit2,120)np,ap_type(np)
         enddo
         close(unit1)
         close(unit2)
120      format(2i5)

c file of total absorption spectra
c rows = pwaves, columns = np      
          do np=1,npmax
           do ilam=1,tlam
             outfile(np,ilam) = aphy_chl(np,ilam)
           enddo
          enddo
         open(unit1,file='p-ini-char-apspec.dat',status='unknown')
         open(unit2,file='p_ini_char_aspec_nohead.dat',status='unknown')
         write(unit1,*)'Rows = pwaves. Columns = np'
         write(unit1,*)'pwaves found in pwaves-check.dat'
         write(unit1,*)'col_1 to col_<npmax>'
         write(unit1,*)'is absorption aphy_chl (m-2 mg chla-1)'
         write(unit1,130)outfile
         write(unit2,130)outfile
c make sure outfile is defined above with the correct size
         close(unit1)
         close(unit2)

c file for absorption spectra of PS's only
c rows = pwaves, columns = np
          do np=1,npmax
           do ilam=1,tlam
             outfile_ps(np,ilam) = aphy_chl_ps(np,ilam)
           enddo
          enddo
         open(unit1,file='p-ini-char-apspec-psc.dat',status='unknown')
         open(unit2,file='p_ini_char_aspec_psc_nohead.dat',
     &        status='unknown')
         write(unit1,*)'Rows = pwaves. Columns = np'
         write(unit1,*)'pwaves found in pwaves-check.dat'
         write(unit1,*)'Is absoprtion by photosynthetic'
         write(unit1,*)'pigments only aphy_chl_ps (m-2 mg chla-1)'
         write(unit1,130)outfile_ps
         write(unit2,130)outfile_ps
         close(unit1)
         close(unit2)
130      format(<npmax>f10.4)


c file for wavebands used
         open(unit1,file='pwaves-check.dat',status='unknown')
         write(unit1,140)pwaves
         close(unit1) 
140      format(i5)


#endif

         return
         end
