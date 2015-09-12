#!/usr/bin/env bash

TEST_POSITIVE=" test.txt "
TEST_NEGATIVE=" testBadHeaders.txt testHeaderLess.txt testHeaderWrongPos2.txt testHeaderWrongPos.txt testWrongRule2.txt testWrongRule3.txt testWrongRule4.txt testWrongRule5.txt testWrongRule.txt testHeaderMalformed.txt testInexistentRule.txt"

for item in $TEST_POSITIVE; do
        ./testLibrary $item 2>/dev/null
        if [ x"$?" = x"0" ]; then
                echo "Test: $item - Status: PASS"
        else
                echo "Test: $item - Status: FAIL"
        fi
done

for item in $TEST_NEGATIVE; do
        ./testLibrary $item 2>/dev/null
        if [ x"$?" != x"0" ]; then
                echo "Test: $item - Status: PASS"
        else
                echo "Test: $item - Status: FAIL"
        fi
done
