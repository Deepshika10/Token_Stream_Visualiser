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
"while"     { print_row("KEYWORD",    yytext, line_no); cnt_keyword++; }

 /* ── Literals ─────────────────────────────────────────────── */
{FLOAT_LIT}  { print_row("FLOAT",      yytext, line_no); cnt_float++;   }
{INT_LIT}    { print_row("INTEGER",    yytext, line_no); cnt_integer++;  }
{STR_LIT}    { print_row("STRING",     yytext, line_no); cnt_string++;   }
{CHAR_LIT}   { print_row("CHAR_LIT",   yytext, line_no); cnt_char++;     }

 /* ── Identifiers ──────────────────────────────────────────── */
{ID}         { print_row("IDENTIFIER", yytext, line_no); cnt_ident++;    }

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
"::"  { print_row("OPERATOR",  yytext, line_no); cnt_op++;     }

 /* ── Single-character operators ───────────────────────────── */
[+\-*/=<>!%&|^~]  { print_row("OPERATOR",  yytext, line_no); cnt_op++;     }

 /* ── Punctuation / Symbols ────────────────────────────────── */
[;,(){}[\].:?]    { print_row("SYMBOL",    yytext, line_no); cnt_symbol++; }

 /* ── Comments (tracked but not printed as tokens) ─────────── */
{SL_COMMENT}  {
    /* single-line comment — count but do not emit a token row */
    cnt_comment++;
}
{ML_COMMENT}  {
    /* multi-line comment — update line counter & count */
    int i;
    for (i = 0; yytext[i] != '\0'; i++)
        if (yytext[i] == '\n') line_no++;
    cnt_comment++;
}

 /* ── Whitespace ───────────────────────────────────────────── */
\n          { line_no++; }
[ \t\r]+    { /* ignore */ }

 /* ── Anything else is an error token ─────────────────────── */
.           { print_row("ERROR",      yytext, line_no); cnt_error++;   }

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

/* ============================================================
   Table borders and header
   +-------+--------------------+--------------------+--------+
   ============================================================ */
#define COL_SEP "+-------+--------------------+--------------------+--------+"
#define COL_HDR "| %-5s | %-18s | %-18s | %-6s |"
#define COL_ROW "| %-5d | %-18s | %-18s | %-6d |"

void print_banner(const char *filename) {
    printf("\n");
    printf("  +=====================================================+\n");
    printf("  |         T O K E N   S T R E A M   V I S U A L I Z E R         |\n");
    printf("  |                                                     |\n");
    printf("  |  Input : %-41s|\n", filename);
    printf("  +=====================================================+\n");
    printf("\n");
}

void print_header(void) {
    printf("%s\n", COL_SEP);
    printf(COL_HDR "\n", "No.", "TOKEN TYPE", "TOKEN VALUE", "LINE");
    printf("%s\n", COL_SEP);
}

void print_row(const char *type, const char *value, int ln) {
    char buf[64];
    token_no++;
    printf(COL_ROW "\n", token_no, type, truncate_val(value, buf, 18), ln);
}

void print_footer(void) {
    printf("%s\n", COL_SEP);
}

void print_summary(void) {
    int grand = cnt_keyword + cnt_ident  + cnt_integer + cnt_float  +
                cnt_string  + cnt_char   + cnt_op      + cnt_symbol +
                cnt_error;

    printf("\n");
    printf("  +========================+=========+\n");
    printf("  |   TOKEN STREAM SUMMARY           |\n");
    printf("  +========================+=========+\n");
    printf("  | %-22s | %-7s |\n", "Category",         "Count");
    printf("  +========================+=========+\n");
    printf("  | %-22s | %-7d |\n", "Keywords",          cnt_keyword);
    printf("  | %-22s | %-7d |\n", "Identifiers",       cnt_ident);
    printf("  | %-22s | %-7d |\n", "Integers",          cnt_integer);
    printf("  | %-22s | %-7d |\n", "Floats",            cnt_float);
    printf("  | %-22s | %-7d |\n", "String Literals",   cnt_string);
    printf("  | %-22s | %-7d |\n", "Char Literals",     cnt_char);
    printf("  | %-22s | %-7d |\n", "Operators",         cnt_op);
    printf("  | %-22s | %-7d |\n", "Symbols",           cnt_symbol);
    printf("  | %-22s | %-7d |\n", "Comments (skipped)",cnt_comment);
    printf("  | %-22s | %-7d |\n", "Errors",            cnt_error);
    printf("  +------------------------+---------+\n");
    printf("  | %-22s | %-7d |\n", "TOTAL TOKENS",      grand);
    printf("  +========================+=========+\n");
    printf("\n");
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
