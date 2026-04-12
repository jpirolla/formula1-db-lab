COMMENT ON TABLE Constructors IS 'Tabela de Escuderias';
COMMENT ON TABLE Driver IS 'Tabela de Pilotos';

COMMENT ON TABLE Circuits IS 'Tabela de Autódromos';
COMMENT ON COLUMN Circuits.Alt IS 'Altitude in meters';

COMMENT ON TABLE Races IS 'Dados e Métricas de cada corrida';
COMMENT ON COLUMN Races.Time IS 'Hora local de início da corrida e.g."13:00:00"';

COMMENT ON TABLE LapTimes IS 'Tempos e posições do piloto em cada volta da corrida';
COMMENT ON COLUMN LapTimes.Position IS 'Driver race position';
COMMENT ON COLUMN LapTimes.Time IS 'Lap time as text e.g. "1:43.762"';
COMMENT ON COLUMN LapTimes.Milliseconds IS 'Lap time in milliseconds e.g. 103762';

COMMENT ON TABLE PitStops IS 'Paradas no box de cada piloto em cada corrida';
COMMENT ON COLUMN PitStops.Time IS 'Time of stop during the race, e.g. "13:52:25"';
COMMENT ON COLUMN PitStops.Duration IS 'Duration of stop as text e.g. "21.783"';
COMMENT ON COLUMN PitStops.Milliseconds IS 'Duration of stop in milliseconds, e.g. 21783';

COMMENT ON TABLE Qualifying IS 'Primeiro, segundo e terceiro melhores tempos de cada piloto nas voltas de qualificação';
COMMENT ON COLUMN Qualifying.q1 IS 'Best quafying time';
COMMENT ON COLUMN Qualifying.q2 IS 'Second best quafying time';
COMMENT ON COLUMN Qualifying.q3 IS 'Third best quafying time';

COMMENT ON TABLE DriverStandings IS 'Pontuação obtida na corrida pelo Piloto';
COMMENT ON COLUMN DriverStandings.PositionText IS 'D: Disqualified; E: Excluded; F: Failed to qualify; N: Not classified; R: Retired; W: Withdrew';

COMMENT ON TABLE Results IS 'Dados de resultados de cada piloto em cada corrida';
COMMENT ON COLUMN Results.PositionText IS 'D: Disqualified; E: Excluded; F: Failed to qualify; N: Not classified; R: Retired; W: Withdrew';
COMMENT ON COLUMN Results.StatusId IS 'Código do enumerador de ocorrência na tabela "Status"';

COMMENT ON TABLE status IS 'Tabela de enumeração de ocorrências';


-- SELECT C.RelName, A.AttName, Coli, Col_Description(C.OID, Coli) 
    -- FROM Pg_Class C, Pg_Attribute A, Generate_series(1, C.RelNAtts-1) Coli
    -- WHERE A.AttRelID=C.OID AND A.AttNum=Coli 
          -- AND C.RelName !~'pg_' AND C.RelName !~'sql_' AND RelKind='r'

