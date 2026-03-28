%{
/* ============================================================
   Token Stream Visualizer — lexer.l
   Build:  flex lexer.l && gcc lex.yy.c -o tokenizer
   Run:    ./tokenizer input.txt
   ============================================================ */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>


int line_no     = 1;
int has_error   = 0;


void print_banner(const char *filename);
void print_header(void);
void print_row(const char *type, const char *value, int ln);
void print_footer(void);
void print_summary(void);
extern int first_token;

%}

%option noyywrap


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
"while"     { print_row("Keyword",    yytext, line_no); }


{FLOAT_LIT}  { print_row("Number",     yytext, line_no); }
{INT_LIT}    { print_row("Number",     yytext, line_no); }
{STR_LIT}    { print_row("String",     yytext, line_no); }
{CHAR_LIT}   { print_row("Char",       yytext, line_no); }


{ID}         { print_row("Identifier", yytext, line_no); }


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
"::"  { print_row("Operator",  yytext, line_no); }


[+\-*/=<>!%&|^~]  { print_row("Operator",  yytext, line_no); }


[;,(){}[\].:?]    { print_row("Symbol",    yytext, line_no); }


{SL_COMMENT}  {
    /* single-line comment */
}
{ML_COMMENT}  {
    /* multi-line comment — update line counter */
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
.           {
    has_error = 1;
    print_row("Error", yytext, line_no);
}

%%

int first_token = 1;

void print_row(const char *type, const char *value, int ln) {
    if (!first_token) {
        printf(" | ");
    }
    printf("%s(%s)", type, value);
    first_token = 0;
}

void print_footer(void) {
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

    yylex();
    print_footer();
    if (has_error) {
        printf("This file is errorneous, so cannot proceed wit the next phase\n");
    }

    fclose(fp);
    return 0;
}
