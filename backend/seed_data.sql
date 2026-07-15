-- Clear existing data if any (except modules)
TRUNCATE TABLE ward_mapping RESTART IDENTITY CASCADE;
TRUNCATE TABLE field_officers RESTART IDENTITY CASCADE;

-- Insert Field Officers
-- Module 1: Water Utility (WU)
INSERT INTO field_officers (module_id, officer_name, phone_number, ward_from, ward_to) VALUES
(1, 'WU Officer 1', '9000000001', 1, 10),
(1, 'WU Officer 2', '9000000002', 11, 20),
(1, 'WU Officer 3', '9000000003', 21, 30),
(1, 'WU Officer 4', '9000000004', 31, 42);

-- Module 2: Solar Power (SP)
INSERT INTO field_officers (module_id, officer_name, phone_number, ward_from, ward_to) VALUES
(2, 'SP Officer 1', '9000000005', 1, 10),
(2, 'SP Officer 2', '9000000006', 11, 20),
(2, 'SP Officer 3', '9000000007', 21, 30),
(2, 'SP Officer 4', '9000000008', 31, 42);

-- Module 3: Pollution Monitoring (PM)
INSERT INTO field_officers (module_id, officer_name, phone_number, ward_from, ward_to) VALUES
(3, 'PM Officer 1', '9000000009', 1, 10),
(3, 'PM Officer 2', '9000000010', 11, 20),
(3, 'PM Officer 3', '9000000011', 21, 30),
(3, 'PM Officer 4', '9000000012', 31, 42);

-- Module 4: Vehicle Tracking (VT)
INSERT INTO field_officers (module_id, officer_name, phone_number, ward_from, ward_to) VALUES
(4, 'VT Officer 1', '9000000013', 1, 10),
(4, 'VT Officer 2', '9000000014', 11, 20),
(4, 'VT Officer 3', '9000000015', 21, 30),
(4, 'VT Officer 4', '9000000016', 31, 42);

-- Module 5: Water Body Levels (WB)
INSERT INTO field_officers (module_id, officer_name, phone_number, ward_from, ward_to) VALUES
(5, 'WB Officer 1', '9000000017', 1, 10),
(5, 'WB Officer 2', '9000000018', 11, 20),
(5, 'WB Officer 3', '9000000019', 21, 30),
(5, 'WB Officer 4', '9000000020', 31, 42);

-- Module 6: Garbage Monitoring (GM)
INSERT INTO field_officers (module_id, officer_name, phone_number, ward_from, ward_to) VALUES
(6, 'GM Officer 1', '9000000021', 1, 10),
(6, 'GM Officer 2', '9000000022', 11, 20),
(6, 'GM Officer 3', '9000000023', 21, 30),
(6, 'GM Officer 4', '9000000024', 31, 42);

-- Module 7: Smart Lighting (SL)
INSERT INTO field_officers (module_id, officer_name, phone_number, ward_from, ward_to) VALUES
(7, 'SL Officer 1', '9000000025', 1, 10),
(7, 'SL Officer 2', '9000000026', 11, 20),
(7, 'SL Officer 3', '9000000027', 21, 30),
(7, 'SL Officer 4', '9000000028', 31, 42);

-- Module 8: Weather Sensors (WS)
INSERT INTO field_officers (module_id, officer_name, phone_number, ward_from, ward_to) VALUES
(8, 'WS Officer 1', '9000000029', 1, 10),
(8, 'WS Officer 2', '9000000030', 11, 20),
(8, 'WS Officer 3', '9000000031', 21, 30),
(8, 'WS Officer 4', '9000000032', 31, 42);

-- Module 9: Health Management (HM)
INSERT INTO field_officers (module_id, officer_name, phone_number, ward_from, ward_to) VALUES
(9, 'HM Officer 1', '9000000033', 1, 10),
(9, 'HM Officer 2', '9000000034', 11, 20),
(9, 'HM Officer 3', '9000000035', 21, 30),
(9, 'HM Officer 4', '9000000036', 31, 42);


-- Generate Ward Mapping for all modules
-- Loop through modules (1 to 9) and map each ward (1 to 42) to the correct officer based on ward range
INSERT INTO ward_mapping (module_id, ward_no, officer_id)
SELECT 
    fo.module_id,
    w.ward,
    fo.officer_id
FROM field_officers fo
CROSS JOIN LATERAL generate_series(fo.ward_from, fo.ward_to) AS w(ward);
