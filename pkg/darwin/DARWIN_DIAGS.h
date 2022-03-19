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
      integer iConsDIN
      integer iConsNO3
      integer iConsNO2
      integer iConsNH4
      integer iConsPO4
      integer iConsFe
      integer iConsSi
      integer iConsDIC
      integer iConsDIC_PIC
      integer iRespirDIC
      integer iReminDIC_DOC
      integer iReminDIC_POC
      integer iDisscDIC_PIC
      integer iConsALK
      integer iSrcAlk
      integer iConsO2
      integer iProdO2
      integer iPPplank
      integer iPCplank
      integer iGRplank
      integer iGrGn
      integer iGrGC
      integer iHPplank
      integer iHCplank
#ifdef DARWIN_ALLOW_CSTORE
      integer iEX
      integer iGW
      integer iDN
      integer iDP
      integer iDFe
      integer iDSi
      integer iDmin
# ifdef DARWIN_ALLOW_CSTORE_DIAGS
      integer iEXplank
      integer iGWplank
      integer iDNplank
      integer iDPplank
      integer iDFplank
      integer iDSplank
      integer iDminplank
# endif
#endif
      integer darwin_nDiag

      PARAMETER(iPP=      1)
      PARAMETER(iNfix=    2)
      PARAMETER(iDenit=   3)
      PARAMETER(iDenitN=  4)
      PARAMETER(iConsDIN= 5)
      PARAMETER(iConsNO3= 6)
      PARAMETER(iConsNO2= 7)
      PARAMETER(iConsNH4= 8)
      PARAMETER(iConsPO4= 9)
      PARAMETER(iConsFe= 10)
      PARAMETER(iConsSi= 11)
      PARAMETER(iConsDIC=12)
      PARAMETER(iConsDIC_PIC=13)
      PARAMETER(iRespirDIC=14)
      PARAMETER(iReminDIC_DOC=15)
      PARAMETER(iReminDIC_POC=16)
      PARAMETER(iDisscDIC_PIC=17)
      PARAMETER(iConsALK=18)
      PARAMETER(iSrcAlk= 19)
      PARAMETER(iConsO2= 20)
      PARAMETER(iProdO2= 21)
#ifdef DARWIN_ALLOW_CSTORE
      PARAMETER(iEX=  22)
      PARAMETER(iGW=  iEX+1)
      PARAMETER(iDN=  iGW+1)
      PARAMETER(iDP=  iDN+1)
      PARAMETER(iDFe= iDP+1)
      PARAMETER(iDSi= iDFe+1)
      PARAMETER(iDmin=iDSi+1)
# ifdef DARWIN_ALLOW_CSTORE_DIAGS
      PARAMETER(iEXplank=iDmin+1)
      PARAMETER(iGWplank=iEXplank+nPhoto)
      PARAMETER(iDNplank=iGWplank+nPhoto)
      PARAMETER(iDPplank=iDNplank+nPhoto)
      PARAMETER(iDFplank=iDPplank+nPhoto)
      PARAMETER(iDSplank=iDFplank+nPhoto)
      PARAMETER(iDminplank=iDSplank+nPhoto)
      PARAMETER(iPPplank=iDminplank+nPhoto)
# else
      PARAMETER(iPPplank=iDmin+1)
# endif
#else
      PARAMETER(iPPplank=22)
#endif
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
