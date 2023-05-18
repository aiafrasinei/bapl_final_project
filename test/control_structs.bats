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

@test "if" {
    run lua interpreter.lua test/inputs/control_structs/if
    assert_output "12"
}

@test "if else" {
    run lua interpreter.lua test/inputs/control_structs/if_else
    assert_output --partial "12"
}

@test "elif" {
    run lua interpreter.lua test/inputs/control_structs/elif
    assert_output --partial "2"
}

@test "unless" {
    run lua interpreter.lua test/inputs/control_structs/unless
    assert_output --partial "true"
}