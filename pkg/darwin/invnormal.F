C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/invnormal.F,v 1.2 2007/12/11 21:33:24 jahn Exp $
C $Name:  $

c Inverse normal distribution 
c returns inverse normal cumulative distribution 
c from p:[0,1] -> y:[-inf,+inf] centered on mu with stdev of sigma
c p is RandNo passed in, y is return variable for deviate
c
c  Scott Grant, Spring 2006

         SUBROUTINE invnormal(y,p,mean,sigma)
         implicit none

c local variables
         real*8 mean
         real*8 sigma
         real*8 q
         real*8 r
         real*8 x
         real*8 p
         real*8 plow
         real*8 phigh
         real*8 y
         real*8 a(6)
         real*8 b(5)
         real*8 c(6)
         real*8 d(4)

         
c Create random variable from -inf to +inf 
c Coefficients in rational approximations.
         a(1) = -3.969683028665376d+01
         a(2) =  2.209460984245205d+02
         a(3) = -2.759285104469687d+02
         a(4) =  1.383577518672690d+02
         a(5) = -3.066479806614716d+01
         a(6) =  2.506628277459239d+00
         
         b(1) = -5.447609879822406d+01
         b(2) =  1.615858368580409d+02
         b(3) = -1.556989798598866d+02
         b(4) =  6.680131188771972d+01
         b(5) = -1.328068155288572d+01

         c(1) = -7.784894002430293d-03
         c(2) = -3.223964580411365d-01
         c(3) = -2.400758277161838d+00
         c(4) = -2.549732539343734d+00
         c(5) =  4.374664141464968d+00
         c(6) =  2.938163982698783d+00

         d(1) =  7.784695709041462d-03
         d(2) =  3.224671290700398d-01
         d(3) =  2.445134137142996d+00
         d(4) =  3.754408661907416d+00

c  Define break-points.

         plow  = 0.02425d0
         phigh = 1.d0 - plow

c  Rational approximation for lower region.

         if ((0 .lt. p) .and. (p .lt. plow))then
            q = sqrt(-2.0d0*log(p))
            x = (((((c(1)*q+c(2))*q+c(3))*q+c(4))*q+c(5))*q+c(6)) /
     &      ((((d(1)*q+d(2))*q+d(3))*q+d(4))*q+1.d0)
         endif

c  Rational approximation for central region.

         if ((plow .le. p).and.(p .le. phigh))then
            q = p - 0.5d0
            r = q*q
            x = (((((a(1)*r+a(2))*r+a(3))*r+a(4))*r+a(5))*r+a(6))*q /
     &     (((((b(1)*r+b(2))*r+b(3))*r+b(4))*r+b(5))*r+1.d0)
         endif

c  Rational approximation for upper region.

         if ((phigh .lt. p).and.(p .lt. 1))then
            q = sqrt(-2.0d0*log(1-p))
            x = -(((((c(1)*q+c(2))*q+c(3))*q+c(4))*q+c(5))*q+c(6)) /
     &      ((((d(1)*q+d(2))*q+d(3))*q+d(4))*q+1.d0)
         endif 

c Normal Deviate about mean
c        write(6,*)'DEVIATE',x
         y = sigma*sqrt(2.0d0)*x + mean      
c        write(6,*)'Normal PDF Value INSIDE:',y
c        write(6,*)'MEAN:',mean
c        write(6,*)'SIGMA:',sigma


         return
         end
