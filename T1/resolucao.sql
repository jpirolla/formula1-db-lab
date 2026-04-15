/* ============================================================================================================
   T1 - Laboratório de Banco de Dados
   RESOLUÇÃO - ETAPA DE LIMPEZA, DEDUPLICAÇÃO E CONSULTAS
   
   Alvo: PostgreSQL
   Procedimentos executados na ordem requisitada:
   1. Inclusão de Nacionalidade e atualização de Entidades
   2. Deduplicação de Cidades (<1km e mesmo nome/país)
   3. Exercícios Práticos (Consultas DML)
============================================================================================================ */

BEGIN;

-----------------------------------------------------------------------------------------
-- PARTE 1 - Melhoria da Qualidade de Dados (Alteração do Esquema)
-----------------------------------------------------------------------------------------

-- 1. Incluir o atributo Nacionalidade na entidade Países (countries)
ALTER TABLE countries ADD COLUMN nationality VARCHAR(255);

-- Mapeamento empirico simplificado das nacionalidades mais comuns presentes na F1 para atualizar a tabela countries
-- (Utilizamos uma tabela temporária para aplicar as nacionalidades aos países com seus códigos)
CREATE TEMP TABLE tmp_nationality_map (
    country_code VARCHAR(2),
    nationality VARCHAR(255)
);

INSERT INTO tmp_nationality_map (country_code, nationality) VALUES
('GB', 'British'), ('IT', 'Italian'), ('DE', 'German'), ('FR', 'French'), 
('BR', 'Brazilian'), ('FI', 'Finnish'), ('ES', 'Spanish'), ('AU', 'Australian'), 
('US', 'American'), ('AT', 'Austrian'), ('JP', 'Japanese'), ('NL', 'Dutch'), 
('MX', 'Mexican'), ('CA', 'Canadian'), ('BE', 'Belgian'), ('CH', 'Swiss'), 
('MC', 'Monegasque'), ('NZ', 'New Zealander'), ('AR', 'Argentine'), ('SE', 'Swedish'),
('ZA', 'South African'), ('CO', 'Colombian'), ('VE', 'Venezuelan'), ('PL', 'Polish'),
('RU', 'Russian'), ('IN', 'Indian'), ('DK', 'Danish'), ('IE', 'Irish'), 
('PT', 'Portuguese'), ('UY', 'Uruguayan'), ('CL', 'Chilean'), ('TH', 'Thai'),
('ID', 'Indonesian'), ('MY', 'Malaysian'), ('CN', 'Chinese');

-- Atualiza a recem-criada coluna 'nationality' da tabela 'countries'
UPDATE countries c
SET nationality = t.nationality
FROM tmp_nationality_map t
WHERE c.code = t.country_code;

-- Adicionar atributo de referência (country_id) nas tabelas Drivers e Constructors
ALTER TABLE drivers ADD COLUMN country_id INTEGER REFERENCES countries(id);
ALTER TABLE constructors ADD COLUMN country_id INTEGER REFERENCES countries(id);

-- Atualizar o country_id realizando o match de strings
UPDATE drivers d
SET country_id = c.id
FROM countries c
WHERE lower(trim(c.nationality)) = lower(trim(d.nationality));

UPDATE constructors cons
SET country_id = c.id
FROM countries c
WHERE lower(trim(c.nationality)) = lower(trim(cons.nationality));

-- Remover campo textual nationality legado conforme solicitado
ALTER TABLE drivers DROP COLUMN nationality;
ALTER TABLE constructors DROP COLUMN nationality;


-----------------------------------------------------------------------------------------
-- PARTE 2 - Deduplicação da Entidade Cidades
-----------------------------------------------------------------------------------------

-- Criar a função matemática Haversine para cálculo de distância entre as cidades
CREATE OR REPLACE FUNCTION haversine_distance(lat1 FLOAT, lon1 FLOAT, lat2 FLOAT, lon2 FLOAT)
RETURNS FLOAT AS $$
DECLARE
    radius_km FLOAT := 6371.0;
    dlat FLOAT := RADIANS(lat2 - lat1);
    dlon FLOAT := RADIANS(lon2 - lon1);
    a FLOAT;
    c FLOAT;
BEGIN
    a := SIN(dlat/2) * SIN(dlat/2) + COS(RADIANS(lat1)) * COS(RADIANS(lat2)) * SIN(dlon/2) * SIN(dlon/2);
    -- Protecao contra a > 1 que causaria NAN em raros desvios de flutuacao
    IF a > 1.0 THEN a := 1.0; END IF;
    c := 2 * ASIN(SQRT(a));
    RETURN radius_km * c;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Coletar as estatísticas ANTES da deduplicação (Apenas referencial, se quiser validar)
-- SELECT COUNT(*) AS qtd_antes FROM cities;

