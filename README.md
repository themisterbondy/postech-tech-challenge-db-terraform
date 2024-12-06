# 🗂️ Documentação do Banco de Dados

## 📄 Sumário
- [Introdução](#introdução)
- [Justificativa da Escolha do Banco de Dados](#justificativa-da-escolha-do-banco-de-dados)
- [Estrutura do Banco de Dados](#estrutura-do-banco-de-dados)
    - [Tabela Carts](#tabela-carts)
    - [Tabela Customers](#tabela-customers)
    - [Tabela Orders](#tabela-orders)
    - [Tabela Products](#tabela-products)
    - [Tabela CartItems](#tabela-cartitems)
    - [Tabela OrderItems](#tabela-orderitems)
- [Considerações sobre Modelagem](#considerações-sobre-modelagem)
- [Índices e Performance](#índices-e-performance)
- [Timestamps Automáticos](#timestamps-automáticos)

## 📌 Introdução
Este documento descreve a modelagem do banco de dados utilizado no projeto, incluindo as justificativas para as escolhas de design, detalhes das tabelas e relações. A documentação visa facilitar a compreensão do sistema, promovendo transparência no design e boas práticas.

## 📊 Justificativa da Escolha do Banco de Dados

### **PostgreSQL**
A escolha do **PostgreSQL** como banco de dados se deve às seguintes razões:
1. **Conformidade com ACID**: PostgreSQL é um banco de dados relacional que garante transações seguras, consistentes e duráveis, seguindo o padrão **ACID**.
2. **Extensibilidade e Flexibilidade**: PostgreSQL oferece recursos como suporte a **tipos personalizados**, **extensões** (ex.: `uuid-ossp`), e **armazenamento de JSON**, o que aumenta a flexibilidade da aplicação.
3. **Comunidade e Ecosistema**: Forte suporte da comunidade e desenvolvimento ativo fazem com que seja uma escolha segura e estável para desenvolvimento a longo prazo.
4. **Escalabilidade**: PostgreSQL se adapta bem a diferentes tamanhos de aplicações, sendo capaz de atender pequenas e grandes demandas, com recursos como **replicação** e **particionamento de tabelas**.

## 🛠️ Estrutura do Banco de Dados

### **Tabela Carts**
- **Descrição**: Armazena informações dos carrinhos de compra dos clientes.
- **Definição**:
  ```sql
  CREATE TABLE "Carts" (
      "Id" uuid NOT NULL DEFAULT (uuid_generate_v4()),
      "CustomerId" uuid NOT NULL,
      "CreatedAt" timestamp with time zone NOT NULL DEFAULT now(),
      "PaymentStatus" text NOT NULL,
      "TransactionId" uuid,
      CONSTRAINT "PK_Carts" PRIMARY KEY ("Id"),
      CONSTRAINT "FK_Carts_Customers_CustomerId" FOREIGN KEY ("CustomerId") REFERENCES "Customers" ("Id") ON DELETE CASCADE
  );

  CREATE INDEX "IX_Carts_CustomerId" ON "Carts" ("CustomerId");
Relacionamentos: Cada carrinho está associado a um cliente (CustomerId como FK).
Considerações: PaymentStatus será mantido como texto, validado pela aplicação para evitar inconsistências.

### **Tabela Customers**
- **Descrição**: Armazena informações dos clientes, incluindo nome, e-mail e CPF.
- **Definição**:
  ```sql
  CREATE TABLE "Customers" (
      "Id" uuid NOT NULL DEFAULT (uuid_generate_v4()),
      "Name" character varying(255) NOT NULL,
      "Email" character varying(255) NOT NULL UNIQUE,
      "Cpf" character varying(11) NOT NULL UNIQUE,
      CONSTRAINT "PK_Customers" PRIMARY KEY ("Id")
  );
  ```

- **Índices**: Índices únicos para garantir que não existam CPFs ou e-mails duplicados.
- **Considerações**: Dados sensíveis como CPF são armazenados de forma única para evitar duplicidade e facilitar a busca.

### **Tabela Orders**
- **Descrição**: Armazena informações dos pedidos feitos pelos clientes.
- **Definição**:

```sql
CREATE TABLE "Orders" (
"Id" uuid NOT NULL DEFAULT (uuid_generate_v4()),
"CreatedAt" timestamp with time zone NOT NULL DEFAULT now(),
"Status" text NOT NULL,
"CustomerId" uuid NOT NULL,
"TransactionId" uuid,
CONSTRAINT "PK_Orders" PRIMARY KEY ("Id"),
CONSTRAINT "FK_Orders_Customers_CustomerId" FOREIGN KEY ("CustomerId") REFERENCES "Customers" ("Id") ON DELETE CASCADE
);

CREATE INDEX "IX_Orders_CustomerId" ON "Orders" ("CustomerId");
```

Relacionamentos: Cada pedido está relacionado a um cliente (CustomerId como FK).
Considerações: Status do pedido será mantido como texto e validado na aplicação.
Tabela Products
Descrição: Armazena informações dos produtos disponíveis na loja.
Definição:

```sql
CREATE TABLE "Products" (
    "Id" uuid NOT NULL DEFAULT (uuid_generate_v4()),
    "Name" character varying(100) NOT NULL,
    "Description" character varying(500),
    "Price" numeric(18,2) NOT NULL,
    "Category" character varying(50) NOT NULL,
    "ImageUrl" character varying(800),
    CONSTRAINT "PK_Products" PRIMARY KEY ("Id")
);

CREATE INDEX "IX_Products_Category" ON "Products" ("Category");
```

Índices: Índice em Category para otimizar buscas por categoria de produto.
Considerações: Estrutura mantém flexibilidade para adicionar informações adicionais sobre o produto, como descrição e URL de imagem.
Tabela CartItems
Descrição: Armazena os itens associados a um carrinho específico.
Definição:

```sql
CREATE TABLE "CartItems" (
"Id" uuid NOT NULL DEFAULT (uuid_generate_v4()),
"ProductId" uuid NOT NULL,
"CartId" uuid NOT NULL,
"UnitPrice" numeric(18,2) NOT NULL,
"Quantity" integer NOT NULL,
CONSTRAINT "PK_CartItems" PRIMARY KEY ("Id"),
CONSTRAINT "FK_CartItems_Carts_CartId" FOREIGN KEY ("CartId") REFERENCES "Carts" ("Id") ON DELETE CASCADE,
CONSTRAINT "FK_CartItems_Products_ProductId" FOREIGN KEY ("ProductId") REFERENCES "Products" ("Id")
);

CREATE INDEX "IX_CartItems_CartId" ON "CartItems" ("CartId");
CREATE INDEX "IX_CartItems_ProductId" ON "CartItems" ("ProductId");
```

Relacionamentos: Cada item está associado a um carrinho (CartId) e a um produto (ProductId).
Considerações: Quantity e UnitPrice ajudam a calcular o valor total do carrinho.
Tabela OrderItems
Descrição: Armazena os itens associados a um pedido específico.
Definição:
```sql
CREATE TABLE "OrderItems" (
"Id" uuid NOT NULL DEFAULT (uuid_generate_v4()),
"OrderId" uuid NOT NULL,
"ProductId" uuid NOT NULL,
"UnitPrice" numeric(18,2) NOT NULL,
"Quantity" integer NOT NULL,
CONSTRAINT "PK_OrderItems" PRIMARY KEY ("Id"),
CONSTRAINT "FK_OrderItems_Orders_OrderId" FOREIGN KEY ("OrderId") REFERENCES "Orders" ("Id") ON DELETE CASCADE,
CONSTRAINT "FK_OrderItems_Products_ProductId" FOREIGN KEY ("ProductId") REFERENCES "Products" ("Id")
);

CREATE INDEX "IX_OrderItems_OrderId" ON "OrderItems" ("OrderId");
CREATE INDEX "IX_OrderItems_ProductId" ON "OrderItems" ("ProductId");
``` 
Relacionamentos: Cada item está associado a um pedido (OrderId) e a um produto (ProductId).
Considerações: Estrutura similar a CartItems, mas reflete o estado final de um pedido.
📚 Considerações sobre Modelagem
UUIDs como Chaves Primárias: Foram escolhidos UUIDs para todas as chaves primárias para garantir unicidade global e flexibilidade em cenários distribuídos.
Relacionamentos e Integridade: As Foreign Keys garantem a consistência dos relacionamentos entre Carts, Orders, Customers, Products e seus respectivos itens.
Status e PaymentStatus: Não foram normalizados por decisão de design, mas são validados pela lógica de aplicação para manter valores consistentes.
⚙️ Índices e Performance
Índices Únicos: Em Customers.Email e Customers.Cpf para garantir a integridade dos dados e evitar duplicidade.
Índices de Consulta: Índices em Products.Category, CartItems.CartId, OrderItems.OrderId, entre outros, para otimizar o desempenho de consultas frequentes e facilitar operações de junção.
🕒 Timestamps Automáticos
As tabelas incluem campos CreatedAt e UpdatedAt para facilitar auditorias e acompanhamento de mudanças nos registros.
Exemplo:
```sql

"CreatedAt" timestamp with time zone NOT NULL DEFAULT now(),
"UpdatedAt" timestamp with time zone NOT NULL DEFAULT now()
```
Considerações: Esses campos são particularmente úteis para acompanhar o ciclo de vida dos registros, desde a criação até a última modificação.