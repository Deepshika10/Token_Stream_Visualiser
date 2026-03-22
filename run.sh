#!/usr/bin/env bash
# ============================================================
#  Token Stream Visualizer — run.sh
#
#  What this script does:
#    1. Runs flex on lexer.l  to generate lex.yy.c
#    2. Compiles  lex.yy.c   to produce the tokenizer binary
#    3. Runs the tokenizer on each of the 5 input files and
#       saves every token-stream table to its output file:
#         input1.txt  →  output1.txt
#         input2.txt  →  output2.txt
#         input3.txt  →  output3.txt
#         input4.txt  →  output4.txt
#         input5.txt  →  output5.txt
#
#  Usage (Linux / macOS / WSL / Git Bash):
#    chmod +x run.sh
#    ./run.sh
#
#  Requirements:
#    flex  — sudo apt install flex   |  brew install flex
#    gcc   — sudo apt install gcc    |  brew install gcc
# ============================================================

set -e   # exit immediately on any error

# ── Colour codes (disabled when not in an interactive terminal) ──
if [ -t 1 ]; then
    GREEN="\033[0;32m"
    YELLOW="\033[1;33m"
    RED="\033[0;31m"
    CYAN="\033[0;36m"
    RESET="\033[0m"
else
    GREEN="" YELLOW="" RED="" CYAN="" RESET=""
fi

# ── Banner ────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}  +================================================+"
echo -e "  |      Token Stream Visualizer — run.sh         |"
echo -e "  +================================================+${RESET}"
echo ""

# ── Detect binary name (tokenizer vs tokenizer.exe on Windows) ───
BIN="./tokenizer"
if [[ "$(uname -s 2>/dev/null)" == *"MINGW"*  ]] || \
   [[ "$(uname -s 2>/dev/null)" == *"CYGWIN"* ]]; then
    BIN="./tokenizer.exe"
fi

# ── Step 1 : flex ─────────────────────────────────────────────────
echo -e "  ${YELLOW}[1/2]${RESET} Generating lex.yy.c from lexer.l  (flex) ..."

if ! command -v flex &>/dev/null; then
    echo -e "  ${RED}[ERR]${RESET} 'flex' not found."
    echo "        Install it:  sudo apt install flex   OR   brew install flex"
    exit 1
fi

flex lexer.l
echo -e "  ${GREEN}[OK] ${RESET} lex.yy.c generated."
echo ""

# ── Step 2 : gcc ──────────────────────────────────────────────────
echo -e "  ${YELLOW}[2/2]${RESET} Compiling lex.yy.c into tokenizer binary  (gcc) ..."

if ! command -v gcc &>/dev/null; then
    echo -e "  ${RED}[ERR]${RESET} 'gcc' not found."
    echo "        Install it:  sudo apt install gcc    OR   brew install gcc"
    exit 1
fi

gcc -Wall -Wextra -o tokenizer lex.yy.c
echo -e "  ${GREEN}[OK] ${RESET} tokenizer binary built."
echo ""

# ── Step 3 : run on all 5 inputs ──────────────────────────────────
echo -e "  ${CYAN}Running tokenizer on all 5 input files ...${RESET}"
echo ""

PASS=0
FAIL=0

for i in 1 2 3 4 5; do
    INPUT="input${i}.txt"
    OUTPUT="output${i}.txt"

    if [ -f "$INPUT" ]; then
        $BIN "$INPUT" > "$OUTPUT"
        echo -e "  ${GREEN}[OK] ${RESET} $INPUT  →  $OUTPUT"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}[!!] ${RESET} $INPUT not found — skipped."
        FAIL=$((FAIL + 1))
    fi
done

# ── Summary ───────────────────────────────────────────────────────
echo ""
echo -e "  +----------------------------------+"
echo -e "  |  Processed : ${GREEN}${PASS} file(s)${RESET}              |"
if [ "$FAIL" -gt 0 ]; then
echo -e "  |  Skipped   : ${RED}${FAIL} file(s)${RESET}              |"
fi
echo -e "  +----------------------------------+"
echo ""
echo -e "  Open any ${CYAN}output*.txt${RESET} file to view the token stream."
echo ""
