#ifndef OASIM_OPTIONS_H
#define OASIM_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#ifdef ALLOW_OASIM

#include "CPP_OPTIONS.h"

CBOP
C    !ROUTINE: OASIM_OPTIONS.h
C    !INTERFACE:

C    !DESCRIPTION:
C options for oasim package
CEOP

C compute solar zenith angle at myTime instead of averaging over time step
#undef OASIM_INST_ZENITH_ANGLE

C read combined fortran-unformatted files as in original OASIM
C these are used constant-in-time for each month
#undef OASIM_READ_UNFORMATTED

C write preprocessed forcing data
#undef OASIM_OUTPUT_FORCING

C To emulate original oasim code as closely as possible, set the
C following two CPP options, set oasim_fixedLon=0. and set oasim_timeInterp=0
C in data.oasim or #define OASIM_READUNFORMATTED
C
C - compute nutation correction only on day change
#undef OASIM_DAILY_NUTATE
C - do not vectorize zenith angle computation
#undef OASIM_SCALAR_ZENITH_ANGLE_COMP

#endif /* ALLOW_OASIM */
#endif /* OASIM_OPTIONS_H */
