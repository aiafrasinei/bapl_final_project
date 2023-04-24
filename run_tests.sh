#!/bin/bash

#comment print(pt.pt(ast)) and print(pt.pt(code)) in interpreter.lua for the tests to work

./test/bats/bin/bats test/math_ops.bats
./test/bats/bin/bats test/precedence.bats
./test/bats/bin/bats test/comments.bats
./test/bats/bin/bats test/statements.bats