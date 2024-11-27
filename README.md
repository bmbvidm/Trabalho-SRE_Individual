# Trabalho-SRE_Individual
Este é um repositório criado para documentar a entrega do Projeto Individual da Disciplina SRE do curso MBA em Engenharia de Dados


Passo a Passo para Criar Infraestrutura como Código (IaC) na AWS usando Terraform no Windows, considerando o desenho abaixo:

![image](https://github.com/user-attachments/assets/4e8182ff-0b33-45ac-bca6-6d00a4053047)

Para atendimento desta arquitetura devemos provisionar: 

## API Gateway 
## Lambda Functions
## SQS Queue
## IAM Roles

Segue passo a passo: 

# 1. Preparação do Ambiente

## 1.1. Instale o Terraform
Baixe o Terraform:
Acesse o site oficial: Terraform Downloads.
Baixe a versão compatível com o Windows.
Extraia o executável:
Extraia o arquivo ZIP para um diretório local



## 1.2. Configure o AWS CLI
Instale o AWS CLI:

Baixe o instalador para Windows: AWS CLI Downloads.
Siga as instruções do instalador.
Configure o AWS CLI:

Abra o Prompt de Comando ou PowerShell.
Execute:
cmd
Copiar código
aws configure

Insira suas credenciais da AWS:
Access Key ID e Secret Access Key.
Região padrão (ex.: us-east-1).
Formato de saída (geralmente json).


# 2. Criar o Diretório do Projeto
Crie uma pasta para o projeto:

cmd
Copiar código
mkdir C:\bruna-sre-iac
cd C:\bruna-sre-iac

Crie os arquivos necessários:

main.tf: Contém os recursos principais.
variables.tf: Define variáveis para o projeto.
outputs.tf: Especifica saídas dos recursos.


# 3. Escrever o Código Terraform

## 3.1. Configuração do Provedor
Adicione ao arquivo main.tf:


provider "aws" {
  region = "us-east-1"
}

## 3.2. Recursos da Infraestrutura
Adicione os recursos descritos na topologia:

Lambda Function:


resource "aws_lambda_function" "query_handler" {
  function_name = "QueryHandler"
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "query_handler.zip"
}

resource "aws_lambda_function" "command_handler" {
  function_name = "CommandHandler"
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "command_handler.zip"
}


API Gateway:


resource "aws_api_gateway_rest_api" "api" {
  name        = "MyApi"
  description = "API Gateway para Lambda"
}
SQS:


resource "aws_sqs_queue" "commands_queue" {
  name = "CommandsQueue"
}

IAM Role para Lambda:


resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

## 3.3. Variáveis e Saídas
No arquivo variables.tf:


variable "region" {
  default = "us-east-1"
}

No arquivo outputs.tf:


output "api_url" {
  value = aws_api_gateway_rest_api.api.execution_arn
}

# 4. Inicializar e Implantar o Terraform
Inicialize o projeto:


terraform init

Valide o código:
terraform validate


Exiba o plano:
terraform plan

Aplique as mudanças:

terraform apply

Confirme digitando yes.

# 5. Testar e Validar
Teste os recursos:

Acesse o API Gateway pelo console da AWS e teste as rotas configuradas.
Verifique as funções Lambda e o funcionamento da fila SQS.

Monitoramento:

Use o CloudWatch para verificar logs das funções Lambda.


# 6. Empacotamento de Funções Lambda
Crie o código das funções Lambda (ex.: lambda_function.py):


def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": "Hello from Lambda!"
    }

Empacote em um arquivo ZIP:


zip query_handler.zip lambda_function.py
Carregue no S3 (se necessário) ou especifique o caminho local no Terraform.

