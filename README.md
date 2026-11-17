# Trabalho 3 — Compiladores

Analisador léxico e sintático para uma pequena linguagem de programação, desenvolvido para a disciplina de **Compiladores**. A linguagem suporta funções (`fn`), variáveis tipadas (`i64` / `f64`), expressões aritméticas e lógicas e estruturas de controle (`if` / `else` / `while`).

Ao final da análise, o programa percorre o código e imprime:

- a **tabela de símbolos** — funções, variáveis declaradas e seus tipos;
- as **estruturas de controle** de cada função (`if` / `while`).

## 🧰 Tecnologias

- **C**
- **Flex (Lex)** — análise léxica (`xyz.l`)
- **Bison/Yacc** — análise sintática e ações semânticas (`xyz.y`)

## ▶️ Compilar e executar

```bash
make                 # gera o executável
./<executavel> <arquivo-de-entrada>
```

> Consulte o `Makefile` para o nome exato do alvo e do executável gerado.

## 📁 Arquivos

- `xyz.l` — regras léxicas (definição dos tokens)
- `xyz.y` — gramática e ações semânticas (tabela de símbolos e fluxo de controle)
- `Makefile` — automação do build
