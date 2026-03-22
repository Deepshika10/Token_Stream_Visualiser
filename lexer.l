%{
/* ============================================================
   Token Stream Visualizer — lexer.l
   Build:  flex lexer.l && gcc lex.yy.c -o tokenizer
   Run:    ./tokenizer input.txt
   ============================================================ */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* ── counters ─────────────────────────────────────────────── */
int line_no     = 1;
int token_no    = 0;

int cnt_keyword = 0;
int cnt_ident   = 0;
int cnt_integer = 0;
int cnt_float   = 0;
int cnt_string  = 0;
int cnt_char    = 0;
int cnt_op      = 0;
int cnt_symbol  = 0;
int cnt_comment = 0;
int cnt_error   = 0;

/* ── forward declarations ─────────────────────────────────── */
void print_banner(const char *filename);
void print_header(void);
void print_row(const char *type, const char *value, int ln);
void print_footer(void);
void print_summary(void);
char *truncate_val(const char *s, char *buf, int maxlen);
extern int first_token;

%}

%option noyywrap

/* ── helper definitions ───────────────────────────────────── */
DIGIT       [0-9]
LETTER      [a-zA-Z_]
ALNUM       [a-zA-Z0-9_]
INT_LIT     {DIGIT}+
FLOAT_LIT   {DIGIT}+\.{DIGIT}+([eE][+\-]?{DIGIT}+)?
ID          {LETTER}{ALNUM}*
STR_LIT     \"([^\\\"\n]|\\.)*\"
CHAR_LIT    \'([^\\\'\n]|\\.)\'
SL_COMMENT  "//"[^\n]*
ML_COMMENT  "/*"([^*]|\*+[^*/])*\*+"/"

%%

 /* ── Keywords (must precede IDENTIFIER rule) ─────────────── */
"auto"      |
"break"     |
"case"      |
"char"      |
"const"     |
"continue"  |
"default"   |
"do"        |
"double"    |
"else"      |
"enum"      |
"extern"    |
"float"     |
"for"       |
"goto"      |
"if"        |
"int"       |
"long"      |
"register"  |
"return"    |
"short"     |
"signed"    |
"sizeof"    |
"static"    |
"struct"    |
"switch"    |
"typedef"   |
"union"     |
"unsigned"  |
"void"      |
"volatile"  |
"while"     { print_row("Keyword",    yytext, line_no); cnt_keyword++; }

 /* ── Literals ─────────────────────────────────────────────── */
{FLOAT_LIT}  { print_row("Number",     yytext, line_no); cnt_float++;   }
{INT_LIT}    { print_row("Number",     yytext, line_no); cnt_integer++;  }
{STR_LIT}    { print_row("String",     yytext, line_no); cnt_string++;   }
{CHAR_LIT}   { print_row("Char",       yytext, line_no); cnt_char++;     }

 /* ── Identifiers ──────────────────────────────────────────── */
{ID}         { print_row("Identifier", yytext, line_no); cnt_ident++;    }

 /* ── Multi-character operators (before single-char!) ──────── */
"=="  |
"!="  |
"<="  |
">="  |
"&&"  |
"||"  |
"++"  |
"--"  |
"+="  |
"-="  |
"*="  |
"/="  |
"%="  |
"<<"  |
">>"  |
"->"  |
"::"  { print_row("Operator",  yytext, line_no); cnt_op++;     }

 /* ── Single-character operators ───────────────────────────── */
[+\-*/=<>!%&|^~]  { print_row("Operator",  yytext, line_no); cnt_op++;     }

 /* ── Punctuation / Symbols ────────────────────────────────── */
[;,(){}[\].:?]    { print_row("Symbol",    yytext, line_no); cnt_symbol++; }

 /* ── Comments (tracked but not printed as tokens) ─────────── */
{SL_COMMENT}  {
    /* single-line comment — count but do not emit a token row */
    cnt_comment++;
}
{ML_COMMENT}  {
    /* multi-line comment — update line counter & count */
    int i;
    for (i = 0; yytext[i] != '\0'; i++) {
        if (yytext[i] == '\n') {
            line_no++;
            if (!first_token) {
                printf("\n");
                first_token = 1;
            }
        }
    }
    cnt_comment++;
}

 /* ── Whitespace ───────────────────────────────────────────── */
\n          { 
    line_no++; 
    if (!first_token) {
        printf("\n");
        first_token = 1;
    }
}
[ \t\r]+    { /* ignore */ }

 /* ── Anything else is an error token ─────────────────────── */
.           { print_row("Error",      yytext, line_no); cnt_error++;   }

%%

/* ============================================================
   Helper: truncate a value string so the table stays aligned.
   buf must be at least maxlen+4 bytes.
   ============================================================ */
char *truncate_val(const char *s, char *buf, int maxlen) {
    int len = (int)strlen(s);
    if (len <= maxlen) {
        strncpy(buf, s, maxlen + 3);
        buf[maxlen + 3] = '\0';
    } else {
        strncpy(buf, s, maxlen - 3);
        buf[maxlen - 3] = '\0';
        strcat(buf, "...");
    }
    return buf;
}

int first_token = 1;

void print_banner(const char *filename) {
    /* empty */
}

void print_header(void) {
    /* empty */
}

void print_row(const char *type, const char *value, int ln) {
    if (!first_token) {
        printf(" | ");
    }
    printf("%s(%s)", type, value);
    first_token = 0;
    token_no++;
}

void print_footer(void) {
    printf("\n");
}

void print_summary(void) {
    /* empty */
}

/* ============================================================
   main — accepts a filename as the first argument
   ============================================================ */
int main(int argc, char *argv[]) {
    FILE *fp;

    if (argc < 2) {
        fprintf(stderr, "\n  Usage : %s <input_file>\n", argv[0]);
        fprintf(stderr, "  Example: %s input.txt\n\n", argv[0]);
        return 1;
    }

    fp = fopen(argv[1], "r");
    if (!fp) {
        fprintf(stderr, "\n  Error : Cannot open file '%s'\n\n", argv[1]);
        return 1;
    }

    yyin = fp;

    print_banner(argv[1]);
    print_header();
    yylex();
    print_footer();
    print_summary();

    fclose(fp);
    return 0;
}
