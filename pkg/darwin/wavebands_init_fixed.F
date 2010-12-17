C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/wavebands_init_fixed.F,v 1.19 2010/12/17 22:20:23 jahn Exp $
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
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN.h"
#ifdef WAVEBANDS
#include "WAVEBANDS_PARAMS.h"
#endif
#include "DARWIN_IO.h"

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C     myThid     :: my Thread Id number
      integer myThid      
CEOP

#ifdef WAVEBANDS

C     !LOCAL VARIABLES:
C     == Local variables ==
c local variables      
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      character*80 title
      integer iUnit
      integer swlambda,splambda,ssflambda
      _RL sap,sap_ps,sbp,sbbp
      _RL saw,sbw
      _RL ssf
c      _RL planck, c, hc, oavo, hcoavo, rlamm
#ifdef DAR_CALC_ACDOM
      _RL rlam450,rlam
#else
      _RL sacdom
#endif
c local indeces
      integer nabp,i,ilam

C band widths used to convert OASIM data to irradiation per nm
C put boundaries half-way between central values
C but first and last boundary are at first and last "central" value
      wb_width(1) = .5*(pwaves(2)-pwaves(1))
      do i=2,tlam-1
        wb_width(i) = .5*(pwaves(i+1)-pwaves(i-1))
      enddo
      wb_width(tlam) = .5*(pwaves(tlam)-pwaves(tlam-1))
      wb_totalWidth = 0.0
      do i=1,tlam
        wb_totalWidth = wb_totalWidth + wb_width(i)
      enddo
      if (wb_totalWidth.LE.0) then
        WRITE(msgBuf,'(2A)') 'WAVEBANDS_INIT_FIXED: ',
     &  'please provide wavelengths in darwin_waves.'
        CALL PRINT_ERROR( msgBuf, myThid )
        STOP 'ABNORMAL END: S/R WAVEBANDS_INIT_FIXED'
      endif


c  Water data files
      if (darwin_waterabsorbFile .NE. ' '  ) THEN
        CALL MDSFINDUNIT( iUnit, myThid )
        open(iUnit,file=darwin_waterabsorbFile,
     &                           status='old',form='formatted')  
        do i = 1,6                 ! six lines of text for the header
         read(iUnit,'(a50)')title     ! trucates or pads (with spaces) to 50 characters length
        enddo
        do ilam = 1,tlam           
         read(iUnit,20)swlambda,saw,sbw
         if (swlambda.NE.pwaves(ilam)) then
           WRITE(msgBuf,'(2A)') 'WAVEBANDS_INIT_FIXED: ',
     &     "wavelength for water spectrum doesn't match darwin_waves:"
           CALL PRINT_ERROR( msgBuf, myThid )
           WRITE(msgBuf,'(2A,I3,A,I4,A,F4.0)') 'WAVEBANDS_INIT_FIXED: ',
     &     'ilam', ilam, ': ', swlambda, ' versus ', pwaves(ilam)
           CALL PRINT_ERROR( msgBuf, myThid )
           STOP 'ABNORMAL END: S/R WAVEBANDS_INIT_FIXED'
         endif
         aw(ilam) = saw
         bw(ilam) = sbw
        enddo
        close(iUnit)
20      format(i5,f15.4,f10.4)
      else
        WRITE(msgBuf,'(A)')
     &      'WAVEBANDS_INIT_FIXED: need to specify water absorption'
        CALL PRINT_ERROR( msgBuf, myThid )
        STOP 'ABNORMAL END: S/R WAVEBANDS_INIT_FIXED'
      endif
      

c phyto data files
c ANNA phyto input data files must have a column for absorption by PS pigs
c ANNA easiest way to 'turn off' PS for growth is to put same values in both abs columns
      if (darwin_phytoabsorbFile.NE. ' '  ) THEN
        CALL MDSFINDUNIT( iUnit, myThid )
        open(iUnit,file=darwin_phytoabsorbFile,
     &                                   status='old',form='formatted')
        do i = 1,6               ! six lines of text for the header
         read(iUnit,'(a50)')title
        enddo        
        sbbp = 0. _d 0
        do nabp = 1,tnabp        
         read(iUnit,'(a50)')title   ! reads one line of text for the phytoplankton type header
         do ilam  = 1,tlam         
