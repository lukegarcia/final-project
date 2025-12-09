-- Please edit the sample below
CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.gold.county_weather_4hours_mv AS
SELECT 
cg.county_id, 
cg.county_name,
cg.longitude, 
cg.latitude,
wh.data_block_id, 
TO_DATE(wh.datetime, "yyyy-MM-dd") AS wh_observ_date,
FLOOR(EXTRACT(HOUR FROM wh.datetime) / 4) AS wh_observ_4hour,
AVG(wh.temperature) AS wh_temperature, 
AVG(wh.dewpoint) AS wh_dewpoint, 
AVG(wh.snowfall) AS wh_snowfall, 
AVG(wh.surface_pressure) AS wh_surface_pressure, 
AVG(wh.cloudcover_total) AS wh_cloudcover_total,
AVG(wh.cloudcover_low) AS wh_cloudcover_low,
AVG(wh.cloudcover_mid) AS wh_cloudcover_mid,
AVG(wh.cloudcover_high) AS wh_cloudcover_high,
AVG(wh.windspeed_10m) AS wh_windspeed_10m,
AVG(wh.winddirection_10m) AS wh_winddirection_10m,
AVG(wh.shortwave_radiation) AS wh_shortwave_radiation,
AVG(wh.direct_solar_radiation) AS wh_direct_solar_radiation,
AVG(wh.diffuse_radiation) AS wh_diffuse_radiation,
AVG(wf.temperature) AS wf_temperature,
AVG(wf.dewpoint) AS wf_dewpoint,
AVG(wf.cloudcover_total) AS wf_cloudcover_total,
AVG(wf.cloudcover_low) AS wf_cloudcover_low,
AVG(wf.cloudcover_mid) AS wf_cloudcover_mid,
AVG(wf.cloudcover_high) AS wf_cloudcover_high,
AVG(wf.10_metre_u_wind_component) AS wf_10_metre_u_wind_component,
AVG(wf.10_metre_v_wind_component) AS wf_10_metre_v_wind_component,
AVG(wf.direct_solar_radiation) AS wf_direct_solar_radiation,
AVG(wf.surface_solar_radiation_downwards) AS wf_surface_solar_radiation_downwards,
AVG(wf.snowfall) AS wf_snowfall,
AVG(wf.total_precipitation) AS wf_total_precipitation
FROM cscie103_catalog_final.silver.county_map cg INNER JOIN cscie103_catalog_final.silver.weather_hist_mv wh ON 
cg.county_id = wh.county_id INNER JOIN cscie103_catalog_final.silver.weather_forecast_mv wf ON 
cg.county_id = wf.county_id and wh.data_block_id = wf.data_block_id AND wh.datetime = wf.forecast_datetime
GROUP BY cg.county_id, cg.county_name, cg.longitude, cg.latitude, wh.data_block_id, wh_observ_date, wh_observ_4hour
;

CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.gold.county_energy_4hours_mv AS
SELECT 
t.county_id, 
t.county_name,
cm.latitude,
cm.longitude,
t.is_business,
t.is_consumption,
t.product_type_id,
t.product_type,
c.installed_capacity,
c.eic_count,
t.target,
ep.euros_per_mwh,
gp.highest_price_per_mwh,
gp.lowest_price_per_mwh,
t.datetime,
TO_DATE(t.datetime) as t_observ_date,
FLOOR(EXTRACT(HOUR FROM t.datetime)/4) as t_observ_4hour,
c.observ_date as c_observ_date,
gp.forecast_date as gp_forecast_date,
gp.origin_date as gp_origin_date,
ep.forecast_date as ep_forecast_date,
ep.origin_date as ep_origin_date,
t.data_block_id,
t.row_id,
t.prediction_unit_id
FROM cscie103_catalog_final.silver.train_mv t INNER JOIN cscie103_catalog_final.silver.client_mv c
ON t.county_id = c.county_id 
AND t.product_type_id = c.product_type_id
AND t.is_business = c.is_business
AND t.data_block_id = c.data_block_id 
INNER JOIN cscie103_catalog_final.silver.gas_prices_mv gp
ON t.data_block_id = gp.data_block_id 
INNER JOIN cscie103_catalog_final.silver.electricity_prices_mv ep
ON t.data_block_id = ep.data_block_id 
AND EXTRACT(HOUR FROM t.datetime)=EXTRACT(HOUR FROM ep.forecast_date)
INNER JOIN cscie103_catalog_final.silver.county_map cm
ON t.county_id = cm.county_id
;
CREATE OR REFRESH MATERIALIZED VIEW cscie103_catalog_final.gold.county_energy_weather_4hours_mv AS
SELECT distinct 
cw.*, 
ce.is_business,
ce.is_consumption,
ce.product_type_id,
ce.product_type,
ce.installed_capacity,
ce.eic_count,
ce.target,
ce.euros_per_mwh,
ce.highest_price_per_mwh,
ce.lowest_price_per_mwh,
ce.datetime,
ce.t_observ_date,
ce.t_observ_4hour,
ce.c_observ_date,
ce.gp_forecast_date,
ce.gp_origin_date,
ce.ep_forecast_date,
ce.ep_origin_date,
ce.row_id,
ce.prediction_unit_id
FROM cscie103_catalog_final.gold.county_weather_4hours_mv cw INNER JOIN
cscie103_catalog_final.gold.county_energy_4hours_mv ce ON
cw.county_id = ce.county_id AND
cw.data_block_id = ce.data_block_id;