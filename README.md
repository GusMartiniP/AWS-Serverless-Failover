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
