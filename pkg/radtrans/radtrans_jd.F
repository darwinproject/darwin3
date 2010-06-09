      function radtrans_jd(i,j,k)
c
c
c    This function converts a calendar date to the corresponding Julian
c    day starting at noon on the calendar date.  The algorithm used is
c    from Van Flandern and Pulkkinen, Ap. J. Supplement Series 41, 
c    November 1979, p. 400.
c
c
c	Arguments
c     
c     	Name    Type 	I/O 	Description
c     	----	---- 	--- 	-----------
c     	i	I*4  	 I 	Year - e.g. 1970
c     	j       I*4  	 I  	Month - (1-12)
c     	k       I*4  	 I  	Day  - (1-31)
c     	jd      I*4  	 O  	Julian day
c
c     external references
c     -------------------
c      none
c
c
c     Written by Frederick S. Patt, GSC, November 4, 1992
c
c
      INTEGER radtrans_jd,i,j,k

      radtrans_jd = 367*i - 7*(i+(j+9)/12)/4 + 275*j/9 + k + 1721014

c  This additional calculation is needed only for dates outside of the 
c   period March 1, 1900 to February 28, 2100
c     	radtrans_jd = radtrans_jd + 15 - 3*((i+(j-9)/7)/100+1)/4

      return
      end
