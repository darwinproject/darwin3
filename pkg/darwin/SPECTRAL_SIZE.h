C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/SPECTRAL_SIZE.h,v 1.1 2011/04/12 19:25:09 jahn Exp $
C $Name:  $

c SPECTRAL_SIZE.h 
c description: Size specification for spectral quantities
c
c tlam = number of wavebands
c        must match number of wavebands in input datafiles
c        must be the same for all data types (water, phyto, CDOM, surface spectra)

         INTEGER tlam
         PARAMETER (tlam=13)

