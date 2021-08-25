#ifdef ALLOW_DARWIN

CBOP
C    !ROUTINE: DARWIN_DIAGS.h
C    !INTERFACE:
C #include DARWIN_DIAGS.h

C    !DESCRIPTION:
C Contains indices into diagnostics array

      integer iPP
      integer iNfix
      integer iDenit
      integer iDenitN
      integer iPPplank
      integer iPCplank
      integer iGRplank
      integer iGrGn
      integer iConsDIN
      integer iConsPO4
      integer iConsSi
      integer iConsFe
      integer darwin_nDiag
      PARAMETER(iPP=     1)
      PARAMETER(iNfix=   2)
      PARAMETER(iDenit=  3)
      PARAMETER(iDenitN= 4)
      PARAMETER(iConsPO4=5)
      PARAMETER(iConsSi= 6)
      PARAMETER(iConsFe= 7)
      PARAMETER(iConsDIN=8)
      PARAMETER(iPPplank=9)
#ifdef DARWIN_DIAG_PERTYPE
      PARAMETER(iPCplank=iPPplank+nplank)
      PARAMETER(iGRplank=iPCplank+nplank)
      PARAMETER(iGrGn=iGRplank+nplank)
      PARAMETER(darwin_nDiag=iGrGn+nplank-1)
#else
      PARAMETER(iPCplank=iPPplank)
      PARAMETER(iGRplank=iPCplank)
      PARAMETER(iGrGn=iGRplank)
      PARAMETER(darwin_nDiag=iGrGn-1)
#endif

CEOP
#endif /* ALLOW_DARWIN */
