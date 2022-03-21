.. include:: ../defs.hrst

.. _Mortality:

Mortality
^^^^^^^^^

Mortality stop at :math:`{c}_j^{\min}`:

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

   :varlink:`mort`            & :varlink:`a_mort`                & :math:`m^{(1)}_j`             & 0.02 / day       & s\ :sup:`-1`            & linear mortality rate
   :varlink:`mort2`           & :varlink:`a_mort2`               & :math:`m^{(2)}_j`             & 0                & m\ :sup:`3` s / mmol C  & quadratic mortality coefficient
   :varlink:`Xmin`            & :varlink:`a_Xmin`                & :math:`c^{\min}_j`            & 0                & mmol C m\ :sup:`-3`     & minimum abundance for mortality, respiration and exudation
   :varlink:`tempMort`        & :varlink:`grp_tempMort`          & :math:`e^{\op{m}}_j`          & 1                &                         & 1: mortality is temp. dependent, 0: not
   :varlink:`tempMort2`       & :varlink:`grp_tempMort2`         & :math:`e^{\op{m2}}_j`         & 1                &                         & 1: quadr.tic mortality is temperature dependent, 0: not
   :varlink:`ExportFracMort`  & :varlink:`a_ExportFracMort`      & :math:`f^{\op{exp}\op{m}}_j`  & 0.5              &                         & fraction of linear mortality to POM
   :varlink:`ExportFracMort2` & :varlink:`a_ExportFracMort2`     & :math:`f^{\op{exp}\op{m2}}_j` & 0.5              &                         & fraction of quadratic mortality to POM

