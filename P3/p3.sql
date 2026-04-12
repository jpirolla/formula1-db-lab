-- FORMULA 1 DATABASE— SCRIPT DE CRIAÇÃO DE TABELAS
-- Remove tabelas existentes (ordem inversa das dependências)
DROP TABLE IF EXISTS constructor_standings CASCADE;
DROP TABLE IF EXISTS driver_standings      CASCADE;
DROP TABLE IF EXISTS standings             CASCADE;
DROP TABLE IF EXISTS qualifying            CASCADE;
DROP TABLE IF EXISTS results               CASCADE;
DROP TABLE IF EXISTS status                CASCADE;
DROP TABLE IF EXISTS races                 CASCADE;
DROP TABLE IF EXISTS seasons               CASCADE;
DROP TABLE IF EXISTS circuits              CASCADE;
DROP TABLE IF EXISTS constructors          CASCADE;
DROP TABLE IF EXISTS drivers               CASCADE;
DROP TABLE IF EXISTS airports              CASCADE;
DROP TABLE IF EXISTS airport_types         CASCADE;
DROP TABLE IF EXISTS cities                CASCADE;
DROP TABLE IF EXISTS feature_codes         CASCADE;
DROP TABLE IF EXISTS country_languages     CASCADE;
DROP TABLE IF EXISTS iso_language_codes    CASCADE;
DROP TABLE IF EXISTS language_names        CASCADE;
DROP TABLE IF EXISTS time_zones            CASCADE;
DROP TABLE IF EXISTS countries             CASCADE;
DROP TABLE IF EXISTS continents            CASCADE;


-- 1. CONTINENTS

CREATE TABLE continents (
    id   SERIAL      PRIMARY KEY,
    code VARCHAR(2)  UNIQUE NOT NULL,
    name VARCHAR(50) UNIQUE NOT NULL
);


-- 2. COUNTRIES

CREATE TABLE countries (
    id             INTEGER      PRIMARY KEY,      -- id proveniente do GeoNames
    code           VARCHAR(2)   UNIQUE NOT NULL,  -- ISO 3166-1 alpha-2
    name           TEXT         NOT NULL,
    wikipedia_link TEXT,
    keywords       TEXT,
    continent_id   INTEGER      NOT NULL,
    FOREIGN KEY (continent_id) REFERENCES continents(id)
);


-- 3. TIME_ZONES

CREATE TABLE time_zones (
    id         SERIAL        PRIMARY KEY,
    name       VARCHAR(100)  UNIQUE NOT NULL,
    gmt_offset NUMERIC(5,2)  NOT NULL,
    dst_offset NUMERIC(5,2)  NOT NULL,
    raw_offset NUMERIC(5,2)  NOT NULL
);


-- 4. LANGUAGE_NAMES

CREATE TABLE language_names (
    id   SERIAL PRIMARY KEY,
    name TEXT   UNIQUE NOT NULL
);


-- 5. ISO_LANGUAGE_CODES

CREATE TABLE iso_language_codes (
    id          SERIAL      PRIMARY KEY,
    iso_639_3   VARCHAR(10) UNIQUE,           -- 3-letter code
    iso_639_2   VARCHAR(10) UNIQUE,           -- 2-letter bibliographic
    iso_639_1   VARCHAR(5),                   -- 2-letter alpha-2 (may be NULL)
    language_id INTEGER     NOT NULL,
    FOREIGN KEY (language_id) REFERENCES language_names(id)
);


-- 6. COUNTRY_LANGUAGES  

CREATE TABLE country_languages (
    country_id  INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    PRIMARY KEY (country_id, language_id),
    FOREIGN KEY (country_id)  REFERENCES countries(id),
    FOREIGN KEY (language_id) REFERENCES language_names(id)
);


-- 7. FEATURE_CODES

CREATE TABLE feature_codes (
    id           SERIAL      PRIMARY KEY,
    feature_class CHAR(1)    NOT NULL,          
    feature_code VARCHAR(10) NOT NULL,         
    name         TEXT        NOT NULL,
    description  TEXT,
    UNIQUE (feature_class, feature_code)
);


-- 8. CITIES

