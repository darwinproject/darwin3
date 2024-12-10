#ifdef ALLOW_RADTRANS

CBOP
C    !ROUTINE: RADTRANS_SIZE.h
C    !INTERFACE:
C #include RADTRANS_SIZE.h

C    !DESCRIPTION:
C Contains dimensions and index ranges for radtrans model.
C
C  nlam :: number of wavebands

      integer nlam
      parameter(nlam=1)

CEOP
#endif /* ALLOW_RADTRANS */
