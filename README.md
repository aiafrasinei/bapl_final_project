# bapl final project

Final Project Report: constanta
Language Syntax

In this section, describe the overall syntax of your language.
New Features/Changes

    Selene language with some modifications.

    Variables names with types:
    "varname"_"type"

    _e - empty
    _b - boolean
    _n - number
    _s - string
    _f - function
    _t - table

    example variables:
    temp_b = false
    i_n = 1000
    str_s = "tes"
    nr_n = 10

    example functions:
    function factorial_n (nr_n) {
        if nr {
            return nr * factorial(nr-1)
        } else {
            return 1
        }
    }

    function main_n () {
        input_n = 6
        test_n = factorial(input)
        return test
    }

    After assign the variable can be used without the _type.

    StackApi

    This one is inspired by forth language.

    Language supports a stack api
    Any number of stacks can be created (each having a name).
    2 stacks are created at initialization: “default” and “temp”

    API as language statements:

    stack operations:
    PUSH, POP, DEPTH, PRINT, PEEK

    stack juggling:
    notation meaning ( initial stack - after operation stack)

    DROP     : ( n - )
    DUP      : ( n - n n )
    SWAP     : ( n1 n2 - n2 n1 )
    OVER     : ( n1 n2 - n1 n2 n1 )
    TUCK     : ( n1 n2 - n2 n1 n2 )
    ROT      : ( n1 n2 n3 - n2 n3 n1 )
    MINROT   : ( n1 n2 n3 - n3 n1 n2 )
    2DROP    : ( n1 n2 - )
    2DUP     : ( n1 n2 - n1 n2 n1 n2 )
    2SWAP    : ( n1 n2 n3 n4 - n3 n4 n1 n2 )
    2OVER    : ( n1 n2 n3 n4 - n1 n2 n3 n4 n1 n2 )
    2ROT     : ( n1 n2 n3 n4 n5 n6 - n3 n4 n5 n6 n1 n2 )
    2MINROT  : ( n1 n2 n3 n4 n5 n6 - n5 n6 n1 n2 n3 n4 )

    API to create stacks:
    SUSE “name”     - change the current stack
    SADD “name”     - add stack
    SRM “name”      - stack remove
    SREP “name”     - stack replace
    SCLEAR “name”   - stack clear
    SRA             - remove all stacks

    Can be used as a reverse polish notation calculator.

    arithmetics:
    Expects 2 elements on the current stack, pops the 2 elements and push the result.
    S+ - addition        - ( n1 n2 — sum )
    S- - substraction    - ( n1 n2 — diff )
    S* - multiplication  - ( n1 n2 — prod )
    S/ - division        - ( n1 n2 — quot )
    S% - mod             - ( n1 n2 — rem )

In this section, describe the new features or changes that you have added to the programming language. This should include:

    Detailed explanation of each feature/change

    - Unit tests using bash bats tool (57 input files, this saved me a lot of times when i created regressions)
    - Exp supports bool and strings
    - @ can print strings
    - Remove semicolons from syntax
    - Bash like comparison operators (lt, gt, le, ge, eq, ne)
    - Forward function declarations and error check for multiple declarations
    - Optional type system

    Type checks on assignment,if and function call return.
    If you dont use _type when declaring variables no type checks are performed.

Any trade-offs or limitations you are aware of

    No time to do the type check of function parameters, but all the information is in the ast to do it.
    I didnt add the optional initialization for last function parameter, i dont like that feature.

Future

In this section, discuss the future of your language / DSL, such as deployability (if applicable), features, etc.

What would be needed to get this project ready for production?

    I really like this syntax, to be production ready i need to write a transpiler to a different language like c,java.
    At least thats my plan for the future.

How would you extend this project to do something more? Are there other features you’d like? How would you go about adding them?

    Would like to use this language for scripting purposes (like bash but better).Have some apis for process management.
    Keep the language simple to use, type system is optional.
    I have this idea of using sqlite3 db as files and main data structure.
    For example this statement: 
    CREATEDB "AdressBook FirstName_s LastName_s HomePhone_n WorkPhone_n Adress_s"
    could be used to create an AdressBook table with proper types.
    Then the language will have a syntax to use the AdressBook.

Self assessment

    Self assessment of your project: for each criteria described on the final project specs, choose a score (1, 2, 3) and explain your reason for the score in 1-2 sentences.
    
    Language Completness 2
    Code Quality and Report 2 (Code organization is ok from my point of view. Keep it simple and readable was my goal)
    Originality & Scope 2 (I like the current syntax and i have the feeling other people will like it too.)

    I learned a lot and given the time i had available i am proud of the result.

Have you gone beyond the base requirements? How so?

    Type system.
    Proper unit tests that check the output of the program.
    Organization of the code.
    Examples directory (i used some problems from https://projecteuler.net)

References

List any references used in the development of your language besides this courses, including any books, papers, or online resources.
    Lua book
    Crafting interpreters book
    https://www.forth.com/starting-forth/2-stack-manipulation-operators-arithmetic/
    https://projecteuler.net
    https://www.complang.tuwien.ac.at/forth/gforth/Docs-html/Data-stack.html
