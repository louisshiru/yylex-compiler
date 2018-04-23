/* Definition section */
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	/* Symbol table function */
	void create_symbol(); 	// Create symbol table
	void insert_symbol(); 	// Insert entry to symbol table
	int lookup_symbol(char*, int); // Lookup symbol table
	void dump_symbol(); 	// Dump out symbol table
	char *text(char*);	// Extract ID, Type

	/* Check syntax error fucntion */
	void check_Undeclared(char*);
	void check_Redefined(char*);

	/* Another Function */
	void gocmt();	// Judge comment lines
	void init();	// alloc memory

	/* Symbol Table Structure */
	struct symbol_table{ 
		int Index;	
		char ID[40];
		char Type[8];
		struct symbol_table *next;
	};
	/* Invalid_ID Structure */
	struct invalid_ID{
		char ID[40];
		struct invalid_ID *next;
	};
	struct invalid_ID *traversal(char*);//Looking up invalid ID table
	
	/* Declaim */
	struct symbol_table *Table, *head; // head -> Table's first
	struct invalid_ID *i_Table, *i_head; // i_head -> i_Table's first
	int line = 0; 		// count lines
	int comment_line = 0;// count comment line
	int initflag = 0; 	// First time malloc and create symbol table
	int Index = 0; 		// count index
	char *ID; 		// Temp, store ID
	char *Type; 		// Temp, store Type
	char store[1024] = ""; 	// Temp, store comments
	int line_table[1024] = {0};
	int line_index = 0;
	
%}

/* Define regular expression label */

letter [a-zA-Z]
digit [0-9]

id {letter}+({letter}|{digit})*
number {digit}+
float_num {number}"."{number}

declare_var_int "var"(" "|[\t])+{id}(" "|[\t])+"int"(" "|[\t])*
declare_var_flt "var"(" "|[\t])+{id}" "+"float32"(" "|[\t])*

