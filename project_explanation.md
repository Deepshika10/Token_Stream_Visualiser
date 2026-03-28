# Token Stream Visualizer - Detailed Project Explanation

## Project Overview

The Token Stream Visualizer is a lexical analyzer (lexer) implemented in C using the Flex tool. It reads C source code files and breaks them down into individual tokens, displaying them in a formatted stream with their types, values, and line numbers. The project demonstrates fundamental concepts in compiler design, specifically the lexical analysis phase.

**Purpose**: To tokenize C code and visualize the token stream, helping students understand how compilers break down source code into meaningful units.

**Technologies Used**:
- **Flex**: A fast lexical analyzer generator
- **C**: The implementation language
- **GCC**: Compiler for building the executable

## Project Structure

```
Token_Stream_Visualiser/
├── lexer.l           # Flex specification file (main source code)
├── lex.yy.c          # Generated C code from Flex (auto-generated)
├── tokenizer         # Compiled executable binary
├── run.sh            # Build and run script
├── README.md         # Project documentation
├── input1.txt        # Basic C code sample
├── input2.txt        # Functions and control structures
├── input3.txt        # Advanced C features
├── input4.txt        # Invalid tokens (errors)
├── input5.txt        # Mixed valid/invalid code
├── invalid1.txt      # Error examples
├── invalid2.txt      # Error examples
├── invalid3.txt      # Error examples
├── invalid4.txt      # Error examples
└── invalid5.txt      # Error examples
```

## Prerequisites

Before running this project, you need to install:
- **Flex**: `sudo apt install flex` (Ubuntu/Debian) or `brew install flex` (macOS)
- **GCC**: `sudo apt install gcc` (Ubuntu/Debian) or included with Xcode (macOS)

## How to Build and Run

### Option 1: Using the Script (Recommended)

```bash
chmod +x run.sh    # Make script executable (first time only)
./run.sh          # Builds and runs on all input files
```

### Option 2: Manual Build and Run

```bash
# Step 1: Generate C code from Flex specification
flex lexer.l

# Step 2: Compile the generated C code
gcc -Wall -Wextra -o tokenizer lex.yy.c

# Step 3: Run on an input file
./tokenizer input1.txt              # Output to terminal
./tokenizer input1.txt > output.txt  # Save output to file
```

## Detailed Code Explanation

The main logic is in `lexer.l`, which is a Flex specification file. Let's break it down line by line:

### Header Section (Lines 1-25)

```c
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
int line_no     = 1;    // Current line number in input
int token_no    = 0;    // Total tokens processed

int cnt_keyword = 0;    // Count of keywords found
int cnt_ident   = 0;    // Count of identifiers found
int cnt_integer = 0;    // Count of integer literals
int cnt_float   = 0;    // Count of float literals
int cnt_string  = 0;    // Count of string literals
int cnt_char    = 0;    // Count of character literals
int cnt_op      = 0;    // Count of operators
int cnt_symbol  = 0;    // Count of symbols/punctuation
int cnt_comment = 0;    // Count of comments
int cnt_error   = 0;    // Count of error tokens
```

**Explanation**: This section includes necessary C headers and declares global counters to track different types of tokens. These counters are used for statistics but aren't currently displayed in the output.

```c
/* ── forward declarations ─────────────────────────────────── */
void print_banner(const char *filename);
void print_header(void);
void print_row(const char *type, const char *value, int ln);
void print_footer(void);
void print_summary(void);
char *truncate_val(const char *s, char *buf, int maxlen);
extern int first_token;
```

**Explanation**: Forward declarations of helper functions that will format and print the token output.

```c
%}
```

**Explanation**: End of the C code block that gets copied directly into the generated lex.yy.c file.

### Flex Options (Line 26)

```c
%option noyywrap
```

**Explanation**: Tells Flex not to generate the yywrap() function, which is used for multiple input files. We only process one file at a time.

### Token Definitions (Lines 28-37)

```c
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
```

