-- =========================================
-- 3. POPULANDO CLIENTES E PRODUTOS
-- =========================================
INSERT INTO clientes (nome)
SELECT 'Cliente_' || generate_series(1, 50);

INSERT INTO produtos (tipo)
VALUES 
('Renda Fixa'),
('Fundos'),
('Acoes');

-- =========================================
-- 4. GERANDO TRANSAÇÕES (6 meses)
-- =========================================
INSERT INTO transacoes (id_cliente, id_produto, data, tipo, valor)
SELECT 
    c.id_cliente,
    p.id_produto,
    d::date,
    CASE WHEN random() > 0.5 THEN 'entrada' ELSE 'saida' END,
    ROUND((random() * 5000 + 100)::numeric, 2)
FROM clientes c
CROSS JOIN produtos p
CROSS JOIN generate_series('2025-01-01'::date, '2025-06-30', interval '7 day') d;

-- =========================================
-- 5. GERANDO POSIÇÃO DE CUSTÓDIA (COM ERROS)
-- =========================================
INSERT INTO posicao_custodia (id_cliente, id_produto, data, saldo)
SELECT
    t.id_cliente,
    t.id_produto,
    t.data,
    SUM(
        CASE 
            WHEN t.tipo = 'entrada' THEN t.valor
            ELSE -t.valor
        END
    ) OVER (PARTITION BY t.id_cliente, t.id_produto ORDER BY t.data)
    + CASE 
        WHEN random() < 0.1 THEN (random() * 2000) -- ERRO intencional
        ELSE 0
      END
FROM transacoes t;

-- =========================================
-- 6. GERANDO POSIÇÃO CONTÁBIL (OUTRA FONTE)
-- =========================================
INSERT INTO posicao_contabil (id_cliente, id_produto, data, saldo)
SELECT
    id_cliente,
    id_produto,
    data,
    saldo + (random() * 500 - 250) -- pequenas divergências
FROM posicao_custodia;

-- =========================================
-- 7. GERANDO DADOS DE CONCORRENTES
-- =========================================
INSERT INTO concorrentes (data, auc_total)
SELECT
    d::date,
    ROUND((1000000 + random() * 500000)::numeric, 2)
FROM generate_series('2025-01-01'::date, '2025-06-30', interval '1 month') d;

-- =========================================
-- 8. EXEMPLOS DE CONSULTAS (para validar)
-- =========================================

-- AUC total por mês
SELECT 
    date_trunc('month', data) AS mes,
    SUM(saldo) AS auc_total
FROM posicao_custodia
GROUP BY mes
ORDER BY mes;

-- Divergência entre custódia e contábil
SELECT 
    c.id_cliente,
    c.id_produto,
    c.data,
    c.saldo AS saldo_custodia,
    co.saldo AS saldo_contabil,
    (c.saldo - co.saldo) AS diferenca
FROM posicao_custodia c
JOIN posicao_contabil co
ON c.id_cliente = co.id_cliente
AND c.id_produto = co.id_produto
AND c.data = co.data
WHERE ABS(c.saldo - co.saldo) > 100;

-- Verificar inconsistência de saldo vs transações
WITH fluxo AS (
    SELECT
        id_cliente,
        id_produto,
        data,
        SUM(CASE WHEN tipo = 'entrada' THEN valor ELSE -valor END)
        OVER (PARTITION BY id_cliente, id_produto ORDER BY data) AS saldo_calculado
    FROM transacoes
)
SELECT 
    f.id_cliente,
    f.id_produto,
    f.data,
    f.saldo_calculado,
    p.saldo AS saldo_custodia,
    (p.saldo - f.saldo_calculado) AS erro
FROM fluxo f
JOIN posicao_custodia p
ON f.id_cliente = p.id_cliente
AND f.id_produto = p.id_produto
AND f.data = p.data
WHERE ABS(p.saldo - f.saldo_calculado) > 500;
