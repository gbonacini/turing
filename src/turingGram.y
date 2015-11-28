/* -----------------------------------------------------------------
// Libturing - A library emulating a turing machine
// Copyright (C) 2015  Gabriele Bonacini
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA 
// ----------------------------------------------------------------- */

%{

// ### Turing machine grammar file: transform the lex tokens in memory structs for both data and program ###

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <turingParserTypes.h>
#include <turingGram.h>

int yylex(void);
int yyerror (header *head, element **tape, operation* program[], char *msg);

int line;

int yydebug=0;
operation *last[MAXRULEINDEX];
// ### The numer of instruction levels is restricted in the range 0 - 1023 ###

%}

%start turing

%union
{
        long int number;
        char *string;
	instructions transition;
}

%token <string> TAPE 
%token <number> STATUS 
%token <number> RULE 
%token <transition> OPERATION 
%token <number> CONFIGOFF 
%token <number> CONFIGSTAT 
%token <number> CONFIGHALT 
%token SEPARATOR 

%error-verbose
%parse-param { header *head} 
%parse-param {element **tape} 
%parse-param {operation* program[]}

%initial-action
{
	memset(last, 0, sizeof(last));
};

%%

turing: header SEPARATOR program ;

program: statement ;| program statement ;

header: tape SEPARATOR offset SEPARATOR state SEPARATOR halt ;

tape: TAPE	{
			char *buffer = $1;
			element *previous = NULL;
			element *current = NULL;
			for(unsigned long int i=0;i<strlen(buffer);i++){
				current = (element*)calloc(1, sizeof(element));
				if(current == NULL){
					yyerror(NULL, NULL, NULL, "Can't allocate new memory");
					exit(ALLOC_MEM_ERR);
				}
				if(i == 0) *tape = current;
				current->value = buffer[i];
				current->prev = previous;
				current->next = NULL;
				if(previous != NULL) previous->next = current;
				previous = current;
			}
			#ifdef  __DEBUG__TURING__
				fprintf(ERRSTREAM, "YACC - Turing yacc header offset - %s\n", $1);
			#endif
			free(buffer);
		;}
;

offset: CONFIGOFF	{
				head->offset=$1;
				#ifdef  __DEBUG__TURING__
					fprintf(ERRSTREAM, "YACC - Turing yacc header offset - %ld\n", $1);
				#endif
			;}
;
		
state: CONFIGSTAT	{
				head->state=$1;
				#ifdef  __DEBUG__TURING__ 
					fprintf(ERRSTREAM, "YACC - Turing yacc header stat - %ld\n", $1);
				#endif
			;}
;
		
halt: CONFIGHALT	{
				head->halt=$1;
				#ifdef  __DEBUG__TURING__ 
					fprintf(ERRSTREAM, "YACC - Turing yacc header halt - %ld\n", $1);
				#endif
			;}
;
statement: RULE OPERATION STATUS SEPARATOR {
								int index = $1;
								long int  status = $3;
								char read = ($2).read;
								char write = ($2).write;
								int  cursor = ($2).cursor;

								// ### The numer of instruction for a specified levels is implemented as ###
								// ### linked list. This give acceptable performance if the number of    ###
								// ### instructions in that level is small. In the other case, other     ###
								// ### kinds of data structs are preferable (i.e.e to permit a binary    ###
								// ### search instead of linear search.                                  ###

								if((index > (MAXRULEINDEX -1)) || (status > (MAXRULEINDEX -1))){
									yyerror(NULL, NULL, NULL, "Too many rules");
								}
								
								if(last[index] != NULL){
									(last[index])->next = (operation *)calloc(1, sizeof(operation));
									if((last[index])->next == NULL){
										yyerror(NULL, NULL, NULL, "Can't allocate new memory");
										exit(ALLOC_MEM_ERR);
									}

									last[index] = (last[index])->next;
									#ifdef  __DEBUG__TURING__ 
										fprintf(ERRSTREAM, "YACC - Turing yacc ADDED Rule on: %d\n", index);
									#endif
								}else{
									last[index] = (operation *)calloc(1, sizeof(operation));
									if(last[index] == NULL){
										yyerror(NULL, NULL, NULL, "Can't allocate new memory");
										exit(ALLOC_MEM_ERR);
									}
									program[index] = last[index];
									#ifdef  __DEBUG__TURING__ 
										fprintf(ERRSTREAM, "YACC - Turing yacc CREATED Rule on: %d\n", index);
									#endif
								}				
								(last[index])->read = read;
								(last[index])->write = write;
								(last[index])->direction = cursor;
								(last[index])->status = status;
								#ifdef  __DEBUG__TURING__ 
									fprintf(ERRSTREAM, "YACC - Turing yacc statement IDX: %d | %c | %c | %d | %ld \n",\
										 index, (last[index])->read, (last[index])->write,\
										 (last[index])->direction, (last[index])->status);
								#endif
							;}
;

%%

// ### Added because osx doesn't have liby.a installed.  ###

int yyerror (header *head, element **tape, operation* program[], char *msg){
	if( head != NULL || tape != NULL || program != NULL)
		fprintf (ERRSTREAM, "YACC - Head: %p Tape: %p Operation: %p\n", head, tape, program);
	return fprintf (ERRSTREAM, "YACC - Turing library error: %s\n",  msg);
}
