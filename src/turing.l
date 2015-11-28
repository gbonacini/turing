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

%option yywrap
%option nounput
%option noinput

%{

// ### Turing machine configuration file tokenizer and syntax checking  ###

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <errno.h>

#include <turingParserTypes.h>
#include <turingGram.h>

#define HEADTAPE	1
#define HEADOFFSET	2
#define HEADSTATE	3
#define HEADHALT	4
#define HEADMAXLINES	4

extern int line;

extern YYSTYPE yylval;
extern int yyerror();

char *endptr;

%}

%%

^[!].*[\n] {
	// ### Comment: it's ignored
}
^[ \t]*[\n] {
	// ### Blank Line: it's ignored
}
^[\n] {
	// ### Empty Line: it's ignored
}
[ ]{2,} {

	yyerror(NULL, NULL, NULL, "Only single separator permitted"); 
	exit(NO_PARSE_ERR);
}
[\n] {
	line++;
	return SEPARATOR;
}
^["-}]*$ {
	// ### Match all the printable characters, excluding ' ' and '~'
	// ### because they have special purpose.
	int ret;
	long int converBuff;

	errno = 0;

	switch(line+1){
		case HEADTAPE:
			yylval.string = strdup(yytext);
			if(yylval.string == NULL){
				yyerror(NULL, NULL, NULL, "Can't allocate new memory"); 
				exit(ALLOC_MEM_ERR);
			}
			ret = TAPE;
			#ifdef __DEBUG__TURING__
				fprintf(ERRSTREAM,"Lex - HEADTAPE -- Ret: %d \n", ret);  
			#endif
		break;
		case HEADOFFSET:
			converBuff = strtol(yytext, &endptr, 10);
			if( endptr != (yytext + yyleng) || errno == EINVAL || errno == ERANGE ) {
				yyerror(NULL, NULL, NULL, "Invalid header type"); 
				exit(NO_PARSE_ERR);
			}
			yylval.number = converBuff;
			ret = CONFIGOFF;
			#ifdef __DEBUG__TURING__
				fprintf(ERRSTREAM,"Lex - HEADOFF -- Ret: %d \n", ret);  
			#endif

		break;
		case HEADSTATE:
			converBuff = strtol(yytext, &endptr, 10);
			if( endptr != (yytext + yyleng) || errno == EINVAL || errno == ERANGE ) {
				yyerror(NULL, NULL, NULL, "Invalid header type"); 
				exit(NO_PARSE_ERR);
			}
			yylval.number = converBuff;
			ret = CONFIGSTAT;
			#ifdef __DEBUG__TURING__
				fprintf(ERRSTREAM,"Lex - HEADSTATE -- Ret: %d \n", ret);  
			#endif
		break;
		case HEADHALT:
			converBuff = strtol(yytext, &endptr, 10);
			if( endptr != (yytext + yyleng) || errno == EINVAL || errno == ERANGE ) {
				yyerror(NULL, NULL, NULL, "Invalid header type"); 
				exit(NO_PARSE_ERR);
			}
			yylval.number = converBuff;
			ret = CONFIGHALT;
			#ifdef __DEBUG__TURING__
				fprintf(ERRSTREAM,"Lex - HEADHALT -- Ret: %d \n", ret);  
			#endif
		break;
	}
	
	#ifdef __DEBUG__TURING__
		fprintf(ERRSTREAM,"Lex - HEADER -- ID: %d -- BUFFER: %s\n", ret, yytext);  
		if(ret != TAPE) fprintf(ERRSTREAM, "Lex - Result: %s\n", endptr == (yytext + yyleng) ? "VALID" : "NOT VALID");
	#endif

	return ret;
}
[ ]["-~][ ]["-~][ ][-]?[01][ ] {
	#ifdef __DEBUG__TURING__
 		fprintf(ERRSTREAM,"Lex - OPERATION -- ID: %d -- BUFFER: %s\n", OPERATION, yytext);  
	#endif

	yylval.transition.read = yytext[1];
	yylval.transition.write = yytext[3];
	yylval.transition.cursor = atol(yytext + 5);

	return OPERATION;
}
[0-9]+$ {
	#ifdef __DEBUG__TURING__
 		fprintf(ERRSTREAM,"Lex - STATUS  -- ID: %d -- BUFFER: %s\n", STATUS, yytext);  
	#endif

	errno = 0;
	yylval.number = strtol(yytext, NULL, 10);
	if( errno == EINVAL || errno == ERANGE ) {
		yyerror(NULL, NULL, NULL, "Invalid rule index"); 
		exit(NO_PARSE_ERR);
	}

	return STATUS;
}
^[0-9]+ {
	#ifdef __DEBUG__TURING__
 		fprintf(ERRSTREAM,"Lex - RULE  -- ID: %d -- BUFFER: %s\n", STATUS, yytext);  
	#endif

	errno = 0;
	yylval.number = strtol(yytext, NULL, 10);
	if( errno == EINVAL || errno == ERANGE ) {
		yyerror(NULL, NULL, NULL, "Invalid rule index"); 
		exit(NO_PARSE_ERR);
	}

	return RULE;
}
.  {
	yyerror(NULL, NULL, NULL, "Illegal token"); 
	exit(NO_PARSE_ERR);
}
%%

int yywrap(){
	#ifdef __DEBUG__TURING__
 		fprintf(ERRSTREAM,"Lex - EOF\n");  
	#endif

	return 1; 
}

