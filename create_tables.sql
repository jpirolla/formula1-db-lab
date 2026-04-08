
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
    FOREIGN KEY (circuit_id) REFERENCES circuits(id)
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
    FOREIGN KEY (constructor_id) REFERENCES constructors(id)
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
    FOREIGN KEY (status_id)      REFERENCES status(id)
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
    standing_id INTEGER NOT NULL,
    driver_id   INTEGER NOT NULL,
    PRIMARY KEY (standing_id, driver_id),
    FOREIGN KEY (standing_id) REFERENCES standings(id),
    FOREIGN KEY (driver_id)   REFERENCES drivers(id)
);


-- 21. CONSTRUCTOR_STANDINGS  (especialização de standings)

CREATE TABLE constructor_standings (
    standing_id    INTEGER NOT NULL,
    constructor_id INTEGER NOT NULL,
    PRIMARY KEY (standing_id, constructor_id),
    FOREIGN KEY (standing_id)    REFERENCES standings(id),
    FOREIGN KEY (constructor_id) REFERENCES constructors(id)
);