**Explanation**: Regular expression patterns that define different types of tokens:
- `DIGIT`: Any digit 0-9
- `LETTER`: Letters or underscore
- `ALNUM`: Letters, digits, or underscore
- `INT_LIT`: One or more digits
- `FLOAT_LIT`: Decimal numbers with optional scientific notation
- `ID`: Valid C identifier (letter/underscore followed by alnum)
- `STR_LIT`: String literals in double quotes
- `CHAR_LIT`: Character literals in single quotes
- `SL_COMMENT`: Single-line comments (// ...)
- `ML_COMMENT`: Multi-line comments (/* ... */)

### Rules Section (Lines 39-108)

```c
%%
```

**Explanation**: Marks the beginning of the token recognition rules. Each rule has a pattern followed by C code to execute when that pattern matches.

#### Keywords (Lines 41-62)

```c
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
"float"      |
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
```

**Explanation**: Matches all C keywords. The `|` separates alternatives. When a keyword is found, it calls `print_row()` to output "Keyword(keyword)" and increments the keyword counter.

#### Literals (Lines 64-67)

```c
 /* ── Literals ─────────────────────────────────────────────── */
{FLOAT_LIT}  { print_row("Number",     yytext, line_no); cnt_float++;   }
{INT_LIT}    { print_row("Number",     yytext, line_no); cnt_integer++;  }
{STR_LIT}    { print_row("String",     yytext, line_no); cnt_string++;   }
{CHAR_LIT}   { print_row("Char",       yytext, line_no); cnt_char++;     }
```

**Explanation**: Matches numeric literals (both int and float), string literals, and character literals. All numbers are categorized as "Number" regardless of type.

#### Identifiers (Lines 69-70)

```c
 /* ── Identifiers ──────────────────────────────────────────── */
{ID}         { print_row("Identifier", yytext, line_no); cnt_ident++;    }
```

**Explanation**: Matches valid C identifiers (variable names, function names, etc.) and prints them as "Identifier(name)".

#### Multi-character Operators (Lines 72-84)

```c
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
```

**Explanation**: Matches compound operators like ==, !=, <=, etc. These must come before single-character operators to avoid conflicts.

#### Single-character Operators (Lines 86-87)

```c
 /* ── Single-character operators ───────────────────────────── */
[+\-*/=<>!%&|^~]  { print_row("Operator",  yytext, line_no); cnt_op++;     }
```

**Explanation**: Matches single-character operators using a character class.

#### Symbols/Punctuation (Lines 89-90)

```c
 /* ── Punctuation / Symbols ────────────────────────────────── */
[;,(){}[\].:?]    { print_row("Symbol",    yytext, line_no); cnt_symbol++; }
```

**Explanation**: Matches punctuation symbols like semicolons, parentheses, brackets, etc.

#### Comments (Lines 92-107)

```c
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
```

**Explanation**: Comments are counted but not printed as tokens. Multi-line comments need special handling to count line breaks correctly.

#### Whitespace (Lines 109-116)

```c
 /* ── Whitespace ───────────────────────────────────────────── */
\n          {
    line_no++;
    if (!first_token) {
        printf("\n");
        first_token = 1;
    }
}
[ \t\r]+    { /* ignore */ }
```

**Explanation**: Newlines increment the line counter and may print line breaks in output. Spaces and tabs are ignored.

#### Error Handling (Lines 118-119)

```c
 /* ── Anything else is an error token ─────────────────────── */
.           { print_row("Error",      yytext, line_no); cnt_error++;   }
```

**Explanation**: Any character that doesn't match previous patterns is treated as an error token.

### User Code Section (Lines 121-167)

```c
%%
```

**Explanation**: Marks the end of rules and beginning of user-defined C functions.

#### Helper Functions

```c
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
```

**Explanation**: Utility function to truncate long token values for display purposes (though not currently used in print_row).

```c
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
```

**Explanation**: 
- `first_token`: Flag to control spacing between tokens
- `print_row()`: Main function that outputs each token in "Type(value)" format with proper separators
- Other functions are placeholders for future enhancements

## Token Categories Explained

| Category | Description | Examples | Output Format |
|----------|-------------|----------|---------------|
| Keyword | C reserved words | `int`, `if`, `while` | `Keyword(int)` |
| Identifier | Variable/function names | `main`, `x`, `my_var` | `Identifier(main)` |
| Number | Integer or float literals | `42`, `3.14` | `Number(42)` |
| String | String literals | `"hello"` | `String("hello")` |
| Char | Character literals | `'A'`, `'\n'` | `Char('A')` |
| Operator | Mathematical/logical operators | `+`, `==`, `&&` | `Operator(==)` |
| Symbol | Punctuation | `;`, `{`, `(` | `Symbol(;))` |
| Error | Invalid characters | `@`, `#`, `$` | `Error(@)` |

## Input/Output Examples

### Input: input1.txt
```
int a = 100;
int b = 200;
float pi = 3.14159;
```

### Output:
```
Keyword(int) | Identifier(a) | Operator(=) | Number(100) | Symbol(;)
Keyword(int) | Identifier(b) | Operator(=) | Number(200) | Symbol(;)
Keyword(float) | Identifier(pi) | Operator(=) | Number(3.14159) | Symbol(;)
```

### Input: invalid4.txt (with errors)
```
int a = 10 # 5;
float b = @.0;
```

### Output:
```
Keyword(int) | Identifier(a) | Operator(=) | Number(10) | Error(#) | Number(5) | Symbol(;)
Keyword(float) | Identifier(b) | Operator(=) | Error(@) | Number(.0) | Symbol(;)
```

## What Happens When Changes Are Made

### Modifying Token Patterns
- **Adding a new keyword**: Add it to the keywords list in lexer.l, rebuild with `flex lexer.l && gcc lex.yy.c -o tokenizer`
- **Changing output format**: Modify `print_row()` function
- **Adding new token types**: Define new patterns and corresponding actions

### Adding New Features
- **Line numbers in output**: Modify `print_row()` to include line numbers
- **Token counting summary**: Implement `print_summary()` to display counter values
- **Error reporting**: Enhance error handling with more descriptive messages

### File Changes and Rebuilding
1. Edit `lexer.l`
2. Run `flex lexer.l` to regenerate `lex.yy.c`
3. Run `gcc -Wall -Wextra -o tokenizer lex.yy.c` to rebuild
4. Test with `./tokenizer input_file.txt`

### Common Modifications
- **Case sensitivity**: Flex is case-sensitive by default; use `%option case-insensitive` to change
- **Performance**: Add `%option fast` for faster scanning
- **Debugging**: Add `%option debug` to see pattern matching details

## How the Lexer Works Internally

1. **Input Reading**: Reads the input file character by character
2. **Pattern Matching**: Uses regular expressions to identify token patterns
3. **Longest Match Rule**: When multiple patterns match, chooses the longest
4. **Rule Priority**: Earlier rules take precedence over later ones
5. **Token Actions**: Each matched pattern triggers its associated C code
6. **State Management**: Maintains line numbers and token counters
7. **Output Formatting**: Prints tokens in a stream format separated by " | "

This project demonstrates the fundamental principles of lexical analysis that form the first phase of any compiler or interpreter.