CREATE TABLE cities (
    id                BIGINT          PRIMARY KEY,   
    name              TEXT            NOT NULL,
    ascii_name        TEXT,
    alternate_names   TEXT,
    latitude          NUMERIC(10,6)   NOT NULL,
    longitude         NUMERIC(10,6)   NOT NULL,
    feature_code_id   INTEGER,
    country_id        INTEGER,
    time_zone_id      INTEGER,
    cc2               VARCHAR(200),
    admin1_code       VARCHAR(20),
    admin2_code       VARCHAR(80),
    admin3_code       VARCHAR(20),
    admin4_code       VARCHAR(20),
    population        BIGINT,
    elevation         INTEGER,
    dem               INTEGER,
    modification_date DATE,
    FOREIGN KEY (feature_code_id) REFERENCES feature_codes(id),
    FOREIGN KEY (country_id)      REFERENCES countries(id),
    FOREIGN KEY (time_zone_id)    REFERENCES time_zones(id)
);


-- 9. AIRPORT_TYPES

CREATE TABLE airport_types (
    id   SERIAL      PRIMARY KEY,
    type VARCHAR(50) UNIQUE NOT NULL   
);


-- 10. AIRPORTS

CREATE TABLE airports (
    id                INTEGER     PRIMARY KEY,    
    ident             VARCHAR(10) UNIQUE NOT NULL,
    airport_type_id   INTEGER,
    name              TEXT        NOT NULL,
    latitude_deg      NUMERIC(10,6),
    longitude_deg     NUMERIC(10,6),
    elevation_ft      INTEGER,
    city_id           BIGINT,
    scheduled_service BOOLEAN,
    icao_code         VARCHAR(10),
    iata_code         VARCHAR(5),
    gps_code          VARCHAR(10),
    local_code        VARCHAR(10),
    home_link         TEXT,
    wikipedia_link    TEXT,
    keywords          TEXT,
    FOREIGN KEY (airport_type_id) REFERENCES airport_types(id),
    FOREIGN KEY (city_id)         REFERENCES cities(id)
);


-- 11. CIRCUITS

CREATE TABLE circuits (
    id            SERIAL      PRIMARY KEY,
    circuit_ref   VARCHAR(100) UNIQUE NOT NULL,   
    name          TEXT         NOT NULL,
    lat           NUMERIC(10,6),
    long          NUMERIC(10,6),
    city_id       BIGINT,
    wikipedia_url TEXT,
    FOREIGN KEY (city_id) REFERENCES cities(id)
);


-- 12. CONSTRUCTORS

CREATE TABLE constructors (
    id              SERIAL       PRIMARY KEY,
    constructor_ref VARCHAR(100) UNIQUE NOT NULL,   
    name            TEXT         NOT NULL,
    nationality     TEXT,
    country_id      INTEGER,
    wikipedia_url   TEXT,
    FOREIGN KEY (country_id) REFERENCES countries(id)
);


-- 13. DRIVERS

CREATE TABLE drivers (
    id          SERIAL       PRIMARY KEY,
    driver_ref  VARCHAR(100) UNIQUE NOT NULL,   
    given_name  TEXT         NOT NULL,
    family_name TEXT         NOT NULL,
    nationality TEXT,
    date_of_birth DATE
);


-- 14. SEASONS

CREATE TABLE seasons (
    id   SERIAL  PRIMARY KEY,
    year INTEGER UNIQUE NOT NULL
);


-- 15. RACES

CREATE TABLE races (
    id          SERIAL       PRIMARY KEY,
    race_ref    VARCHAR(20)  UNIQUE NOT NULL,   
    season_id   INTEGER      NOT NULL,
    round       INTEGER      NOT NULL,
    race_name   TEXT         NOT NULL,
    race_date   DATE,
    race_time   TIME,
    circuit_id  INTEGER      NOT NULL,
    FOREIGN KEY (season_id)  REFERENCES seasons(id),
    FOREIGN KEY (circuit_id) REFERENCES circuits(id),
    UNIQUE (season_id, round)
);


-- 16. STATUS

CREATE TABLE status (
    id     SERIAL PRIMARY KEY,
    status TEXT   UNIQUE NOT NULL    
);


-- 17. QUALIFYING

CREATE TABLE qualifying (
    id              SERIAL  PRIMARY KEY,
    race_id         INTEGER NOT NULL,
    driver_id       INTEGER NOT NULL,
    constructor_id  INTEGER NOT NULL,
    position        INTEGER,
    q1              VARCHAR(15),    
    q2              VARCHAR(15),
    q3              VARCHAR(15),
    FOREIGN KEY (race_id)        REFERENCES races(id),
    FOREIGN KEY (driver_id)      REFERENCES drivers(id),
    FOREIGN KEY (constructor_id) REFERENCES constructors(id),
    UNIQUE (race_id, driver_id)
);


