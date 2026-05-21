.. include:: ../defs.hrst

.. _sub_phys_pkgs_darwin_sediments:

Sediments
^^^^^^^^^

The iron sediment source is discussed in
:numref:`ssub_phys_pkgs_darwin_iron_sedimentation`.

Two versions of the RADI metamodel for sediments are supported: Defining
:varlink:`DARWIN_ALLOW_RADIv1` in DARWIN_OPTIONS.h activates version 1
:cite:`sulpis:22`; Version 2 :cite:`van_der_zant:2026` is activated by
:varlink:`DARWIN_ALLOW_RADIv2`.  Both require :varlink:`DARWIN_BOTTOM_SINK` to
be defined.

RADI v1
'''''''

Sediment fluxes are based on modeled sinking fluxes of POC and PIC into the
bottom, see :eq:`eq_darwin_sink`.

DIC, alkalinity and oxygen fluxes can be out of the sediment (positive) or
burial into the sediment (negative):

.. math::
   F^{\mathrm{sed}}_{\mathrm{DIC}} = \left( a_1 \Omega_{\mathrm{C}} c
                      + b_1 F^{\mathrm{sink}}_{\mathrm{POC}}
                      + c_1 F^{\mathrm{sink}}_{\mathrm{PIC}}
                      + d_1 c \right) f^{\mathrm{Tcorr}}_{\mathrm{DIC}}

.. math::
   F^{\mathrm{sed}}_{\mathrm{ALK}} = \left( a_2 \Omega_{\mathrm{C}} c
                      + b_2 F^{\mathrm{sink}}_{\mathrm{POC}}
                      + c_2 F^{\mathrm{sink}}_{\mathrm{PIC}}
                      + d_2 c \right) f^{\mathrm{Tcorr}}_{\mathrm{ALK}}

.. math::
   F^{\mathrm{sed}}_{\mathrm{O2}}  = \left( a_3 \Omega_{\mathrm{C}} c
                      + b_3 F^{\mathrm{sink}}_{\mathrm{POC}}
                      + c_3 F^{\mathrm{sink}}_{\mathrm{PIC}}
                      + d_3 c \right) f^{\mathrm{Tcorr}}_{\mathrm{O2}}

POC and Calcite fluxes are burial-only (always negative):

.. math::
   F^{\mathrm{sed}}_{\mathrm{POC}} = \min\left(0, - \left( a_4 \Omega_{\mathrm{C}} c
                      + b_4 F^{\mathrm{sink}}_{\mathrm{POC}}
                      + c_4 F^{\mathrm{sink}}_{\mathrm{PIC}}
                      + d_4 c \right) \right)

.. math::
   F^{\mathrm{sed}}_{\mathrm{Clc}} = \min\left(0, - \left( a_5 \Omega_{\mathrm{C}} c
                      + b_5 F^{\mathrm{sink}}_{\mathrm{POC}}
                      + c_5 F^{\mathrm{sink}}_{\mathrm{PIC}}
                      + d_5 c \right) \right)

DIC, ALK and O2 fluxes are enhanced at higher temperatures:

.. math::
   f^{\mathrm{Tcorr}}_{\mathrm{O2}}  &= \frac{0.031558 + 0.001428\cdot|T|}{0.0335572}

   f^{\mathrm{Tcorr}}_{\mathrm{DIC}} &= \frac{0.015179 + 0.000795\cdot|T|}{0.016292}

   f^{\mathrm{Tcorr}}_{\mathrm{ALK}} &= \frac{0.015179 + 0.000795\cdot|T|}{0.016292}

These are normalized to 1 at :math:`|T|=1.4`.


.. rst-class:: right-align-secondright-col

