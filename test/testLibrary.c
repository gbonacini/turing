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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <parseTuringConfig.h>

int main(int argc, char** argv){

    int result;
    header head;
    element *tape;
    operation* program[MAXRULEINDEX];

    memset(program, 0, sizeof(program));
    
    if(argc < 2){
		   fprintf(stderr,"Test file needed!");
		   exit(1);
    }
    result = parseTuringConfig(argv[1], &head, &tape, program);
   
    if(result == 0){
	   fprintf(stderr,"Parse status - OK  - Status: %d\n", result);
    }else{
	   fprintf(stderr,"Parse status - NOK - Err: %d\n", result);
	   exit(-1);
    }
   
    result = executeTuring(&head, &tape, program);

    if(result == 0){
	   fprintf(stderr,"Execution status - OK  - Status: %d\n", result);
    }else{
	   fprintf(stderr,"Execution status - NOK - Err: %d\n", result);
	   exit(-1);
    }

    printTape(tape);

    freAll(tape, program);

    return 0;
}