#ifdef DAR_NONSPECTRAL_BACKSCATTERING_RATIO
          read(iUnit,30)splambda,sap,sap_ps,sbp
#else
          read(iUnit,'(i4,3f10.0,f20.0)')splambda,sap,sap_ps,sbp,sbbp
#endif
          if (splambda.NE.pwaves(ilam)) then
           WRITE(msgBuf,'(2A)') 'WAVEBANDS_INIT_FIXED: ',
     &     "wavelength for phyto spectrum doesn't match darwin_waves:"
           CALL PRINT_ERROR( msgBuf, myThid )
           WRITE(msgBuf,'(2A,I3,A,I4,A,F4.0)') 'WAVEBANDS_INIT_FIXED: ',
     &     'ilam', ilam, ': ', splambda, ' versus ', pwaves(ilam)
           CALL PRINT_ERROR( msgBuf, myThid )
           STOP 'ABNORMAL END: S/R WAVEBANDS_INIT_FIXED'
          endif
          ap(nabp,ilam) = sap
          ap_ps(nabp,ilam) = sap_ps
          bp(nabp,ilam) = sbp
          bbp(nabp,ilam) = sbbp
         enddo
        enddo
        close(iUnit)
30      format(i4,3f10.4)
      else
        WRITE(msgBuf,'(A)')
     &      'WAVEBANDS_INIT_FIXED: need to specify phyto absorption'
        CALL PRINT_ERROR( msgBuf, myThid )
        STOP 'ABNORMAL END: S/R WAVEBANDS_INIT_FIXED'
      endif


#ifndef OASIM
c QQ NEED IN HERE ifndef OASIM
c surface spectrum for initial use
      if (darwin_surfacespecFile .NE. ' '  ) THEN
       CALL MDSFINDUNIT( iUnit, myThid )
       open(iUnit,file=darwin_surfacespecFile,
     &                             status='old',form='formatted')
       do i = 1,3             ! three lines of text for the header
        read(iUnit,'(a50)')title
       enddo
       do ilam = 1,tlam
        read(iUnit,40)ssflambda,ssf
        if (ssflambda.NE.pwaves(ilam)) then
           WRITE(msgBuf,'(2A)') 'WAVEBANDS_INIT_FIXED: ',
     &     "wavelength for surface spectrum doesn't match darwin_waves:"
           CALL PRINT_ERROR( msgBuf, myThid )
           WRITE(msgBuf,'(2A,I3,A,I4,A,F4.0)') 'WAVEBANDS_INIT_FIXED: ',
     &     'ilam', ilam, ': ', ssflambda, ' versus ', pwaves(ilam)
           CALL PRINT_ERROR( msgBuf, myThid )
           STOP 'ABNORMAL END: S/R WAVEBANDS_INIT_FIXED'
        endif
        sf(ilam) = ssf
       enddo
       close(iUnit)
40     format(i5,f15.6)  
      else
        WRITE(msgBuf,'(A)')
     &      'WAVEBANDS_INIT_FIXED: need surface spectrum'
        CALL PRINT_ERROR( msgBuf, myThid )
        STOP 'ABNORMAL END: S/R WAVEBANDS_INIT_FIXED'
      endif
#endif /* not OASIM */


c absorption by cdom
#ifndef DAR_CALC_ACDOM
c if no file given then CDOM is zero
      if (darwin_acdomFile.NE. ' '  ) THEN
        CALL MDSFINDUNIT( iUnit, myThid )
        open(iUnit,file=darwin_acdomFile,
     &                        status='old',form='formatted')
        do i = 1,6            ! six lines of text for the header
         read(iUnit,'(a50)')title
        enddo
        do i = 1,tlam
         read(iUnit,50)sacdom
         acdom(i) = sacdom
        enddo
        close(iUnit)
50      format(f10.4)
      else
        WRITE(msgBuf,'(A)')
     &      'WAVEBANDS_INIT_FIXED: no aCDOM'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, 1 )

        do i = 1,tlam
         acdom(i) = 0. _d 0
        enddo
      endif
