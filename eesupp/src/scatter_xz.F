#include "CPP_EEOPTIONS.h"

      SUBROUTINE SCATTER_XZ( global, local, myThid )
C     Scatter elements of a x-z array from mpi process 0 to all processes.
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
C     mythid - thread number for this instance of the routine.
C     global,local - working arrays used to transfer 2-D fields
      INTEGER mythid
      Real*8  global(Nx)
      _RL     local(1-OLx:sNx+OLx,nSx,nSy)

      INTEGER iG, i, bi, bj
#ifdef ALLOW_USE_MPI

      _RL     temp(1-OLx:sNx+OLx,nSx,nSy)

      INTEGER istatus(MPI_STATUS_SIZE), ierr
      INTEGER isource, itag, npe
      INTEGER lbuff
#endif /* ALLOW_USE_MPI */

C--   Make everyone wait except for master thread.
      _BARRIER
      _BEGIN_MASTER( myThid )

#ifndef ALLOW_USE_MPI

      DO bj=1,nSy
         DO bi=1,nSx
               DO i=1,sNx
                  iG = myXGlobalLo-1+(bi-1)*sNx+i
                  local(i,bi,bj) = global(iG)
               ENDDO
         ENDDO
      ENDDO

#else /* ALLOW_USE_MPI */

      lbuff=(sNx+2*OLx)*nSx*nSy
      isource = 0
      itag = 0

      IF( mpiMyId .EQ. 0 ) THEN

C--   Process 0 fills-in its local data
         npe = 0
         DO bj=1,nSy
            DO bi=1,nSx
                  DO i=1,sNx
                     iG = mpi_myXGlobalLo(npe+1)-1+(bi-1)*sNx+i
                     local(i,bi,bj) = global(iG)
                  ENDDO
            ENDDO
         ENDDO

C--   Process 0 sends local arrays to all other processes
         DO npe = 1, numberOfProcs-1
            DO bj=1,nSy
               DO bi=1,nSx
                     DO i=1,sNx
                        iG = mpi_myXGlobalLo(npe+1)-1+(bi-1)*sNx+i
                        temp(i,bi,bj) = global(iG)
                     ENDDO
               ENDDO
            ENDDO
            CALL MPI_SEND (temp, lbuff, MPI_DOUBLE_PRECISION,
     &           npe, itag, MPI_COMM_MODEL, ierr)
         ENDDO

      ELSE

C--   All proceses except 0 receive local array from process 0
         CALL MPI_RECV (local, lbuff, MPI_DOUBLE_PRECISION,
     &        isource, itag, MPI_COMM_MODEL, istatus, ierr)

      ENDIF

#endif /* ALLOW_USE_MPI */

      _END_MASTER( myThid )
      _BARRIER

C--   Fill in edges.
CMM      _EXCH_XY_RL( local, myThid )

      RETURN
      END
