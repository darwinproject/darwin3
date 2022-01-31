.. include:: ../defs.hrst

.. _CarbonChemistry:

Carbon chemistry
^^^^^^^^^^^^^^^^

Carbon and oxygen surface fluxes are handled similarly to the
:ref:`sub_pkg_dic`.

.. csv-table:: Carbon parameters
   :delim: &
   :widths: auto
   :header: Name, Default, Units, Description

   :varlink:`m3perkg`                & 1 / 1024.5            & m\ :sup:`3`/kg                   & constant for converting per kg to per m^3
   :varlink:`surfSaltMinInit`        & 4.0                   & g/kg                             & limits for carbon solver input at initialization
   :varlink:`surfSaltMaxInit`        & 50.0                  & g/kg                             & ...
   :varlink:`surfTempMinInit`        & --4.0                 & °C                               &
   :varlink:`surfTempMaxInit`        & 39.0                  & °C                               &
   :varlink:`surfDICMinInit`         & 10.0                  & mmol C m\ :sup:`-3`              &
   :varlink:`surfDICMaxInit`         & 4000.0                & mmol C m\ :sup:`-3`              &
   :varlink:`surfALKMinInit`         & 10.0                  & meq m\ :sup:`-3`                 &
   :varlink:`surfALKMaxInit`         & 4000.0                & meq m\ :sup:`-3`                 &
   :varlink:`surfPO4MinInit`         & 1D-10                 & mmol P m\ :sup:`-3`              &
   :varlink:`surfPO4MaxInit`         & 10.0                  & mmol P m\ :sup:`-3`              &
   :varlink:`surfSiMinInit`          & 1D-8                  & mmol Si m\ :sup:`-3`             &
   :varlink:`surfSiMaxInit`          & 500.0                 & mmol Si m\ :sup:`-3`             &
   :varlink:`surfSaltMin`            & 4.0                   & g/kg                             & limits for carbon solver input during run
   :varlink:`surfSaltMax`            & 50.0                  & g/kg                             & ...
   :varlink:`surfTempMin`            & --4.0                 & °C                               &
   :varlink:`surfTempMax`            & 39.0                  & °C                               &
   :varlink:`surfDICMin`             & 400.0                 & mmol C m\ :sup:`-3`              &
   :varlink:`surfDICMax`             & 4000.0                & mmol C m\ :sup:`-3`              &
   :varlink:`surfALKMin`             & 400.0                 & meq m\ :sup:`-3`                 &
   :varlink:`surfALKMax`             & 4000.0                & meq m\ :sup:`-3`                 &
   :varlink:`surfPO4Min`             & 1D-10                 & mmol P m\ :sup:`-3`              &
   :varlink:`surfPO4Max`             & 10.0                  & mmol P m\ :sup:`-3`              &
   :varlink:`surfSiMin`              & 1D-8                  & mmol Si m\ :sup:`-3`             &
   :varlink:`surfSiMax`              & 500.0                 & mmol Si m\ :sup:`-3`             &