-- 18. RESULTS

CREATE TABLE results (
    id              SERIAL         PRIMARY KEY,
    race_id         INTEGER        NOT NULL,
    driver_id       INTEGER        NOT NULL,
    constructor_id  INTEGER        NOT NULL,
    grid            INTEGER,
    position        INTEGER,
    position_order  INTEGER        NOT NULL,
    points          NUMERIC(8,2)   NOT NULL DEFAULT 0,
    laps            INTEGER,
    status_id       INTEGER        NOT NULL,
    FOREIGN KEY (race_id)        REFERENCES races(id),
    FOREIGN KEY (driver_id)      REFERENCES drivers(id),
    FOREIGN KEY (constructor_id) REFERENCES constructors(id),
    FOREIGN KEY (status_id)      REFERENCES status(id),
    UNIQUE (race_id, driver_id)
);


-- 19. STANDINGS  (tabela-base para standings de temporada)

CREATE TABLE standings (
    id        SERIAL         PRIMARY KEY,
    season_id INTEGER        NOT NULL,
    round     INTEGER        NOT NULL,
    position  INTEGER,
    points    NUMERIC(8,2)   NOT NULL DEFAULT 0,
    wins      INTEGER        NOT NULL DEFAULT 0,
    FOREIGN KEY (season_id) REFERENCES seasons(id)
);


-- 20. DRIVER_STANDINGS  (especialização de standings)

CREATE TABLE driver_standings (
    standing_id INTEGER PRIMARY KEY,
    driver_id   INTEGER NOT NULL,
    FOREIGN KEY (standing_id) REFERENCES standings(id),
    FOREIGN KEY (driver_id)   REFERENCES drivers(id)
);


-- 21. CONSTRUCTOR_STANDINGS  (especialização de standings)

CREATE TABLE constructor_standings (
    standing_id    INTEGER PRIMARY KEY,
    constructor_id INTEGER NOT NULL,
    FOREIGN KEY (standing_id)    REFERENCES standings(id),
    FOREIGN KEY (constructor_id) REFERENCES constructors(id)
);

-- FORMULA 1 DATABASE — DATA LOAD SCRIPT



-- 1. STAGING TABLES CLEANUP & CREATION


DROP TABLE IF EXISTS staging_country_info;
DROP TABLE IF EXISTS staging_feature_codes;
DROP TABLE IF EXISTS staging_timezones;
DROP TABLE IF EXISTS staging_languages;
DROP TABLE IF EXISTS staging_countries;
DROP TABLE IF EXISTS staging_cities;
DROP TABLE IF EXISTS staging_airports;
DROP TABLE IF EXISTS staging_circuits;
DROP TABLE IF EXISTS staging_constructors;
DROP TABLE IF EXISTS staging_drivers;
DROP TABLE IF EXISTS staging_races;
DROP TABLE IF EXISTS staging_results;
DROP TABLE IF EXISTS staging_qualifying;
DROP TABLE IF EXISTS staging_driver_standings;
DROP TABLE IF EXISTS staging_constructor_standings;

CREATE UNLOGGED TABLE staging_country_info (
    iso VARCHAR, iso3 VARCHAR, iso_numeric VARCHAR, fips VARCHAR, country VARCHAR, capital VARCHAR, area NUMERIC, population BIGINT, continent VARCHAR, tld VARCHAR, currency_code VARCHAR, currency_name VARCHAR, phone VARCHAR, postal_format VARCHAR, postal_regex VARCHAR, languages VARCHAR, geonameid BIGINT, neighbours VARCHAR, equivalentfipscode VARCHAR
);

CREATE UNLOGGED TABLE staging_feature_codes (
    class_code VARCHAR, name TEXT, description TEXT
);

CREATE UNLOGGED TABLE staging_timezones (
    country_code VARCHAR, timezone_id VARCHAR, gmt_offset NUMERIC, dst_offset NUMERIC, raw_offset NUMERIC
);

CREATE UNLOGGED TABLE staging_languages (
    iso_639_3 VARCHAR, iso_639_2 VARCHAR, iso_639_1 VARCHAR, language_name TEXT
);

