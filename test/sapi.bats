setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$DIR/..:$PATH"
}

@test "use" {
    run lua interpreter.lua < test/inputs/sapi/use
    assert_output --partial "first"
}

@test "stack ops" {
    run lua interpreter.lua < test/inputs/sapi/ops
    assert_output --partial "1 1"
}

@test "stack add" {
    run lua interpreter.lua < test/inputs/sapi/sadd
    assert_output --partial "1 2 3"
}

@test "stack remove" {
    run lua interpreter.lua < test/inputs/sapi/srm
    assert_output --partial "alive"
}

@test "stack replace" {
    run lua interpreter.lua < test/inputs/sapi/sadd
    assert_output --partial "1 2 3"
}

@test "stack clear" {
    run lua interpreter.lua < test/inputs/sapi/clear
    assert_output --partial "\""first"\""
}

@test "stack remove all" {
    run lua interpreter.lua < test/inputs/sapi/sra
    assert_output --partial "alive"
}

@test "stack rot minrot" {
    run lua interpreter.lua < test/inputs/sapi/rot_minrot
    assert_output --partial "1 2 3"
}

@test "stack two drop" {
    run lua interpreter.lua < test/inputs/sapi/two_drop
    assert_output --partial "5"
}

@test "stack two swap" {
    run lua interpreter.lua < test/inputs/sapi/two_swap
    assert_output --partial "3 3 2 2"
}

@test "stack two dup" {
    run lua interpreter.lua < test/inputs/sapi/two_dup
    assert_output --partial "2 2 2 2"
}

@test "stack two over" {
    run lua interpreter.lua < test/inputs/sapi/two_over
    assert_output --partial "3 3 2 2 3 3"
}

@test "stack tuck" {
    run lua interpreter.lua < test/inputs/sapi/tuck
    assert_output --partial "2 1 2"
}

@test "stack two rot" {
    run lua interpreter.lua < test/inputs/sapi/two_rot
    assert_output --partial "2 2 3 3 1 1"
}


@test "stack two minrot" {
    run lua interpreter.lua < test/inputs/sapi/two_minrot
    assert_output --partial "3 3 1 1 2 2"
}

@test "addition" {
    run lua interpreter.lua < test/inputs/sapi/s+
    assert_output --partial "3"
}

@test "minus" {
    run lua interpreter.lua < test/inputs/sapi/s-
    assert_output --partial "2"
}

@test "mul" {
    run lua interpreter.lua < test/inputs/sapi/smul
    assert_output --partial "4"
}

@test "division" {
    run lua interpreter.lua < test/inputs/sapi/sdivision
    assert_output --partial "0"
}

@test "modulo" {
    run lua interpreter.lua < test/inputs/sapi/s%
    assert_output --partial "2"
}

@test "rpn eval" {
    run lua interpreter.lua < test/inputs/sapi/rpneval
    assert_output --partial "6"
}