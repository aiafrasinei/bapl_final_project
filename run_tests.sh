#!/bin/bash

./test/bats/bin/bats test/math_ops.bats
./test/bats/bin/bats test/precedence.bats
./test/bats/bin/bats test/comments.bats
./test/bats/bin/bats test/statements.bats
./test/bats/bin/bats test/control_structs.bats
./test/bats/bin/bats test/arrays.bats
./test/bats/bin/bats test/strings.bats
./test/bats/bin/bats test/functions.bats
./test/bats/bin/bats test/type_system.bats