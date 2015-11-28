// -----------------------------------------------------------------
// Libturing - A library emulating turing machine
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

#ifndef __PARSETURINGTYPES__
#define __PARSETURINGTYPES__

#include <stdbool.h>
#include <errno.h>

#define NO_CONFIG_FILE_ERR 2
#define NO_PARSE_ERR       3
#define NO_RULE_MATCH      4
#define ALLOC_MEM_ERR  	   5
#define DIR_UNEXIST_ERR    6
#define DIR_INVALID_ERR    7
#define INPUT_ERR          8
#define PARSER_ERR         9
#define EXECUTION_ERR     10

#define ERRSTREAM stderr
// ### The numer of instruction levels is restricted in the range 0 - 1023 ###
#define MAXRULEINDEX 1024

#define DIRECTION_L    -1
#define DIRECTION_R     1
#define DIRECTION_S     0

#define JOLLY_CHAR      '~'
#define SPACE_CHAR      '-'

// ### Element is the basic component of a "tape" ###
// ### The "tape" is a double linked list         ###

typedef struct element element;

struct element { 
			char value;
			element *prev;
			element *next;
};

// ### Operation is one of the possible basic operation on the Turing machine ###
// ### A operation element single linked list is the group  of instructions   ###
// ### in a specific status level.                                            ###

typedef struct operation operation;

struct operation {
			char read;
			char write;
			int direction;
			long int status;
			operation *next;
};

// ### Header is the initial setting of the Turing machine that is read in the config file ###

typedef struct header header;

struct header {
			long int offset;
			long int state;
			long int halt;
};

// ### This is a service struct used by the parser module   ###

typedef struct instructions instructions;

struct instructions {
	char read;
	char write;
	int cursor;
};

#endif

