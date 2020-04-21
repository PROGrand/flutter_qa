#!/bin/bash

cd example
flutter test --coverage
cd ..
flutter test --coverage
sed -i 's/SF:lib\\/SF:example\\lib\\/' example/coverage/lcov.info
sed -i 's/SF:lib\//SF:example\/lib\//' example/coverage/lcov.info
lcov -a example/coverage/lcov.info -a coverage/lcov.info -o total.info
genhtml -o coverage total.info
