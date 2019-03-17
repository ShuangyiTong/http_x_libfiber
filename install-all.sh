# make and install libfiber
make -C ./srclib/libfiber-master libfiber.so
cp ./srclib/libfiber-master/libfiber.so /lib

# copy libfiber header to apr include and include
cp -r ./srclib/libfiber-master/include ./srclib/apr/include/libfiber
cp -r ./srclib/libfiber-master/include ./include/libfiber

# clean apr because makefile in apr does not monitor source files, not sure why
make -C ./srclib/apr clean

# make
make

# install
make install