.. csv-table:: RADI sediment metamodel version 1 parameters
   :delim: &
   :widths: auto
   :header: Name, Symbol, Default, Units
   :name: phys_pkg_darwin_radiv1_parameters

   :varlink:`sed_a1` & :math:`a_1` & --0.101 & 
   :varlink:`sed_b1` & :math:`b_1` &   1.040 & 
   :varlink:`sed_c1` & :math:`c_1` &   0.128 & 
   :varlink:`sed_d1` & :math:`d_1` &   0.125 & 
   :varlink:`sed_a2` & :math:`a_2` & --0.225 & 
   :varlink:`sed_b2` & :math:`b_2` &   0.581 & 
   :varlink:`sed_c2` & :math:`c_2` &   0.273 & 
   :varlink:`sed_d2` & :math:`d_2` &   0.211 & 
   :varlink:`sed_a3` & :math:`a_3` & --0.018 & 
   :varlink:`sed_b3` & :math:`b_3` & --0.800 & 
   :varlink:`sed_c3` & :math:`c_3` &   0.011 & 
   :varlink:`sed_d3` & :math:`d_3` & --0.033 & 
   :varlink:`sed_a4` & :math:`a_4` &   0.000 & 
   :varlink:`sed_b4` & :math:`b_4` &   0.027 & 
   :varlink:`sed_c4` & :math:`c_4` &   0.012 & 
   :varlink:`sed_d4` & :math:`d_4` & --0.001 & 
   :varlink:`sed_a5` & :math:`a_5` &   0.117 & 
   :varlink:`sed_b5` & :math:`b_5` & --0.251 & 
   :varlink:`sed_c5` & :math:`c_5` &   0.852 & 
   :varlink:`sed_d5` & :math:`d_5` & --0.127 & 
   :varlink:`sed_c`  & :math:`c`   & 3.17E-5 & mmol m\ :sup:`-2` s\ :sup:`-1`


RADI v2
'''''''

Sediment fluxes into the water column (if positive) or burial into the sediment
(if negative) are parametrized in terms of modeled sinking fluxes into the
bottom, see :eq:`eq_darwin_sink`,

.. math::
   F^{\mathrm{sed}}_{\mathrm{DIC}} &= a_1 + b_1 |T| + c_1 \Omega_{\mathrm{C}}
                      + d_1 \left( F^{\mathrm{sink}}_{\mathrm{POC}}
                                 + F^{\mathrm{sink}}_{\mathrm{plank,C}}
                            \right)
                      + e_1 F^{\mathrm{sink}}_{\mathrm{PIC}}

   F^{\mathrm{sed}}_{\mathrm{ALK}} &= a_2 + b_2 |T| + c_2 \Omega_{\mathrm{C}}
                      + d_2 \left( F^{\mathrm{sink}}_{\mathrm{POC}}
                                 + F^{\mathrm{sink}}_{\mathrm{plank,C}}
                            \right)
                      + e_2 F^{\mathrm{sink}}_{\mathrm{PIC}}

   F^{\mathrm{sed}}_{\mathrm{O2}}  &= a_3 + b_3 |T| + c_3 \Omega_{\mathrm{C}}
                      + d_3 \left( F^{\mathrm{sink}}_{\mathrm{POC}}
                                 + F^{\mathrm{sink}}_{\mathrm{plank,C}}
                            \right)
                      + e_3 F^{\mathrm{sink}}_{\mathrm{PIC}}

   F^{\mathrm{sed}}_{\mathrm{NO3}} &= a_4
                      + b_4 \left( F^{\mathrm{sink}}_{\mathrm{PON}}
                                 + F^{\mathrm{sink}}_{\mathrm{plank,N}}
                            \right)
                      + c_4 F_{\mathrm{DIC}}
                      + d_4 F_{\mathrm{O2}}

                    &\quad + e_4 |T| F_{\mathrm{DIC}}
                      + f_4 |T| F_{\mathrm{O2}}
                      + g_4 F_{\mathrm{DIC}} F_{\mathrm{O2}}

   F^{\mathrm{sed}}_{\mathrm{PO4}} &= a_5 + b_5 |T| + c_5 \Omega_{\mathrm{C}}
                      + d_5 \left( F^{\mathrm{sink}}_{\mathrm{POP}}
                                 + F^{\mathrm{sink}}_{\mathrm{plank,P}}
                            \right)
                      + e_5 F^{\mathrm{sink}}_{\mathrm{PIC}}

   F^{\mathrm{sed}}_{\mathrm{NH4}} &= a_6 + b_6 |T| + c_6 \Omega_{\mathrm{C}}
                      + d_6 \left( F^{\mathrm{sink}}_{\mathrm{PON}}
                                 + F^{\mathrm{sink}}_{\mathrm{plank,N}}
                            \right)
                      + e_6 F^{\mathrm{sink}}_{\mathrm{PIC}}


