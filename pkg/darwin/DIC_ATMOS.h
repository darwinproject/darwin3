C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/DIC_ATMOS.h,v 1.1 2009/05/29 18:32:50 stephd Exp $
C $Name:  $

       COMMON /INTERACT_ATMOS_NEEDS/
     &              co2atmos,
     &              total_atmos_carbon, total_ocean_carbon,
     &              total_atmos_carbon_year,
     &              total_ocean_carbon_year,
     &              total_atmos_carbon_start,
     &              total_ocean_carbon_start,
     &              total_atmos_carbon_ini,
     &              atpco2_ini

       _RL co2atmos(1000)
       _RL total_atmos_carbon
       _RL total_ocean_carbon
       _RL total_atmos_carbon_year
       _RL total_atmos_carbon_start
       _RL total_ocean_carbon_year
       _RL total_ocean_carbon_start
       _RL total_atmos_carbon_ini
       _RL atpco2_ini
