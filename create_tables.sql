-- =========================
-- COUNTRIES
-- =========================
CREATE TABLE countries (
  id SERIAL PRIMARY KEY,
  code VARCHAR(3) UNIQUE NOT NULL,
  name TEXT NOT NULL,
  continent TEXT,
  wikipediaLink TEXT,
  keywords TEXT
);

-- =========================
-- CIRCUITS
-- =========================
CREATE TABLE circuits (
  circuitId SERIAL PRIMARY KEY,
  circuitRef TEXT,
  name TEXT NOT NULL,
  location TEXT,
  country VARCHAR(3),
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  alt INTEGER,
  url TEXT
);

-- =========================
-- CONSTRUCTORS
-- =========================
CREATE TABLE constructors (
  constructorId SERIAL PRIMARY KEY,
  constructorRef TEXT,
  name TEXT NOT NULL,
  nationality TEXT,
  url TEXT
);

-- =========================
-- DRIVERS
-- =========================
CREATE TABLE drivers (
  driverId SERIAL PRIMARY KEY,
  driverRef TEXT,
  number INTEGER,
  code VARCHAR(3),
  forename TEXT,
  surname TEXT,
  dateOfBirth DATE,
  nationality TEXT,
  url TEXT
);

-- =========================
-- SEASONS
-- =========================
CREATE TABLE seasons (
  year INTEGER PRIMARY KEY,
  url TEXT
);

-- =========================
-- RACES
-- =========================
CREATE TABLE races (
  raceId SERIAL PRIMARY KEY,
  year INTEGER,
  round INTEGER,
  circuitId INTEGER,
  name TEXT,
  date DATE,
  time TIME,
  url TEXT,

  FOREIGN KEY (year) REFERENCES seasons(year),
  FOREIGN KEY (circuitId) REFERENCES circuits(circuitId)
);

-- =========================
-- STATUS
-- =========================
CREATE TABLE status (
  statusId SERIAL PRIMARY KEY,
  status TEXT
);

-- =========================
-- RESULTS
-- =========================
CREATE TABLE results (
  resultId SERIAL PRIMARY KEY,
  raceId INTEGER,
  driverId INTEGER,
  constructorId INTEGER,
  number INTEGER,
  grid INTEGER,
  position INTEGER,
  positionText TEXT,
  positionOrder INTEGER,
  points DOUBLE PRECISION,
  laps INTEGER,
  time TEXT,
  milliseconds INTEGER,
  fastestLap INTEGER,
  rank INTEGER,
  fastestLapTime TEXT,
  fastestLapSpeed TEXT,
  statusId INTEGER,

  FOREIGN KEY (raceId) REFERENCES races(raceId) ON DELETE CASCADE,
  FOREIGN KEY (driverId) REFERENCES drivers(driverId),
  FOREIGN KEY (constructorId) REFERENCES constructors(constructorId),
  FOREIGN KEY (statusId) REFERENCES status(statusId)
);

-- =========================
-- LAPTIMES
-- =========================
CREATE TABLE laptimes (
  raceId INTEGER,
  driverId INTEGER,
  lap INTEGER,
  position INTEGER,
  time TEXT,
  milliseconds INTEGER,

  PRIMARY KEY (raceId, driverId, lap),

  FOREIGN KEY (raceId) REFERENCES races(raceId) ON DELETE CASCADE,
  FOREIGN KEY (driverId) REFERENCES drivers(driverId)
);

-- =========================
-- PITSTOPS
-- =========================
CREATE TABLE pitstops (
  raceId INTEGER,
  driverId INTEGER,
  stop INTEGER,
  lap INTEGER,
  time TEXT,
  duration TEXT,
  milliseconds INTEGER,

  PRIMARY KEY (raceId, driverId, stop),

  FOREIGN KEY (raceId) REFERENCES races(raceId) ON DELETE CASCADE,
  FOREIGN KEY (driverId) REFERENCES drivers(driverId)
);

-- =========================
-- QUALIFYING
-- =========================
CREATE TABLE qualifying (
  qualifyId SERIAL PRIMARY KEY,
  raceId INTEGER,
  driverId INTEGER,
  constructorId INTEGER,
  number INTEGER,
  position INTEGER,
  q1 TEXT,
  q2 TEXT,
  q3 TEXT,

  FOREIGN KEY (raceId) REFERENCES races(raceId) ON DELETE CASCADE,
  FOREIGN KEY (driverId) REFERENCES drivers(driverId),
  FOREIGN KEY (constructorId) REFERENCES constructors(constructorId)
);

-- =========================
-- DRIVER STANDINGS
-- =========================
CREATE TABLE driver_standings (
  driverStandingsId SERIAL PRIMARY KEY,
  raceId INTEGER,
  driverId INTEGER,
  points DOUBLE PRECISION,
  position INTEGER,
  positionText TEXT,
  wins INTEGER,

  FOREIGN KEY (raceId) REFERENCES races(raceId) ON DELETE CASCADE,
  FOREIGN KEY (driverId) REFERENCES drivers(driverId)
);

-- =========================
-- AIRPORTS
-- =========================
CREATE TABLE airports (
  id SERIAL PRIMARY KEY,
  ident TEXT,
  type TEXT,
  name TEXT,
  latDeg DOUBLE PRECISION,
  longDeg DOUBLE PRECISION,
  elevFt INTEGER,
  continent TEXT,
  isoCountry VARCHAR(3),
  isoRegion TEXT,
  city TEXT,
  scheduled_service BOOLEAN,
  gpsCode TEXT,
  iataCode TEXT,
  localCode TEXT,
  homeLink TEXT,
  wikipediaLink TEXT,
  keywords TEXT,

  FOREIGN KEY (isoCountry) REFERENCES countries(code)
);

-- =========================
-- GEOCITIES15K
-- =========================
CREATE TABLE geocities15k (
  geonameId BIGINT PRIMARY KEY,
  name TEXT,
  asciiName TEXT,
  alternateNames TEXT,
  lat DOUBLE PRECISION,
  long DOUBLE PRECISION,
  featureClass TEXT,
  featureCode TEXT,
  country VARCHAR(3),
  cc2 TEXT,
  admin1Code TEXT,
  admin2Code TEXT,
  admin3Code TEXT,
  admin4Code TEXT,
  population BIGINT,
  elevation INTEGER,
  dem INTEGER,
  timeZone TEXT,
  modificationDate DATE,

  FOREIGN KEY (country) REFERENCES countries(code)
);
-- Sobre tipagem
-- DOUBLE PRECISION -> coordenadas
-- TEXT -> mais flexível 
-- SERIAL -> auto incremento (pesquisar melhor depois)
