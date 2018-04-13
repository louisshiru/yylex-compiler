/* Definition section */
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	/* Symbol table function */
	void create_symbol(); 	// Create symbol table
	void insert_symbol(); 	// Insert entry to symbol table
	int lookup_symbol(); 	// Lookup symbol table
	void dump_symbol(); 	// Dump out symbol table
	int init(); 		// Do something initialize
	char *text(char*);	// Extract ID, Type
	
	/*Create Data Structure*/
	struct symbol_table{
		int Index;
		char ID[40];
		char Type[8];
		struct symbol_table *next;
	};

	/* Declaim */
	struct symbol_table *Table, *head; // head -> Table's first
	int line = 0; 		// count lines
	int comment_line = 0; 	// count comment line
	int initflag = 0; 	// First time malloc and create symbol table
	int Index = 0; 		// count Index
	char *ID; 		// Temp, store ID
	char *Type; 		// Temp, store Type
	char store[1024] = ""; 	// Temp, store comments
	
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
<comment>"*/" { BEGIN(INITIAL); strcat(store, yytext); printf("%s\t\t C++ Comment\n", store); strcpy(store, ""); }
<comment>\n { strcat(store, yytext); }
<comment>. { strcat(store, yytext); }

{slash_comm} {comment_line++; printf("%s \t\t C++ Comment\n", yytext); }

{declare_var_int} { printf("%s \t int TYPE VAR \n", text(yytext)); create_symbol(); }
{declare_var_flt} { printf("%s \t float TYPE VAR \n", text(yytext)); create_symbol(); }

"print"	{ printf ("%s \t\t PRINT function \n", yytext);}
"println"	{printf ("%s \t\t PRINTLN function \n", yytext);}
"if"	{ printf ("%s \t IF function \n", yytext); }
"else"	{ printf ("%s \t Else function \n", yytext); }
"for"	{ printf ("%s \t FOR function \n", yytext); }

"&&"	{ printf ("%s \t And \n", yytext); }
"||"	{ printf ("%s \t Or \n", yytext); }
"!"	{ printf ("%s \t Not \n", yytext); }

"="	{ printf ("%s \t Assign \n", yytext); }
"+="	{ printf ("%s \t Add assign \n", yytext); }
"-="	{ printf ("%s \t Sub assign \n", yytext); }
"*="	{ printf ("%s \t Mul assign \n", yytext); }
"/="	{ printf ("%s \t Div assign \n", yytext); }
"%="	{ printf ("%s \t Mod assign \n", yytext); }

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
// If parse end. return 1
int yywrap(void)
{
    return 1;
}

int init()
{	
	Table = malloc(sizeof(struct symbol_table)); 
	head = Table; // Set head as Table's first
	printf("Create a symbol table\n");
	return 1;
}

char *text(char* yytext){
	
	//strtok ( strings, delimiter );
	yytext = strtok(yytext, " \t\n");
	
	ID = strtok(NULL, " \t\n");
	
	Type = strtok(NULL, " \t\n");
	
	return ID;
}

void create_symbol() 
{
	// If never init, do this.
	if (initflag == 0)
		initflag = init();

	// set every variable
	Index++;
	Table -> Index = Index;
	strcpy(Table -> ID, ID);
	strcpy(Table -> Type, Type);
	Table -> next = malloc(sizeof(struct symbol_table));
	
	printf("Insert a symbol: %s\n", Table->ID);

	printf("%d\t%s\t%s\n", Table -> Index, Table->ID, Table->Type);

	// Table point to next
	Table = Table->next;
}

void insert_symbol() 
{
	;
}

int lookup_symbol() 
{
	;
}

void dump_symbol() 
{
	struct symbol_table *next, *temp;

	// If head is NULL return
	if(!head) return;

	temp = head;

        while(temp -> Index != 0){
                printf("%d\t%s\t%s\n", temp->Index, temp -> ID, temp->Type);
                temp = temp -> next;
        }

	// If head's address same as Table's,
	// free head and return.
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
