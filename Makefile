# ============================================================
#  Token Stream Visualizer — Makefile
#  Usage:
#    make          → build the tokenizer binary
#    make run      → build + run on input.txt
#    make clean    → remove generated files
# ============================================================

CC      = gcc
LEX     = flex
TARGET  = tokenizer
LEXFILE = lexer.l
LEXOUT  = lex.yy.c
INPUT   = input.txt
CFLAGS  = -Wall -Wextra -g

# ── Default target: build the binary ────────────────────────
all: $(TARGET)

# ── Step 1: run flex to generate lex.yy.c ───────────────────
$(LEXOUT): $(LEXFILE)
	$(LEX) $(LEXFILE)

# ── Step 2: compile lex.yy.c into the tokenizer binary ──────
#    We do NOT need -lfl because %option noyywrap is set in
#    lexer.l, so no external flex library is required.
$(TARGET): $(LEXOUT)
	$(CC) $(CFLAGS) -o $(TARGET) $(LEXOUT)

# ── run: build then execute on the default input file ────────
run: $(TARGET)
	./$(TARGET) $(INPUT)

# ── test: run against a custom file (make test FILE=my.c) ────
test: $(TARGET)
	./$(TARGET) $(FILE)

# ── clean: remove all generated artefacts ────────────────────
clean:
	rm -f $(TARGET) $(LEXOUT)

# ── help: print usage reminder ────────────────────────────────
help:
	@echo ""
	@echo "  Token Stream Visualizer — available targets"
	@echo "  ─────────────────────────────────────────────"
	@echo "  make            Build the tokenizer binary"
	@echo "  make run        Build + run on $(INPUT)"
	@echo "  make test FILE=<path>  Run on a custom input file"
	@echo "  make clean      Remove tokenizer and lex.yy.c"
	@echo "  make help       Show this message"
	@echo ""

.PHONY: all run test clean help
