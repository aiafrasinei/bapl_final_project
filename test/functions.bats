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

@test "answer" {
    run lua interpreter.lua test/inputs/functions/42
    assert_output "42"
}

@test "fact" {
    run lua interpreter.lua test/inputs/functions/fact
    assert_output "720"
}

@test "forwad decl ok" {
    run lua interpreter.lua test/inputs/functions/fwd_decl_ok
    assert_output "720"
}

@test "multiple fwd declarations" {
    run lua interpreter.lua test/inputs/functions/multiple_fwd_decl
    assert_output --partial "ERR: multiple forward declarations for function factorial"
}

@test "fact with types" {
    run lua interpreter.lua test/inputs/functions/fact_with_types
    assert_output "720"
}

@test "sum" {
    run lua interpreter.lua test/inputs/functions/sum
    assert_output "2"
}

@test "multiple params" {
    run lua interpreter.lua test/inputs/functions/multiple_params
    assert_output "3"
}