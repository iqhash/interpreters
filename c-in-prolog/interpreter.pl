% Author: Haishi Qi 

% consult(tokenizer).
% run('test.txt',ParseTree,VariablesOut)
run(File,ParseTree,VariablesOut):-
	tokenize(File,Program),
	parse(ParseTree,Program,[]),
	execute(ParseTree,[],VariablesOut).

parse(ParseTree) --> block([],ParseTree).

% execute([def_assign(b),op_assign(a,1)],[],Vars)
execute([],Vars,Vars).
execute([Statement|T],Vars1,Vars3):-
	Statement \== [],do(Statement,Vars1,Vars2), execute(T,Vars2,Vars3).

% do([def_assign(b)],[],Vars2)
do(def_assign(N),Vars1,Vars2):-
	var_type(N,Vars1,Type),
	update_vars(Type,(N,0),Vars1,Vars2).
	
% do(op_assign(c, cal(1, plus, 1)),[],Vars2)	
do(op_assign(N,VV),Vars1,Vars2):-
	evaluate(Vars1,VV, V),
	var_type(N,Vars1,Type),
	update_vars(Type,(N,V),Vars1,Vars2).

% do(while(condition(a, less, 10), [write(a), op_assign(a, cal(a, plus, 1))]),[(a,8)],Vars).
do(while(Condition, StList), Vars1, Vars3):-
	my_compare(Condition,Vars1,Truth),
	((Truth == true,
	execute(StList, Vars1, Vars2), 
	do(while(Condition, StList), Vars2, Vars3));
	(Truth == false,
	Vars3 = Vars1
	)).


do(if(Condition, StList), Vars1, Vars2):-
	my_compare(Condition,Vars1,Truth),
	(
	(Truth == true, execute(StList, Vars1, Vars2));
	(Truth == false, Vars2 = Vars1)
	).


do(read(N),Vars1,Vars2):-
	read(V),
	var_type(N,Vars1,Type),
	update_vars(Type,(N,V),Vars1,Vars2).
	
do(write(VV),Vars1,Vars2):-
	evaluate(Vars1, VV, Result),
	writeln(Result),
	Vars2 = Vars1.

% my_compare(condition(a, less, 10), [(a,9)], Truth)
my_compare(condition(X, Op, Y), Vars1, Truth):-
	evaluate(Vars1,X,Xr),
	evaluate(Vars1,Y, Yr),
	Exp =.. [Op, Xr, Yr, Truth],
	call(Exp).

equal(X,Y,Truth):- 
	(X == Y, Truth = true);
	(X \== Y, Truth = false).

not_equal(X,Y,Truth):-
	(X \== Y, Truth = true);
	(X == Y, Truth = false).

greater(X,Y,Truth):- 
	(X > Y, Truth = true);
	(X =< Y, Truth = false).

less(X,Y,Truth):- (X < Y, Truth = true);(X >= Y, Truth = false).

greater_equal(X,Y,Truth):- (X >= Y, Truth = true);(X < Y, Truth = false).

less_equal(X,Y,Truth):- 
	(X =< Y, Truth = true);(X > Y, Truth = false).


% evaluate right side of  = and write
% calculations(Tree,[1,+,2,-,3],[]), evaluate(Tree, Result).
evaluate(Vars, cal(X, Op, Y), Result) :-
    evaluate(Vars,X, Xr),
    evaluate(Vars,Y, Yr),
    Exp =.. [Op, Xr, Yr, Result],
    call(Exp).
evaluate(Vars,X, Xr) :- (number(X),Xr is X);(member((X,V),Vars), Xr is V).

plus(X, Y, R) :- R is X + Y.
minus(X, Y, R) :- R is X - Y.



% Grammar 
block(StList1,StList2) --> [begin],statements(StList1,StList2),[end].


statements(StList1,StList2) --> statement(StList1,StList2).

statements(StList1,StList3) --> statement(StList1,StList2), statements(StList2,StList3).


statement(StList1,StList2) --> assignment(Tree),{my_append(Tree,StList1,StList2)}.
statement(StList1,StList2) --> my_read(Tree),{my_append(Tree,StList1,StList2)}.
statement(StList1,StList2) --> my_write(Tree),{my_append(Tree,StList1,StList2)}.
statement(StList1,StList2) --> while(Tree),{my_append(Tree,StList1,StList2)}.
statement(StList1,StList2) --> if(Tree),{my_append(Tree,StList1,StList2)}.


assignment(Tree) --> default_assign(Tree).
assignment(Tree) --> operator_assign(Tree).


default_assign(def_assign(Name)) --> 
	var_name(Name).
operator_assign(op_assign(Name,Tree)) --> 
	var_name(Name),[:=],calculations(Tree).


calculations(VV) --> 
	vv(VV).
calculations(Tree) --> 
	vv(VV1), more_calculations(VV1,Tree).	
more_calculations(VV1,cal(VV1,Operator,VV2)) --> 
	more_calculation(Operator,VV2).
more_calculations(VV1,Tree) -->
	more_calculation(Operator1,VV2),more_calculations(cal(VV1,Operator1,VV2),Tree).	
more_calculation(Operator,VV) --> 
	operator(Operator),vv(VV).


% var / value
vv(Name) --> var_name(Name).
vv(Value) --> var_value(Value).
operator(plus) --> [+].
operator(minus) --> [-].


% read & write
my_read(read(Name)) --> 
	[read],
	var_name(Name).
my_write(write(Tree)) --> 
	[write],
	calculations(Tree).


% while
while(while(condition(Name,Op,Tree),StList)) --> [while],condition(Name,Op,Tree),block([],StList).

if(if(condition(Name,Op,Tree),StList)) --> [if],condition(Name,Op,Tree),block([],StList).



condition(Name,Op,Tree) -->
	var_name(Name),condition_op(Op),calculations(Tree).

condition_op(equal) --> [=].
condition_op(not_equal) --> [\=].
condition_op(greater) --> [>].
condition_op(less) --> [<].
condition_op(greater_equal) --> [>=].
condition_op(less_equal) --> [=<].






% get Var_Name & Var_Value
var_name(Name) --> [Name],{check_name(Name),\+member(Name,[write,read,begin,end,while])}.
var_value(Value) -->[Value],{number(Value)}.


check_name(N):-
	catch(atom_chars(N, L), _, fail),
	is_lower(L).

is_lower([]).
is_lower([H|T]) :-
    catch(char_type(H, lower), _, fail),
	 is_lower(T).



% append or update
update_vars(new_var,Var,Vars1,Vars2):-
	my_append(Var,Vars1,Vars2).
update_vars(ex_var,Var,Vars1,Vars2):-
	update(Var,Vars1,Vars2).
	
var_type(Name,Vars,Type):-
	is_new_var((Name,Value),Vars,Type);
	is_ex_var((Name,Value),Vars,Type).

is_new_var(Var,Vars,new_var):-
	\+member(Var,Vars).
is_ex_var(Var,Vars,ex_var):-
	member(Var,Vars).
	

%update old var in list
update(_Var,[],[]).
update((Name,Value),[(Name,_OldValue)|T1],[(Name,Value)|T2]):-
	update((Name,Value),T1,T2).
update((Name1,Value1),[(Name2,Value2)|T1],[(Name2,Value2)|T2]):-
	Name1\==Name2,
	update((Name1,Value1),T1,T2).

%append statement/new Var to list
my_append(X,[],[X]).
my_append(X,[H|T1],[H|T2]):-
	my_append(X,T1,T2).