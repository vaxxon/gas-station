-- Active: 1763009871852@@127.0.0.1@3306@gas_station
DROP DATABASE IF EXISTS gas_station;
CREATE DATABASE IF NOT EXISTS gas_station;
USE gas_station;

CREATE TABLE `country` (
  `country_id` int AUTO_INCREMENT NOT NULL,
  `name` varchar(300) NOT NULL,
  `short_code` varchar(3) NOT NULL,
  PRIMARY KEY (`country_id`)
);

CREATE TABLE `manufacturer` (
  `manufacturer_id` int AUTO_INCREMENT NOT NULL,
  `country_id` int NOT NULL,
  `name` varchar(300) NOT NULL,
  `website` varchar(300),
  PRIMARY KEY (`manufacturer_id`),
  FOREIGN KEY (`country_id`)
      REFERENCES `country`(`country_id`)
        ON DELETE RESTRICT
);

CREATE TABLE `unit` (
  `unit_id` int AUTO_INCREMENT NOT NULL,
  `short_code` varchar(6) NOT NULL,
  `name` varchar(300) NOT NULL,
  `mm` decimal(5,2) NOT NULL,
  PRIMARY KEY (`unit_id`)
);

CREATE TABLE `module_format` (
  `module_format_id` int AUTO_INCREMENT NOT NULL,
  `width_unit_id` int NOT NULL,
  `height_unit_id` int NOT NULL,
  `name` varchar(300) NOT NULL,
  `description` text,
  PRIMARY KEY (`module_format_id`),
  FOREIGN KEY (`width_unit_id`)
      REFERENCES `unit`(`unit_id`)
        ON DELETE RESTRICT,
  FOREIGN KEY (`height_unit_id`)
      REFERENCES `unit`(`unit_id`)
        ON DELETE RESTRICT
);

CREATE TABLE `module` (
  `module_id` int AUTO_INCREMENT NOT NULL,
  `module_format_id` int NOT NULL,
  `manufacturer_id` int NOT NULL,
  `name` varchar(300) NOT NULL,
  `width` int NOT NULL,
  `depth_mm` decimal(5,2) NOT NULL,
  `height` int NOT NULL,
  `instruction_manual_link` varchar(500),
  `pcb_version` varchar(200),
  `i2c_compatible` boolean,
  `midi_compatible` boolean,
  `is_power_unit` boolean,
  `pos_12V_draw` decimal(5,2),
  `neg_12V_draw` decimal(5,2),
  `pos_5V_draw` decimal(5,2),
  PRIMARY KEY (`module_id`),
  FOREIGN KEY (`manufacturer_id`)
      REFERENCES `manufacturer`(`manufacturer_id`)
        ON DELETE RESTRICT,
  FOREIGN KEY (`module_format_id`)
      REFERENCES `module_format`(`module_format_id`)
        ON DELETE RESTRICT
);

CREATE TABLE `module_function` (
  `module_function_id` int AUTO_INCREMENT NOT NULL,
  `name` varchar(300) NOT NULL,
  `description` text,
  PRIMARY KEY (`module_function_id`)
);

CREATE TABLE `module_module_function` (
  `module_id` int NOT NULL,
  `module_function_id` int NOT NULL,
  PRIMARY KEY (`module_id`, `module_function_id`),
  FOREIGN KEY (`module_id`)
      REFERENCES `module`(`module_id`)
        ON DELETE CASCADE,
  FOREIGN KEY (`module_function_id`)
      REFERENCES `module_function`(`module_function_id`)
        ON DELETE RESTRICT
);

CREATE TABLE `synth` (
  `synth_id` int AUTO_INCREMENT NOT NULL,
  `name` varchar(300) NOT NULL,
  `description` text,
  PRIMARY KEY (`synth_id`)
);

CREATE TABLE `case_model` (
  `case_model_id` int AUTO_INCREMENT NOT NULL,
  `manufacturer_id` int,
  `module_format_id` int,
  `name` varchar(300),
  `width` int,
  `max_depth_mm` decimal(5,2),
  `height` int,
  `instruction_manual_link` varchar(500),
  `is_power_unit` boolean,
  PRIMARY KEY (`case_model_id`),
  FOREIGN KEY (`manufacturer_id`)
      REFERENCES `manufacturer`(`manufacturer_id`)
        ON DELETE RESTRICT,
  FOREIGN KEY (`module_format_id`)
      REFERENCES `module_format`(`module_format_id`)
        ON DELETE RESTRICT
);

CREATE TABLE `case` (
  `case_id` int AUTO_INCREMENT NOT NULL,
  `case_model_id` int,
  `name` varchar(300),
  `description` text,
  `is_template` boolean,
  PRIMARY KEY (`case_id`),
  FOREIGN KEY (`case_model_id`)
      REFERENCES `case_model`(`case_model_id`)
        ON DELETE RESTRICT
);

