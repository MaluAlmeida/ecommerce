create database dbEcommerce;
use dbEcommerce;

CREATE TABLE produtos (
Id INT PRIMARY KEY AUTO_INCREMENT,
Nome VARCHAR(100),
Categoria VARCHAR(70),
Descricao varchar(500),
EstadoConservacao VARCHAR(50),
Preco DECIMAL(10,2),
DataPedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE produtoImagens (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    ProdutoId INT NOT NULL,
    Url VARCHAR(255) NOT NULL,
    OrdemImagem INT DEFAULT 1,
    FOREIGN KEY (ProdutoId) REFERENCES produtos(Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE usuarios(
Id INT PRIMARY KEY AUTO_INCREMENT,
Nome VARCHAR(100),
DataNasc varchar(10) not null,
Email VARCHAR(150) UNIQUE,
Senha VARCHAR(100),
CPF VARCHAR(20) UNIQUE,
Telefone VARCHAR(20),
Tipo ENUM  ('admin', 'cliente') NOT NULL DEFAULT 'cliente'
);

CREATE TABLE enderecos(
    Id INT AUTO_INCREMENT PRIMARY KEY,
    UsuarioId INT NOT NULL,
    NomeCompleto varchar(200),
    Logradouro VARCHAR(150) NOT NULL,
    Numero VARCHAR(10),
    Cidade VARCHAR(100),
    Estado VARCHAR(50),
    Bairro varchar(50),
    CEP VARCHAR(15),
    Complemento VARCHAR(100),
    FOREIGN KEY (UsuarioId) REFERENCES usuarios(Id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE metodosPagamento (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Descricao VARCHAR(50) NOT NULL
);


CREATE TABLE cartoes (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    UsuarioId INT NOT NULL,
    Tipo varchar(20) NOT NULL,
    NomeTitular VARCHAR(100) NOT NULL,
    Numero VARCHAR(25) NOT NULL, 
    Bandeira VARCHAR(30) NOT NULL,
    Validade VARCHAR(10) NOT NULL,
    CVV VARCHAR(3) NOT NULL,
    FOREIGN KEY (UsuarioId) REFERENCES usuarios(Id)
        ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE pedidos (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    UsuarioId INT NOT NULL,
    EnderecoId INT NOT NULL,
    MetodoPagamentoId INT NULL,
    CartaoId INT,
    DataPagamento datetime,
    TaxaEntrega DECIMAL(10,2) DEFAULT 0.00,
	StatusPagamento VARCHAR(50) DEFAULT 'Aguardando Pagamento',
	StatusPedido VARCHAR(50) DEFAULT 'Criado',
    DataPedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ValorTotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (UsuarioId) REFERENCES usuarios(Id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (EnderecoId) REFERENCES enderecos(Id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (MetodoPagamentoId) REFERENCES metodosPagamento(Id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (CartaoId) REFERENCES cartoes(Id)
        ON DELETE SET NULL ON UPDATE CASCADE
);


CREATE TABLE itensPedido (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    PedidoId INT NOT NULL,
    ProdutoId INT NOT NULL,
    Quantidade INT NOT NULL,
    PrecoUnitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (PedidoId) REFERENCES pedidos(Id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ProdutoId) REFERENCES produtos(Id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

INSERT INTO metodosPagamento (Descricao) 
VALUES ('Cartão'),
('Pix');

SELECT * FROM usuarios;

INSERT INTO produtos (Nome, Categoria, Descricao, EstadoConservacao, Preco)
VALUES 
( 'Vestido Rococo Ivory' , 'Roupa ',' O vestido estilo rococo pertencente à Idade Média, apresenta tecido claro e rico em detalhes, com um corpete justo e uma saia ampla que transmite elegância e destaque social. Os laços nas mangas e os bordados delicados reforçam o luxo e o cuidado artesanal típico das vestes usadas por mulheres nobres da época. ',' Pequenos defeitos' , 10000.00),
( 'Victorian Corset' , 'Roupa' ,  'O corpete, com sua modelagem ajustada e detalhes delicados, é característico do século XIX, especialmente do período vitoriano, quando esse tipo de peça era usado para definir a silhueta feminina. Já a blusa leve e translúcida complementa o conjunto, destacando o contraste entre rigidez e delicadeza típico das vestimentas de época. ', 'Perfeitamente conservado' , 5000.00),
( 'Manto Dourado com franjas' , 'Roupa ',  'O Manto apresenta um tecido dourado adornado com longas franjas decorativas que percorrem toda a frente, punhos e barra, criando um visual luxuoso e marcante. A peça, do século XIX, combina elegância e riqueza de detalhes, refletindo o refinamento das vestimentas usadas por damas da alta sociedade. A textura elaborada e o acabamento ornamental tornam o manto um destaque histórico de grande valor estético.' , 'Leves Rasgos', 30000.00),
( 'Vestido Dourado da realeza ','Roupa', 'Vestido do século XVII, apresenta tecido dourado brilhante com detalhes em renda e botões decorativos que percorrem toda a parte frontal. A saia ampla e estruturada, junto do bolero com babados nos ombros, reflete o luxo e a sofisticação usados por damas da alta sociedade. A combinação de brilho, volume e ornamentos torna a peça um destaque histórico de grande valor estético. ', 'Sem Defeitos' , 40000.00 ),
( 'Máscara Bicéfala Africana em Madeira' , 'Arte' , 'Rara e antiga máscara tribal africana, esculpida em madeira com rica pátina. Apresenta um design singular com duas cabeças cônicas no topo, simbolizando a dualidade e o poder ancestral. Uma peça autêntica de arte etnográfica, perfeita para colecionadores.' , 'Leves rachaduras' , 20000.00),
( 'Escultura de Arte Popular com Serpente' , 'Arte ', 'Escultura antiga em madeira policromada, estilo arte popular. Representa uma figura feminina vestindo túnica estampada, dominando uma grande serpente enrolada em seu corpo. A rica pátina e a pintura desgastada confirmam sua autenticidade e idade. Peça única para colecionadores de arte sacra ou popular brasileira.' ,' Desgastada' , 15000.00 )
,( 'Estatueta Tribal Africana Antiga' ,' Arte ', 'Escultura em madeira escura, autêntica e antiga, apresentando uma figura com expressão ritualística e postura de guardião. Destaca-se a textura quadriculada no ventre e a aplicação sutil de pigmentos. Uma peça poderosa de arte tribal, ideal para colecionadores. ', 'Conservada ', 30000.00 )
,( 'Escultura Ritual Africana de Conjunto' ,' Arte ', 'Rara e fascinante escultura ritualística em madeira, possivelmente um relicário ou objeto de poder. A peça é notável por seu arranjo em grupo, apresentando uma figura central proeminente com pintura vermelha (ocre), flanqueada por figuras secundárias mais escuras. O conjunto é amarrado por uma corda de fibra natural e apoiado sobre uma base texturizada. Item de grande valor etnográfico e museológico.' , 'Leves arranhões' , 25000.00 )
,( 'Estatueta de Espírito Ancestral ',' Arte ', 'Escultura tribal em madeira com forte pátina cinza-azulada. A figura, possivelmente um macaco ou espírito da floresta, está em posição ajoelhada/agachada, segurando um recipiente nas mãos. O rosto é notável, com a mandíbula superior exposta (crânio parcial). É uma peça de arte tribal única, que evoca mistério e rituais xamânicos. ', ' Conservada ', 60000.00 ) 
,( ' Sofá Estofado em Mogno' ,' móvel ', 'Imponente sofá antigo, ricamente esculpido em mogno maciço no elegante Estilo Império Americano (c. 1820-1860). Apresenta estrutura robusta, braços curvados e base sólida. O estofamento é em tecido listrado com cores vibrantes (vermelho e bege), contrastando com a madeira escura. Uma peça de mobiliário refinada, ideal para ambientes que buscam a solidez e a formalidade da alta sociedade do século XIX. ', 'Leves Rasgos ', 70000.00 )
,( 'Cadeira Francesa' , 'móvel' , 'Sofisticada chaise longue com design clássico francês, perfeito para momentos de repouso elegante. Estofamento luxuoso em cetim cor champagne, com encosto ricamente trabalhado em capitonê. A moldura lateral e os pés são realçados com folheação a ouro, conferindo um brilho vintage e opulento. Peça de mobiliário decorativo que adiciona um toque de glamour e charme neoclássico a qualquer sala ou boudoir.' , 'Conservada' , 80000.00) 
,( 'Cadeira Rústica de Antlers' ,' móvel ', 'Cadeira excepcionalmente rara e de forte impacto visual, construída inteiramente com chifres de veado (antlers) no estilo rústico de cabana de caça europeia . O assento e o encosto são estofados em camurça marrom, proporcionando conforto ao design orgânico e complexo. Uma peça de colecionador que transcende o mobiliário, sendo uma verdadeira escultura decorativa, perfeita para um escritório masculino ou um chalé sofisticado.' ,' Desgastada' , 55000.00 )
,( 'Banco Estofado com Braços em Espiral Americano' , 'móvel' , 'Charmoso banco estofado, típico do período vitoriano americano. A peça possui estofamento em um delicado tecido jacquard (brocado) de padrão floral em tons neutros e suaves. Os braços laterais curtos e enrolados (scrolled arms) conferem um estilo acolhedor, contrastando com os quatro pés esculpidos em cabriolé (curvados) e acabamento escuro. Versátil para uso como apoio de pés, banco de hall de entrada ou no pé da cama. ', 'Leves defeitos', 48000.00)
,( 'Anel de Safira e Diamantes' , 'jóia' , 'Clássico anel antigo vitoriano (c. 1880-1900) em ouro amarelo. O design five-stone (cinco pedras) apresenta três safiras azuis intensas intercaladas com dois diamantes lapidação old mine cut ou european cut. O aro possui uma delicada textura ou gravação. Uma joia tradicional, frequentemente usada como presente de aniversário ou promessa, exalando romance e história.' , 'Desgastado' , 90000.00)
,( ' Broche em Formato de Cruz' , 'jóia ', 'Intrigante broche antigo, de design simétrico em formato de cruz. É cravejado com oito gemas retangulares verdes (possivelmente turmalinas ou vidros coloridos) ao redor de uma pedra central quadrada, que parece ser Quartzo Rutilado ou Moonstone. Uma peça de impacto, que remete à joalheria vitoriana ou eduardiana, ideal para ser usada como peça central em um blazer ou lenço. ', 'Conservado' , 120000.00)
,( 'Anel Gypsy Safira e Diamantes ', 'jóia ', 'Delicado anel antigo em ouro amarelo. Apresenta um design fluido e orgânico, comum no final do período Vitoriano (Aesthetic Movement), com um motivo de volutas (scrolls) e folhagens gravadas. É cravejado com safiras azuis e pequenos diamantes antigos, incrustados diretamente no metal (gypsy setting). Uma joia charmosa e de uso diário, com elegância sutil.' ,' Leves riscos' , 230000.00 )
,( 'Colar Duplo com Medalhão Oval e Micro-Mosaico' , 'jóia ',' Impressionante colar antigo de duas voltas de contas em ouro. O ponto focal é um grande medalhão oval ricamente ornamentado e vazado, que abriga uma inserção central, possivelmente um camafeu ou um micro-mosaico em miniatura. A corrente de contas em design filigranado e a presença de laços no pendente destacam a complexidade artesanal do século XIX. Uma peça de museu para colecionadores.',' Conservado', 150000.00 )
,('Anel Cluster de Esmeralda e Diamantes' , 'jóia',' Magnífico anel estilo "Cluster" (cacho) do período Eduardino (c. 1900-1915). A joia apresenta uma Esmeralda lapidação emerald cut, central e vívida, circundada por uma auréola de oito diamantes antigos (lapidação old mine cut), com o aro em ouro amarelo e detalhes orgânicos laterais. Uma peça de alta joalheria, perfeita para noivado ou para coleções de joias finas.' , 'Leves defeitos' , 350000.00);



INSERT INTO produtoImagens (ProdutoId, Url) VALUES
(1 , 'rococofranca.png'),
(2, 'corset.png'),
(3, 'manto.png' ),
( 4 , 'dourado.png '),
( 5, 'africa.png '),
(6 , 'serpente.png '),
( 7 , 'tribal.png' ),
( 8 ,'ritual.png'),
( 9 , 'ancestral.png'),
( 10 , 'mogno.png'),
( 11 , 'cadeira.png' ),
( 12 , 'rustica.png' ),
(13 , 'banco.png '),
(14 , 'safira.png' ),
(15 , 'broche.png'),
(16 , 'anel.png '),
(17, 'colar.png '),
(18 , 'esmeralda.png');

select * from produtos;
select * from  usuarios;

INSERT INTO usuarios(Nome, DataNasc, Email, Senha, CPF, Telefone, Tipo)
VALUES 
('Admin', '12121200','admin@admin.com', '123', '11111111111', '11999999999', 'admin'),
('Malu', '27072007', 'malu@gmail.com', '123', '11111111115', '11999999995', 'cliente');
