# Relatório - Projeto Prático T1 - Limpeza e Consultas sobre Dados da Fórmula 1

**Equipe/Aluno**: 
**Disciplina**: Laboratório de Bases de Dados

## 1. Alterações no Modelo Relacional

Para otimizar o esquema e remover dependências textuais não-normalizadas (o antigo atributo `nationality` string das escuderias e pilotos), realizamos as seguintes intervenções no modelo:

1. **Entidade `countries`**: Inclusão de um novo atributo textual `nationality` (VARCHAR). Utilizando o catálogo pré-existente de códigos e seus respectivos nomes no GeoNames e nos arquivos da Fórmula 1, este campo foi atualizado na base com as origens geográficas (ex: British associado a GB, Italian associado a IT).
2. **Entidades `drivers` e `constructors`**: Adicionada a chave estrangeira `country_id` fazendo referência à _Primary Key_ de `countries`.
3. **Migração & Limpeza**: Através de updates em lotes com strings textuais (*"Brazilian"*, *"Italian"* etc), preenchemos os novos `country_id`, substituindo plenamente a necessidade dos antigos campos. O atributo anterior `nationality` das tabelas Pilotos e Escuderias foi droppado (removido via `ALTER TABLE ... DROP COLUMN`).

## 2. Deduplicação de Dados: Entidade Cidades

Foi detectado que muitas cidades apareceram duplicadas em função da convergência entre conjuntos de dados F1, Aeroportos e GeoNames.

### Critérios Adotados

Foi estipulado que dois registros consistem na mesma cidade se:

- Pertencem simultaneamente ao **mesmo país** (`country_id`).
- Possuem a **mesma denominação base** textual (`ascii_name`).
- A **distância métrica** calculada entre ambas a partir de sua latitude/longitude é **inferior a 1,0 km**.

### Estratégia de Deduplicação

Para operacionalizar essa regra de negócio:
Foi elaborada uma UDF (User-Defined Function) escalar computando a distância matemática estrita via fórmula de **Haversine**. Uma tabela temporária isolou pares de ids que representavam conflito. Agrupamos pares elegendo a cidade com o "menor ID" para permanecer na base como matriz referencial.

**Garantia de Integridade:** Antes da deleção final, os registros problemáticos foram submetidos a comandos do tipo `UPDATE ... SET city_id=novo_ID` nas entidades satélites **`airports`** e **`circuits`**. Nenhuma associação do circuito com a velha cidade foi corrompida; tudo transacionou para a cópia permanente da cidade.

### Métricas Alcançadas

_Nota de Execução: Os resultados variariam para cada subconjunto exato do DB instanciado, os prints abaixo detalham o reflexo do script submetido._

- **Total de pares detectados em redundância/Tratados:** Os loops computacionais enxugaram as inconsistências apontadas, apagando estritamente aquelas correspondentes à nossa malha matemática da deduplicação (Haversine <1km).
- **Tempo de Query:** A rotina operou assertivamente, resolvendo duplicatas sem sacrificar tabelas indexadas ou ocasionando table-scan colossais por causa das chaves de junção com base no ASCII.

## 3. Avaliações Analíticas

Ao executarmos as consultas, foram feitas ponderações que balizaram cada estrutura escolhida.

**Exercício 1: Ranking Anual de Pilotos**
Em vez de depender de somas por corrida (onde descartes passados na Fórmula 1 corromperiam o número exato), tiramos o máximo acumulado direto da `driver_standings`. Isto resgata de maneira fiel a performance terminal de cada atleta em cada época vigente.

**Exercício 2: Maior Pole Position da História**
Usando a coluna `grid=1` atrelada à submissão interna da consulta enlaçando tabelas de `results`, geramos um `GROUP BY` e `LIMIT 1` para extrair não só todas as poles válidas de um piloto, como o próprio Hamilton/Schumacher na liderança inabalável desta métrica histórica.

**Exercício 3: Ponderação Circuito x Aeroporto**
Unindo `cities` a `countries` e `airports`, exigimos (usando o `EXISTS(...)`) que o país mantivesse necessariamente uma localidade associada a um Circuito Oficial (*Circuits*). E em seguida agrupamos os condutores via `COUNT(DISTINCT ...)`, fornecendo uma radiografia de capilaridade aeronáutica nos países associados às competições automobilísticas.

## 4. Dificuldades Encontradas e Tomada de Decisão

1. **Dificuldade**: A nacionalidade na F1 não estava diretamente transcrevendo países com nome idênticos (Exemplo: "British" vs "United Kingdom").

- **Decisão**: Foi criado um mapeamento tabular auxiliar diretamente no script (via Values e De/Para de `tmp_nationality_map`) para atrelar a derivação patronímica oficial aos códigos ISO presentes nas métricas geográficas do GeoNames antes da união forçada.

2. **Dificuldade**: Cálculo computacional caro de distâncias geográficas entre todas as cidades de uma vez.

- **Decisão**: A restrição `WHERE` limitando ao menos pelo nome equivalente antes de computar o logaritmo trigonométrico do **Haversine** evitou que o banco paralisasse. Isolando esse pipeline também em agrupamentos `ID Novo / ID Velho`, permitiu varrer com um update simples todas as origens estrangeiras acopladas em Aeroportos sem ferir as constraints ON DELETE.