.. rst-class:: right-align-right-col

.. csv-table:: RADI sediment metamodel version 2 parameters
   :delim: &
   :widths: auto
   :header: Name, Symbol, Default
   :name: phys_pkg_darwin_radiv2_parameters

   :varlink:`sed_globala1` & :math:`a_1` & 2.07E-5
   :varlink:`sed_globalb1` & :math:`b_1` & --5.64E-7
   :varlink:`sed_globalc1` & :math:`c_1` & --5.42E-6
   :varlink:`sed_globald1` & :math:`d_1` & 1.45
   :varlink:`sed_globale1` & :math:`e_1` & 4.19E-1
   :varlink:`sed_globala2` & :math:`a_2` & 1.55E-5
   :varlink:`sed_globalb2` & :math:`b_2` & --2.94E-7
   :varlink:`sed_globalc2` & :math:`c_2` & --6.55E-6
   :varlink:`sed_globald2` & :math:`d_2` & 5.83E-1
   :varlink:`sed_globale2` & :math:`e_2` & 1.38E-1
   :varlink:`sed_globala3` & :math:`a_3` & --1.35E-5
   :varlink:`sed_globalb3` & :math:`b_3` & 5.08E-8
   :varlink:`sed_globalc3` & :math:`c_3` & 1.79E-6
   :varlink:`sed_globald3` & :math:`d_3` & --1.07
   :varlink:`sed_globale3` & :math:`e_3` & --4.47E-1
   :varlink:`sed_globala4` & :math:`a_4` & 3.0E-6
   :varlink:`sed_globalb4` & :math:`b_4` & --7.14E-1
   :varlink:`sed_globalc4` & :math:`c_4` & 1.94E-1
   :varlink:`sed_globald4` & :math:`d_4` & 2.81E-1
   :varlink:`sed_globale4` & :math:`e_4` & --2.21E-2
   :varlink:`sed_globalf4` & :math:`f_4` & --2.97E-2
   :varlink:`sed_globalg4` & :math:`g_4` & --3.20E2
   :varlink:`sed_globala5` & :math:`a_5` & --2.42E-7
   :varlink:`sed_globalb5` & :math:`b_5` & 1.54E-8
   :varlink:`sed_globalc5` & :math:`c_5` & --4.77E-8
   :varlink:`sed_globald5` & :math:`d_5` & 1.64
   :varlink:`sed_globale5` & :math:`e_5` & 1.20E-2
   :varlink:`sed_globala6` & :math:`a_6` & --3.87E-6
   :varlink:`sed_globalb6` & :math:`b_6` & 9.15E-8
   :varlink:`sed_globalc6` & :math:`c_6` & --7.26E-7
   :varlink:`sed_globald6` & :math:`d_6` & 1.73
   :varlink:`sed_globale6` & :math:`e_6` & 1.51E-1


