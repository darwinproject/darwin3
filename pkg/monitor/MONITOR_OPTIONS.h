C CPP options file for monitor package
C Use this file for selecting options within the monitor package

#ifndef MONITOR_OPTIONS_H
#define MONITOR_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#ifdef ALLOW_MONITOR
C     Package-specific Options & Macros go here

C Disable use of hFacZ
#undef MONITOR_TEST_HFACZ

#endif /* ALLOW_MONITOR */
#endif /* MONITOR_OPTIONS_H */
