/* Definition section */
%{
	#include <stdio.h>
	#include <stdlib.h>

	/* Symbol table function */
	void create_symbol();
	void insert_symbol();
	int lookup_symbol();
	void dump_symbol();

%}

/* Define regular expression label */

letter [a-zA-Z]
digit [0-9]
id {letter}+({letter}|{digit})*
number {digit}+

/* Rules section */
%%

"="	{ printf("%s \t Assign \n", yytext); }
"--"	{ printf("%s \t dcr \n", yytext); }
"++"	{ printf("%s \t icr \n", yytext); }
"%"	{ printf("%s \t mod \n", yytext); }
"/"	{ printf("%s \t div \n", yytext); }
"*"	{ printf("%s \t Mul \n", yytext); }
"+" 	{ printf("%s \t Add \n", yytext); }
"-"		{ printf("%s \t Sub \n", yytext); }
{id}	{ printf("%s \t ID \n", yytext); }
\n			{;}

%%

/*	C Code section */
int yywrap(void)
{
    return 1;
}

void create_symbol() {;}
void insert_symbol() {;}
int lookup_symbol() {;}
void dump_symbol() {;}

int main(int argc,char *argv[])
{
	yyin = fopen(argv[1],"r");
	yylex();

	dump_symbol();

	return 0;
}

