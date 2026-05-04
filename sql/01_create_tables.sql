-- =========================================
-- 1. LIMPEZA
-- =========================================
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS produtos;
DROP TABLE IF EXISTS transacoes;
DROP TABLE IF EXISTS posicao_custodia;
DROP TABLE IF EXISTS posicao_contabil;
DROP TABLE IF EXISTS concorrentes;

-- =========================================
-- 2. TABELAS BASE
-- =========================================
CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nome TEXT
);

CREATE TABLE produtos (
    id_produto SERIAL PRIMARY KEY,
    tipo TEXT
);

CREATE TABLE transacoes (
    id_transacao SERIAL PRIMARY KEY,
    id_cliente INT,
    id_produto INT,
    data DATE,
    tipo TEXT, -- 'entrada' ou 'saida'
    valor NUMERIC
);

CREATE TABLE posicao_custodia (
    id_cliente INT,
    id_produto INT,
    data DATE,
    saldo NUMERIC
);

CREATE TABLE posicao_contabil (
    id_cliente INT,
    id_produto INT,
    data DATE,
    saldo NUMERIC
);

CREATE TABLE concorrentes (
    data DATE,
    auc_total NUMERIC
);
