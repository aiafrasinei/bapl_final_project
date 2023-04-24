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

@test "addition" {
    run lua interpreter.lua < test/inputs/math_ops/add
    assert_output "5"
}

@test "substraction" {
    run lua interpreter.lua < test/inputs/math_ops/sub
    assert_output "4"
}

@test "multiplication" {
    run lua interpreter.lua < test/inputs/math_ops/mul
    assert_output "6"
}

@test "division" {
    run lua interpreter.lua < test/inputs/math_ops/div
    assert_output "3.0"
}

@test "modulo" {
    run lua interpreter.lua < test/inputs/math_ops/mod
    assert_output "0"
}

@test "power" {
    run lua interpreter.lua < test/inputs/math_ops/pow
    assert_output "8.0"
}

@test "less then" {
    run lua interpreter.lua < test/inputs/math_ops/less_then
    assert_output "1"
}

@test "greater then" {
    run lua interpreter.lua < test/inputs/math_ops/greater_then
    assert_output "1"
}

@test "less or equal then" {
    run lua interpreter.lua < test/inputs/math_ops/less_or_equal_then
    assert_output "1"
}

@test "greater or equal then" {
    run lua interpreter.lua < test/inputs/math_ops/greater_or_equal_then
    assert_output "1"
}

@test "equal then" {
    run lua interpreter.lua < test/inputs/math_ops/equal_then
    assert_output "1"
}

@test "not equal then" {
    run lua interpreter.lua < test/inputs/math_ops/not_equal_then
    assert_output "1"
}
