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

@test "empty statement" {
    run lua interpreter.lua test/inputs/statements/empty_block
    assert_output "5"
}

@test "print expresions" {
    run lua interpreter.lua test/inputs/statements/print_exp
    assert_output --partial "4"
}

@test "print array" {
    run lua interpreter.lua test/inputs/statements/print_array
    assert_output --partial "[ 1 2 3 ]"
}

@test "print text" {
    run lua interpreter.lua test/inputs/statements/print_text
    assert_output --partial "text"
}

@test "not expresions" {
    run lua interpreter.lua test/inputs/statements/not
    assert_output ""
}