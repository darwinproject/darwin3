#include "MDSIO_OPTIONS.h"

      SUBROUTINE MDS_SEG4toRL( j,bi,bj,k,nNz, seg, copyTo, arr )

C IN:
C     j,bi,bj,k  integer :: indices to array "arr"
C     nNz        integer :: K dimension of array "arr"
C     seg        Real*4  :: 1-D vector of length sNx
C OUT:
C     arr         _RL    :: model tiled array
C
C Created: 03/20/99 adcroft@mit.edu

      IMPLICIT NONE
C Global variables / common blocks
#include "SIZE.h"

C Arguments
      INTEGER j,bi,bj,k,nNz
      _RL arr(1-oLx:sNx+oLx,1-oLy:sNy+oLy,nNz,nSx,nSy)
      LOGICAL copyTo
      Real*4 seg(sNx)
C Local
      INTEGER ii
C     ------------------------------------------------------------------
      IF (copyTo) THEN
       DO ii=1,sNx
        arr(ii,j,k,bi,bj)=seg(ii)
       ENDDO
      ELSE
       DO ii=1,sNx
        seg(ii)=arr(ii,j,k,bi,bj)
       ENDDO
      ENDIF
C     ------------------------------------------------------------------
      RETURN
      END
