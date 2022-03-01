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
      integer iPCplank
      integer iConsPO4
      integer iConsSi
      integer iConsFe
      integer iConsDIN
      integer iConsNO3
      integer iConsNO2
      integer iConsNH4
      integer iConsDIC
      integer iConsDIC_PIC
      integer iRespirDIC
      integer iReminDIC_DOC
      integer iReminDIC_POC
      integer iDisscDIC_PIC
      integer iConsALK
      integer iConsO2
      integer iPPplank
      integer iGRplank
      integer iGrGn
      integer iGrGC
      integer iHPplank
      integer iHCplank
      integer darwin_nDiag

      PARAMETER(iPP=     1)
      PARAMETER(iNfix=   2)
      PARAMETER(iDenit=  3)
      PARAMETER(iDenitN= 4)
      PARAMETER(iConsPO4=5)
      PARAMETER(iConsSi= 6)
      PARAMETER(iConsFe= 7)
      PARAMETER(iConsDIN=8)
      PARAMETER(iConsNO3=9)
      PARAMETER(iConsNO2=10)
      PARAMETER(iConsNH4=11)
      PARAMETER(iConsDIC=12)
      PARAMETER(iConsDIC_PIC=13)
      PARAMETER(iRespirDIC=14)
      PARAMETER(iReminDIC_DOC=15)
      PARAMETER(iReminDIC_POC=16)
      PARAMETER(iDisscDIC_PIC=17)
      PARAMETER(iConsALK=18)
      PARAMETER(iConsO2=19)
      PARAMETER(iPPplank=20)

#ifdef DARWIN_DIAG_PERTYPE
      PARAMETER(iPCplank=iPPplank+nplank)
      PARAMETER(iGRplank=iPCplank+nplank)
      PARAMETER(iGrGn=iGRplank+nplank)
      PARAMETER(iGrGC=iGrGn+nplank)
      PARAMETER(iHPplank=iGrGC+nplank)
      PARAMETER(iHCplank=iHPplank+nplank)
      PARAMETER(darwin_nDiag=iHCplank+nplank-1)
#else
      PARAMETER(iPCplank=iPPplank)
      PARAMETER(iGRplank=iPPplank)
      PARAMETER(iGrGn=iPPplank)
      PARAMETER(iGrGC=iPPplank)
      PARAMETER(iHPplank=iPPplank)
      PARAMETER(iHCplank=iPPplank)
      PARAMETER(darwin_nDiag=iPPplank-1)
#endif

CEOP
#endif /* ALLOW_DARWIN */