#else /* DAR_CALC_ACDOM */
c for 3-D or for direct comparison to RADTRANS would need the same formulation for CDOM as in radtrans.
c   CDOM absorption exponent
      rlam450 = 450.0 _d 0
      do ilam = 1,tlam
       if (pwaves(ilam) .eq. 450) nl450 = ilam
       rlam = float(pwaves(ilam))
       excdom(ilam) = exp(-darwin_Sdom*(rlam-rlam450))
      enddo

      WRITE(msgBuf,'(A,1P1E20.12)')
     &      'WAVEBANDS_INIT_FIXED: darwin_Sdom = ', darwin_Sdom
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      WRITE(msgBuf,'(A,I3)')
     &      'WAVEBANDS_INIT_FIXED: nl450 = ', nl450
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
#endif /* DAR_CALC_ACDOM */

#ifdef DAR_DIAG_ACDOM
c     find waveband index for acdom diagnostic
      if (darwin_diag_acdom_ilam.GE.100) then
       do ilam = 1,tlam
        if (pwaves(ilam) .eq. darwin_diag_acdom_ilam) then
          darwin_diag_acdom_ilam = ilam
          goto 60
        endif
       enddo
60     continue
      endif

      WRITE(msgBuf,'(A,I3,A,I4)')
     &      'WAVEBANDS_INIT_FIXED: aCDOM diag ilam = ',
     &      darwin_diag_acdom_ilam, ', lambda = ',
     &      pwaves(darwin_diag_acdom_ilam)
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
#endif

#ifdef DAR_RADTRANS
c  absorption and scattering by particles
      if (darwin_particleabsorbFile .NE. ' '  ) THEN
        CALL MDSFINDUNIT( iUnit, myThid )
        open(iUnit,file=darwin_particleabsorbFile,
     &                           status='old',form='formatted')  
        do i = 1,6                 ! six lines of text for the header
         read(iUnit,'(a50)')title     ! trucates or pads (with spaces) to 50 characters length  
        enddo
        do ilam = 1,tlam           
         read(iUnit,'(I4,3F15.0)')splambda,sap,sbp,sbbp  
         if (splambda.NE.pwaves(ilam)) then
           WRITE(msgBuf,'(2A)') 'WAVEBANDS_INIT_FIXED: ',
     &    "wavelength for particle spectrum doesn't match darwin_waves:"
           CALL PRINT_ERROR( msgBuf, myThid )
           WRITE(msgBuf,'(2A,I3,A,I4,A,F4.0)') 'WAVEBANDS_INIT_FIXED: ',
     &     'ilam', ilam, ': ', splambda, ' versus ', pwaves(ilam)
           CALL PRINT_ERROR( msgBuf, myThid )
           STOP 'ABNORMAL END: S/R WAVEBANDS_INIT_FIXED'
         endif
         apart(ilam) = sap
         bpart(ilam) = sbp
         bbpart(ilam) = sbbp
         apart_P(ilam) = sap/darwin_part_size_P
         bpart_P(ilam) = sbp/darwin_part_size_P
         bbpart_P(ilam) = sbbp/darwin_part_size_P
        enddo
        close(iUnit)
      else
        do ilam = 1,tlam           
         apart(ilam) = 0. _d 0
         bpart(ilam) = 0. _d 0
         bbpart(ilam) = 0. _d 0
         apart_P(ilam) = 0. _d 0
         bpart_P(ilam) = 0. _d 0
         bbpart_P(ilam) = 0. _d 0
        enddo
      endif

c     print a summary
      WRITE(msgBuf,'(A)') 'WAVEBANDS_INIT_FIXED: waveband widths:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      WRITE(msgBuf,'(A,A)') 'WAVEBANDS_INIT_FIXED: ',
     &     ' lam width'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      do ilam = 1,tlam           
        WRITE(msgBuf,'(A,I4,F15.6)') 'WAVEBANDS_INIT_FIXED: ',
     &     pwaves(ilam), wb_width(ilam)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, 1 )
      enddo
      WRITE(msgBuf,'(A)') 'WAVEBANDS_INIT_FIXED:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
