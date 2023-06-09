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

@test "simple bool" {
    run lua interpreter.lua test/inputs/bools/simple
    assert_output "true"
}

@test "bool if check" {
    run lua interpreter.lua test/inputs/bools/if_bool
    assert_output "false"
}

@test "bool if corner" {
    run lua interpreter.lua test/inputs/bools/if_corner
    assert_output "false"
}