C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/gchem/Attic/gchem_forcing_sep.F,v 1.1 2008/01/11 21:28:02 jahn Exp $
C $Name:  $

#include "GCHEM_OPTIONS.h"

CBOP
C !ROUTINE: GCHEM_FORCING_SEP
C !INTERFACE: ==========================================================
      SUBROUTINE GCHEM_FORCING_SEP(myTime,myIter, myThid )

C !DESCRIPTION:
C     calls subroutine that will update passive tracers values
C     with a separate timestep. Since GCHEM_FORCING_SEP is now
C     called before DO_FIELDS_BLOCKING_EXCHANGES, the passive 
C     tracer values in the halo regions are not up to date and 
C     must not be used.

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS.h"
#ifdef ALLOW_DIC
#include "DIC_BIOTIC.h"
#include "DIC_ABIOTIC.h"
#endif /* ALLOW_DIC */

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid, myIter
      _RL myTime

c!LOCAL VARIABLES: ====================================================
C  i,j                  :: loop indices
C  bi,bj                :: tile indices
C  k                    :: vertical level
      INTEGER bi,bj,imin,imax,jmin,jmax
      INTEGER i,j
      INTEGER niter
CEOP

#ifdef ALLOW_GCHEM
#ifdef GCHEM_SEPARATE_FORCING

ccccccccccccccccccccccccc
c global calculations   c
ccccccccccccccccccccccccc
#ifdef ALLOW_DIC
#ifdef ALLOW_OLD_VIRTUALFLUX
c find global surface averages
       gsm_s = 0.
       gsm_dic = 0.
       gsm_alk = 0.
       call tracer_meanarea(myThid,salt, 1,gsm_s)
       call tracer_meanarea(myThid,
     &               ptracer(1-Olx,1-Oly,1,1,1,1), 1, gsm_dic)
       print*,'mean surface dic', gsm_dic,gsm_s
       call tracer_meanarea(myThid,
     &               ptracer(1-Olx,1-Oly,1,1,1,2), 1, gsm_alk)

#endif /* ALLOW_OLD_VIRTUALFLUX */
#endif

#ifdef ALLOW_NPZDCAR
#ifdef ALLOW_OLD_VIRTUALFLUX
c find global surface averages
       call NPZDCAR_AREAMEANS(myTime,myIter, myThid )
#endif /* ALLOW_OLD_VIRTUALFLUX */
#endif
ccccccccccccccccccccccccccccccccccccccccccc


ccccccccccccccccccccccccc
c chemical forcing      c
ccccccccccccccccccccccccc
C$taf loop = parallel
       DO bj=myByLo(myThid),myByHi(myThid)
C$taf loop = parallel
        DO bi=myBxLo(myThid),myBxHi(myThid)

        jMin=1
        jMax=sNy
        iMin=1
        iMax=sNx
c
ccccccccccccccccccccccccccc DIC cccccccccccccccccccccccccccccccc
c
#ifdef ALLOW_DIC
#ifdef ALLOW_FE
          call DIC_BIOTIC_Forcing( Ptracer(1-Olx,1-Oly,1,bi,bj,1),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,2),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,3),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,4),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,5),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,6),
     &                          bi,bj,imin,imax,jmin,jmax,
     &                          myIter,myTime,myThid)
#else
#ifdef ALLOW_O2
          call DIC_BIOTIC_Forcing( Ptracer(1-Olx,1-Oly,1,bi,bj,1),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,2),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,3),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,4),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,5),
     &                          bi,bj,imin,imax,jmin,jmax,
     &                          myIter,myTime,myThid)
#else
          call DIC_BIOTIC_Forcing( Ptracer(1-Olx,1-Oly,1,bi,bj,1),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,2),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,3),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,4),
     &                          bi,bj,imin,imax,jmin,jmax,
     &                          myIter,myTime,myThid)
#endif
#endif
#endif
cccccccccccccccccccccccccc END DIC cccccccccccccccccccccccccccccccccc
#ifdef ALLOW_DARWIN
#ifdef NUT_SUPPLY
c articficial supply of nutrients
          call DARWIN_Nut_Supply( Ptracer(1-Olx,1-Oly,1,bi,bj,1),
     &                          bi,bj,imin,imax,jmin,jmax,
     &                          myIter,myTime,myThid)
          call DARWIN_Nut_Supply( Ptracer(1-Olx,1-Oly,1,bi,bj,2),
     &                          bi,bj,imin,imax,jmin,jmax,
     &                          myIter,myTime,myThid)
          call DARWIN_Nut_Supply( Ptracer(1-Olx,1-Oly,1,bi,bj,3),
     &                          bi,bj,imin,imax,jmin,jmax,
     &                          myIter,myTime,myThid)
          call DARWIN_Nut_Supply( Ptracer(1-Olx,1-Oly,1,bi,bj,4),
     &                          bi,bj,imin,imax,jmin,jmax,
     &                          myIter,myTime,myThid)
#endif
ccccccccccccccc
          call DARWIN_cons(myIter,myTime,myThid)
          call DARWIN_Forcing(  Ptracer(1-Olx,1-Oly,1,bi,bj,1),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,2),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,3),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,4),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,5),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,6),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,7),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,8),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,9),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,10),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,11),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,12),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,13),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,14),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,15),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,16),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,17),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,18),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,19),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,20),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,21),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,22),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,23),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,24),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,25),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,26),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,27),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,28),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,29),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,30),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,31),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,32),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,33),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,34),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,35),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,36),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,37),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,38),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,39),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,40),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,41),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,42),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,43),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,44),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,45),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,46),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,47),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,48),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,49),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,50),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,51),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,52),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,53),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,54),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,55),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,56),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,57),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,58),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,59),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,60),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,61),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,62),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,63),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,64),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,65),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,66),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,67),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,68),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,69),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,70),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,71),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,72),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,73),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,74),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,75),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,76),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,77),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,78),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,79),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,80),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,81),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,82),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,83),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,84),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,85),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,86),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,87),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,88),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,89),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,90),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,91),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,92),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,93),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,94),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,95),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,96),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,97),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,98),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,99),
     &                          bi,bj,imin,imax,jmin,jmax,
     &                          myIter,myTime,myThid)
          call DARWIN_cons(myIter,myTime,myThid)
#endif

#ifdef ALLOW_NPZDCAR
          call NPZDCAR_Forcing( Ptracer(1-Olx,1-Oly,1,bi,bj,1),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,2),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,3),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,4),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,5),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,6),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,7),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,8),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,9),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,10),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,11),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,12),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,13),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,14),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,15),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,16),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,17),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,18),
     &                          Ptracer(1-Olx,1-Oly,1,bi,bj,19),
     &                          bi,bj,imin,imax,jmin,jmax,
     &                          myIter,myTime,myThid)
#endif
c
        ENDDO
       ENDDO

#endif /* GCHEM_SEPARATE_FORCING */
#endif /* ALLOW_GCHEM */

      RETURN
      END
