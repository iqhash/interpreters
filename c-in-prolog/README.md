Simple C like language interpreter in Prolog
============================================

#How to use
1. Open command line —> cd go to the containing directory —> run prolog

2. Compile tokenizer & interpreter
Type in: [interpreter]. —> hit enter.  
example:  
?- [interpreter].  
% interpreter compiled 0.01 sec, 17,292 bytes  
true.  
?- [tokenizer].  
% tokenizer compiled 0.00 sec, 3,200 bytes  
true.  
NOTE: if you use sicstus, you need to change “read_line_to_codes” to “read_line” inside tokenizer.  

3. run('test.txt',ParseTree,VariablesOut).  
% this executes the content inside “test.txt”  
|:  
% this input will show up (result of “read a”). you can for example type in “10.”, hit enter.  
% NOTE: ALL PROLOG QUERIES MUST END WITH A FULL STOP “.”  
% and you will get the following output:  
10  
9  
8  
7  
6  
100000003  
0  
1  
2  
ParseTree = [read(a), while(condition(a, greater, 5), [write(a), op_assign(a, cal(a, minus, 1))]), def_assign(a), op_assign(b, cal(a, plus, 1)), op_assign(c, cal(b, plus, 1)), if(condition(a, not_equal, 0), [op_assign(a, cal(..., ..., ...)), op_assign(..., ...)|...]), write(cal(cal(..., ..., ...), minus, 1)), write(a), write(...)|...],  
VariablesOut = [ (a, 0), (b, 1), (c, 2)] .  

That’s it.  

#test.txt
You can type in your own logic and test it out. Have fun.  
NOTE: You need to have empty spaces between tokens (b := a + 1 ) in order for the tokenizer to work.  

#Supported statements

1. IO
//read variableName  
read a  

//write variable | evaluation  
write a  
write a + 1 – 2  

2. Assign
//default assign(default value 0)  
a  
//the kind of assign you do everyday  
a := 1  

3. evaluation
//plus minus (you can add some more if you want)  
a := 1  
a := 1 + 2 – 3  
a := b + 1  

4. if statement
if  
a < 10  
begin  
statement1  
statement2  
...  
end  


5. while statement
while  
a < 10  
begin  
statement1  
statement2  
...  
end  

6. Supported comparison operators
equal: :=  
not_equal: \=  
greater: >  
less: <  
greater_equal: >=  
less_equal: =<  