CREATE TABLE `synth_case` (
  `case_id` int NOT NULL,
  `synth_id` int NOT NULL,
  PRIMARY KEY (`case_id`, `synth_id`),
  FOREIGN KEY (`synth_id`)
      REFERENCES `synth`(`synth_id`)
        ON DELETE CASCADE,
  FOREIGN KEY (`case_id`)
      REFERENCES `case`(`case_id`)
        ON DELETE CASCADE
);

CREATE TABLE `connection_type` (
  `connection_type_id` int AUTO_INCREMENT NOT NULL,
  `name` varchar(200) NOT NULL,
  `description` text,
  PRIMARY KEY (`connection_type_id`)
);

CREATE TABLE `patch` (
  `patch_id` int AUTO_INCREMENT NOT NULL,
  `synth_id` int,
  `case_id` int,
  `name` varchar(300) NOT NULL,
  PRIMARY KEY (`patch_id`),
  FOREIGN KEY (`case_id`)
      REFERENCES `case`(`case_id`)
        ON DELETE CASCADE,
  FOREIGN KEY (`synth_id`)
      REFERENCES `synth`(`synth_id`)
        ON DELETE CASCADE
);

CREATE TABLE `jack_format` (
  `jack_format_id` int AUTO_INCREMENT NOT NULL,
  `name` varchar(300) NOT NULL,
  `description` text,
  PRIMARY KEY (`jack_format_id`)
);

CREATE TABLE `jack` (
  `jack_id` int AUTO_INCREMENT NOT NULL,
  `jack_format_id` int NOT NULL,
  `module_id` int NOT NULL,
  `name` varchar(300) NOT NULL,
  `description` varchar(500),
  `type` enum('input', 'output', 'io') NOT NULL,
  `voltage_max` decimal(4,2),
  `voltage_min` decimal(4,2),
  `baud_rate` int,
  PRIMARY KEY (`jack_id`),
  FOREIGN KEY (`jack_format_id`)
      REFERENCES `jack_format`(`jack_format_id`)
        ON DELETE RESTRICT,
  FOREIGN KEY (`module_id`)
      REFERENCES `module`(`module_id`)
        ON DELETE CASCADE
);

CREATE TABLE `connection` (
  `connection_id` int AUTO_INCREMENT NOT NULL,
  `from_id` int NOT NULL,
  `to_id` int NOT NULL,
  `type_id` int NOT NULL,
  `normalized` boolean,
  PRIMARY KEY (`connection_id`),
  FOREIGN KEY (`to_id`)
      REFERENCES `jack`(`jack_id`)
        ON DELETE CASCADE,
  FOREIGN KEY (`from_id`)
      REFERENCES `jack`(`jack_id`)
        ON DELETE CASCADE,
  FOREIGN KEY (`type_id`)
      REFERENCES `connection_type`(`connection_type_id`)
        ON DELETE RESTRICT
);

CREATE TABLE `cable` (
  `connection_id` int NOT NULL,
  `patch_id` int NOT NULL,
  `hex_color_code` varchar(6) NOT NULL,
  PRIMARY KEY (`connection_id`, `patch_id`),
  FOREIGN KEY (`connection_id`)
      REFERENCES `connection`(`connection_id`)
        ON DELETE CASCADE,
  FOREIGN KEY (`patch_id`)
      REFERENCES `patch`(`patch_id`)
        ON DELETE CASCADE
);

CREATE TABLE `rack` (
  `rack_id` int AUTO_INCREMENT NOT NULL,
  `case_id` int NOT NULL,
  `module_format_id` int NOT NULL,
  `name` varchar(300) NOT NULL,
  `width` int NOT NULL,
  `max_depth_mm` decimal(5,2) NOT NULL,
  `height` int NOT NULL,
  `screw_type` enum('M2', 'M3') NOT NULL,
  `is_power_unit` boolean,
  PRIMARY KEY (`rack_id`, `case_id`),
  FOREIGN KEY (`case_id`)
      REFERENCES `case`(`case_id`)
        ON DELETE RESTRICT,
  FOREIGN KEY (`module_format_id`)
      REFERENCES `module_format`(`module_format_id`)
        ON DELETE RESTRICT
);

CREATE TABLE `module_rack` (
  `module_id` int NOT NULL,
  `rack_id` int NOT NULL,
  `case_id` int NOT NULL,
  PRIMARY KEY (`module_id`, `rack_id`, `case_id`),
  FOREIGN KEY (`rack_id`, `case_id`)
      REFERENCES `rack`(`rack_id`, `case_id`)
        ON DELETE CASCADE,
  FOREIGN KEY (`module_id`)
      REFERENCES `module`(`module_id`)
        ON DELETE RESTRICT
);

CREATE TABLE `jack_function` (
  `jack_function_id` int AUTO_INCREMENT NOT NULL,
  `name` varchar(300),
  `description` text,
  PRIMARY KEY (`jack_function_id`)
);

