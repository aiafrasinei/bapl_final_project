# bapl final project

Final Project Report: [Project Name]
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

examples:
temp_b = false;
i_n = 1000;
str_s = "tes"
nr_n = 10

Interpreter has access to any number of stacks using stackapi.
2 stacks are created by default: ("default" and "temp").
Initial selected stack is the default.
Stacks can be selected using USE operation ( USE "temp"; ).

Standard stack operations:
PUSH exp, POP, DEPTH, DROP, PRINT, PEEK nr
Additional stack operations:
DUP, OVER, SWAP, ROT , MINROT
Stack Api operations:
ADD , RM , CLEAR, REPLACE, USE

In this section, describe the new features or changes that you have added to the programming language. This should include:

    Detailed explanation of each feature/change
    Examples of how they can be used
    Any trade-offs or limitations you are aware of

    Comparison operators similar to bash (lt, gt, le, ge , eq, ne).
    Types definitions:
        <name> <field_name_type field2_type ...


Future

In this section, discuss the future of your language / DSL, such as deployability (if applicable), features, etc.

    What would be needed to get this project ready for production?
    How would you extend this project to do something more? Are there other features you’d like? How would you go about adding them?

Self assessment

    Self assessment of your project: for each criteria described on the final project specs, choose a score (1, 2, 3) and explain your reason for the score in 1-2 sentences.
    Have you gone beyond the base requirements? How so?

References

List any references used in the development of your language besides this courses, including any books, papers, or online resources.
