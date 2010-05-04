C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/wavebands_init_fixed.F,v 1.5 2010/05/04 16:00:10 stephd Exp $
C $Name:  $

c ANNA wavebands_init_fixed.F reads-in and assigns input paramters for WAVEBANDS. 

#include "DARWIN_OPTIONS.h"

CBOP
C     !ROUTINE: WAVEBANDS_INIT_FIXED
C     !INTERFACE:
       subroutine wavebands_init_fixed(myThid)

C     !DESCRIPTION: \bv
C     *==========================================================*
C     | SUBROUTINE WAVEBANDS_INIT_FIXED
C     | o reads-in and assigns input paramters for WAVEBANDS.
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
c local variables      
      character*80 title
      integer pwaves_all(tnabp,tlam)
      integer wwaves(tlam),sfwaves(tlam)
      integer swlambda,splambda,ssflambda,splambda_ps
      real sap,sap_ps,sbp
      real saw,sbw 
      real ssf
      real sacdom      
c local indeces
      integer nabp,i,ilam


c  Water data files
      open(14,file="abw_13wg.dat",status='old',form='formatted')  
      do i = 1,6                 ! six lines of text for the header
       read(14,'(a50)')title     ! trucates or pads (with spaces) to 50 characters length  
      enddo
      do ilam = 1,tlam           
       read(14,20)swlambda,saw,sbw  
       wwaves(ilam) = swlambda   
       aw(ilam) = saw
       bw(ilam) = sbw
      enddo
      close(14)
20    format(i5,f15.4,f10.4)

c phyto data files
c ANNA phyto input data files must have a column for absorption by PS pigs
c ANNA easiest way to 'turn off' PS for growth is to put same values in both abs columns
      open(16,file="a1_psc_13.dat",status='old',form='formatted')
      do i = 1,6               ! six lines of text for the header
       read(16,'(a50)')title    
      enddo        
      do nabp = 1,tnabp        
       read(16,'(a50)')title   ! reads one line of text for the phytoplankton type header
       do i  = 1,tlam         
        read(16,30)splambda,sap,sap_ps,sbp
        pwaves_all(nabp,i) = splambda 
        ap(nabp,i) = sap
        ap_ps(nabp,i) = sap_ps
        bp(nabp,i) = sbp
      enddo
      enddo
      close(16)
30    format(i4,3f10.4)
      
      do i=1,tlam
        pwaves(i) = pwaves_all(1,i)
      enddo

c surface spectrum for initial use
      open(18,file="surfspec_13amt6.dat",status='old',form='formatted')
      do i = 1,3             ! three lines of text for the header
       read(18,'(a50)')title 
      enddo
      do i = 1,tlam
       read(18,40)ssflambda,ssf
       sfwaves(i) = ssflambda
       sf(i) = ssf
      enddo
      close(18)
40    format(i5,f15.6)  


c absorption by cdom
c ANNA CDOM must have a file
c ANNA easiest way to 'turn off' CDOM is to set all values to zero (use CDOM_ZERO_13.dat)
      open(19,file="aCDOM13amtVK2006.dat",status='old',form='formatted')
      do i = 1,6            ! six lines of text for the header
       read(19,'(a50)')title
      enddo
      do i = 1,tlam
       read(19,50)sacdom
       acdom(i) = sacdom
      enddo
      close(19)
50    format(f10.4)


#endif

      return
      end