-- Tabela temporaria de Mapeamento De-Para para cidades equivalentes usando CTE Recursiva (para resolver casos transitivos como A->B e B->C e evitar erro de FK)
-- Critérios: Mesmo pais e cidade (ascii_name pra ignorar acentos possiveis), diferenca de distancia menor que 1.0 km
CREATE TEMP TABLE city_mappings AS
WITH RECURSIVE pairs AS (
    SELECT 
        c1.id AS id_principal, 
        c2.id AS id_duplicado,
        haversine_distance(c1.latitude, c1.longitude, c2.latitude, c2.longitude) AS dist
    FROM cities c1
    JOIN cities c2 
      ON lower(trim(c1.ascii_name)) = lower(trim(c2.ascii_name))
     AND c1.country_id = c2.country_id
     AND c1.id < c2.id -- Garantir que associamos menor id como principal para evitar loop infinito
    WHERE c1.latitude IS NOT NULL AND c1.longitude IS NOT NULL
      AND c2.latitude IS NOT NULL AND c2.longitude IS NOT NULL
),
filtered_pairs AS (
    SELECT id_principal, id_duplicado 
    FROM pairs 
    WHERE dist < 1.0
),
transitive AS (
    -- Caso base: os pares identificados diretamente
    SELECT id_duplicado, id_principal AS id_novo
    FROM filtered_pairs
    
    UNION
    
    -- Passo recursivo: se meu 'id_novo' também é uma duplicata em outro par, eu pego a raiz
    SELECT t.id_duplicado, p.id_principal AS id_novo
    FROM transitive t
    JOIN filtered_pairs p ON t.id_novo = p.id_duplicado
)
-- Agrupamos para cada cidade que será deletada e elegemos o ID mais antigo (absoluto raiz)
SELECT id_duplicado, MIN(id_novo) AS id_novo
FROM transitive
GROUP BY id_duplicado;

-- Atualizar referências de Airports e Circuits para o novo ID consolidado raiz (id_novo)
UPDATE airports a
SET city_id = m.id_novo
FROM city_mappings m
WHERE a.city_id = m.id_duplicado;

UPDATE circuits c
SET city_id = m.id_novo
FROM city_mappings m
WHERE c.city_id = m.id_duplicado;

-- Excluir as cidades duplicadas mapeadas
DELETE FROM cities
WHERE id IN (SELECT id_duplicado FROM city_mappings);

-- Estatísticas DEPOIS
-- SELECT COUNT(*) AS qtd_depois FROM cities;


-----------------------------------------------------------------------------------------
-- PARTE 3 - Consultas (Exercícios)
-----------------------------------------------------------------------------------------

-- Exercício 1: Liste o total de pontos obtido por cada piloto, por ano e em ordem descendente.
-- Dica: Os pontos obtidos em cada corrida estão na tabela DriverStandings.
-- (Observação F1: driver_standings contem "pontos acumulados" ate aquela corrida `round`.
-- Assim, usamos MAX(points) na temporada, que eh o placar final do ano).
SELECT 
    d.given_name || ' ' || d.family_name AS piloto_nome,
    se.year AS ano,
    MAX(s.points) AS total_pontos
FROM driver_standings ds
JOIN standings s ON ds.standing_id = s.id
JOIN seasons se ON se.id = s.season_id
JOIN drivers d ON d.id = ds.driver_id
GROUP BY d.given_name, d.family_name, se.year
ORDER BY total_pontos DESC, se.year DESC;

-- Exercício 2: Nome do piloto que partiu mais vezes em primeiro lugar (grid) da história.
-- Apresente o nome completo do piloto e a quantidade de vezes.

SELECT 
    d.given_name || ' ' || d.family_name AS piloto_nome,
    COUNT(*) AS qtd_largadas_grid_1
FROM results r
JOIN drivers d ON d.id = r.driver_id
WHERE r.grid = 1
GROUP BY d.given_name, d.family_name
ORDER BY qtd_largadas_grid_1 DESC
FETCH FIRST 1 ROWS WITH TIES;

-- Exercício 3: Para cada país que sedia corridas, liste a quantidade de cidades 
-- e o número total de aeroportos existentes nesse país.
-- Dica: Filtre países com circuito antes
SELECT 
    c.name AS pais,
    COUNT(DISTINCT ci.id) AS qtd_cidades,
    COUNT(DISTINCT a.id) AS qtd_aeroportos
FROM countries c
JOIN cities ci ON ci.country_id = c.id
LEFT JOIN airports a ON a.city_id = ci.id
WHERE EXISTS (
    SELECT 1 
    FROM circuits cir
    JOIN cities cir_city ON cir_city.id = cir.city_id
    WHERE cir_city.country_id = c.id
)
GROUP BY c.id, c.name
ORDER BY c.name ASC;

COMMIT;
