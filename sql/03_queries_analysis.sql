WITH saldo_diario_transacoes AS (
  SELECT
    id_cliente,
    id_produto,
    data,
    SUM(CASE WHEN tipo = 'saida' THEN valor * -1 ELSE valor END) AS saldo_movimentado
  FROM `auc-494022.simulacao_financeira.transacoes`
  GROUP BY id_cliente, id_produto, data
),


base_datas AS (
  SELECT id_cliente, id_produto, data FROM saldo_diario_transacoes
  UNION DISTINCT
  SELECT id_cliente, id_produto, data FROM `auc-494022.simulacao_financeira.posicao_custodia`
  UNION DISTINCT
  SELECT id_cliente, id_produto, data FROM `auc-494022.simulacao_financeira.posicao_contabil`
)


SELECT
  b.id_cliente,
  b.id_produto,
  b.data,


  ROUND(cu.saldo,2) AS saldo_custodia,
  ROUND(co.saldo,2) AS saldo_contabil,
  sdt.saldo_movimentado


FROM base_datas b


LEFT JOIN `auc-494022.simulacao_financeira.posicao_custodia` cu
  ON b.id_cliente = cu.id_cliente
  AND b.id_produto = cu.id_produto
  AND b.data = cu.data


LEFT JOIN `auc-494022.simulacao_financeira.posicao_contabil` co
  ON b.id_cliente = co.id_cliente
  AND b.id_produto = co.id_produto
  AND b.data = co.data


LEFT JOIN saldo_diario_transacoes sdt
  ON b.id_cliente = sdt.id_cliente
  AND b.id_produto = sdt.id_produto
  AND b.data = sdt.data
