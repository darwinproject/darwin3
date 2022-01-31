.. include:: ../defs.hrst

.. _para_phys_pkg_darwin_sink:

Sinking and Swimming
^^^^^^^^^^^^^^^^^^^^

Plankton and particulate organic matter sink with prescribed velocities. The
downward flux from a grid cell to the cell below (in mmol m\ :sup:`--2` s\
:sup:`--1`) is

.. math::

   F_{k,k+1} = w_{\mathrm{sink}} p_k

where :math:`w_{\mathrm{sink}}` is one of the sinking velocities in
:numref:`tab_phys_pkg_darwin_sink_param` and :math:`p_k` is the corresponding
tracer concentration in the upper grid cell.

If :varlink:`DARWIN_BOTTOM_SINK` is defined, plankton and particulates can also
sink into the bottom (where they are lost).

Plankton can also swim upwards with a fixed velocity,

.. math::

   F_{k+1,k} = w_{\mathrm{swim}} p_{k+1}

.. csv-table:: Velocity parameters for particulate organic matter and plankton
   :delim: &
   :widths: auto
   :header: trait, parameter, tracer
   :name: tab_phys_pkg_darwin_sink_param

                      & :varlink:`wPIC_sink` & PIC
                      & :varlink:`wC_sink`   & POC
                      & :varlink:`wN_sink`   & PON
                      & :varlink:`wP_sink`   & POP
                      & :varlink:`wSi_sink`  & POSi
                      & :varlink:`wFe_sink`  & POFe
   :varlink:`biosink` & :varlink:`a <a_biosink>`,\ :varlink:`b_biosink` & plankon (c, n, p, fe, si and Chl quotas if present)
   :varlink:`bioswim` & :varlink:`a <a_bioswim>`,\ :varlink:`b_bioswim` & plankon (c, n, p, fe, si and Chl quotas if present)

