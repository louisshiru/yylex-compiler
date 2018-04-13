/* Definition section */
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	/* Symbol table function */
	void create_symbol();
	void insert_symbol();
	int lookup_symbol();
	void dump_symbol();
	int init();
	char *text(char*);
	
	struct symbol_table{
		int Index;
		char *ID;
		char *Type;
		struct symbol_table *next;
	};

	struct symbol_table *Table, *head;

	int line = 0;
	int comment_line = 0;
	int initflag = 0;
	int Index = 0;
	char *ID;
	char *Type;
	char store[1024] = "";
	
%}

/* Define regular expression label */

letter [a-zA-Z]
digit [0-9]
delim [" "\n\t(){}]

id {letter}+({letter}|{digit})*
number {digit}+
float_num {number}"."{number}

string ["](.|{delim})*["]
slash_comm "//".*

declare_var_int_assign "var"(" "|[\t])+{id}(" "|[\t])+"int"(" "|[\t])*"="(" "|[\t])*{number}
declare_var_int "var"(" "|[\t])+{id}(" "|[\t])+"int"(" "|[\t])*
declare_var_flt_assign "var"(" "|[\t])+{id}(" "|[\t])+"float32"(" "|[\t])*"="(" "|[\t])*({float_num}|{number})
declare_var_flt "var"(" "|[\t])+{id}" "+"float32"(" "|[\t])*

%x comment
/* Rules section */
%%

"/*"	{ BEGIN(comment); comment_line++; strcat(store, yytext); }
<comment>"*/" { BEGIN(INITIAL); printf("%s*/\t\t C++ Comment\n", store); }
<comment>\n { strcat(store, yytext); }
<comment>. { strcat(store, yytext); }

{slash_comm} {comment_line++; printf("%s \t\t C++ Comment\n", yytext); }

{declare_var_int} { printf("%s \t int TYPE VAR \n", text(yytext)); create_symbol(); }
{declare_var_flt} { printf("%s \t float TYPE VAR \n", text(yytext)); create_symbol(); }

"print"	{ printf ("%s \t\t PRINT function \n", yytext);}
"println"	{printf ("%s \t\t PRINTLN function \n", yytext);}
"if"	{ printf ("%s \t if \n", yytext); }
"else"	{ printf ("%s \t else \n", yytext); }
"for"	{ printf ("%s \t FOR function \n", yytext); }

"&&"	{ printf ("%s \t and \n", yytext); }
"||"	{ printf ("%s \t or \n", yytext); }
"!"	{ printf ("%s \t not \n", yytext); }

"="	{ printf ("%s \t assign \n", yytext); }
"+="	{ printf ("%s \t add assign \n", yytext); }
"-="	{ printf ("%s \t sub assign \n", yytext); }
"*="	{ printf ("%s \t mul assign \n", yytext); }
"/="	{ printf ("%s \t div assign \n", yytext); }
"%="	{ printf ("%s \t mod assign \n", yytext); }

"<"	{ printf ("%s \t Less than \n", yytext); }
">"	{ printf ("%s \t Greater than \n", yytext); }
"<="	{ printf ("%s \t Less than or Equal \n", yytext); }
">="	{ printf ("%s \t Greater than or Equal \n", yytext); }
"=="	{ printf ("%s \t Equal \n", yytext); }
"!="	{ printf ("%s \t Uneqaul \n", yytext); }

"+" 	{ printf("%s \t Add \n", yytext); }
"-"	{ printf("%s \t Sub \n", yytext); }
"*"	{ printf ("%s \t Mul \n", yytext); }
"/"	{ printf ("%s \t Div \n", yytext); }
"%"	{ printf ("%s \t Mod \n", yytext); }
"++"	{ printf ("%s \t Increment \n", yytext); }
"--"	{ printf ("%s \t Decrement \n", yytext); }

{number} { printf ("%s \t Number \n", yytext);}
{string} { printf ("%s \t string \n", yytext);}
{id}	{ printf("%s \t ID \n", yytext); }
\n	{ line++; }
"{" { printf ("%s \t LCB \n", yytext);}
"}" { printf ("%s \t RCB \n", yytext);}
"(" { printf ("%s \t LB \n", yytext);}
")" { printf ("%s \t RB \n", yytext);}

%%

/*	C Code section */
int yywrap(void)
{
    return 1;
}

int init()
{	
	Table = malloc(sizeof(struct symbol_table));
	head = Table;
	printf("Create a symbol table\n");
	return 1;
}


//提出變數; strtok 2 次
char *text(char* yytext){
	
	yytext = strtok(yytext, " \t\n");
	
	ID = strtok(NULL, " \t\n");
	
	Type = strtok(NULL, " \t\n");
	
	return ID;
}

void create_symbol() 
{
	if (initflag == 0)
		initflag = init();

	Index++;
	Table -> Index = Index;
	Table -> ID = ID;
	Table -> Type = Type;
	Table -> next = malloc(sizeof(struct symbol_table));
	
	printf("Insert a symbol: %s\n", Table->ID);

	Table = Table->next;
}

void insert_symbol() 
{
	if (initflag == 0)
		initflag = init();
}

int lookup_symbol() 
{
	;
}

void dump_symbol() 
{
	struct symbol_table *next, *temp;

	if(!head) return;

	temp = head;

        while(temp -> next != NULL){
                printf("%d\t%s\t%s\n", temp->Index, temp->ID, temp->Type);
                temp = temp -> next;
        }

	if (head == Table)
	{
		free(head);
		return;
	}

	while(Table -> next != NULL)
	{
		next = Table -> next;
		free(Table);
		Table = next;
	}

	return;
}

int main(int argc,char *argv[])
{
	yyin = fopen(argv[1],"r");
	yylex();

	printf("\nParse over, the line number is %d.\n\n", line);

        printf("comment: %d lines\n\n", comment_line);
	
	printf("The symbol table dump:\n");
	dump_symbol();
 

	return 0;
}

