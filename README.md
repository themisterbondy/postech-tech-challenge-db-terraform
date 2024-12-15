# Documentação do Repositório Terraform para Infraestrutura Azure com PostgreSQL

## Descrição
Este repositório contém uma configuração de **Infraestrutura como Código** utilizando **Terraform**, projetada para provisionar e gerenciar recursos na **Azure**, com foco principal no provisionamento de um servidor PostgreSQL Flexível, incluindo banco de dados, configurações, e regras de firewall.

O repositório também inclui um pipeline automatizado utilizando GitHub Actions (**main.yml**), para validação e aplicação contínua das alterações na configuração de infraestrutura.

---

## Componentes

### Arquivos Principais

- **`main.yml`**: Pipeline de CI/CD configurado com GitHub Actions para validação e aplicação das alterações no Terraform.
- **`main.tf`**: Código base que define os recursos e configurações na Azure utilizando Terraform.

---

## Estrutura do Repositório

### Pipeline CI/CD (`main.yml`)
O arquivo `main.yml` configura um fluxo de trabalho no GitHub Actions para validar, gerar o plano e aplicar alterações no Terraform.

#### **Fluxo do Pipeline**
1. **Eventos que Disparam o Pipeline**:
    - Push em qualquer branch.
    - Pull requests fechados.
    - Manualmente via `workflow_dispatch`.

2. **Permissões Necessárias**:
    - `id-token`: Permite login seguro na Azure.
    - `contents`: Usado para verificar o repositório.

3. **Etapas do Job `terraform`**:
    - **Checkout do Código**:
      Baixa o código do repositório usando `actions/checkout@v2`.
    - **Setup Terraform**:
      Configura a versão do Terraform usando `hashicorp/setup-terraform@v3`.
    - **Login no Azure**:
      Realiza login na Azure utilizando credenciais armazenadas como **secrets** no repositório.
    - **Terraform Init**:
      Inicializa o diretório com os recursos definidos no Terraform.
    - **Terraform Validate**:
      Valida a sintaxe e estrutura do código Terraform.
    - **Terraform Plan**:
      Cria um plano de execução da infraestrutura a ser provisionada.
    - **Terraform Apply**:
      Aplica automaticamente as alterações somente na branch `main`.

4. **Secrets Necessários**:
   Configure os seguintes secrets no repositório GitHub:
    - `AZURE_CLIENT_ID`
    - `AZURE_TENANT_ID`
    - `AZURE_SUBSCRIPTION_ID`
    - `POSTGRESQL_SERVER_NAME`
    - `ADMIN_USERNAME`
    - `ADMIN_PASSWORD`
    - `DATABASE_NAME`

### Infraestrutura Terraform (`main.tf`)
A configuração no arquivo `main.tf` provisiona a seguinte infraestrutura na Azure:

1. **Provider AzureRM**
    - Configurado para gerenciar recursos de infraestrutura da Azure.
    - Requer a versão `~> 4.0`.
2. **Variáveis Configuráveis**:
    - **`subscription_id`**: Configura a assinatura do Azure.
    - **`resource_group_name`**: Nome do grupo de recursos. *(Default: `"rg-postgresql-postech-fiap"`)*
    - **`location`**: Região do Azure para provisionamento. *(Default: `"eastus2"`)*
    - **`postgresql_server_name`**: Nome do servidor PostgreSQL.
    - **`admin_username`**: Usuário administrador do banco.
    - **`admin_password`**: Senha do usuário administrador.
    - **`database_name`**: Nome do banco de dados.
3. **Recursos Criados**:
    - **PostgreSQL Flexível**:
        - Configurado com SKU `B_Standard_B1ms` e versão `16`.
        - Retenção de backup configurada para 7 dias.
    - **Banco de Dados PostgreSQL**:
        - Charset: `UTF8`.
        - Collation: `en_US.utf8`.
    - **Firewall**:
        - Permite conexões de todos os IPs (`0.0.0.0` a `255.255.255.255`).
    - **Configurações e Extensões**:
        - Extensões habilitadas: `CITEXT`, `HSTORE`, `UUID-OSSP`.

---