CREATE UNLOGGED TABLE staging_countries (
    id INTEGER, code VARCHAR, name TEXT, continent VARCHAR, wikipedia_link TEXT, keywords TEXT
);

CREATE UNLOGGED TABLE staging_cities (
    geonameid BIGINT, name VARCHAR, asciiname VARCHAR, alternatenames TEXT, latitude NUMERIC, longitude NUMERIC, feature_class VARCHAR, feature_code VARCHAR, country_code VARCHAR, cc2 VARCHAR, admin1_code VARCHAR, admin2_code VARCHAR, admin3_code VARCHAR, admin4_code VARCHAR, population BIGINT, elevation INTEGER, dem INTEGER, timezone VARCHAR, modification_date DATE
);

CREATE UNLOGGED TABLE staging_airports (
    id VARCHAR, ident VARCHAR, type VARCHAR, name VARCHAR, latitude_deg VARCHAR, longitude_deg VARCHAR, elevation_ft VARCHAR, continent VARCHAR, iso_country VARCHAR, iso_region VARCHAR, municipality VARCHAR, scheduled_service VARCHAR, icao_code VARCHAR, iata_code VARCHAR, gps_code VARCHAR, local_code VARCHAR, home_link VARCHAR, wikipedia_link VARCHAR, keywords TEXT
);

CREATE UNLOGGED TABLE staging_circuits (
    circuit_id VARCHAR, name VARCHAR, lat VARCHAR, lng VARCHAR, locality VARCHAR, country VARCHAR, url VARCHAR
);

CREATE UNLOGGED TABLE staging_constructors (
    constructor_id VARCHAR, name VARCHAR, nationality VARCHAR, url VARCHAR
);

CREATE UNLOGGED TABLE staging_drivers (
    driver_id VARCHAR, forename VARCHAR, surname VARCHAR, nationality VARCHAR, dob VARCHAR
);

CREATE UNLOGGED TABLE staging_races (
    race_id VARCHAR, season INT, round INT, race_name VARCHAR, date VARCHAR, time VARCHAR, circuit_id VARCHAR
);

CREATE UNLOGGED TABLE staging_results (
    race_id VARCHAR, driver_id VARCHAR, constructor_id VARCHAR, grid VARCHAR, position VARCHAR, position_order VARCHAR, points VARCHAR, laps VARCHAR, status VARCHAR
);

CREATE UNLOGGED TABLE staging_qualifying (
    race_id VARCHAR, driver_id VARCHAR, constructor_id VARCHAR, position VARCHAR, q1 VARCHAR, q2 VARCHAR, q3 VARCHAR
);

CREATE UNLOGGED TABLE staging_driver_standings (
    season INT, round INT, driver_id VARCHAR, position VARCHAR, points VARCHAR, wins VARCHAR
);

CREATE UNLOGGED TABLE staging_constructor_standings (
    season INT, round INT, constructor_id VARCHAR, position VARCHAR, points VARCHAR, wins VARCHAR
);



-- 2. COPY COMMANDS


\copy staging_country_info FROM '/home/juliana/03.repositorios/02.projetos/formula1-db-lab/LabBD/countryInfo_clean.tsv' WITH (FORMAT csv, DELIMITER E'\t', NULL '');
\copy staging_feature_codes FROM '/home/juliana/03.repositorios/02.projetos/formula1-db-lab/LabBD/featureCodes_en.tsv' WITH (FORMAT csv, DELIMITER E'\t', NULL '');
\copy staging_timezones FROM '/home/juliana/03.repositorios/02.projetos/formula1-db-lab/LabBD/timeZones.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true, NULL '');
\copy staging_languages FROM '/home/juliana/03.repositorios/02.projetos/formula1-db-lab/LabBD/iso-languagecodes.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true, NULL '');
\copy staging_countries FROM '/home/juliana/03.repositorios/02.projetos/formula1-db-lab/LabBD/countries.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy staging_cities FROM '/home/juliana/03.repositorios/02.projetos/formula1-db-lab/LabBD/cities15000.tsv' WITH (FORMAT csv, DELIMITER E'\t', NULL '');
\copy staging_airports FROM '/home/juliana/03.repositorios/02.projetos/formula1-db-lab/LabBD/airports.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy staging_circuits FROM '/home/juliana/03.repositorios/02.projetos/formula1-db-lab/LabBD/circuits.csv' WITH (FORMAT csv, HEADER true, ENCODING 'latin1', NULL '');
\copy staging_constructors FROM '/home/juliana/03.repositorios/02.projetos/formula1-db-lab/LabBD/constructors.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy staging_drivers FROM '/home/juliana/03.repositorios/02.projetos/formula1-db-lab/LabBD/drivers.csv' WITH (FORMAT csv, HEADER true, NULL '\N');
\copy staging_races FROM '/home/juliana/03.repositorios/02.projetos/formula1-db-lab/LabBD/races.csv' WITH (FORMAT csv, HEADER true, NULL '\N');
\copy staging_results FROM '/home/juliana/03.repositorios/02.projetos/formula1-db-lab/LabBD/results.csv' WITH (FORMAT csv, HEADER true, NULL '\N');
\copy staging_qualifying FROM '/home/juliana/03.repositorios/02.projetos/formula1-db-lab/LabBD/qualifying.csv' WITH (FORMAT csv, HEADER true, NULL '\N');
\copy staging_driver_standings FROM '/home/juliana/03.repositorios/02.projetos/formula1-db-lab/LabBD/driver_standings.csv' WITH (FORMAT csv, HEADER true, NULL '\N');
\copy staging_constructor_standings FROM '/home/juliana/03.repositorios/02.projetos/formula1-db-lab/LabBD/constructor_standings.csv' WITH (FORMAT csv, HEADER true, NULL '\N');



