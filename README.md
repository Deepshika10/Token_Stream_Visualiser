# Token Stream Visualizer

A lexical analyzer built with **C** and **Flex** that scans any C source file and prints a formatted token-stream table with types, values, line numbers, and a summary report.

---

## Project Structure

```
Token_Stream_Visualiser/
├── lexer.l        ← Flex rules + C code (core logic)
├── run.sh         ← Build & run script for all 5 inputs
├── input1.txt     ← Valid:   basic types, arithmetic, operators
├── input2.txt     ← Valid:   functions, loops, conditionals
├── input3.txt     ← Valid:   structs, pointers, literals, all operators
├── input4.txt     ← Invalid: stray symbols (@, #, $, `, \)
├── input5.txt     ← Mixed:   valid C with error tokens scattered in
├── .gitignore
└── README.md
```

> `lex.yy.c`, `tokenizer`, and `output*.txt` are generated at runtime.

---

## Prerequisites

Install **flex** and **gcc**:

| Platform | Command |
|---|---|
| Ubuntu / Debian / WSL | `sudo apt install flex gcc` |
| macOS | `brew install flex` · `xcode-select --install` |
| MSYS2 / MinGW | `pacman -S flex gcc` |

---

## How to Run

### Option A — Script (all 5 inputs at once)

```bash
chmod +x run.sh   # first time only
./run.sh
```

### Option B — Manual (single file)

```bash
# Step 1: generate C code
flex lexer.l

# Step 2: compile
gcc -Wall -Wextra -o tokenizer lex.yy.c

# Step 3: run
./tokenizer input1.txt              # print to terminal
./tokenizer input1.txt > output1.txt   # save to file
```

> **Windows (MSYS2/Git Bash):** use `tokenizer.exe` in step 2 & 3. `run.sh` handles this automatically.

---

## Token Categories

| Type | Examples |
|---|---|
| `KEYWORD` | `int`, `if`, `while`, `return` |
| `IDENTIFIER` | `main`, `x`, `my_var` |
| `INTEGER` | `42`, `100` |
| `FLOAT` | `3.14`, `2.7e+1` |
| `STRING` | `"hello"` |
| `CHAR_LIT` | `'A'`, `'\n'` |
| `OPERATOR` | `+`, `==`, `&&`, `->`, `++` |
| `SYMBOL` | `;`, `{`, `(`, `[` |
| `ERROR` | `@`, `#`, `$`, `` ` ``, `\` |
| *(Comments)* | `// …`, `/* … */` — counted, not printed |

*Flex 2.6+ · GCC · Linux · macOS · WSL · MSYS2*