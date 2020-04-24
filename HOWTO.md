# How to use some tools

## dartdoc
$ flutter pub global activate dartdoc

$ dartdoc --no-allow-non-local-warnings --no-auto-include-dependencies

## build runner
$ flutter pub run build_runner build

## pub.dev publish
$ flutter pub publish

## coverage
cd examples
flutter test --coverage
cd ..
flutter test --coverage
sed -i 's/SF:lib\\/SF:example\\lib\\/' example/coverage/lcov.info
sed -i 's/SF:lib\//SF:example\/lib\//' example/coverage/lcov.info
lcov -a example/coverage/lcov.info -a coverage/lcov.info -o total.info
genhtml -o coverage total.info
