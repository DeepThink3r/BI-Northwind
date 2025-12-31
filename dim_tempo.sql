--Cria tabela caso não exista

DROP TABLE IF EXISTS dw.dim_tempo;

CREATE TABLE dw.dim_tempo (
    sk_tempo        INTEGER PRIMARY KEY,  
    data_completa   DATE NOT NULL,
    ano             INTEGER,
    mes             INTEGER,
    dia             INTEGER,
    dia_ano         INTEGER,
    trimestre       INTEGER,
    semestre        INTEGER,
    nome_mes        VARCHAR(20),
    nome_dia_semana VARCHAR(20),
    dia_semana_num  INTEGER,
    fim_semana      BOOLEAN,
    mes_ano         VARCHAR(10)
);

-- Cria um índice para acelerar filtros por data
CREATE INDEX idx_dim_tempo_data ON dw.dim_tempo(data_completa);

-- Inserindo data

INSERT INTO dw.dim_tempo
SELECT
    -- Criação da chave inteira YYYYMMDD
    TO_CHAR(datum, 'YYYYMMDD')::INTEGER AS sk_tempo,
    
    datum AS data_completa,
    
    EXTRACT(YEAR FROM datum) AS ano,
    EXTRACT(MONTH FROM datum) AS mes,
    EXTRACT(DAY FROM datum) AS dia,
    EXTRACT(DOY FROM datum) AS dia_ano,
    EXTRACT(QUARTER FROM datum) AS trimestre,
    
    -- Cálculo do Semestre
    CASE WHEN EXTRACT(QUARTER FROM datum) <= 2 THEN 1 ELSE 2 END AS semestre,
    
    -- Nome do Mês
    CASE EXTRACT(MONTH FROM datum)
        WHEN 1 THEN 'Janeiro'
        WHEN 2 THEN 'Fevereiro'
        WHEN 3 THEN 'Março'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Maio'
        WHEN 6 THEN 'Junho'
        WHEN 7 THEN 'Julho'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Setembro'
        WHEN 10 THEN 'Outubro'
        WHEN 11 THEN 'Novembro'
        WHEN 12 THEN 'Dezembro'
    END AS nome_mes,
    
    -- Nome do Dia da Semana em PT-BR
    CASE EXTRACT(ISODOW FROM datum)
        WHEN 1 THEN 'Segunda-feira'
        WHEN 2 THEN 'Terça-feira'
        WHEN 3 THEN 'Quarta-feira'
        WHEN 4 THEN 'Quinta-feira'
        WHEN 5 THEN 'Sexta-feira'
        WHEN 6 THEN 'Sábado'
        WHEN 7 THEN 'Domingo'
    END AS nome_dia_semana,
    
    -- Número do dia da semana
    EXTRACT(ISODOW FROM datum) AS dia_semana_num,
    
    -- Flag de Fim de Semana (6=Sábado, 7=Domingo no ISO)
    CASE WHEN EXTRACT(ISODOW FROM datum) IN (6, 7) THEN TRUE ELSE FALSE END AS fim_semana,

    -- Coluna auxiliar para ordenar gráficos "Mês-Ano"
    TO_CHAR(datum, 'Mon-YY') AS mes_ano

FROM (
    -- DEFINA AQUI O PERÍODO DE DATAS
    -- ::date converte a string para data
    -- '1 day'::interval define o passo (dia a dia)
    SELECT generate_series('2017/01/01'::date, '2032/12/31'::date, '1 day'::interval)::date AS datum
) t;

select * from dw.dim_tempo

delete from dw.dim_tempo 