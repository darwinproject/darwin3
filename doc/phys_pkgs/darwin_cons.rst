.. include:: ../defs.hrst

.. _para_phys_pkg_darwin_cons:

Conservation of chemical elements
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ecosystem equations cycle the chemical elements C, N, P, Fe, Si, oxygen and
alkalinity in a conservative way, with a few exceptions.  Conservation can be
monitored by defining :varlink:`DARWIN_ALLOW_CONS`.  This will trigger writing
of a text file darwin_cons_X.txt for each element X that contains the total
amount and global mean for each iteration.  Non-conservation can arise in a
number of ways:

If :varlink:`DARWIN_BOTTOM_SINK` is defined, particulate organic matter and
plankton can sink into the bottom where they are presumed to be sedimentized
and no longer accounted for.

With an implicit linear free surface, there is tracer non-conservation at the
surface.  This can be corrected by setting :varlink:`darwin_linFSConserv` to
true, see section below.

With :varlink:`DARWIN_ALLOW_CARBON` defined, there are carbon and oxygen fluxes
through the sea surface.  If :varlink:`ALLOW_OLD_VIRTUALFLUX` is defined, there
will also be corrective surface fluxes for carbon and alkalinity corresponding
to changes in salinity at the free surface, see :ref:`CarbonChemistry`.


With :varlink:`ironFile` set, there will be an iron flux through the sea
surface.  Furthermore, if :varlink:`DARWIN_MINFE` is defined, the total
inorganic iron tracer is adjusted so that free iron does not exceed
:varlink:`freefemax`.  With :varlink:`DARWIN_PART_SCAV` defined, some free iron
is scavenged and lost.  And finally, if :varlink:`fesedflux` (or
:varlink:`fesedflux_pcm` if :varlink:`DARWIN_IRON_SED_SOURCE_VARIABLE` is
defined) is set, there is an iron source from sediment at the bottom of the
ocean.

Diazotrophs can take up molecular nitrogen, which is not accounted for in the
model.  Conversely, with :varlink:`DARWIN_ALLOW_DENIT` defined, ammonia and
nitrate will be turned into molecular nitrogen, see :numref:`Denitrification`.
These sources and sinks of nitrogen are logged in the file darwin_cons_N.txt
in separate columns.  Note that they are tendencies while the global totals and
means are snapshots in time.

In order to visualize where tracer non-conservation occurs, it is useful to
write out all ecosystem tendency diagnostics, gDAR##, and then add up the ones
contributing to each element, i.e.,

.. csv-table::
   :delim: &
   :widths: auto

   DIC, DOC, POC, PIC, CDOM*R_CP_CDOM, c\ :sub:`1`, ...      & for C
   NO3, NO2, NH4, DON, PON, CDOM*R_NP_CDOM, n\ :sub:`1`, ... & for N
   PO4, DOP, POP, CDOM, p\ :sub:`1`, ...                     & for P
   FeT, DOFe, POFe, CDOM*R_FeP_CDOM, fe\ :sub:`1`, ...       & for Fe
   SiO2, POSi, si\ :sub:`1`, ...                             & for Si
   O2                                                        & for oxygen
   Alk                                                       & for alkalinity

Without :varlink:`DARWIN_ALLOW_NQUOTA`, n\ :sub:`1` has to be replaced by
c\ :sub:`1`\*R_NC\ :sub:`1`, etc.  Note that gDAR## contain all the
above-mentioned sources of non-conservation except the limit on free iron.
There are also separate diagnostics for the rates of nitrogen fixation, Nfix,
and denitrification, DenitN.  The surface flux of soluble iron is given in
sfcSolFe, that of CO2 in fluxCO2.  The change of oxygen in the surface layer
due to air-sea exchange is given in gO2surf, that of alkalinity due to virtual
flux is given in gALKsurf, and the change of DIC due to both regular and
virtual surface fluxes in gDICsurf.


Linear free surface
'''''''''''''''''''

When a linear free surface is used (:varlink:`implicitFreeSurface` is set),
tracers are not conserved as the moving sea surface is not explicitly
represented in the model.  With :varlink:`DARWIN_linFSConserve` set, this
non-conservation is fixed globally for each element represented in the
ecosystem model (carbon, nitrogen, phosphorus, iron, silica, Alkalinity and
oxygen).  For each of these elements, the total tracer lost at the surface is
computed and added back into the corresponding inorganic tracer (DIC, NO3, PO4,
FeT, DSi, Alk and O2), spread out evenly over the entire 3-dimensional
domain.

.. csv-table:: Linear-free-surface parameters
   :delim: &
   :widths: auto
   :class: longtable
   :header: Param, Default, Description

   :varlink:`DARWIN_linFSConserve` & .FALSE. & whether to correct for linear-free-surface non-conservation
