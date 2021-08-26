.. include:: ../defs.hrst

Change Log
^^^^^^^^^^

(bug fixes and breaking changes in bold)

- 2021-08-25 Add growth rate diagnostics 'PC####'
- 2021-08-25 Add biomass and Chlorophyll diags, 'plankC' and 'Chl'

darwin_ckpt68b

- 2021-08-24 merge checkpoint68b of MITgcm

darwin_ckpt68a

- 2021-07-23 merge checkpoint68a of MITgcm
- 2021-07-23 Fix "Add more carbon flux diagnostics"
- 2021-05-28 Update diagnostics in docs

merge checkpoint67z of MITgcm

- 2021-05-27 Add ecosystem tendency diagnostics without sink/swim: ‘gECO##’
- 2021-05-27 Add more carbon flux diagnostics: ‘fluxO2’, ‘VfluxO2’, ‘VfluxAlk’ (see fix above)
- 2021-05-27 **Take PIC into account for respiration and exudation**
- 2021-05-27 Error if bacteria or predators have PIC
- 2021-05-27 Add Coccolithophore shells to linfs conserve
- 2021-05-28 Do not write nonconserving terms at beginning of time step
- 2021-05-28 Add more sources of nonconservation to check
- 2021-05-27 **Fix bug with DARWIN_ALLOW_DENIT and bacteria**

  - caused non-conservation

- 2021-05-27 **Also turn off POSi remin and consum at low O2 and NO3**

merge checkpoint67y of MITgcm

- 2021-04-24 Error if radtrans compiled but not used with darwin
- 2021-04-18 Allow to compile radtrans without sun package
- 2021-04-23 Add radtrans_check and error if used without enable

merge checkpoint67x of MITgcm

- 2021-04-09 Add comment about flux diags units and sign to docs
- 2021-01-29 Update darwin docs
- 2021-01-29 Simplify units of plankton IOPs
- 2021-01-25 Add LGR encoding for Greek unicode characters in docs
- 2021-01-15 Add DARWIN_TEMP_VERSION 4
- 2021-01-22 Add separate temperature function for bacteria

merge checkpoint67w of MITgcm

merge checkpoint67v of MITgcm

- 2021-01-29 Move aphy_chl_ave to params
- 2021-02-04 **Fix loop range for DARWIN_SCATTER_CHL**
- 2021-01-14 Add carbonspecific spectral plankton absorption
- 2021-01-12 Fix units of fugfCO2 diagnostic
- 2021-01-11 **Fix filling of fugfCO2 diagnostic**

merge checkpoint67u of MITgcm

merge checkpoint67t of MITgcm

- 2020-10-28 Clean up and update darwin diags table in docs

merge checkpoint67s of MITgcm

merge checkpoint67r of MITgcm

- 2020-06-07 Clean up some comments
- 2020-06-07 Update docs
- 2020-06-07 Remove nPPplank, nGRplank, nGrGn
- 2020-03-19 Add diagnostics for pertype grazing gains

merge checkpoint67q of MITgcm

- 2020-03-12 Document new iron sediment source formulation
- 2020-03-12 Make iron sediment source in terms of POC

merge checkpoint67p of MITgcm

merge checkpoint67o of MITgcm

merge checkpoint67n of MITgcm

- 2019-10-17 Avoid division by zero

merge checkpoint67m of MITgcm

- 2019-10-10 Eliminate more traces of gud
- 2019-10-08 merge master of MITgcm
- 2019-10-03 Add soluble iron input diagnostic
- 2019-08-12 Rearrange EXF interpolation header files

merge checkpoint67l of MITgcm

- 2019-08-07 Add docs for darwin and radtrans packages
- 2019-02-19 add \op macro as an abbreviation for \operatorname
- 2019-08-06 Replace ksatPOM, ksatDOM by trait parameters a_ksatPON, a_ksatDON
- 2019-07-31 Describe parameters in code
- 2019-07-25 Fix units for oxygen diagnostic
- 2019-07-31 **Move phymin to trait parameters**
- 2019-08-06 Add \*RepCycle parameters to radtrans pkg

merge checkpoint67k of MITgcm

- 2019-07-23 Avoid division by zero for zero quota
- 2019-07-18 **Replace bacteria uptake parameters by trait PCmax**
- 2019-07-12 Document radtrans parameters in code
- 2019-07-12 Add recalcitrant POC and CDOM parameters

merge checkpoint67j of MITgcm

- 2019-06-14 Fix names for palatability generation
- 2019-05-13 Add DenitN diagnostic

merge checkpoint67i of MITgcm

- 2019-05-09 Add warning for use of default pCO2 value
- 2019-05-08 Retire darwin_atmos_pCO2
- 2019-04-30 **Clip negative light values**
- 2019-04-30 Indent cpp directives
- 2019-04-26 Add \*RepCycle parameters
- 2019-04-26 Set use of exf wind, seaice area and Qsw in namelist
- 2019-04-26 Remove parameter useDarwinYearlyFields
- 2019-04-16 **Do not reduce light under ice if DARWIN_useQsw**
- 2019-04-18 Add darwin_pickupSuff, defaulting to pickupSuff
- 2019-04-18 Add diagnostic for CO2 fugacity factor
- 2019-04-29 Add DARWIN_BOTTOM_SINK option
- 2019-04-29 Add legacy chl initialization for no-PARfile case
- 2019-04-02 Clean up preprocessor directives and code blocks
- 2019-04-16 **Cut negatives in freefe**
- 2019-04-26 Disable temp dependence for zooplankton with random trait generation
- 2019-04-26 Add tempGraz trait
- 2019-04-16 Retire mort*TempFuncMin, use tempMort* directly
- 2019-05-01 **Replace regularization by conditionals**
- 2019-05-02 Do not log kMinFeSed, kMaxFeSed before they are computed
- 2019-04-01 Remove unused parameters expPref, expPalat
- 2019-04-08 Put nitrogen conservation numbers on one line
- 2019-04-02 Shorten ptracers units (for netcdf output)
- 2019-04-02 Fix for python 3.X

merge checkpoint67h of MITgcm

- 2019-02-21 Move chl init parameters to DARWIN_PARAMS
- 2018-02-26 add darwin package
- 2018-02-26 update darwin call interface
- 2018-09-19 add radtrans package
- 2018-02-19 add sun package

MITgcm checkpoint67g

