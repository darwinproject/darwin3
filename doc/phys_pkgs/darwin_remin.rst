.. include:: ../defs.hrst

.. _Remineralization:

Remineralization
^^^^^^^^^^^^^^^^

Remineralization rates are temperature dependent:

.. math:: r_{*O*} = f^{{{\text{remin}}}}(T) \kappa_{*O*}

Nitrogen chemistry:

.. math::

     P_{\op{NO2}} &= \kappa^{\text{nit}}_{\rm a} \op{NH}_4 \gamma^{\text{nit}}

     P_{\op{NO3}} &= \kappa^{\text{nit}}_{\rm b} \op{NO}_2 \gamma^{\text{nit}}

where

.. math::

   \gamma^{\text{nit}} = \max(0, 1-I/I_{\text{oxi}}

Set :math:`I_{\text{oxi}}=0` to turn off light dependence.
