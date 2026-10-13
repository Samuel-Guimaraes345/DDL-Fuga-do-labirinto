# DDL // Fuga do Labirinto

![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Status](https://img.shields.io/badge/Status-Pronto_para_uso-brightgreen?style=for-the-badge)

## 📖 Sobre o Projeto

**DDL // Fuga do Labirinto** é um jogo de labirinto para celular, criado para a **dinâmica com a turma** de um trabalho acadêmico de **Modelagem de Banco de Dados**, com o tema **Geração e Implementação de Scripts DDL**.

O objetivo é simples: **encontrar a saída antes que o esquema mude.** Durante a partida, o próprio jogo executa comandos DDL (`ALTER`, `DROP` e `CREATE`) que transformam o labirinto em tempo real, mostrando na prática o que cada um deles faz com uma estrutura de banco de dados.

O jogo é feito em **HTML, CSS e JavaScript puros**, sem frameworks. Ao terminar, o tempo de cada participante é gravado em um **banco de dados PostgreSQL real**, que monta automaticamente a classificação da dinâmica.

## 🎮 Como Jogar

[![Play](https://img.shields.io/badge/▶️_PLAY-DDL_Fuga_do_Labirinto-2fe6d6?style=for-the-badge)](https://samuel-guimaraes345.github.io/NOME-DO-REPOSITORIO/)

1. Escaneie o **QR Code** (ou clique no botão acima) e toque em **Iniciar Jogo**.
2. Digite seu **nome e sobrenome verdadeiros**.
3. Leia a placa da entrada: a saída é a **porta de número 3**. O cronômetro só começa quando você fecha o aviso.
4. Encontre a porta... mas atenção: **a saída pode mudar de lugar**.
5. Entre no **portal** para vencer.
6. Aguarde aparecer **"✔ Tempo registrado na classificação"** antes de fechar a página.

> ⚠️ Apenas a **1ª tentativa** vale para o prêmio. As seguintes contam como treino.

### Controles

| Ação | Celular | Teclado |
|---|---|---|
| Mover | Setas na parte de baixo da tela (segure para andar mais rápido) | Setas ou W A S D |
| Pausar | Botão ⏸ no topo da tela | — |

### Dentro do jogo

- ⏱️ **Cronômetro** no topo, com precisão de milissegundos. Ele fica **pausado** enquanto você lê os avisos e os comandos SQL, para ninguém ser penalizado.
- 🔑 **Chave:** o ícone acende quando você conquista a chave.
- 💬 **Indicador de status** com dicas do que fazer em cada fase.

## 🧠 O que o Jogo Tem a Ver com DDL

| Comando | O que acontece no labirinto | O que representa |
|---|---|---|
| `ALTER` | A saída **troca de lugar**. O número 3 muda de porta, e pode acontecer mais de uma vez. | Modifica uma estrutura que já existe, sem apagá-la |
| `DROP` | A porta de saída **vira parede** e uma chave aparece no lugar. | Remove a estrutura |
| `CREATE` | Ao levar a chave ao pedestal da sala central, um **portal** é criado em um dos 4 corredores. | Cria uma nova estrutura |

Antes de cada evento, o jogo mostra uma "chuva de código" e um pop-up com o **comando SQL correspondente**.

## ✨ Funcionalidades

- 🧩 **Labirinto 23×23** com ramificações, becos sem saída e 8 portas numeradas, em que só uma leva à saída
- 🔀 **Mapa que muda durante a partida**, com eventos `ALTER`, `DROP` e `CREATE`
- 🌧️ **Efeito "chuva de código"** antes de cada comando
- ⏱️ **Cronômetro justo**, pausado durante os avisos
- 📱 **Feito para celular:** setas na tela, com suporte a teclado
- 💾 **Registro confiável do tempo:** se a internet falhar, o jogo guarda o resultado e tenta de novo sozinho
- 🏆 **Classificação automática** em banco de dados, organizada do menor para o maior tempo

## 📊 Painel de Classificação (organização)

Acesse `ranking.html` no endereço do jogo e digite a senha da organização.

- Lista os participantes em ordem: **1º, 2º, 3º...** do menor para o maior tempo
- Considera **só a 1ª tentativa** de cada nome (ignora maiúsculas e acentos)
- Atualiza sozinho a cada 5 segundos, ideal para o projetor
- Destaca o **pódio** (1º ao 3º) e as **20 primeiras posições**
- Marca com `CONFERIR` tempos abaixo de 30 segundos, para a organização checar

## 🛠️ Tecnologias Utilizadas

- **HTML5 / CSS3** — Interface, telas, HUD e animações
- **JavaScript (Vanilla)** — Lógica do jogo, movimentação, eventos e fila de envio do resultado
- **PostgreSQL (via Supabase)** — Banco de dados da classificação
- **SQL** — Estruturas, regras, funções e consultas do ranking (`schema.sql`)

## 🗄️ O que o Projeto Demonstra em Banco de Dados

| Conceito | Onde aparece |
|---|---|
| `CREATE TABLE` com chave primária e `CHECK` | Tabela `tentativas` |
| `CREATE INDEX` | Busca rápida por nome |
| `CREATE VIEW` | `ranking_labirinto` e `auditoria_labirinto` |
| `CREATE FUNCTION` | `registrar_tentativa` e `consultar_ranking` |
| `ALTER TABLE` | Ativação da segurança em nível de linha (RLS) |
| `TRUNCATE` | Limpar os dados de teste antes do evento |
| Funções de janela (`row_number`) | Numeração do ranking e identificação da 1ª tentativa |
| `GRANT` / `REVOKE` | O celular só consegue chamar as duas funções acima |

## 📁 Arquivos do Repositório

| Arquivo | Descrição |
|---|---|
| `index.html` | O jogo |
| `ranking.html` | Painel de classificação da organização |
| `schema.sql` | Script DDL do banco de dados |

## ⚠️ Limitações Conhecidas

- Duas pessoas com o **mesmo nome** não são bloqueadas. A segunda tentativa fica fora do ranking e a organização decide.
- "Nome verdadeiro" é conferido pela organização, e não por software.
- O histórico dentro do jogo (botão "Tempo de conclusão") mostra apenas as tentativas daquele celular. O ranking geral está em `ranking.html`.

## 🔒 Privacidade

O jogo coleta **nome, sobrenome, tempo** e um identificador anônimo do aparelho, apenas para a classificação da dinâmica. São dados pessoais segundo a LGPD (Lei nº 13.709/2018) e serão apagados após o evento.

## 👥 Equipe - Usuário no GitHub

Albert dos Santos Mariano
Alessandra Guimarães da Silva
Alison Belen Condori Mayta
Davi Pereira de Oliveira Silva
Ellen Cristina Soares de Jesus 
Giovana Moura Alves da Silva
João Pedro Theodoro de Sousa Andrade
Petterson Michel Lima Aguilar
Samuel Carmoni de Oliveira
Samuel Guimarães da Silva

*Trabalho acadêmico · Modelagem de Banco de Dados · Geração e Implementação de Scripts DDL*
