.. include:: ../defs.hrst

.. _Remineralization:

Remineralization and Nitrification
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Remineralization rates are temperature dependent:

.. math::

   R_{\op{DOC}}  &= \kappa_{\op{DOC}}  f^{{{\op{remin}}}}(T) \op{DOC}

   R_{\op{DON}}  &= \kappa_{\op{DON}}  f^{{{\op{remin}}}}(T) \op{DON}

   R_{\op{DOP}}  &= \kappa_{\op{DOP}}  f^{{{\op{remin}}}}(T) \op{DOP}

   R_{\op{DOFe}} &= \kappa_{\op{DOFe}} f^{{{\op{remin}}}}(T) \op{DOFe}

   R_{\op{POC}}  &= \kappa_{\op{POC}}  f^{{{\op{remin}}}}(T) \op{POC}

   R_{\op{PON}}  &= \kappa_{\op{PON}}  f^{{{\op{remin}}}}(T) \op{PON}

   R_{\op{POP}}  &= \kappa_{\op{POP}}  f^{{{\op{remin}}}}(T) \op{POP}

   R_{\op{POFe}} &= \kappa_{\op{POFe}} f^{{{\op{remin}}}}(T) \op{POFe}

   R_{\op{POSi}} &= \kappa_{\op{POSi}} f^{{{\op{remin}}}}(T) \op{POSi}


Nitrogen chemistry:

.. math::

     P_{\op{NO2}} &= \kappa^{\op{nit}}_{\rm a} \op{NH}_4 \gamma^{\op{nit}}

     P_{\op{NO3}} &= \kappa^{\op{nit}}_{\rm b} \op{NO}_2 \gamma^{\op{nit}}

where

.. math::

   \gamma^{\op{nit}} = \max(0, 1-I/I_{\op{oxi}})
   \;.

Set :math:`I_{\op{oxi}}=0` to turn off light dependence.

Note that with :varlink:`DARWIN_ALLOW_DENIT` defined, remineralization stops
when :math:`{\mathrm{O}}_2<{\mathrm{O}}_2^{{\text{crit}}}` and
:math:`\op{NO}_3<\op{NO}_3^{{\text{crit}}}`, see :numref:`Denitrification`.


.. csv-table::  parameters
   :delim: &
   :widths: 14,12,18,15,42
   :class: longtable
   :header: Param, Symbol, Default, Units, Description

   :varlink:`KDOC`       & :math:`\kappa_{\op{DOC}}`         & 1/(100 days) & 1/s                & DOC remineralization rate
   :varlink:`KDOP`       & :math:`\kappa_{\op{DOP}}`         & 1/(100 days) & 1/s                & DON remineralization rate
   :varlink:`KDON`       & :math:`\kappa_{\op{DON}}`         & 1/(100 days) & 1/s                & DOP remineralization rate
   :varlink:`KDOFe`      & :math:`\kappa_{\op{DOFe}}`        & 1/(100 days) & 1/s                & DOFe remineralization rate
   :varlink:`KPOC`       & :math:`\kappa_{\op{POC}}`         & 1/(50 days)  & 1/s                & POC remineralization rate
   :varlink:`KPOP`       & :math:`\kappa_{\op{POP}}`         & 1/(50 days)  & 1/s                & POP remineralization rate
   :varlink:`KPON`       & :math:`\kappa_{\op{PON}}`         & 1/(50 days)  & 1/s                & PON remineralization rate
   :varlink:`KPOFe`      & :math:`\kappa_{\op{POFe}}`        & 1/(50 days)  & 1/s                & POFe remineralization rate
   :varlink:`KPOSi`      & :math:`\kappa_{\op{POSi}}`        & 1/(300 days) & 1/s                & POSi remineralization rate
   :varlink:`Knita`      & :math:`\kappa^{\op{nit}}_{\rm a}` & 1/(0.5 days) & 1/s                & ammonia oxidation rate
   :varlink:`Knitb`      & :math:`\kappa^{\op{nit}}_{\rm b}` & 1/(10 days)  & 1/s                & nitrite oxidation rate
   :varlink:`PAR_oxi`    & :math:`I_{\op{oxi}}`              & 10           & μEin/m\ :sup:`2`/s & critical light level after which oxidation starts
