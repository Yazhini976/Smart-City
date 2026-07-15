-- ============================================================
-- SMART CITY COMMON DATABASE
-- This is the SINGLE Postgres database shared by the container
-- app AND all 9 module apps (UGSS, Water Utility, Solar Power,
-- Pollution, Vehicle Tracking, Water Body, Garbage, Smart
-- Lighting, Weather Sensors, Health Management).
--
-- CONVENTION FOR MODULE TEAMS:
-- Each module app must prefix its own tables with its module
-- key so nothing collides, e.g.:
--   ugss_pipelines, ugss_alerts
--   water_tanks, water_readings
--   solar_panels, solar_generation_log
--   pollution_stations, pollution_readings
--   vehicle_fleet, vehicle_positions
--   waterbody_sites, waterbody_readings
--   garbage_bins, garbage_routes
--   lighting_poles, lighting_status
--   weather_stations, weather_readings
--   health_facilities, health_beds, health_alerts
-- Every module table should carry a `citizen_id` or
-- `raised_by` FK back to citizens(id) wherever a complaint /
-- reading is tied to a person, so the whole platform stays
-- joinable through this one database.
-- ============================================================

CREATE TABLE IF NOT EXISTS citizens (
    id              SERIAL PRIMARY KEY,
    mobile_number   VARCHAR(15) UNIQUE NOT NULL,
    role            VARCHAR(20) NOT NULL DEFAULT 'citizen', -- 'citizen' or 'staff'
    name            VARCHAR(120),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Whitelist of staff mobile numbers. Only numbers listed here
-- ever see the citizen/staff role-selection popup.
CREATE TABLE IF NOT EXISTS staff_numbers (
    id              SERIAL PRIMARY KEY,
    mobile_number   VARCHAR(15) UNIQUE NOT NULL,
    department      VARCHAR(80),
    added_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- OTP records. otp_hash stores a SHA-256 hash, never plaintext.
CREATE TABLE IF NOT EXISTS otp_verifications (
    id              SERIAL PRIMARY KEY,
    mobile_number   VARCHAR(15) NOT NULL,
    otp_hash        VARCHAR(64) NOT NULL,
    captcha_id      VARCHAR(64),
    expires_at      TIMESTAMPTZ NOT NULL,
    verified        BOOLEAN NOT NULL DEFAULT false,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_otp_mobile ON otp_verifications(mobile_number);

-- Reference table naming the 9 modules, so the dashboard and
-- any admin tooling can drive off the DB instead of hardcoding.
CREATE TABLE IF NOT EXISTS modules (
    id              SERIAL PRIMARY KEY,
    module_key      VARCHAR(40) UNIQUE NOT NULL,
    display_name    VARCHAR(120) NOT NULL,
    subtitle        VARCHAR(160),
    sort_order      INT NOT NULL DEFAULT 0
);

INSERT INTO modules (module_key, display_name, subtitle, sort_order) VALUES
    ('ugss',        'UGSS Monitoring',    'Inflow, Overflow, Blockage Alerts', 1),
    ('water',       'Water Utility',      'Flow, Pressure, Tank Level',        2),
    ('solar',       'Solar Power',        'Generation, Feed-in, Battery',      3),
    ('pollution',   'Pollution Monitoring','AQI: PM2.5, NO2, CO',              4),
    ('vehicle',     'Vehicle Tracking',   'City Buses, Ambulances, Utility Vehicles', 5),
    ('waterbody',   'Water Body Levels',  'Tanks, Lakes, Reservoirs',          6),
    ('garbage',     'Garbage Monitoring', 'Bin Status, Route Completion, Alerts', 7),
    ('lighting',    'Smart Lighting',     'City Street Lights: Online/Offline',8),
    ('weather',     'Weather Sensors',    'Rainfall, Temp, Humidity, Wind',    9)
ON CONFLICT (module_key) DO NOTHING;

-- Complaints raised by citizens, tagged to a module.
CREATE TABLE IF NOT EXISTS complaints (
    id              SERIAL PRIMARY KEY,
    citizen_id      INT REFERENCES citizens(id),
    module_key      VARCHAR(40) REFERENCES modules(module_key),
    description     TEXT NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'open', -- open / in_progress / resolved
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    resolved_at     TIMESTAMPTZ
);
