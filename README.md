# Relatório de Atividades — Laboratório de Banco de Dados: Fórmula 1

**Disciplina:** Banco de Dados  
**Atividade:** Implementação de Esquema Relacional e Carga de Dados

---

## 1. Descrição das Atividades

O trabalho consistiu na modelagem, criação e população de um banco de dados relacional com dados reais de Fórmula 1 e de dados geográficos auxiliares (GeoNames). O banco foi implementado em **PostgreSQL**.

As atividades foram divididas em duas etapas principais:

- **Criação das Tabelas** (`create_tables.sql`): definição do esquema relacional a partir do MER fornecido, incluindo chaves primárias, estrangeiras e restrições de unicidade.
- **Carga de Dados** (`load_data.sql`): ingestão dos dados a partir de arquivos CSV e TSV utilizando tabelas de staging temporárias, seguida de inserções relacionais nas tabelas finais.

---

## 2. Criação das Tabelas

O banco de dados contém **21 tabelas**, organizadas em camadas de dependência:

### Tabelas de Dimensão (sem dependências)
| Tabela | Descrição |
| :--- | :--- |
| `continents` | Continentes (AF, AS, EU, NA, OC, SA, AN) |
| `time_zones` | Fusos horários com offsets GMT/DST |
| `language_names` | Nomes de idiomas (GeoNames) |
| `feature_codes` | Códigos de entidades geográficas (GeoNames) |
| `airport_types` | Tipos de aeroporto (small, large, heliport…) |
| `status` | Status de corrida (Finished, Retired, Accident…) |
| `seasons` | Anos de temporada da F1 |

### Tabelas Relacionais Intermediárias
| Tabela | Descrição |
| :--- | :--- |
| `countries` | Países com link ao continente |
| `iso_language_codes` | Códigos ISO 639 vinculados a `language_names` |
| `country_languages` | Associativa N:M entre países e idiomas |

### Tabelas Geográficas
| Tabela | Descrição |
| :--- | :--- |
| `cities` | Cidades com >15.000 hab. (GeoNames), FK para país, tz e feature_code |
| `airports` | Aeroportos mundiais com FK para cidade e tipo |

### Tabelas de Fórmula 1
| Tabela | Descrição |
| :--- | :--- |
| `circuits` | Autódromos com FK para cidade |
| `constructors` | Escuderias |
| `drivers` | Pilotos |
| `races` | Corridas com FK para temporada e circuito |
| `results` | Resultados por piloto por corrida |
| `qualifying` | Tempos de classificação |
| `standings` | Tabela base de pontuações |
| `driver_standings` | Especialização de standings para pilotos |
| `constructor_standings` | Especialização de standings para escuderias |

---

## 3. Carga de Dados

A carga foi realizada em fases:

1. **Criação de tabelas de staging** (`UNLOGGED TABLE`) para receber os dados brutos sem restrições.
2. **Uso de `\copy`** para leitura dos arquivos locais (CSV e TSV) com client-side permissions, evitando erros de permissão do servidor PostgreSQL.
3. **Inserções relacionais**: os dados das staging tables foram mapeados para as tabelas finais com JOINs para resolver FKs.
4. **Tratamento de dados heterogêneos**: campos numéricos com strings não-numéricas (e.g., `R`, `D`) foram tratados com `CASE`/regex; datas e horários nulos foram convertidos via `NULLIF`; o arquivo `circuits.csv` foi lido com `ENCODING 'latin1'`.

### Arquivos de Origem

| Arquivo | Destino Principal |
| :--- | :--- |
| `countryInfo.txt` (GeoNames) | `countries`, `country_languages` |
| `countries.csv` | `countries` |
| `timeZones.tsv` | `time_zones` |
| `iso-languagecodes.tsv` | `language_names`, `iso_language_codes` |
| `featureCodes_en.tsv` | `feature_codes` |
| `cities15000.tsv` | `cities` |
| `airports.csv` | `airports`, `airport_types` |
| `circuits.csv` | `circuits` |
| `constructors.csv` | `constructors` |
| `drivers.csv` | `drivers` |
| `races.csv` | `races`, `seasons` |
| `results.csv` | `results`, `status` |
| `qualifying.csv` | `qualifying` |
| `driver_standings.csv` | `standings`, `driver_standings` |
| `constructor_standings.csv` | `standings`, `constructor_standings` |

---

## 4. Sumário de População das Tabelas

Resultado após execução completa do script `load_data.sql` no banco `f1_test`:

| Tabela | Registros |
| :--- | ---: |
| `airport_types` | 21 |
| `airports` | 84.958 |
| `circuits` | 76 |
| `cities` | 33.430 |
| `constructor_standings` | 1.016 |
| `constructors` | 168 |
| `continents` | 7 |
| `countries` | 249 |
| `country_languages` | 717 |
| `driver_standings` | 2.829 |
| `drivers` | 616 |
| `feature_codes` | 684 |
| `iso_language_codes` | 7.926 |
| `language_names` | 7.926 |
| `qualifying` | 3.016 |
| `races` | 1.146 |
| `results` | 7.600 |
| `seasons` | 76 |
| `standings` | 4.192 |
| `status` | 108 |
| `time_zones` | 418 |
| **Total** | **156.179** |

---
