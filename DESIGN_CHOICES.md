Extend the Selene language with some small features.

- Unit tests using bash bats tool (this saved me a lot of times when i created regressions)
- Exp supports bool and strings
- @ can print strings
- Remove semicolons from syntax
- Bash like comparison operators (lt, gt, le, ge, eq, ne)
- Forward function declarations and error check for multiple declarations
- Optional type system
VariableName_Type = exp
Types:
_e empty
_n number
_s string
_t table
_f function
_b bool  

Examples: 
a_n = 2;
str_s = “some text”;
boo_b = false;

Functions syntax for return types:
function main_n () {
    return factorial(6)
}

Type checks on assignment,if and function call return.
If you dont use _type when declaring variables no type checks are performed.

StackApi

This one is inspired by forth language, dont know how useful can be in the end.

Language supports a stack api
Any number of stacks can be created (each having a name).
2 stacks are created at initialization: “default” and “temp”

API as language statements:

stack operations:
PUSH, POP, DEPTH, PRINT, PEEK

stack juggling:
DROP     - ( n — )
DUP        - ( n — n n )
SWAP     - ( n1 n2 — n2 n1 )
OVER     - ( n1 n2 — n1 n2 n1 )
ROT        - ( n1 n2 n3 — n2 n3 n1 )
MINROT - ( n1 n2 n3 — n3 n1 n2 )

API to create stacks:
SUSE “name”     - change the current stack
SADD “name”     - add stack
SRM “name”      - stack remove
SREP “name”     - stack replace
SCLEAR “name”   - stack clear
SRA             - remove all stacks
