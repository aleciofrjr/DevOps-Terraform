# DevOps Challenge 🏅 2021 - Resolução de Alécio Júnior

## Introdução
A idéia principalmente desta resolução foi mostrar os meus conhecimentos sobre os coneitos DevOps e suas aplicações de acordo com as minhas
escolhas estratégicas desde a construção da INFRA até a criação do PIPELINE.

# Tecnologias e Linguagens

- Terraform
- AWS && AWS-CLI
- Git
- Gitlab
- Nginx
- Shell Script
- Dstat
- npm & jq
- csvtojson

# Pré-Requisitos

### Git e Configuração
- Necessário instalar Git seguindo a documentação oficial, para trabalhar no Gitlab.
    - [Git](https://git-scm.com/book/pt-br/v2/Come%C3%A7ando-Instalando-o-Git)

- Após a intalação efetuar a configuração achave ssh no Gitlab.
    - [Adicionando chaves ssh](https://gitlab.com/ad-si-2015-1/projeto1/-/wikis/tutorial-criar-e-configurar-chave-ssh)

### Terraform
- Necessário instalar terraform seguindo a documentação oficial.
    - [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

### AWS-CLI
- Necessário instalar AWS-CLI seguindo a dcumentação oficial.
    - [AWS-CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

### Dstat
- Como foi sugerido a opção de utilizar ferramenta de monitoramento no Linux chamada **dstat**.
    - [DSTAT](https://www.vivaolinux.com.br/artigo/dstat-Ferramenta-de-Monitoramento-no-Linux)

**OBS:** Ao executar o ***dstat** eu percebi que estava com erro, onde percebi a necessidade de atualizar o arquivo dstat.

### Solução da ferramenta **DSTAT**
- Necessário alterar o arquivo localizado em ~/usr/bin/dstat.
    - Alterar o type-checking nas linhas 547 e 552 conforme o código abaixo:

        - Código original:
        ```
        if isinstance(self.val[name], types.ListType) or isinstance(self.val[name], types.TupleType):
            for j, val in enumerate(self.val[name]):
                line = line + printcsv(val)
                if j + 1 != len(self.val[name]):
                    line = line + char['sep']
        elif isinstance(self.val[name], types.StringType):
        ```
        - Código alterado:
        
        ```
        if isinstance(self.val[name], (tuple, list)):
            for j, val in enumerate(self.val[name]):
                line = line + printcsv(val)
                if j + 1 != len(self.val[name]):
                    line = line + char['sep']
        elif isinstance(self.val[name], str):
        ```
### csvtojson
- Devido ao **DSTAT** gerar um arquivo .csv, pensei em converter este arquivo para .json utilizando a ferramenta csvtojson, porém é necessário instalar **npm** && **jq**.

        ```
        sudo apt update \
        sudo apt install npm jq -y \
        sudo npm install -g csvtojson -y
        ```
### Instruções para executar o Projeto
- Necessário executar somente os comandos do **terraform** para criar uma instância EC2 na AWS, como foi criado um arquivo **main.tf** contendo toda a configuração da instância EC2 onde optei que fosse feita a instalação das ferramentas necessárias para executar o projeto, liberação das portas 22 e efetuar a cópia do shell script que foi criado para executar as ferramentas de monitoramento.

        ```
        terraform init
        
        terraform plan -out "output_plan"
        
        terraform apply output_plan
        ```

- Optei por utilizar **terraform plan -out** devido a segurança de não correr o risco de destruir toda a infraestrutura se for executado com o comando **terraform apply**.

### Configurando o servidor NGINX
- Após ter criado a instância do EC2, necessário verificar se o serviço NGINX está rodando e com acesso a sua página principal. <br> 
Acessando a seguinte página: https://ec2-34-221-77-37.us-west-2.compute.amazonaws.com

- Logo após esta verificação optei por deixar a página inicial do NGINX sendo carregada e para verificar a nossa aplicação é necessário somente executar a seguinte página: https://ec2-34-221-77-37.us-west-2.compute.amazonaws.com/index.json


### Criação e Execução do Script
- A minha estratégia para criação do script foi adicionar os comandos necessários para que fosse gerado o arquivo JSON, com isso o script contém os comandos para executar **dstat** e **csvtojson** salvando direto no PATH: **var/www/html/index.json**. <br>
O script já é salvo dentro da Instância no PATH: **/home/ubuntu**, só é necessário executar-lo. <br>

     ```
    ./script_monitor.sh 
    ```

**OBS:** Podem fazer o acesso a Instância via SSH ao invés de conectar pela interface do AWS. <br>

### Criação do Pipeline
- A criação do pipeline foi elaborada com os seguintes pensamentos:
    1. Efetuar o checkout do repositório.
    2. Validar a infra do terraform.
    3. Efetuar o terraform plan por segurança gerando o output_plan
    4. Executar o terraform apply com output_plan.
    5. Caso Algum stage falhe será executado o terraform destroy para já destruir caso a instância tenha sido criada.

Os items do 1 ao 3 serão executados assim que for criado uma PR para review, pois não é necessário que os items 4 e 5 sejam executados neste momento e com isso seguue o fluxo dos conceitos Devops.

### Dificuldades encontradas durante a resolução do Desafio
1. As primeiras dificuldades que eu encontrei foi durante a criação da instância no EC2 com os seguintes items:
    - Foi necessário entender o ambiente do AWS e suas configurações para acesso onde foi necessário configurar o serviço IAM.
    - Outro problema que eu tive foram com as portas 22 e 80 que era necessário estar no arquivo main.tf, pois eu até conseguia criar a Instância no EC2, mas não tinha nenhum acesso como SSH ou até mesmo com o Ip público.
    - A ferramenta dstat também foi um problema, pois não estava funcionando corretamente.
    - Efetuar a copia do script para a instância onde eu não estava conseguindo de nenhuma maneira até que encontrei na documentação oficial o **"**provisioner "file"** que resloveu meu problema.
    - Deixei o código comentado na parte de efetuar a cópia do arquivo dstat, pois estava dando permissão negado devido a localização do arquivo.
2. Durante a criaçã do script tive outras dificuldades principalmente com o segundo item, pois precisava verificar as atualizações de segurança e não estava conseguindo tratar somente essas atualizações e como o tempo estava curta e eu ainda precisava finalizar o restante optei por não resolver este item.
3. A criação do pipeline, pois foi a primeira vez que configurei um pipeline do zero e acabei me deparando com os seguintes problemas:
    - Como eu iria criar a estrutura do pipeline considerando o que era necessário verificar, acabei resolvendo esta dúvida após ler algumas documentações sobre pipelines e quais opções eu poderia escolher.
    - Após o entendimento resolvi seguir a estratégia mencionada anteriormente, porém percebi que estava dando problemas com as chaves públicas e privadas no qual acabei enviando para o repositório que não é uma boa prática.
    - Problemas com as chaves de segurança a idéia inicial era de utilizar o serviço S3 para armazenar, porém eu estava com o prazo apertado para montar tal infraestrutura, resolvi pesquisar uma outra solução na qual consegui entender qual era o meu problema. <br>
    Comecei criando as variaveis secretas no Gitlab e a partir dessas váriaveis executar o before_script para criar a pasta **~/.ssh/** contendo as minhas chaves e com isso resolvi o problema para clonar meu repositório e garantir que sempre vai estar atualizado.<br>
    Após está solução removi as pastas que contiam as chaves públicas e secretas.
    - O último problema que eu encontrei foi ao conectar na instância EC2 ao executar o stage build do pipeline e como infelizmente não terei tempo para buscar uma nova solução ou outra abordagem acabou ficando desta maneira o pipeline

### Considerações Finas
Fiquei muito animado em conseguir entregar as duas primeiras partes deste desafio no qual pude configurar do zero toda a infra e toda a execução do projeto mesmo com as dificuldades que foram aparecendo e ao memso tempo fui resolvendo aos poucos. <br>
A parte co CI/CD foi o meu maior desafio para implementar do zero contendo somente os conceitos básicos, fiquei muito orgulhoso em ver alguns stages funcionando corretamente e principalmente todo o processo de aprendizado durante esses 5 dias de desafio, agora é focar nos pontos fracos para melhorar e continuar buscando novos desafios com DevOps.






## Introdução do Desafio
Este é um desafio para testar seus conhecimentos de DevOps;

O objetivo é avaliar a sua forma de estruturação e autonomia em decisões para construir algo escalável utilizando as ferramentas propostas.

[SPOILER] As instruções de entrega e apresentação do challenge estão no final deste Readme (=

Será necessário documentar o seu processo e apresentá-lo (utilizando um PowerPoint ou apresentação semelhante), bem como demonstrar o resultado das tarefas no servidor durante a apresentação.Os resultados destas tarefas são menos importantes do que o seu processo de pensamento e decisões à medida que as completa, por isso tente documentar e apresentar os seus hipóteses e decisões na medida do possível.


## **Parte 1 - Configuração do Servidor**

A sua tarefa consiste em configurar um servidor baseado na nuvem e instalar e configurar alguns componentes básicos.

Trabalhar em um [FORK](https://lab.coodesh.com/help/gitlab-basics/fork-project.md) deste repositório em seu usuário ou utilizar um repositório em seu github pessoal (não esqueça de colocar no readme a referência a este challenge).

1. Configurar um servidor AWS (recomenda-se o freetier) executando uma versão Ubuntu LTS.
2. Instalar e configurar qualquer software que você recomendaria em uma configuração de servidor padrão sob as perspectivas de segurança, desempenho, backup e monitorização.
3. Instalar e configurar o nginx para servir uma página web HTML estática.
4. Utilizar ferramentas de automatização como Ansible, Terraform ou AWS Cloudformation.


## **Part 2 – Scripting**

Utilizando uma linguagem de script à sua escolha, construa um projeto (servido através do nginx) que possa relatar estatísticas operacionais básicas sob a forma de um objeto JSON.

As estatísticas devem incluir (como mínimo):



1. Carga actual da CPU, tempo de espera e utilização de memória (opcionalmente reportado como slab, cache, RSS, etc.)
2. Se existem actualizações pendentes (opcionalmente, reportando actualizações de segurança independentemente)
3. Utilização actual do disco e desempenho de leitura/escrita

O resultado final pode incluir quaisquer outras estatísticas que considere importantes para efeitos de monitorização do servidor. Você pode considerar a possibilidade de construir o script em cima do projeto [dstat](https://github.com/dagwieers/dstat).

O seu código deve ser entregue a um repositório Git que demonstram uma compreensão de conceitos tais como ramificação de branchs e merges requests.


## **Part 3 – Continuous Delivery**

Desenhar e construir uma pipeline para apoiar a entrega contínua da aplicação de monitorização construída na Parte 2 no servidor configurado na Parte 1. Descrever a pipeline utilizando um diagrama de fluxo e explicar o objetivo e o processo de seleção usado em cada uma das ferramentas e técnicas específicas que compõem a sua pipeline. 

## Readme do Repositório

- Deve conter o título do projeto
- Uma descrição sobre o projeto em frase
- Deve conter uma lista com linguagem, framework e/ou tecnologias usadas
- Como instalar e usar o projeto (instruções)
- Não esqueça o [.gitignore](https://www.toptal.com/developers/gitignore)
- Se está usando github pessoal, referencie que é um challenge by coodesh:  

>  This is a challenge by [Coodesh](https://coodesh.com/)

## Finalização e Instruções para a Apresentação

Avisar sobre a finalização e enviar para correção.

1. Confira se você respondeu o Scorecard da Vaga que chegou no seu email;
2. Confira se você respondeu o Mapeamento Comportamental que chegou no seu email;
3. Acesse: [https://coodesh.com/challenges/review](https://coodesh.com/challenges/review);
4. Adicione o repositório com a sua solução;
5. Grave um vídeo, utilizando o botão na tela de solicitar revisão da Coodesh, com no máximo 5 minutos, com a apresentação do seu projeto. Foque em pontos obrigatórios e diferenciais quando for apresentar.
6. Adicione o link da apresentação do seu projeto no README.md.
7. Verifique se o Readme está bom e faça o commit final em seu repositório;
8. Confira a vaga desejada;
9. Envie e aguarde as instruções para seguir no processo. Sucesso e boa sorte. =)

## Suporte

Use o nosso canal no slack: http://bit.ly/32CuOMy para tirar dúvidas sobre o processo ou envie um e-mail para contato@coodesh.com. 