-- 3. TRUNCATE FINAL TABLES

TRUNCATE TABLE constructor_standings, driver_standings, standings, qualifying, results, status, races, seasons, circuits, constructors, drivers, airports, airport_types, cities, feature_codes, country_languages, iso_language_codes, language_names, time_zones, countries, continents CASCADE;



-- 4. LOAD DIMENSIONS & LOOKUP TABLES


INSERT INTO continents (code, name)
SELECT DISTINCT TRIM(continent), TRIM(continent) FROM staging_countries WHERE continent IS NOT NULL AND continent != ''
ON CONFLICT DO NOTHING;

INSERT INTO time_zones (name, gmt_offset, dst_offset, raw_offset)
SELECT DISTINCT TRIM(timezone_id), gmt_offset, dst_offset, raw_offset FROM staging_timezones WHERE timezone_id IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO language_names (name)
SELECT DISTINCT TRIM(language_name) FROM staging_languages WHERE language_name IS NOT NULL AND language_name != ''
ON CONFLICT DO NOTHING;

INSERT INTO iso_language_codes (iso_639_3, iso_639_2, iso_639_1, language_id)
SELECT DISTINCT
    NULLIF(TRIM(sl.iso_639_3), ''),
    NULLIF(TRIM(sl.iso_639_2), ''),
    NULLIF(TRIM(sl.iso_639_1), ''),
    ln.id
FROM staging_languages sl
JOIN language_names ln ON ln.name = sl.language_name
ON CONFLICT DO NOTHING;

INSERT INTO feature_codes (feature_class, feature_code, name, description)
SELECT DISTINCT
    TRIM(split_part(class_code, '.', 1)),
    TRIM(split_part(class_code, '.', 2)),
    TRIM(name),
    TRIM(description)
FROM staging_feature_codes WHERE class_code LIKE '%.%'
ON CONFLICT DO NOTHING;

INSERT INTO airport_types (type)
SELECT DISTINCT TRIM(type) FROM staging_airports WHERE type IS NOT NULL AND type != ''
ON CONFLICT DO NOTHING;

INSERT INTO seasons (year)
SELECT DISTINCT season FROM staging_races ORDER BY season
ON CONFLICT DO NOTHING;

INSERT INTO status (status)
SELECT DISTINCT TRIM(status) FROM staging_results WHERE status IS NOT NULL AND status != ''
ON CONFLICT DO NOTHING;



-- 5. LOAD MAIN TABLES


-- Countries
INSERT INTO countries (id, code, name, wikipedia_link, keywords, continent_id)
SELECT DISTINCT sc.id, TRIM(sc.code), TRIM(sc.name), sc.wikipedia_link, sc.keywords, c.id
FROM staging_countries sc
JOIN continents c ON c.code = sc.continent
ON CONFLICT DO NOTHING;

