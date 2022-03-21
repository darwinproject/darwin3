.. include:: ../defs.hrst

Exudation
^^^^^^^^^

If :varlink:`DARWIN_ALLOW_EXUDE` is defined, an additional per-element loss
term is introduced, e.g.,

.. math:: \partial_tp_j = \dots - E^{\mathrm{P}}_j

with

.. math:: E^{\mathrm{P}}_j = \kappa^{\op{exc}}_{{\mathrm{P}}\,j} ({c}_j - {c}_j^{\min}) Q^{\mathrm{P}}_j

and fed into organic matter pools, e.g.,

.. math:: \partial_t\op{DOP}= \dots + \sum_j (1 - f^{\exp\op{exude}}_j) E^{\mathrm{P}}_j

and

.. math:: \partial_t\op{POP}= \dots + \sum_j f^{\exp\op{exude}}_j E^{\mathrm{P}}_j

(Maybe should NOT use :math:`{c}_j^{\min}` in this case, or have a
separate one for each quota?)

.. csv-table:: Exudation parameters
   :delim: &
   :widths: 13,20,17,15,15,20
   :class: longtable
   :header: Trait, Param, Symbol, Default, Units, Description

   :varlink:`kexcc`           & :varlink:`a_kexcC`           & :math:`\kappa^{\op{exc}}_{\op{C} j}`  & 0·V\ :sup:`-0.33`         & s\ :sup:`-1` & exudation rate for carbon
   :varlink:`kexcn`           & :varlink:`a_kexcN`           & :math:`\kappa^{\op{exc}}_{\op{N} j}`  & 0·V\ :sup:`-0.33`         & s\ :sup:`-1` & exudation rate for nitrogen
   :varlink:`kexcp`           & :varlink:`a_kexcP`           & :math:`\kappa^{\op{exc}}_{\op{P} j}`  & 0.024/day·V\ :sup:`-0.33` & s\ :sup:`-1` & exudation rate for phosphorus
   :varlink:`kexcfe`          & :varlink:`a_kexcFe`          & :math:`\kappa^{\op{exc}}_{\op{Fe} j}` & 0.0/day                   & s\ :sup:`-1` & exudation rate for iron
   :varlink:`kexcsi`          & :varlink:`a_kexcSi`          & :math:`\kappa^{\op{exc}}_{\op{Si} j}` & 0.0/day                   & s\ :sup:`-1` & exudation rate for silica
   :varlink:`ExportFracExude` & :varlink:`a_ExportFracExude` & :math:`f^{\op{exp}\op{exude}}_j`      & UNINIT                    &              & fraction of exudation to POM

