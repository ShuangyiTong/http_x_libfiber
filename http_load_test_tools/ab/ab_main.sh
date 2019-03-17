URL="192.168.2.51/"
declare -a test_cases=("apache-thread-worker" "apache-fiber-worker" "apache-thread-prefork" "apache-fiber-prefork" "apache-thread-event")

for test_case in "${test_cases[@]}"
do
    echo "start testing:" $test_case
    ab -n 10000 -c 200 -s 10 $URL # warm up
    ab -n 10000 -c 200 -s 10 -g $test_case.out $URL
    echo "end testing:" $test_case
    echo "waiting communicating with server to setup"
    sleep 20 # do a sleep for now instead of some expect test automations
done

gnuplot ab-plot.plt