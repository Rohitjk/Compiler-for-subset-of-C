%{
	#include <stdlib.h>
	#include <stdio.h>	

%}
%token HEADER_FILE

%token IDENTIFIER

 /* Constants */
%token DEC_CONSTANT HEX_CONSTANT
%token STRING

 /* Logical and Relational operators */
%token AND OR LSEQ GREQ EQ NOTEQ

 /* Short hand assignment operators */
%token MUL_EQ DIV_EQ MOD_EQ ADD_EQ SUB_EQ
%token INCREMENT DECREMENT

 /* Data types */
%token SHORT INT LONG LONG_LONG SIGNED UNSIGNED CONST

 /* Keywords */
%token IF FOR WHILE CONTINUE BREAK RETURN ELSE

%start start

%left ','
%right '='
%left OR
%left AND
%left EQ NOTEQ
%left '<' '>' LSEQ GREQ
%left '+' '-'
%left '*' '/' '%'
%right '!'


%%


 /* Program is made up of multiple builder blocks. */
start: start builder
       |builder;

 /* Each builder block is either a function or a declaration */
builder: //header_file
	 function
         |declaration
	;
/*
header_file: HEADER_FILE
	    |header_file
	;
*/

 /* This is how a function looks like */
function: type IDENTIFIER '(' argument_list ')' '{' statements '}';

 /* Now we will define a grammar for how types can be specified */

type :data_type pointer
    |data_type;

pointer: '*' pointer
    |'*'
    ;

data_type :sign_specifier type_specifier
    |type_specifier
    ;

sign_specifier :SIGNED
    |UNSIGNED
    ;

type_specifier :INT               
    |SHORT INT                      
    |SHORT                         
    |LONG                         
    |LONG INT                     
    |LONG_LONG                       
    |LONG_LONG INT                     
    ;

 /* grammar rules for argument list */
 /* argument list can be empty */
argument_list :arguments
    |
    ;
 /* arguments are comma separated TYPE ID pairs */
arguments :arguments ',' arg
    |arg
    ;

 /* Each arg is a TYPE ID pair */
arg :type IDENTIFIER
   ;

 /* Generic statement. Can be compound or a single statement */
stmt:'{' statements '}'
      |single_stmt
    ;
  

statements:statements stmt
    |
    ;

 /* Grammar for what constitutes every individual statement */
single_stmt :if_block
    |for_block
    |while_block
    |declaration
    |function_call ';'
	|RETURN ';'
	|CONTINUE ';'
	|BREAK ';'
	|RETURN sub_expr ';'
    ;

for_block:FOR '(' expression_stmt  expression_stmt ')' stmt
    |FOR '(' expression_stmt expression_stmt expression ')' stmt
    ;

if_block:IF '(' expression ')' stmt 
	|IF '(' expression ')' stmt ELSE stmt
    ;

while_block: WHILE '(' expression ')' stmt
		;

declaration:type declaration_list ';'
			 |declaration_list ';'
			 | unary_expr ';'
			|error ';'
		;
/*program will contionue to check after encountering a error*/


declaration_list: declaration_list ',' sub_decl
		|sub_decl;

sub_decl: assignment_expr
    |IDENTIFIER                    
    |array_index
    ;

/* This is because we can have empty expession statements inside for loops */
expression_stmt:expression ';'
    |';'
    ;

expression:
    expression ',' sub_expr						
    |sub_expr		                                 
		;

sub_expr:
    sub_expr '>' sub_expr					
    |sub_expr '<' sub_expr						
    |sub_expr EQ sub_expr						
    |sub_expr NOTEQ sub_expr                   
    |sub_expr LSEQ sub_expr                    
    |sub_expr GREQ sub_expr                    
	|sub_expr AND sub_expr              
	|sub_expr OR sub_expr               
	|'!' sub_expr                              
	|arithmetic_expr
    |assignment_expr                        
	|unary_expr                               
    ;


assignment_expr :lhs assign_op arithmetic_expr     
    |lhs assign_op array_index                    
    |lhs assign_op function_call                
	|lhs assign_op unary_expr                     
	|unary_expr assign_op unary_expr           
    ;

unary_expr:	lhs INCREMENT                       
	|lhs DECREMENT                             
	|DECREMENT lhs                             
	|INCREMENT lhs                               
	;
lhs:IDENTIFIER                                  
    ;

assign_op:'='                              
    |ADD_EQ                              
    |SUB_EQ                               
    |MUL_EQ                             
    |DIV_EQ                               
    |MOD_EQ                                    
    ;

arithmetic_expr: arithmetic_expr '+' arithmetic_expr   
    |arithmetic_expr '-' arithmetic_expr               
    |arithmetic_expr '*' arithmetic_expr                
    |arithmetic_expr '/' arithmetic_expr                
	|arithmetic_expr '%' arithmetic_expr                
	|'(' arithmetic_expr ')'               
    |IDENTIFIER                                         
    |constant                                           
    ;

constant: DEC_CONSTANT                                  
    |HEX_CONSTANT                                       
    ;

array_index: IDENTIFIER '[' sub_expr ']'
	;
function_call: IDENTIFIER '(' parameter_list ')'
             |IDENTIFIER '(' ')'
             ;

parameter_list:
              parameter_list ','  parameter
              |parameter
              ;

parameter: sub_expr
	   |STRING

        ;


%%

#include "lex.yy.c"
#include <ctype.h>
int count=0;


int main(int argc, char *argv[])
{

	yyin = fopen(argv[1], "r");

	if(!yyparse())
	{
		printf("\nParsing complete\n");
	}
	else
	{
			printf("\nParsing failed\n");
	}

	fclose(yyin);
	return 0;
}

int yyerror(char *msg)
{
	printf("Line no: %d Error message: %s Token: %s\n", yylineno, msg, yytext);
}
