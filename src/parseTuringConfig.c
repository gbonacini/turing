// -----------------------------------------------------------------
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
// -----------------------------------------------------------------

#include <turingParserTypes.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

extern FILE * yyin;
extern int yydebug;
extern int yyparse(header *head, element **tape, operation* program[]);

int parseTuringConfig(char const *configPath, header *head, element **tape, operation* program[]){

	// ###  Wrap the yacc function ###

	int ret = 0;
	FILE* CONFIG= fopen(configPath, "r");
	if(CONFIG != NULL){
		yyin=CONFIG;
		yydebug=1;
		ret = yyparse(head, tape, program);
		if(ret != 0){
			return NO_PARSE_ERR;
		}
	}else{
		return NO_CONFIG_FILE_ERR;
	}
	(void)fclose(CONFIG);
	return ret;
}

inline int extendTape(int direction, element **tape, element* cursor){

	// ###  Extend the populed area of the "tape" ("left" or "right" ).if required during the eleboration ###

	int ret = 0;
	element* proc = NULL;
	element* newElement =  (element *) calloc(1, sizeof(element));

	if(newElement != NULL){
		switch(direction){
			case DIRECTION_L:
				if( cursor->prev == NULL ){
					cursor->prev = newElement;
					proc = cursor->prev;
					proc->prev = NULL;
					proc->next = cursor;
					proc->value = SPACE_CHAR;
					*tape = cursor->prev;
				}else{
					ret = DIR_INVALID_ERR;
				}
			break;
			case DIRECTION_R:
				if( cursor->next == NULL ){
					cursor->next =  newElement;
					proc = cursor->next;
					proc->prev = cursor;
					proc->next = NULL;
					proc->value = SPACE_CHAR;
				}else{
					ret = DIR_INVALID_ERR;
				}
			break;
			default:
				ret = DIR_UNEXIST_ERR;
				free(newElement);
		}
	} else {
		ret = ALLOC_MEM_ERR;
	}

	return ret;
}

void printTape(element *tape){

	// ###  Print all the "tape" values ###

	while(tape->next != NULL){
	   fprintf(stderr, "%c", tape->value);
	   tape = tape->next;
	}
	fprintf(stderr, "%c\n", tape->value);
}

inline operation* searchRuleToApply(operation *currentRule, char req){

		// ###  Search a matching rule for the specified state. ###

		for( ;; ){
			if(currentRule == NULL){
				return NULL;
			}

			#ifdef  __DEBUG__TURING__
				fprintf(ERRSTREAM, "Turing execution - Search Rule: %c | %c | %d | %ld \n",\
					 currentRule->read, currentRule->write, currentRule->direction, currentRule->status);
			#endif

			if(currentRule->read == req || currentRule->read == JOLLY_CHAR){
				#ifdef  __DEBUG__TURING__
					fprintf(ERRSTREAM, "Turing execution - Match Rule: %c | %c | %d | %ld \n",\
						 currentRule->read, currentRule->write, currentRule->direction, currentRule->status);
				#endif
				return currentRule;			
			} 
			currentRule = currentRule->next;
		}
}

int executeTuring(header *head, element **tape, operation* program[]){

	// ### Execute the Turing machine program using the "tape"data ###

	int ret = 0;
	long int currentStateIdx = head->state;
	element *cursor = *tape;
	operation* currentRule = NULL;

	// Move the cursor on the initial position
	for(int i=0;i !=  head->offset; i++){
		cursor = cursor->next;
	}

	while(currentStateIdx != head->halt){
		currentRule = searchRuleToApply(program[currentStateIdx], cursor->value );
		if( currentRule  == NULL){
			ret = NO_RULE_MATCH;
			break;
		}
		#ifdef  __DEBUG__TURING__
			fprintf(ERRSTREAM, "Turing execution - Curr: %c | Mod: %c | Dir: %d | Old State: %ld Req State: %ld\n",\
				cursor->value, currentRule->write, currentRule->direction, currentStateIdx,  currentRule->status);
			printTape(*tape);
		#endif
		if(currentRule->write != JOLLY_CHAR ){
			cursor->value = currentRule->write;
		}
		switch(currentRule->direction){
			case DIRECTION_L:
				if(cursor->prev == NULL){
					ret = extendTape(DIRECTION_L, tape, cursor);
					#ifdef  __DEBUG__TURING__
						fprintf(ERRSTREAM, "Turing execution - Add L\n");
					#endif
				}
				cursor = cursor->prev;
				#ifdef  __DEBUG__TURING__
					fprintf(ERRSTREAM, "Turing execution - MOVE L: %c\n", cursor->value);
				#endif
			break;
			case DIRECTION_R:
				if(cursor->next == NULL){
					ret = extendTape(DIRECTION_R, tape, cursor);
					#ifdef  __DEBUG__TURING__
						fprintf(ERRSTREAM, "Turing execution - Add R\n");
					#endif
				}
				cursor = cursor->next;
				#ifdef  __DEBUG__TURING__
					fprintf(ERRSTREAM, "Turing execution - MOVE R: %c\n", cursor->value);
				#endif
			break;
			case DIRECTION_S:
				// Do nothing

				#ifdef  __DEBUG__TURING__
					fprintf(ERRSTREAM, "Turing execution - Stay. \n");
				#endif
			break;
		}
		currentStateIdx = currentRule->status;
		#ifdef  __DEBUG__TURING__
			fprintf(ERRSTREAM, "Turing execution - New state : %ld\n", currentStateIdx);
		#endif

	}	

	return ret;
}

void freAll(element *tape, operation *prog[]){
	element   *prev = NULL;
	operation *prevOp = NULL;
	operation *level = NULL;
	

	while(tape->next != NULL){
	   prev = tape;
	   tape = tape->next;
	   free(prev);
	}

	for(int i=0; i<MAXRULEINDEX; i++){
		if(prog[i] == NULL){
			// ### This prevent a memory leak, if the rule levels aren't contiguous ###
			continue; 
		}
		level = prog[i];
		while(level->next != NULL){
		   prevOp = level;
		   level = level->next;
		   free(prevOp);
		}
	}
}