quote ["]

%x comment
%x string
/* Rules section */
%%

"//".* { printf("%s \t\t C++ Comment\n", yytext); line_table[line_index] = line; line_index++;}
"/*"	{ BEGIN(comment); strcat(store, yytext); line_table[line_index] = line; line_index++;}
<comment>"*/" { BEGIN(INITIAL); strcat(store, yytext); printf("%s \t\t C++ Comment\n", store); strcpy(store, "");}
<comment>\n { strcat(store, yytext); line++; line_table[line_index] = line; line_index++;}
<comment>. { strcat(store, yytext); }

{quote} { BEGIN(string); strcat(store, yytext); }
<string>{quote} { BEGIN(INITIAL); strcat(store, yytext); printf("%s \t String \n", store); strcpy(store, "");}
<string>\n { strcat(store, yytext); line++;}
<string>. { strcat(store, yytext); }

{declare_var_int} { printf("%s \t int TYPE VAR \n", text(yytext)); check_Redefined(ID); create_symbol(); }
{declare_var_flt} { printf("%s \t float32 TYPE VAR \n", text(yytext)); check_Redefined(ID);create_symbol(); }

" "
"print"	{ printf ("%s \t\t PRINT function \n", yytext);}
"println"	{printf ("%s \t\t PRINTLN function \n", yytext);}
"if"	{ printf ("%s \t IF function \n", yytext); }
"else"	{ printf ("%s \t ELSE function \n", yytext); }
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

{float_num} {printf ("%s \t Float32 \n", yytext);} 
{number} { printf ("%s \t Number \n", yytext);}
{id}	{ printf("%s \t ID \n", yytext); check_Undeclared(yytext); }
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

void gocmt()
{
	int i, j;
	for(i = 0; i < line; i++)
	{		
		for(j = 0; j < line_index; j++)
		{
			if(line_table[j] == i)
			{
				comment_line++;
				break;
			}
		}
	}
}

char *text(char* yytext){
	
	//strtok ( strings, delimiter );
	yytext = strtok(yytext, " \t\n");
	
	ID = strtok(NULL, " \t\n");
	
	Type = strtok(NULL, " \t\n");
	
	return ID;
}

struct invalid_ID *traversal(char* checkID)
{
	struct invalid_ID *i_temp = i_head;
	
	while(i_temp -> next != NULL)
	{
		if(strcmp(i_temp->ID, checkID) == 0)
			return NULL;
		i_temp = i_temp -> next;
	}
	
	return i_head;
}

void init()
{
	if(Table == NULL)
	{   
		Table = malloc(sizeof(struct symbol_table));
                head = Table; // Set head as Table's first
        }   
     	if(i_Table == NULL)
        {   
                i_Table = malloc(sizeof(struct invalid_ID));
                i_head = i_Table; // Set i_head as i_Table's first
        } 
}

//Traversal Table check syntax error
void check_Undeclared(char* checkID)
{
	init();

	// check if already exist ID in invalid table, if, return. 
//	if(!traversal(checkID)) return;

	int Undeclared = lookup_symbol(checkID, 0);

	//Found syntax error, append to invalid ID table.
	if (Undeclared == -1)
	{
		printf(":%d '%s'-> Semantic Error! Undeclared Variable\n", line+1, checkID);
		strcpy(i_Table -> ID, checkID);
		i_Table -> next = malloc(sizeof(struct invalid_ID));
		i_Table = i_Table -> next;
		return;
	}
}

void check_Redefined(char* checkID)
{
	if(!head) return;

        // check if already exist ID in invalid table, if, return. 
//	if(!traversal(checkID)) return;

	int Redefined = lookup_symbol(checkID, 1);

        //Found syntax error, append to invalid ID table.
        if (Redefined > 0)
        {   
                printf(":%d '%s'-> Semantic Error! Redefined variable\n", line+1, checkID);
                strcpy(i_Table -> ID, checkID);
                i_Table -> next = malloc(sizeof(struct invalid_ID));
                i_Table = i_Table -> next;
                return;
        } 	
}

void create_symbol() 
{
	// If never init, do this.
	if (initflag == 0){
        	
		init();
		
        	printf("Create a symbol table\n");
		
		insert_symbol();
		initflag = 1;
		return;
	}

	if(!traversal(ID)) return;

	else
	insert_symbol();
}

void insert_symbol() 
{
        // set every variable
        Index++;
        Table -> Index = Index;
        strcpy(Table -> ID, ID);
        strcpy(Table -> Type, Type);
        Table -> next = malloc(sizeof(struct symbol_table));

        printf("Insert a symbol: %s\n", Table->ID);

        // Table point to next
        Table = Table->next;

}

int lookup_symbol(char* lookupID, int mode) 
{
	if(!head) return ~0;

	struct symbol_table *temp = head;

	if(mode == 0){

		while(temp -> Index != 0)
		{
			if( strcmp(lookupID, temp->ID) == 0 )
				return temp -> Index;
			temp = temp -> next;
		}
		return ~0;
	}

	int Redefined = 0;

	if(mode == 1)
	{
		while(temp -> next != NULL)
        	{   
                	if(strcmp(temp -> ID, lookupID) == 0)
                	{   
                        	Redefined += 1; // check, if exist >1 same IDs in symbol table.
                	}   
                	temp = temp -> next;
        	}
	}

	return Redefined;
}

void dump_symbol() 
{
	struct symbol_table *cur;
	struct invalid_ID *icur;
	
	init();

	// If head's Index == 0, return
	if(head -> Index == 0)
	{
		puts("\nNothing in symbol table, return\n"); 
		return;
	}
	
	//show and free symbol table
        while(head -> next != NULL){
                printf("%d\t%s\t%s\n", head->Index, head -> ID, head->Type);
		cur = head;
		head = head -> next;
		free(cur);
        }

	puts("");
	
	//free invalid_ID table
	if(!i_head) return;	
	while(i_head -> next != NULL)
	{
		icur = i_head;
		i_head = i_head -> next;
		free(icur);
	}
	
	return;
}

int main(int argc,char *argv[])
{
	yyin = fopen(argv[1],"r");
	yylex();

	printf("\nParse over, the line number is %d.\n\n", line);

	gocmt();

        printf("comment: %d lines\n\n", comment_line);
	
	printf("The symbol table dump:\n");
	dump_symbol();

	fclose(yyin);	

	return 0;
}