CREATE TABLE `jack_jack_function` (
  `jack_id` int NOT NULL,
  `jack_function_id` int NOT NULL,
  PRIMARY KEY (`jack_id`, `jack_function_id`),
  FOREIGN KEY (`jack_function_id`)
      REFERENCES `jack_function`(`jack_function_id`)
        ON DELETE RESTRICT,
  FOREIGN KEY (`jack_id`)
      REFERENCES `jack`(`jack_id`)
        ON DELETE CASCADE
);

CREATE TABLE `power_bus` (
  `power_bus_id` int AUTO_INCREMENT NOT NULL,
  `name` varchar(300) NOT NULL,
  `pos_12V_max` decimal(4,2) NOT NULL,
  `neg_12V_max` decimal(4,2) NOT NULL,
  `pos_5V_max` decimal(4,2) NOT NULL,
  `power_source` text,
  PRIMARY KEY (`power_bus_id`)
);

CREATE TABLE `case_model_power_bus` (
  `case_model_id` int NOT NULL,
  `power_bus_id` int NOT NULL,
  PRIMARY KEY (`case_model_id`, `power_bus_id`),
  FOREIGN KEY (`power_bus_id`)
      REFERENCES `power_bus`(`power_bus_id`)
        ON DELETE RESTRICT,
  FOREIGN KEY (`case_model_id`)
      REFERENCES `case_model`(`case_model_id`)
        ON DELETE CASCADE
);

CREATE TABLE `rack_power_bus` (
  `rack_id` int NOT NULL,
  `case_id` int NOT NULL,
  `power_bus_id` int NOT NULL,
  PRIMARY KEY (`rack_id`, `power_bus_id`),
  FOREIGN KEY (`rack_id`, `case_id`)
      REFERENCES `rack`(`rack_id`, `case_id`)
        ON DELETE CASCADE,
  FOREIGN KEY (`power_bus_id`)
      REFERENCES `power_bus`(`power_bus_id`)
        ON DELETE RESTRICT
);

CREATE TABLE `module_power_bus` (
  `power_bus_id` int NOT NULL,
  `module_id` int NOT NULL,
  PRIMARY KEY (`power_bus_id`, `module_id`),
  FOREIGN KEY (`module_id`)
      REFERENCES `module`(`module_id`)
        ON DELETE CASCADE,
  FOREIGN KEY (`power_bus_id`)
      REFERENCES `power_bus`(`power_bus_id`)
        ON DELETE RESTRICT
);

-- Views

-- select all modules in a rack
CREATE VIEW `rack_modules` AS
  SELECT r.name as `Rack`, m.name as `Module`
  FROM `module` m
  JOIN module_rack mr ON mr.module_id = m.module_id
  JOIN rack r ON r.rack_id = mr.rack_id
  WHERE r.rack_id = '1';

-- select all modules in a case
CREATE VIEW `case_modules` AS
  SELECT c.name AS `Case`, m.name AS `Module`
  FROM `module` m
  JOIN `module_rack` mr ON mr.module_id = m.module_id
  JOIN rack r ON r.rack_id = mr.rack_id AND r.case_id = mr.case_id
  JOIN `case` c ON c.case_id = r.case_id
  WHERE c.case_id = '1';

-- select all modules in a synth
CREATE VIEW `synth_modules` AS
  SELECT s.name AS Synth, m.name AS `Module`
  FROM `module` m
  JOIN `module_rack` mr ON mr.module_id = m.module_id
  JOIN rack r ON r.rack_id = mr.rack_id AND r.case_id = mr.case_id
  JOIN synth_case sc ON sc.case_id = r.case_id
  JOIN synth s ON s.synth_id = sc.synth_id
  WHERE s.synth_id = '1';

-- select all connections in a patch
CREATE VIEW `patch_connections` AS
  SELECT cb.hex_color_code, c.connection_id, c.from_id, c.to_id, c.type_id
  FROM cable cb
  JOIN `connection` c ON cb.connection_id = c.connection_id
  WHERE cb.patch_id = '1'; 

-- calculate total power draw of a case
CREATE VIEW `case_power_draw` AS    
    SELECT
        c.case_id,
        SUM(m.pos_12V_draw) AS total_pos_12V_draw,
        SUM(m.neg_12V_draw) AS total_neg_12V_draw,
        SUM(m.pos_5V_draw) AS total_pos_5V_draw
    FROM `case` AS c
    JOIN rack AS r
    ON r.case_id = c.case_id
    JOIN module_rack AS mr
    ON mr.rack_id = r.rack_id
    JOIN `module` AS m
    ON m.module_id = mr.module_id
    WHERE c.case_id = '1'
    GROUP BY c.case_id;

-- Transactions

-- swap cases in a synth
START TRANSACTION;
DELETE FROM synth_case
WHERE synth_id = 1
    AND case_id = 2;
INSERT INTO synth_case (synth_id, case_id)
	VALUES (1, 3);
COMMIT;

-- Triggers
CREATE TRIGGER trim_module_name
BEFORE INSERT ON `module`
FOR EACH ROW SET NEW.name = TRIM(NEW.name);