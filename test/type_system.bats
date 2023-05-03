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

@test "type check error s to b" {
    run lua interpreter.lua < test/inputs/type_system/assign_s_to_b
    assert_output "ERR: Type check failed on assign, (var: b type: b) attempt to assign text"
}

@test "type check error s to n" {
    run lua interpreter.lua < test/inputs/type_system/assign_s_to_n
    assert_output "ERR: Type check failed on assign, (var: b type: n) attempt to assign text"
}

@test "type check error s to e" {
    run lua interpreter.lua < test/inputs/type_system/assign_s_to_e
    assert_output "ERR: Type check failed on assign, (var: b type: e) attempt to assign text"
}

@test "assign s to s" {
    run lua interpreter.lua < test/inputs/type_system/assign_s_to_s
    assert_output "temp"
}

@test "comparison n to s" {
    run lua interpreter.lua < test/inputs/type_system/comparison_n_to_s
    assert_output "ERR: Type check failed on if comparison, (var: a type: n) with (var: b type: s)"
}

@test "comparison s to n" {
    run lua interpreter.lua < test/inputs/type_system/comparison_s_to_n
    assert_output "ERR: Type check failed on if comparison, (var: b type: s) with (var: a type: n)"
}

@test "comparison b to s" {
    run lua interpreter.lua < test/inputs/type_system/comparison_b_to_s
    assert_output "ERR: Type check failed on if comparison, (var: a type: n) with (var: b type: s)"
}

@test "unitialized var" {
    run lua interpreter.lua < test/inputs/type_system/uninit_var
    assert_output --partial "11"
}