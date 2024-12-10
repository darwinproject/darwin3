#ifndef RADTRANS_OPTIONS_H
#define RADTRANS_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#ifdef ALLOW_RADTRANS

#include "CPP_OPTIONS.h"

CBOP
C    !ROUTINE: RADTRANS_OPTIONS.h
C    !INTERFACE:

C    !DESCRIPTION:
C options for radtrans package
CEOP

C fill diagnostics for radiative transfer solution parameters
#undef  RADTRANS_DIAG_SOLUTION

#endif /* ALLOW_RADTRANS */
#endif /* RADTRANS_OPTIONS_H */

