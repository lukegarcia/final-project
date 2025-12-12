USE CATALOG cscie103_catalog_final;
USE SCHEMA gold;

CREATE OR REPLACE VIEW daily_energy_report_secure AS
SELECT *
FROM cscie103_catalog_final.gold.daily_energy_report
WHERE
    (
      is_member('Off_shore_county') 
      AND county IN (1, 10)          -- offshore counties
    )
    OR
    (
      is_member('Mainland_county')
      AND county NOT IN (1, 10)      -- all other counties
    );

GRANT SELECT ON VIEW daily_energy_report_secure TO `Off_shore_county`;
GRANT SELECT ON VIEW daily_energy_report_secure TO `Mainland_county`;

REVOKE SELECT ON TABLE cscie103_catalog_final.gold.daily_energy_report 
FROM `Off_shore_county`;

REVOKE SELECT ON TABLE cscie103_catalog_final.gold.daily_energy_report 
FROM `Mainland_county`;

