./configure --with-included-apr "$@"
# reference: https://stackoverflow.com/questions/18877229/

# cflags
sed -ie 's/^EXTRA_CFLAGS.*$/& -DARCH_x86_64 -DFIBER_THREAD/g' ./srclib/apr/build/apr_rules.mk
sed -ie 's/^EXTRA_CFLAGS.*$/& -DARCH_x86_64 -DFIBER_THREAD -DFIBER_WORKER=32/g' ./build/config_vars.mk

# linking
sed -ie 's/^EXTRA_LIBS.*$/& -DARCH_x86_64 -lfiber/g' ./srclib/apr/build/apr_rules.mk