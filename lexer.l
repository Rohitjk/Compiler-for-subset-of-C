%{

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include "y.tab.h"

int cmnt_strt = 0;

%}

letter [a-zA-Z]
digit [0-9]
ws  [ \t\r\f\v]+
/*\r is CR,\v is Vertical tab,*/
identifier (_|{letter})({letter}|{digit}|_){0,31}
hex [0-9a-f]

 /* Exclusive states */
%x CMNT
%x PREPROC

%%
  /* Keywords*/
"int"                             {return INT;}
"long"                            {return LONG;}
"long long"                       {return LONG_LONG;}
"short"                           {return SHORT;}
"signed"                          {return SIGNED;}
"unsigned"                        {return UNSIGNED;}
"for"                             {return FOR;}
"while"                           {return WHILE;}
"break"                           {return BREAK;}
"continue"                        {return CONTINUE;}
"if"                              {return IF;}
"else"                            {return ELSE;}
"return"                          {return RETURN;}

{identifier}                      {return  IDENTIFIER;}
{ws}                              {;}
[+\-]?[0][x|X]{hex}+[lLuU]?        {return  HEX_CONSTANT;}
[+\-]?{digit}+[lLuU]?              {return  DEC_CONSTANT;}
	/*l is long suffix and u is unsigned suffix*/

"/*"                              {cmnt_strt = yylineno; BEGIN CMNT;}
<CMNT>.|{ws}                      ;
<CMNT>\n                          {yylineno++;}
<CMNT>"*/"                        {BEGIN INITIAL;}
<CMNT>"/*"                        {printf("Line %3d: Nested comments are not valid!\n",yylineno);}
<CMNT><<EOF>>                     {printf("Line %3d: Unterminated comment\n", cmnt_strt); yyterminate();}
^"#include"                       {BEGIN PREPROC;}
<PREPROC>"<"[^<>\n]+">"            {return HEADER_FILE;}
<PREPROC>{ws}                      {;}
<PREPROC>\"[^"\n]+\"              {return HEADER_FILE;}
<PREPROC>\n                       {yylineno++; BEGIN INITIAL;}
<PREPROC>.                        {printf("Line %3d: Illegal header file format \n",yylineno);}
"//".*                            ;

	/*If the quoted string ends with a backslash before the closing quotation
	mark, it uses yyless() to push back the closing quote, and yyrnore () to 
	tell lex to append the next token to this one. The next token will be the
	rest of the quoted string starting with the pushed back quote, so the entire
	string will end up in yytext.*/
\"[^\"\n]*\"     {

  if(yytext[yyleng-2]=='\\') /* check if it was an escaped quote */
  {
    yyless(yyleng-1);       /* push the quote back if it was escaped */
    yymore();
  }
  else{
  return STRING;
  }
 }

\"[^\"\n]*$                     {printf("Line %3d: Unterminated string %s\n",yylineno,yytext);}
{digit}+({letter}|_)+	        {printf("Line %3d: Illegal identifier name %s\n",yylineno,yytext);}
\n                              {yylineno++;}

"--"			                {return DECREMENT;}
"++"			                {return INCREMENT;}
"+="                      {return ADD_EQ;}
"-="                      {return SUB_EQ;}
"*="                      {return MUL_EQ;}
"/="                      {return DIV_EQ;}
"%="                      {return MOD_EQ;}


"&&"			                {return AND;}
"||"			                {return OR;}
"<="			                {return LSEQ;}
">="			                {return GREQ;}
"=="			                {return EQ;}
"!="		                  {return NOTEQ;}

.                         {return yytext[0];}

%%
