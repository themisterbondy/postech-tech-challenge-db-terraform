# Configuração do provedor
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.3.0"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Definir variáveis
variable "resource_group_name" {
  default = "rg-postgresql-postech-fiap"
}

variable "location" {
  default = "eastus2"
}

variable "postgresql_server_name" {
  description = "The server name for PostgreSQL."
  type        = string
  sensitive   = true
}

variable "admin_username" {
  description = "The admin username for PostgreSQL."
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "The admin password for PostgreSQL."
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "The database name for PostgreSQL."
  type        = string
  sensitive   = true
}


# Criar o servidor PostgreSQL flexível
resource "azurerm_postgresql_flexible_server" "postgresql_flexible" {
  name                   = var.postgresql_server_name
  location               = var.location
  resource_group_name    = var.resource_group_name
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  sku_name               = "B_Standard_B1ms"
  version                = "16"

  storage_mb            = 32768
  backup_retention_days = 7
}

# Configurar extensões do servidor PostgreSQL flexível
resource "azurerm_postgresql_flexible_server_configuration" "postgresql_flexible" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.postgresql_flexible.id
  value     = "CITEXT,HSTORE,UUID-OSSP"
}

# Criar um banco de dados no servidor flexível
resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.postgresql_flexible.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Configurar o firewall para permitir conexões de todos os IPs
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all_ips" {
  name             = "AllowAllIPs"
  server_id        = azurerm_postgresql_flexible_server.postgresql_flexible.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}
