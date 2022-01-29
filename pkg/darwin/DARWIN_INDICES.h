#ifdef ALLOW_DARWIN

CBOP
C    !ROUTINE: DARWIN_INDICES.h
C    !INTERFACE:
C #include DARWIN_INDICES.h

C    !DESCRIPTION:
C Contains indices into ptracer array

C these cannot be modified for now

      INTEGER iDIC
      INTEGER iNO3
      INTEGER iNO2
      INTEGER iNH4
      INTEGER iPO4
      INTEGER iFeT
      INTEGER iSiO2
      INTEGER iDOC
      INTEGER iDON
      INTEGER iDOP
      INTEGER iDOFe
      INTEGER iPOC
      INTEGER iPON
      INTEGER iPOP
      INTEGER iPOFe
      INTEGER iPOSi
      INTEGER iPIC
      INTEGER ic
      INTEGER eCARBON
      INTEGER eCDOM
      INTEGER ec
      INTEGER en
      INTEGER ep
      INTEGER efe
      INTEGER esi
      INTEGER eChl
      INTEGER nDarwin
      PARAMETER (iDIC   =1)
      PARAMETER (iNO3   =iDIC +1)
      PARAMETER (iNO2   =iNO3 +1)
      PARAMETER (iNH4   =iNO2 +1)
      PARAMETER (iPO4   =iNH4 +1)
      PARAMETER (iFeT   =iPO4 +1)
      PARAMETER (iSiO2  =iFeT +1)
      PARAMETER (iDOC   =iSiO2+1)
      PARAMETER (iDON   =iDOC +1)
      PARAMETER (iDOP   =iDON +1)
      PARAMETER (iDOFe  =iDOP +1)
      PARAMETER (iPOC   =iDOFe+1)
      PARAMETER (iPON   =iPOC +1)
      PARAMETER (iPOP   =iPON +1)
      PARAMETER (iPOFe  =iPOP +1)
      PARAMETER (iPOSi  =iPOFe+1)
      PARAMETER (iPIC   =iPOSi+1)
#ifdef DARWIN_ALLOW_CARBON
      INTEGER iALK
      INTEGER iO2
      PARAMETER (iALK   =iPIC +1)
      PARAMETER (iO2    =iALK +1)
      PARAMETER (eCARBON=iO2)
#else
      PARAMETER (eCARBON=iPIC)
#endif
#ifdef DARWIN_ALLOW_CDOM
      INTEGER iCDOM
      PARAMETER (iCDOM  =eCARBON+1)
      PARAMETER (eCDOM  =iCDOM)
#else
      PARAMETER (eCDOM  =eCARBON)
#endif
      PARAMETER (ic     =eCDOM+1)
      PARAMETER (ec     =ic   +nplank-1)
#ifdef DARWIN_ALLOW_NQUOTA
      INTEGER in
      PARAMETER (in     =ec  +1)
      PARAMETER (en     =in  +nplank-1)
#else
      PARAMETER (en     =ec)
#endif
#ifdef DARWIN_ALLOW_PQUOTA
      INTEGER ip
      PARAMETER (ip     =en  +1)
      PARAMETER (ep     =ip  +nplank-1)
#else
      PARAMETER (ep     =en)
#endif
#ifdef DARWIN_ALLOW_FEQUOTA
      INTEGER ife
      PARAMETER (ife    =ep  +1)
      PARAMETER (efe    =ife +nplank-1)
#else
      PARAMETER (efe    =ep)
#endif
#ifdef DARWIN_ALLOW_SIQUOTA
      INTEGER isi
      PARAMETER (isi    =efe +1)
      PARAMETER (esi    =isi +nplank-1)
#else
      PARAMETER (esi    =efe)
#endif
#ifdef DARWIN_ALLOW_CHLQUOTA
      INTEGER iChl
      PARAMETER (iChl   =esi +1)
      PARAMETER (eChl   =iChl+nPhoto-1)
#else
      PARAMETER (eChl   =esi)
#endif
      PARAMETER (nDarwin=eChl)

CEOP
#endif /* ALLOW_DARWIN */