c
#ifndef OASIM
      WRITE(msgBuf,'(A)') 'WAVEBANDS_INIT_FIXED: surface spectrum:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      WRITE(msgBuf,'(A,A)') 'WAVEBANDS_INIT_FIXED: ',
     &     ' lam sf'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      do ilam = 1,tlam           
        WRITE(msgBuf,'(A,I4,F15.6)') 'WAVEBANDS_INIT_FIXED: ',
     &     pwaves(ilam), sf(ilam)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, 1 )
      enddo
      WRITE(msgBuf,'(A)') 'WAVEBANDS_INIT_FIXED:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
#endif
c
      WRITE(msgBuf,'(A)') 'WAVEBANDS_INIT_FIXED: water spectra:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      WRITE(msgBuf,'(A,A)') 'WAVEBANDS_INIT_FIXED: ',
     &     ' lam aw             bw'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      do ilam = 1,tlam           
        WRITE(msgBuf,'(A,I4,F15.4,F10.4)') 'WAVEBANDS_INIT_FIXED: ',
     &     pwaves(ilam), aw(ilam), bw(ilam)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, 1 )
      enddo
      WRITE(msgBuf,'(A)') 'WAVEBANDS_INIT_FIXED:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
c
      WRITE(msgBuf,'(A)') 'WAVEBANDS_INIT_FIXED: phyto spectra:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      do nabp = 1,tnabp        
        WRITE(msgBuf,'(A,I4)') 'WAVEBANDS_INIT_FIXED: type ',nabp
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
        WRITE(msgBuf,'(A,A)') 'WAVEBANDS_INIT_FIXED: ',
     &     ' lam ap        ap_ps     bp        bbp'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
        do ilam = 1,tlam           
          WRITE(msgBuf,'(A,I4,3F10.4,F20.9)') 'WAVEBANDS_INIT_FIXED: ',
     &     pwaves(ilam), ap(nabp,ilam), ap_ps(nabp,ilam),
     &     bp(nabp,ilam), bbp(nabp,ilam)
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, 1 )
        enddo
        WRITE(msgBuf,'(A)') 'WAVEBANDS_INIT_FIXED:'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      enddo
c
      WRITE(msgBuf,'(A)') 'WAVEBANDS_INIT_FIXED: particulate spectra:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      WRITE(msgBuf,'(A,A)') 'WAVEBANDS_INIT_FIXED: ',
     &     ' lam apart          bpart          bbpart'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      do ilam = 1,tlam           
        WRITE(msgBuf,'(A,I4,1P3G15.6)')'WAVEBANDS_INIT_FIXED: ',
     &     pwaves(ilam), apart(ilam), bpart(ilam), bbpart(ilam)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, 1 )
      enddo
      WRITE(msgBuf,'(A)') 'WAVEBANDS_INIT_FIXED:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
c
      WRITE(msgBuf,'(2A)') 'WAVEBANDS_INIT_FIXED: particulate spectra ',
     &                    'in phosphorus units:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      WRITE(msgBuf,'(A,A)') 'WAVEBANDS_INIT_FIXED: ',
     &     ' lam apart_P        bpart_P        bbpart_P'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      do ilam = 1,tlam           
        WRITE(msgBuf,'(A,I4,2F15.9,F15.12)') 'WAVEBANDS_INIT_FIXED: ',
     &     pwaves(ilam), apart_P(ilam), bpart_P(ilam), bbpart_P(ilam)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, 1 )
      enddo
      WRITE(msgBuf,'(A)') 'WAVEBANDS_INIT_FIXED:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
c
#ifndef DAR_CALC_ACDOM
      WRITE(msgBuf,'(A)') 'WAVEBANDS_INIT_FIXED: CDOM spectrum:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      WRITE(msgBuf,'(A,A)') 'WAVEBANDS_INIT_FIXED: ',
     &     ' lam aCDOM'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      do ilam = 1,tlam           
        WRITE(msgBuf,'(A,I4,F10.4)') 'WAVEBANDS_INIT_FIXED: ',
     &     pwaves(ilam), acdom(ilam)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, 1 )
      enddo
      WRITE(msgBuf,'(A)') 'WAVEBANDS_INIT_FIXED:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
#endif

c     constants
      pid = DACOS(-1.0D0)
      rad = 180.0D0/pid
#endif

#endif /* WAVEBANDS */

      return
      end

