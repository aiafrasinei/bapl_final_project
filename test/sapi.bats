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
    assert_output --partial "first"
}

@test "stack remove all" {
    run lua interpreter.lua < test/inputs/sapi/sra
    assert_output --partial "alive"
}