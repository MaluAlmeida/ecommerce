using Newtonsoft.Json;
using System.Text;
using ecommerce.Models;
using ecommerce.Repository;

namespace ecommerce.Services
{
    public static class AuxiliarCarrinho
    {
        public static async Task<List<ItemPedido>> ObterItensCarrinho(HttpRequest requisicao, HttpResponse resposta, IProdutoRepository produtoRepository)
        {
            var itens = new List<ItemPedido>();
            var dicionario = ObterDicionarioCarrinho(requisicao, resposta);

            foreach (var par in dicionario)
            {
                var produto = await produtoRepository.ProdutosPorId(par.Key);
                if (produto == null) continue;

                itens.Add(new ItemPedido
                {
                    ProdutoId = produto.Id,
                    Produto = produto,
                    Quantidade = par.Value,
                    PrecoUnitario = produto.Preco,
                    Imagem = produto.Imagens.FirstOrDefault()
                });
            }

            return itens;
        }


        public static int ObterTamanhoCarrinho(HttpRequest requisicao, HttpResponse resposta)
        {
            int tamanho = 0;
            var carrinho = ObterDicionarioCarrinho(requisicao, resposta);

            foreach (var item in carrinho)
            {
                tamanho += item.Value;
            }

            return tamanho;
        }

        public static decimal ObterSubtotal(List<ItemPedido> itensCarrinho)
        {
            decimal subtotal = 0;

            foreach (var item in itensCarrinho)
            {
                subtotal += item.Quantidade * item.PrecoUnitario;
            }

            return subtotal;
        }

        public static void SalvarCarrinho(HttpResponse resposta, Dictionary<int, int> carrinho)
        {
            string json = JsonConvert.SerializeObject(carrinho);
            string valorBase64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(json));

            var opcoes = new CookieOptions
            {
                Expires = DateTime.Now.AddDays(365),
                Path = "/",
                SameSite = SameSiteMode.Strict,
                Secure = true
            };

            resposta.Cookies.Append("shopping_cart", valorBase64, opcoes);
        }

        public static void AdicionarAoCarrinho(HttpRequest requisicao, HttpResponse resposta, int produtoId)
        {
            var carrinho = ObterDicionarioCarrinho(requisicao, resposta);

            if (carrinho.ContainsKey(produtoId))
                carrinho[produtoId]++;
            else
                carrinho[produtoId] = 1;

            SalvarCarrinho(resposta, carrinho);
        }

        /// <summary>
        /// Diminui a quantidade de um item no carrinho.
        /// </summary>
        public static void DiminuirDoCarrinho(HttpRequest requisicao, HttpResponse resposta, int produtoId)
        {
            var carrinho = ObterDicionarioCarrinho(requisicao, resposta);

            if (!carrinho.ContainsKey(produtoId))
                return;

            if (carrinho[produtoId] > 1)
                carrinho[produtoId]--;
            else
                carrinho.Remove(produtoId);

            SalvarCarrinho(resposta, carrinho);
        }


        public static void RemoverDoCarrinho(HttpRequest requisicao, HttpResponse resposta, int produtoId)
        {
            var carrinho = ObterDicionarioCarrinho(requisicao, resposta);

            if (carrinho.ContainsKey(produtoId))
            {
                carrinho.Remove(produtoId);
                SalvarCarrinho(resposta, carrinho);
            }
        }
        private static Dictionary<int, int> ObterDicionarioCarrinho(HttpRequest requisicao, HttpResponse resposta)
        {
            try
            {
                // Verifica se o cookie existe
                if (!requisicao.Cookies.TryGetValue("shopping_cart", out string? valorBase64) || string.IsNullOrEmpty(valorBase64))
                {
                    return new Dictionary<int, int>();
                }

                string json = Encoding.UTF8.GetString(Convert.FromBase64String(valorBase64));
                var dicionario = JsonConvert.DeserializeObject<Dictionary<int, int>>(json);

                // Se deu erro ou está nulo, devolve dicionário vazio
                return dicionario ?? new Dictionary<int, int>();
            }
            catch
            {
                // Em caso de erro, retorna carrinho vazio
                return new Dictionary<int, int>();
            }
        }
    }
}
