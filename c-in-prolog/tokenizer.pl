
/*** 
Use the tokenize/2 predicate as follows:

run(File):-
	tokenize(File,Program),
	parse(ParseTree,Program,[]),
	execute(ParseTree,[],_VariablesOut).

tokenize(+File,-Tokens):- 
	Tokens is a list of tokens collected from file File. 
	In the file each token should be separated by white space.
***/

tokenize(File,Tokens):-
	open(File,read,InputStream),
	read_from_file(InputStream,Codes1),
	remove_leading_whitespace(Codes1,Codes2),
	tokenize_codelist(Codes2,CodeLists),
	tokens_from_codelists(CodeLists,Tokens),
	close(InputStream).

% read_line | read_line_to_codes
read_from_file(InputStream,Lines2):-
	read_line_to_codes(InputStream,Line), 
	Line \= end_of_file, !,
	read_from_file(InputStream,Lines1), 
	append(Line,[32|Lines1],Lines2). /* 32 = ' ' */
read_from_file(_,[]).

remove_leading_whitespace([Code|Cs1],Cs2):-
	whitespace(Code),
	remove_leading_whitespace(Cs1,Cs2).
remove_leading_whitespace([Code|Cs],[Code|Cs]):-
	\+ whitespace(Code).
remove_leading_whitespace([],[]).

whitespace(9). /* '\t' */
whitespace(32). /* ' ' */

tokenize_codelist([Code|Cs1],[[]|Ls]):-
	whitespace(Code),
	remove_leading_whitespace(Cs1,Cs2),
	tokenize_codelist(Cs2,Ls).
tokenize_codelist([Code|Cs1],[[Code|Cs2]|Ls]):-
	\+ whitespace(Code),
	tokenize_codelist(Cs1,[Cs2|Ls]).
tokenize_codelist([],[]).

tokens_from_codelists([CodeList|CLs],[Token|Ts]):-
	create_token(CodeList,Token), 
	tokens_from_codelists(CLs,Ts).
tokens_from_codelists([],[]).

create_token([Code|Codes],Number):-
	numeric_code(Code), 
	number_codes(Number,[Code|Codes]).
create_token([Code|Codes],Atom):-
	\+ numeric_code(Code), 
	atom_codes(Atom,[Code|Codes]).

numeric_code(Code):-
	Code >= 48, /* 48 = '0' */ 
	Code =< 57. /* 57 = '9' */
	