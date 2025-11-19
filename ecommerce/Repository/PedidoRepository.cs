using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Dapper;
using MySql.Data.MySqlClient;
using ecommerce.Models;

namespace ecommerce.Repository
{
    public class PedidoRepository : IPedidoRepository
    {
        private readonly string _connectionString;

        public PedidoRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<int> AdicionarPedido(Pedido pedido)
        {
            using var connection = new MySqlConnection(_connectionString);
            await connection.OpenAsync();

            const string sqlInsert = @"
INSERT INTO pedidos (UsuarioId, EnderecoId, MetodoPagamentoId, CartaoId, TaxaEntrega, StatusPagamento, StatusPedido, DataPedido, ValorTotal)
VALUES (@UsuarioId, @EnderecoId, @MetodoPagamentoId, @CartaoId, @TaxaEntrega, @StatusPagamento, @StatusPedido, @DataPedido, @ValorTotal);
";
            await connection.ExecuteAsync(sqlInsert, pedido);

            var pedidoId = await connection.ExecuteScalarAsync<int>("SELECT LAST_INSERT_ID();");
            pedido.Id = pedidoId;

            const string sqlItem = @"
INSERT INTO itensPedido (PedidoId, ProdutoId, Quantidade, PrecoUnitario)
VALUES (@PedidoId, @ProdutoId, @Quantidade, @PrecoUnitario);
";
            foreach (var item in pedido.Itens)
            {
                await connection.ExecuteAsync(sqlItem, new
                {
                    PedidoId = pedidoId,
                    item.ProdutoId,
                    item.Quantidade,
                    item.PrecoUnitario
                });
            }

            return pedidoId;
        }

        public async Task<Pedido?> ObterPedidoPorId(int pedidoId)
        {
            using var connection = new MySqlConnection(_connectionString);

            var pedido = await connection.QueryFirstOrDefaultAsync<Pedido>(
                "SELECT * FROM pedidos WHERE Id = @Id",
                new { Id = pedidoId }
            );
            if (pedido == null) return null;

            const string sqlItens = @"
SELECT i.*, p.*
FROM itensPedido i
INNER JOIN produtos p ON p.Id = i.ProdutoId
WHERE i.PedidoId = @PedidoId;";
            var itens = await connection.QueryAsync<ItemPedido, Produto, ItemPedido>(
                sqlItens,
                (i, p) => { i.Produto = p; return i; },
                new { PedidoId = pedidoId },
                splitOn: "Id" 
            );

            pedido.Itens = itens.ToList();
            return pedido;
        }

        public async Task<List<Pedido>> ObterPedidosDoUsuario(int usuarioId)
        {
            using var connection = new MySqlConnection(_connectionString);

            const string sqlPedidos = @"
SELECT 
    p.Id, p.UsuarioId, p.DataPedido, p.ValorTotal, p.StatusPedido, p.DataPagamento,
    p.MetodoPagamentoId,
    m.Id AS MpId, m.Descricao
FROM pedidos p
LEFT JOIN metodosPagamento m ON p.MetodoPagamentoId = m.Id
WHERE p.UsuarioId = @UsuarioId
ORDER BY p.DataPedido DESC;";
            var pedidos = await connection.QueryAsync<Pedido, MetodoPagamento, Pedido>(
                sqlPedidos,
                (p, m) => { p.MetodoPagamento = m ?? new MetodoPagamento { Descricao = "Desconhecido" }; return p; },
                new { UsuarioId = usuarioId },
                splitOn: "MpId"
            );

            var lista = pedidos.ToList(); 
            if (lista.Count == 0) return lista;

            var pedidoIds = lista.Select(p => p.Id).ToArray();

            const string sqlItens = @"
SELECT 
    ip.Id, ip.PedidoId, ip.ProdutoId, ip.Quantidade, ip.PrecoUnitario,
    pr.Id AS ProdId, pr.Nome, pr.Categoria, pr.Preco
FROM itensPedido ip
INNER JOIN produtos pr ON pr.Id = ip.ProdutoId
WHERE ip.PedidoId IN @PedidoIds
ORDER BY ip.PedidoId, ip.Id;";
            var itens = await connection.QueryAsync<ItemPedido, Produto, ItemPedido>(
                sqlItens,
                (item, prod) => { item.Produto = prod; return item; },
                new { PedidoIds = pedidoIds },
                splitOn: "ProdId"
            );

            var porPedido = itens.GroupBy(i => i.PedidoId)
                                 .ToDictionary(g => g.Key, g => g.ToList());

            foreach (var p in lista)
                p.Itens = porPedido.TryGetValue(p.Id, out var lst) ? lst : new List<ItemPedido>();

            return lista;
        }

        public async Task<List<Pedido>> ObterPedidosPorUsuario(int usuarioId)
        {

            return await ObterPedidosDoUsuario(usuarioId);
        }

        public async Task<int> AtualizarStatusPagamento(Pedido pedido)
        {
            using var connection = new MySqlConnection(_connectionString);
            const string sql = @"
UPDATE pedidos 
SET StatusPagamento = @StatusPagamento, DataPagamento = @DataPagamento 
WHERE Id = @Id;";
            return await connection.ExecuteAsync(sql, new { pedido.StatusPagamento, pedido.DataPagamento, pedido.Id });
        }

        public async Task AtualizarStatus(int pedidoId, string statusPedido)
        {
            using var connection = new MySqlConnection(_connectionString);
            await connection.ExecuteAsync(
                "UPDATE pedidos SET StatusPedido = @StatusPedido WHERE Id = @Id",
                new { Id = pedidoId, StatusPedido = statusPedido }
            );
        }

        public Task<List<Pedido>> ObterTodosPedidos()
        {
            throw new NotImplementedException();
        }

        public Task<Pedido?> ObterPedidoPorIdAdm(int pedidoId)
        {
            throw new NotImplementedException();
        }
    }
}
