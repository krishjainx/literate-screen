#!/usr/bin/csh -f

# Script to create a literate executable screen program.  See the
# Drill Bits column in the Sept/Oct 2022 ACM _Queue_ magazine for the
# basic idea.
#
# This script is installed in the unpacked t1 tarball's top directory
# and is run after t2 is unpacked.

set h  = sha256sum
set l8 = litr8x
set b  = screen-5.0.1
set t2 = ../$b.$l8.tar.xz

#####################################################################
echo "    build $l8"
rm -f $l8
set mk = `$h $l8.c | gawk '{print $1}'`
gcc -DLITR8X_SIZE=`wc -c < $l8.c` -DLITR8X_MARK=$mk \
    -D_GNU_SOURCE -std=c11 -Wall -Wextra -O3 -o $l8 $l8.c
cp $l8 /tmp/copy          # avoid open(chicken)->ETXTBSY
/tmp/copy $l8 $l8.c $mk   # implant egg in chicken at mark
rm /tmp/copy              # tidy up
set c1 = `./$l8 | $h | gawk '{print $1}'`
set c2 = `$h $l8.c   | gawk '{print $1}'`
if ( $c1 != $c2 ) then
    echo "        failure"
    exit
else
    echo "        success"
endif

#####################################################################
echo "    configure"

./configure >& configure.out

#####################################################################
echo "    config.status"

./config.status >& config.status.out

#####################################################################
echo "    amend makefile"
set ls = `wc -c     $t2 | gawk '{print $1}'`
set mk = `sha256sum $t2 | gawk '{print $1}'`
echo "        ls $ls"
echo "        mk $mk"
gawk -v ls=$ls -v mk=$mk '{if (/^CFLAGS/) print $0, " -DLITR8X_SIZE=" ls " -DLITR8X_MARK=" mk; else print $0}' < Makefile > newMakefile
mv Makefile Makefile.original
mv newMakefile Makefile

#####################################################################
echo "    make"

make >& make.out

#####################################################################
echo "    check implantation zone size"
set es = `./screen --litr8x-egg-size`
if ( $es == $ls ) then
    echo "        success"
else
    echo "        failure: $es != $ls"
    exit
endif

#####################################################################
echo "    implant"
echo "        ./$l8 screen $t2 $mk"
./$l8 screen $t2 $mk

#####################################################################
echo "    compare eggs"
set c1 = `                             $h $t2 | gawk '{print $1}'`
set c2 = `./screen --litr8x-dump-txz | $h     | gawk '{print $1}'`
if ( $c1 == $c2 ) then
    echo "        success"
else
    echo "        failure:  $c1 != $c2"
    exit
endif

#####################################################################
echo "    done"

