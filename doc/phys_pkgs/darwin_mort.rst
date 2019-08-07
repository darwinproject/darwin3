.. include:: ../defs.hrst

.. _Mortality:

Mortality and Respiration
^^^^^^^^^^^^^^^^^^^^^^^^^

Respiration and mortality stop at :math:`{c}_j^{\min}` (maybe should not
use :math:`{c}_j^{\min}` for respiration?)

.. math:: R^{\mathrm{C}}_j = r^{{{\text{resp}}}}_j f^{{{\text{remin}}}}(T) ({c}_j - {c}_j^{\min})

.. math::

   M_j = m^{(1)}_j {f^{\op{mort}}(T)}^{e^{\op{mort}}_j} ({c}_j - {c}_j^{\min})
         + m^{(2)}_j {f^{\op{mort2}}(T)}^{e^{\op{mort2}}_j} ({c}_j - {c}_j^{\min})^2

The released matter splits into dissolved and particulate organic
pools,

.. math::

   M^{\op{DOM}}_j = (1 - f_j^{\exp\op{mort}}) m^{(1)}_j {f^{\op{mort}}(T)}^{e^{\op{mort}}_j} ({c}_j - {c}_j^{\min})
               + (1 - f_j^{\exp\op{mort2}}) m^{(2)}_j {f^{\op{mort2}}(T)}^{e^{\op{mort2}}_j} ({c}_j - {c}_j^{\min})^2

.. math::

   M^{\op{POM}}_j = f_j^{\exp\op{mort}} m^{(1)}_j {f^{\op{mort}}(T)}^{e^{\op{mort}}_j} ({c}_j - {c}_j^{\min})
               + f_j^{\exp\op{mort2}} m^{(2)}_j {f^{\op{mort2}}(T)}^{e^{\op{mort2}}_j} ({c}_j - {c}_j^{\min})^2
