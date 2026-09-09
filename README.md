# AWS-Serverless-Failover - Presença Digital Blindada 
Projeto criado para o Hackaton Future Builders, patrocinado pela Escola da Nuvem, AWS e Wizard by Pearson. This project was created for the Future Builders Hackathon, sponsored by Escola da Nuvem, AWS, and Wizard by Pearson.

| **Meta de lançamento / Release Date** | 8 de setembro de 2026 / September 8th, 2026  | 
|--------|------------|
| **Épico / Epic** | Desenvolver uma solução de resiliência e blindagem em um site que captura leads de potenciais novos alunos, especialmente em épocas como Black Friday e volta às aulas. O objetivo central foi criar um site estático, que tenha proteção contra DDoS, injeções de códigos e Failover automático em caso de queda do site. EN-US: Develop a resilience and protection solution for a website that captures leads from potential new students, especially during periods like Black Friday and back-to-school season. The central objective was to create a static website that has protection against DDoS attacks, code injections, and automatic failover in case of website downtime. | 
| **Status do documento / Document Status** | Concluído / Finished |
| **Lider técnico / Tech Leader** | Luana Cristina Soares |
| **Arquitetos / Architects** | Gustavo Martini dos Passos; Dyllan Cristian Castaldi (Também atuou como DevOps / Also worked as DevOps) |
| **Q.A** | André Marques de Souza (Obrigado por criar o IaC do nosso projeto! / Thanks for creating our project's IaC!), Fabricio Mitsuo Tanaka | 

🎯 Objetivos/Goals:

Este projeto possui o objetivo de, utilizando ferramentas totalmente gerenciadas pela AWS, criar um site estático, serverless, que tenha alta disponibilidade e resiliência em casos extremos como apagar diretamente o index.html do Bucket S3, e ainda assim o site continuar de pé, com RTO médio de 30 segundos. / This project aims to create a static, serverless website using tools fully managed by AWS. This website will have high availability and resilience in extreme cases, such as directly deleting the index.html file from the S3 bucket, and still remain online, with an average RTO of 30 seconds.


O fluxo de nossa aplicação é a seguinte:

                         CLIENTE
                            │
                            ▼
                     ┌─────────────┐
                     │ AWS Shield  │
                     │    DDoS     │
                     └──────┬──────┘
                            │
                            ▼
                     ┌─────────────┐
                     │   AWS WAF   │
                     │     L7      │
                     └──────┬──────┘
                            │
                            ▼
                  ┌───────────────────┐
                  │  Amazon CloudFront│
                  │    Global Edge    │
                  └─────────┬─────────┘
                            │
                 ┌──────────┴──────────┐
                 │                     │
                 ▼                     ▼
        ┌─────────────────┐   ┌─────────────────┐
        │ Primary Origin  │   │ Secondary Origin│
        │ S3 — sa-east-1  │   │ S3 — us-east-1  │
        └────────┬────────┘   └────────┬────────┘
                 │                     │
                 └─────── Failover ────┘


             FLUXO DE LEADS / FORMULÁRIOS

                    Cliente
                       │
                       ▼
                Amazon API Gateway
                       │
                       ▼
                  AWS Lambda
                Validação/Processamento
                       │
                       ▼
                Amazon DynamoDB
                   Tabela Leads
                       │
                       ▼
                  Amazon S3
              Export / Arquivo


               GOVERNANÇA E OPERAÇÃO

       ┌──────────────┬───────────────┬──────────────┐
       │              │               │              │
       ▼              ▼               ▼              ▼
     CloudWatch     CloudTrail    AWS Backup   CloudFormation
    Logs/Métricas    Auditoria     Proteção          IaC

#En-US Our project's flow goes like this:

                         CLIENT
                            │
                            ▼
                     ┌─────────────┐
                     │ AWS Shield  │
                     │    DDoS     │
                     └──────┬──────┘
                            │
                            ▼
                     ┌─────────────┐
                     │   AWS WAF   │
                     │     L7      │
                     └──────┬──────┘
                            │
                            ▼
                  ┌───────────────────┐
                  │  Amazon CloudFront│
                  │    Global Edge    │
                  └─────────┬─────────┘
                            │
                 ┌──────────┴──────────┐
                 │                     │
                 ▼                     ▼
        ┌─────────────────┐   ┌─────────────────┐
        │ Primary Origin  │   │ Secondary Origin│
        │ S3 — sa-east-1  │   │ S3 — us-east-1  │
        └────────┬────────┘   └────────┬────────┘
                 │                     │
                 └─────── Failover ────┘


              LEADS / FORM SUBMISSION FLOW

                    Client
                       │
                       ▼
                Amazon API Gateway
                       │
                       ▼
                  AWS Lambda
                Validation/Processing
                       │
                       ▼
                Amazon DynamoDB
                   Leads Table
                       │
                       ▼
                  Amazon S3
              Export / Archive


                    OPERATIONS & GOVERNANCE

       ┌──────────────┬───────────────┬──────────────┐
       │              │               │              │
       ▼              ▼               ▼              ▼
     CloudWatch    CloudTrail   AWS Backup   CloudFormation
    Logs/Metrics    Auditing       Protection        IaC


#Recursos/ Resources

° AWS Shield para proteção contra ataques DDoS;
° AWS WAF para proteção na camada de aplicação (L7);
° Amazon CloudFront como CDN e camada global de distribuição;
° AWS Certificate Manager (ACM) para certificado SSL/TLS e HTTPS;
° Amazon S3 para hospedagem do site estático;
° Amazon API Gateway para disponibilização dos endpoints;
° AWS Lambda para validação e processamento das requisições;
° Amazon DynamoDB para armazenamento dos leads;
° Amazon CloudWatch para logs, métricas e alarmes;
° AWS CloudTrail para auditoria e registro das chamadas de API;
° AWS Backup para proteção dos dados;
° Versionamento e Cross-Region Replication (CRR);
° AWS CloudFormation para implementação da infraestrutura como código (IaC).

A região principal da infraestrutura é us-east-2 (Ohio), enquanto a região secundária é us-east-1 (N. Virginia). O bucket S3 primário do site está localizado em sa-east-1 (São Paulo), enquanto o bucket secundário está localizado em us-east-1.

EN-US 

° AWS Shield for DDoS protection;
° AWS WAF for Layer 7 application protection;
° Amazon CloudFront as the global CDN and distribution layer;
° AWS Certificate Manager (ACM) for SSL/TLS certificates and HTTPS;
° Amazon S3 for static website hosting;
° Amazon API Gateway for endpoint exposure;
° AWS Lambda for request validation and processing;
° Amazon DynamoDB for lead storage;
° Amazon CloudWatch for logs, metrics, and alarms;
° AWS CloudTrail for API auditing and logging;
° AWS Backup for data protection;
° Versioning and Cross-Region Replication (CRR);
° AWS CloudFormation for Infrastructure as Code (IaC).

The primary infrastructure region is us-east-2 (Ohio), while the secondary region is us-east-1 (N. Virginia). The primary website S3 bucket is located in sa-east-1 (São Paulo), while the secondary bucket is located in us-east-1.