-- Country Languages
INSERT INTO country_languages (country_id, language_id)
SELECT DISTINCT c.id, ilc.language_id
FROM staging_country_info sci
JOIN countries c ON c.code = sci.iso
CROSS JOIN LATERAL unnest(string_to_array(sci.languages, ',')) AS lang(lang_code)
JOIN iso_language_codes ilc ON (ilc.iso_639_1 = split_part(lang.lang_code, '-', 1) OR ilc.iso_639_3 = lang.lang_code)
ON CONFLICT DO NOTHING;

-- Cities
INSERT INTO cities (id, name, ascii_name, alternate_names, latitude, longitude, feature_code_id, country_id, time_zone_id, cc2, admin1_code, admin2_code, admin3_code, admin4_code, population, elevation, dem, modification_date)
SELECT 
    sc.geonameid, sc.name, sc.asciiname, sc.alternatenames, sc.latitude, sc.longitude,
    fc.id, c.id, tz.id,
    sc.cc2, sc.admin1_code, sc.admin2_code, sc.admin3_code, sc.admin4_code,
    sc.population, sc.elevation, sc.dem, sc.modification_date
FROM staging_cities sc
LEFT JOIN feature_codes fc ON fc.feature_class = sc.feature_class AND fc.feature_code = sc.feature_code
LEFT JOIN countries c ON c.code = sc.country_code
LEFT JOIN time_zones tz ON tz.name = sc.timezone
ON CONFLICT DO NOTHING;

-- Airports
INSERT INTO airports (id, ident, airport_type_id, name, latitude_deg, longitude_deg, elevation_ft, city_id, scheduled_service, iata_code, gps_code, local_code, home_link, wikipedia_link, keywords)
SELECT 
    CAST(sa.id AS INTEGER), TRIM(sa.ident), at.id, TRIM(sa.name), 
    CAST(NULLIF(NULLIF(sa.latitude_deg, '\N'), '') AS NUMERIC), 
    CAST(NULLIF(NULLIF(sa.longitude_deg, '\N'), '') AS NUMERIC), 
    CAST(NULLIF(NULLIF(sa.elevation_ft, '\N'), '') AS NUMERIC)::INTEGER,
    c.id,
    (LOWER(sa.scheduled_service) = 'yes' OR LOWER(sa.scheduled_service) = 'true'),
    sa.iata_code, sa.gps_code, sa.local_code,
    sa.home_link, sa.wikipedia_link, sa.keywords
FROM staging_airports sa
LEFT JOIN airport_types at ON at.type = sa.type
LEFT JOIN countries cy ON cy.code = sa.iso_country
LEFT JOIN cities c ON c.name = sa.municipality AND c.country_id = cy.id
ON CONFLICT DO NOTHING;

-- Circuits
INSERT INTO circuits (circuit_ref, name, lat, long, city_id, wikipedia_url)
SELECT 
    TRIM(sc.circuit_id), TRIM(sc.name), 
    CAST(NULLIF(NULLIF(sc.lat, '\N'), '') AS NUMERIC), 
    CAST(NULLIF(NULLIF(sc.lng, '\N'), '') AS NUMERIC),
    c.id, sc.url
FROM staging_circuits sc
LEFT JOIN countries cy ON (cy.name = sc.country OR cy.code = sc.country)
LEFT JOIN cities c ON (c.name = sc.locality AND c.country_id = cy.id)
ON CONFLICT DO NOTHING;

-- Constructors
INSERT INTO constructors (constructor_ref, name, nationality, wikipedia_url)
SELECT TRIM(constructor_id), TRIM(name), TRIM(nationality), url
FROM staging_constructors
ON CONFLICT DO NOTHING;

-- Drivers
INSERT INTO drivers (driver_ref, given_name, family_name, nationality, date_of_birth)
SELECT TRIM(driver_id), TRIM(forename), TRIM(surname), TRIM(nationality), CAST(NULLIF(NULLIF(dob, '\N'), '') AS DATE)
FROM staging_drivers
ON CONFLICT DO NOTHING;

-- Races
INSERT INTO races (race_ref, season_id, round, race_name, race_date, race_time, circuit_id)
SELECT 
    TRIM(sc.race_id), s.id, sc.round, TRIM(sc.race_name), 
    CAST(NULLIF(NULLIF(sc.date, '\N'), '') AS DATE), 
    CAST(NULLIF(NULLIF(sc.time, '\N'), '') AS TIME), 
    c.id
FROM staging_races sc
JOIN seasons s ON s.year = sc.season
JOIN circuits c ON c.circuit_ref = sc.circuit_id
ON CONFLICT DO NOTHING;