Diagnostics
'''''''''''

Diagnostics available with :varlink:`DARWIN_ALLOW_RADIv1`:

.. tabularcolumns:: |\Y{.16}|\Y{.16}|\Y{.18}|\Y{.5}|

.. csv-table:: RADI sediment model version 1 diagnostic fields
   :delim: &
   :widths: auto
   :class: longtable
   :header: Name, Code, Units, Description

   DICFsed    & ``SM______U1`` & mmol C/m\ :sup:`2`/s            & DIC sediment flux, :math:`F^{\mathrm{sed}}_{\mathrm{DIC}}`
   ALKFsed    & ``SM______U1`` & meq/m\ :sup:`2`/s               & ALK sediment flux, :math:`F^{\mathrm{sed}}_{\mathrm{ALK}}`
   O2Fsed     & ``SM______U1`` & mmol O\ :sub:`2` /m\ :sup:`2`/s & O\ :sub:`2` sediment flux, :math:`F^{\mathrm{sed}}_{\mathrm{O2}}`
   POCFbur    & ``SM______U1`` & mmol C/m\ :sup:`2`/s            & POC buried flux, :math:`F^{\mathrm{sed}}_{\mathrm{POC}}` (negative!)
   CALFbur    & ``SM______U1`` & mmol C/m\ :sup:`2`/s            & Calcite buried flux, :math:`F^{\mathrm{sed}}_{\mathrm{CAL}}` (negative!)
   sedFlPOC   & ``SM_P____U1`` & mmol C/m\ :sup:`2`/s            & POC flux from water column to sediment, :math:`F^{\mathrm{sink}}_{\mathrm{POC}}`
   sedFlPIC   & ``SM_P____U1`` & mmol C/m\ :sup:`2`/s            & PIC flux from water column to sediment, :math:`F^{\mathrm{sink}}_{\mathrm{PIC}}`
   TcorrO2    & ``SM_P____M1`` & 1                               & Temperature correction factor for diffusive O\ :sub:`2` flux
   TcorrALK   & ``SM_P____M1`` & 1                               & Temperature correction factor for diffusive ALK flux
   TcorrDIC   & ``SM_P____M1`` & 1                               & Temperature correction factor for diffusive DIC flux
   OmegCbot   & ``SM_P____M1`` & 1                               & Calcite saturation ratio above the seabed

Diagnostics available with :varlink:`DARWIN_ALLOW_RADIv2`:

.. tabularcolumns:: |\Y{.16}|\Y{.16}|\Y{.18}|\Y{.5}|

.. csv-table:: RADI sediment model version 2 diagnostic fields
   :delim: &
   :widths: auto
   :class: longtable
   :header: Name, Code, Units, Description

   DICFsed    & ``SM______U1`` & mmol C/m\ :sup:`2`/s            & DIC sediment flux, :math:`F^{\mathrm{sed}}_{\mathrm{DIC}}`
   ALKFsed    & ``SM______U1`` & meq/m\ :sup:`2`/s               & ALK sediment flux, :math:`F^{\mathrm{sed}}_{\mathrm{ALK}}`
   O2Fsed     & ``SM______U1`` & mmol O\ :sub:`2` /m\ :sup:`2`/s & O\ :sub:`2` sediment flux, :math:`F^{\mathrm{sed}}_{\mathrm{O2}}`
   NO3Fsed    & ``SM______U1`` & mmol N/m\ :sup:`2`/s            & NO3 sediment flux, :math:`F^{\mathrm{sed}}_{\mathrm{NO3}}`
   PO4Fsed    & ``SM______U1`` & mmol P/m\ :sup:`2`/s            & PO4 sediment flux, :math:`F^{\mathrm{sed}}_{\mathrm{PO3}}`
   NH4Fsed    & ``SM______U1`` & mmol N/m\ :sup:`2`/s            & NH4 sediment flux, :math:`F^{\mathrm{sed}}_{\mathrm{NH4}}`
   sedFlPOC   & ``SM_P____U1`` & mmol C/m\ :sup:`2`/s            & POC flux from water column to sediment, :math:`F^{\mathrm{sink}}_{\mathrm{POC}}`
   sedFlPIC   & ``SM_P____U1`` & mmol C/m\ :sup:`2`/s            & PIC flux from water column to sediment, :math:`F^{\mathrm{sink}}_{\mathrm{PIC}}`
   sedFlPOP   & ``SM_P____U1`` & mmol P/m\ :sup:`2`/s            & POP flux from water column to sediment, :math:`F^{\mathrm{sink}}_{\mathrm{POP}}`
   sedFlPON   & ``SM_P____U1`` & mmol N/m\ :sup:`2`/s            & PON flux from water column to sediment, :math:`F^{\mathrm{sink}}_{\mathrm{PON}}`
   sedFplkC   & ``SM_P____U1`` & mmol C/m\ :sup:`2`/s            & C flux from bottom sink plankton to sed, :math:`F^{\mathrm{sink}}_{\mathrm{plank,C}}`
   sedFplkN   & ``SM_P____U1`` & mmol N/m\ :sup:`2`/s            & N flux from bottom sink plankton to sed, :math:`F^{\mathrm{sink}}_{\mathrm{plank,N}}`
   sedFplkP   & ``SM_P____U1`` & mmol P/m\ :sup:`2`/s            & P flux from bottom sink plankton to sed, :math:`F^{\mathrm{sink}}_{\mathrm{plank,P}}`
   OmegCbot   & ``SM_P____M1`` & 1                               & Calcite saturation ratio above the seabed

