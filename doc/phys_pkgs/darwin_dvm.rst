.. include:: ../defs.hrst

.. _para_phys_pkg_darwin_dvm:

Diel Vertical Migration
^^^^^^^^^^^^^^^^^^^^^^^

(contributed by Darcy Taniguchi)

To enable diel vertical migration compile with :varlink:`DARWIN_ALLOW_DVM`
defined in :filelink:`DARWIN_OPTIONS.h <pkg/darwin/DARWIN_OPTIONS.h>`.
Runtime parameters are given at the bottom of this page.

During the day (when light is available), predators swim towards their
preferred light level, :varlink:`PARpref`.
At night they swim toward the level with maximum food availability (total prey
for each predator type).

Higher trophic levels of predators beyond those in the model are represented
by an additional mortality term:

.. math::
   M^{\text{DVM}}_j = m^{\text{DVM-max}}_j \frac{c_j}{k^{\text{DVM}}_j+c_j}
           \left( 1 - f^{\text{mort}}_{\text{PAR}\,j}
             + f^{\text{mort}}_{\text{PAR}\,j}
             \frac{I}
                  {\frac{k^{\text{DVM}}_j}{k^{\text{DVM}}_j+c_j}
                   k^{\text{PAR-DVM}}_j
                   + I}
           \right) c_j

where :math:`I` is total PAR.

A fraction :varlink:`ExportFracDVM`\ (j) of :math:`M^{\text{DVM}}_j` goes to
particulate organic matter, the rest to dissolved.  Non-carbon elements are
treated as for regular mortality.

Traits and parameters for diel vertical migration are shown in
:numref:`tab_phys_pkg_darwin_dvm_traits`.

.. csv-table:: Traits for diel vertical migration
   :delim: &
   :widths: 20,22,14,15,28
   :header: trait,param,default,units,description
   :name: tab_phys_pkg_darwin_dvm_traits

   :varlink:`bioswimDVM`    & :varlink:`a_bioswimDVM`    & 0.03     & m/s       & swimming speed for diel vertically migrating plankton (pos. upwards) :cite:`bianchi:2013`
                            & :varlink:`b_bioswimDVM`    & 0        &           &
   :varlink:`PARpref`       & :varlink:`a_PARpref`       & 0.0046   & μEin/m²/s & preferred PAR isolume for determining DVM; converted from W/m2 :cite:`bianchi:2013`
                            & :varlink:`b_PARpref`       & 0        &           &
   :varlink:`mortmaxDVM`    & :varlink:`a_mortmaxDVM`    & 8.389E-5 & 1/s       & maximum mortality rate related to PAR for DVM (ImaxHP :cite:`bianchi:2013` from :cite:`hansen:1997`)
                            & :varlink:`b_mortmaxDVM`    & --0.16   &           &
   :varlink:`ksatDVM`       & :varlink:`a_ksatDVM`       & 1/:varlink:`a_R_NC` & mmol C/m³ & half saturation for DVM mortality (K_Z :cite:`bianchi:2013` from :cite:`stock:2010`)
                            & :varlink:`b_ksatDVM`       & 0        &           &
   :varlink:`ksatPARDVM`    & :varlink:`a_ksatPARDVM`    & 0.46     & μEin/m²/s & half sat for light limitation for DVM (K_irr in :cite:`bianchi:2013`)
                            & :varlink:`b_ksatPARDVM`    & 0        &           &
   :varlink:`fracPARmort`   & :varlink:`a_fracPARmort`   & 0.9      &           & fraction of mortality from light-dependent mortality :cite:`bianchi:2013`
                            & :varlink:`b_fracPARmort`   & 0        &           &
   :varlink:`ExportFracDVM` & :varlink:`a_ExportFracDVM` & 0.5      &           & fraction of light-dependent mortality from DVM to POM

