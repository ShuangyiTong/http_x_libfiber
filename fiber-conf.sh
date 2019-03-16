./configure "$@"
# reference: https://stackoverflow.com/questions/18877229/

# cflags
sed -ie 's/^EXTRA_CFLAGS.*$/& -DARCH_x86_64 -DFIBER_THREAD/g' ./srclib/apr/build/apr_rules.mk
sed -ie 's/^EXTRA_CFLAGS.*$/& -DARCH_x86_64 -DFIBER_THREAD/g' ./build/config_vars.mk

# linking
sed -ie 's/^EXTRA_LIBS.*$/& -DARCH_x86_64 -lfiber/g' ./srclib/apr/build/apr_rules.mk