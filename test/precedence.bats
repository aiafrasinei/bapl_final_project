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

@test "addition multiplication" {
    run lua interpreter.lua test/inputs/precedence/add_mul
    assert_output "8"
}

@test "multiplication power" {
    run lua interpreter.lua test/inputs/precedence/mul_pow
    assert_output "16.0"
}

@test "addition power" {
    run lua interpreter.lua test/inputs/precedence/add_pow
    assert_output "6.0"
}

@test "minus number addition substraction" {
    run lua interpreter.lua test/inputs/precedence/minus_add_sub
    assert_output "-4"
}

@test "unary operator" {
    run lua interpreter.lua test/inputs/precedence/unary_op
    assert_output "-3"
}