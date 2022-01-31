.. include:: ../defs.hrst

.. _Mortality:

Mortality and Respiration
^^^^^^^^^^^^^^^^^^^^^^^^^

Respiration and mortality stop at :math:`{c}_j^{\min}` (maybe should not
use :math:`{c}_j^{\min}` for respiration?)

.. math:: R^{\mathrm{C}}_j = r^{{{\text{resp}}}}_j f^{{{\text{remin}}}}(T) ({c}_j - {c}_j^{\min})

.. math::

   M_j = m^{(1)}_j {f^{\op{mort}}(T)}^{e^{\op{m}}_j} ({c}_j - {c}_j^{\min})
         + m^{(2)}_j {f^{\op{mort2}}(T)}^{e^{\op{m2}}_j} ({c}_j - {c}_j^{\min})^2

The released matter splits into dissolved and particulate organic
pools,

.. math::

   M^{\op{DOM}}_j &= (1 - f_j^{\exp\op{m}}) m^{(1)}_j {f^{\op{mort}}(T)}^{e^{\op{m}}_j} ({c}_j - {c}_j^{\min}) \\
                  &+ (1 - f_j^{\exp\op{m2}}) m^{(2)}_j {f^{\op{mort2}}(T)}^{e^{\op{m2}}_j} ({c}_j - {c}_j^{\min})^2

.. math::

   M^{\op{POM}}_j &= f_j^{\exp\op{m}} m^{(1)}_j {f^{\op{mort}}(T)}^{e^{\op{m}}_j} ({c}_j - {c}_j^{\min}) \\
                  &+ f_j^{\exp\op{m2}} m^{(2)}_j {f^{\op{mort2}}(T)}^{e^{\op{m2}}_j} ({c}_j - {c}_j^{\min})^2


Parameters
''''''''''

.. csv-table:: Mortality and respiration parameters
   :delim: &
   :widths: 20,22,11,11,13,23
   :class: longtable
   :header: Trait, Param, Symbol, Default, Units, Description

   :varlink:`respRate`        & :varlink:`a <a_respRate_c>`,\ :varlink:`b_respRate_c` [#]_ & :math:`r^{\op{resp}}_j`       & 0                & s\ :sup:`-1`            & respiration rate
   :varlink:`qcarbon`         & :varlink:`a <a_qcarbon>`,\ :varlink:`b_qcarbon`         & :math:`Q^{\mathrm{c}}_j`      & 1.8E-11          & mmol C cell\ :sup:`--1` & cellular carbon content
   :varlink:`mort`            & :varlink:`a_mort`                & :math:`m^{(1)}_j`             & 0.02 / day       & s\ :sup:`-1`            & linear mortality rate
   :varlink:`mort2`           & :varlink:`a_mort2`               & :math:`m^{(2)}_j`             & 0                & m\ :sup:`3` s / mmol C  & quadratic mortality coefficient
   :varlink:`Xmin`            & :varlink:`a_Xmin`                & :math:`c^{\min}_j`            & 0                & mmol C m\ :sup:`-3`     & minimum abundance for mortality, respiration and exudation
   :varlink:`tempMort`        & :varlink:`grp_tempMort`          & :math:`e^{\op{m}}_j`          & 1                &                         & 1: mortality is temp. dependent, 0: not
   :varlink:`tempMort2`       & :varlink:`grp_tempMort2`         & :math:`e^{\op{m2}}_j`         & 1                &                         & 1: quadr.tic mortality is temperature dependent, 0: not
   :varlink:`ExportFracMort`  & :varlink:`a_ExportFracMort`      & :math:`f^{\op{exp}\op{m}}_j`  & 0.5              &                         & fraction of linear mortality to POM
   :varlink:`ExportFracMort2` & :varlink:`a_ExportFracMort2`     & :math:`f^{\op{exp}\op{m2}}_j` & 0.5              &                         & fraction of quadratic mortality to POM

.. [#] the units of :varlink:`a_respRate_c` are mmol C cell\ :sup:`--1`, see discussion below.


The respiration rate follows a different scaling law from other traits: it
scales in terms of cellular carbon content,

.. math::

    r^{\op{resp}}_j = \frac{\op{a\_respRate\_c(g)}}{Q^{\mathrm{c}}_j}
    \left( 12\cdot10^9 \cdot Q^{\mathrm{c}}_j \right)^{\op{b\_respRate\_c(g)}}

where

.. math::

   Q^{\mathrm{c}}_j = \op{a\_qcarbon(g)} \cdot V_j^{\op{b\_qcarbon(g)}}
   \;.

.. So

    .. math::

        r^{\op{resp}}_j = 12\cdot10^9 \cdot \op{a\_respRate\_c}
        \left( 12\cdot10^9 \cdot Q^{\mathrm{c}}_j \right)^{\op{b\_respRate\_c}-1}

    .. math::

       r^{\op{resp}}_j = 12\cdot10^9 \op{a\_respRate\_c}\cdot(12\cdot10^9 \cdot \op{a\_qcarbon})^{\op{b\_respRate\_c}-1}
                   \cdot V^{(\op{b\_respRate\_c}-1)\cdot\op{b\_qcarbon}}

The units of a_respRate_c are mmol C cell\ :sup:`--1` s\ :sup:`--1`.  It
now defaults to zero.  In the quota model, the default was 3.21·10\
:sup:`--11`/86400.
