# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
modules="prefork worker event"
server_addr=192.168.2.152:80
fiber_only=false
thread_only=false
conf_only=false

while getopts "m:s:ftc" opt; do
    case "$opt" in
    m)  modules=$OPTARG
        ;;
    f)  fiber_only=true
        ;;
    t)  thread_only=true
        ;;
    c)  conf_only=true
        ;;
    s)  server_addr=$OPTARG
        ;;
    esac
done

RUNNING_CONFIG="MPMs: $modules\n\
                Fiber Only: $fiber_only\n\
                Thread Only: $thread_only\n\
                Server Address: $server_addr\n\
                Export Configuration File Only: $conf_only\n"

echo "$RUNNING_CONFIG"

for mpm_name in $modules;
do
    if [ "$thread_only" = false ] ; then
        if [ "$conf_only" = false ] ; then
            # build fiber based apache
            make clean
            ./fiber-conf.sh --with-mpm=$mpm_name --prefix=/httpd/apache-fiber-$mpm_name/
            ./install-all.sh
        fi
        cp ./httpd-fiber.conf /httpd/apache-fiber-$mpm_name/conf/httpd.conf
        sed -i -e "s/ServerName UNDEFINED/ServerName $server_addr/g" /httpd/apache-fiber-$mpm_name/conf/httpd.conf
        sed -i -e "s/ServerRoot UNDEFINED/ServerRoot \/httpd\/apache-fiber-$mpm_name\//g" /httpd/apache-fiber-$mpm_name/conf/httpd.conf
    fi

    # build original apache
    if [ "$fiber_only" = false ] ; then
        if [ "$conf_only" = false ] ; then
            make clean
            ./configure --with-included-apr --with-mpm=$mpm_name --prefix=/httpd/apache-thread-$mpm_name/
            make
            make install
        fi
        cp ./httpd-thread.conf /httpd/apache-thread-$mpm_name/conf/httpd.conf
        sed -i -e "s/ServerName UNDEFINED/ServerName $server_addr/g" /httpd/apache-thread-$mpm_name/conf/httpd.conf
        sed -i -e "s/ServerRoot UNDEFINED/ServerRoot \/httpd\/apache-thread-$mpm_name\//g" /httpd/apache-thread-$mpm_name/conf/httpd.conf
    fi
done

echo "$RUNNING_CONFIG"