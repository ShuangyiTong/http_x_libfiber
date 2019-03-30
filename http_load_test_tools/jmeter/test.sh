rm -rf new-test
mkdir new-test
jmeter -n -l new-test/res.csv -o new-test/res.das -e -t echo.jmx  -Jjmeter.reportgenerator.overall_granularity=3000
