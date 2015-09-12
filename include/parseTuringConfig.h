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

#ifndef __PARSETURING__
#define __PARSETURING__

#include <turingParserTypes.h>

       int        parseTuringConfig(char const *configPath, header *head, element **tape, operation* program[]);
inline operation* searchRuleToApply(operation *currentRule, char req);
inline element*   extendTape(int direction, element **tape, element* cursor);
       int        executeTuring(header *head, element **tape, operation* program[]);
       void       printTape(element *tape);
       void       freAll(element *tape, operation *prog[]);

#endif