-- Qualifying
INSERT INTO qualifying (race_id, driver_id, constructor_id, position, q1, q2, q3)
SELECT r.id, d.id, c.id, 
    CASE WHEN sq.position ~ '^[0-9.]+$' THEN CAST(sq.position AS NUMERIC)::INTEGER ELSE NULL END, 
    sq.q1, sq.q2, sq.q3
FROM staging_qualifying sq
JOIN races r ON r.race_ref = sq.race_id
JOIN drivers d ON d.driver_ref = sq.driver_id
JOIN constructors c ON c.constructor_ref = sq.constructor_id
ON CONFLICT DO NOTHING;

-- Results
INSERT INTO results (race_id, driver_id, constructor_id, grid, position, position_order, points, laps, status_id)
SELECT r.id, d.id, c.id, 
    CASE WHEN sr.grid ~ '^[0-9.]+$' THEN CAST(sr.grid AS NUMERIC)::INTEGER ELSE NULL END, 
    CASE WHEN sr.position ~ '^[0-9.]+$' THEN CAST(sr.position AS NUMERIC)::INTEGER ELSE NULL END, 
    CASE WHEN sr.position_order ~ '^[0-9.]+$' THEN CAST(sr.position_order AS NUMERIC)::INTEGER ELSE NULL END, 
    CASE WHEN sr.points ~ '^[0-9.]+$' THEN CAST(sr.points AS NUMERIC) ELSE 0 END, 
    CASE WHEN sr.laps ~ '^[0-9.]+$' THEN CAST(sr.laps AS NUMERIC)::INTEGER ELSE NULL END, 
    st.id
FROM staging_results sr
JOIN races r ON r.race_ref = sr.race_id
JOIN drivers d ON d.driver_ref = sr.driver_id
JOIN constructors c ON c.constructor_ref = sr.constructor_id
JOIN status st ON st.status = sr.status
ON CONFLICT DO NOTHING;

ALTER TABLE standings ADD COLUMN IF NOT EXISTS temp_driver_ref VARCHAR;
ALTER TABLE standings ADD COLUMN IF NOT EXISTS temp_constructor_ref VARCHAR;

INSERT INTO standings (season_id, round, position, points, wins, temp_driver_ref)
SELECT s.id, ds.round, 
    CASE WHEN ds.position ~ '^[0-9.]+$' THEN CAST(ds.position AS NUMERIC)::INTEGER ELSE NULL END, 
    CASE WHEN ds.points ~ '^[0-9.]+$' THEN CAST(ds.points AS NUMERIC) ELSE 0 END, 
    CASE WHEN ds.wins ~ '^[0-9.]+$' THEN CAST(ds.wins AS NUMERIC)::INTEGER ELSE 0 END, 
    ds.driver_id
FROM staging_driver_standings ds
JOIN seasons s ON s.year = ds.season
ON CONFLICT DO NOTHING;

INSERT INTO driver_standings (standing_id, driver_id)
SELECT st.id, d.id
FROM standings st
JOIN drivers d ON d.driver_ref = st.temp_driver_ref
WHERE st.temp_driver_ref IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO standings (season_id, round, position, points, wins, temp_constructor_ref)
SELECT s.id, cs.round, 
    CASE WHEN cs.position ~ '^[0-9.]+$' THEN CAST(cs.position AS NUMERIC)::INTEGER ELSE NULL END, 
    CASE WHEN cs.points ~ '^[0-9.]+$' THEN CAST(cs.points AS NUMERIC) ELSE 0 END, 
    CASE WHEN cs.wins ~ '^[0-9.]+$' THEN CAST(cs.wins AS NUMERIC)::INTEGER ELSE 0 END, 
    cs.constructor_id
FROM staging_constructor_standings cs
JOIN seasons s ON s.year = cs.season
ON CONFLICT DO NOTHING;

INSERT INTO constructor_standings (standing_id, constructor_id)
SELECT st.id, c.id
FROM standings st
JOIN constructors c ON c.constructor_ref = st.temp_constructor_ref
WHERE st.temp_constructor_ref IS NOT NULL
ON CONFLICT DO NOTHING;

ALTER TABLE standings DROP COLUMN IF EXISTS temp_driver_ref;
ALTER TABLE standings DROP COLUMN IF EXISTS temp_constructor_ref;