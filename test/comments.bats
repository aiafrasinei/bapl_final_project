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

@test "single comment" {
    run lua interpreter.lua < test/inputs/comments/single
    assert_output "0"
}

@test "single on multiple lines comment" {
    run lua interpreter.lua < test/inputs/comments/multi_single_line
    assert_output "0"
}

@test "multi line comment" {
    run lua interpreter.lua < test/inputs/comments/multi_line
    assert_output "0"
}