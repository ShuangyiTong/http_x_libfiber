for mpm_name in prefork worker event;
do
    # build original apache
    make clean
    ./configure --with-included-apr --with-mpm=$mpm_name --prefix=/httpd/apache-thread-$mpm_name/
    make
    make install
    cp ./httpd-thread.conf /httpd/apache-thread-$mpm_name/conf/

    # build fiber based apache
    make clean
    ./fiber-conf.sh --with-mpm=$mpm_name --prefix=/httpd/apache-fiber-$mpm_name/
    ./install-all.sh
    cp ./httpd-fiber.conf /httpd/apache-fiber-$mpm_name/conf/httpd.conf
done