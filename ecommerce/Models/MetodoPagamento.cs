namespace ecommerce.Models
{
    public class MetodoPagamento
    {
        public int Id { get; set; }
        public string Descricao { get; set; } = string.Empty;
        public List<Cartao>? Cartoes { get; set; }
        public List<Pedido>? Pedidos { get; set; }
    }
}
