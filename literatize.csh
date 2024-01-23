#!/usr/bin/csh -f

# Rough prototype literate-izer for "screen" program by Dr. Kelly and Krish Jain,  undergrad at the University of Rochester.

set h    = sha256sum
set b    = screen-5.0.1
set l8   = litr8x
set t1   = $b.tar.gz
set t2   = $b.$l8.tar.xz
set t1cs = dd6465093d40ad7beb5acf01e64b9306de048ab0c98b11809b3461c0d10534c8
set sl   = screen_literatize.csh

#####################################################################
echo "make sure t1 tarball is correct"

if ( `$h $t1 | gawk '{print $1}'` != $t1cs ) then
    echo checksum mismatch
    exit
endif

#####################################################################
echo "unpack original tarball t1 = $t1"

rm -rf $b
zcat $t1 | tar xf -

#####################################################################
echo "install $l8 in $b"

cd $b

cat <<EOF > $l8.c
/* "Literate Executables" implantation program
   Copyright (C) 2022  Terence Kelly
   Contact:  tpkelly @ { acm.org, cs.princeton.edu, eecs.umich.edu }

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU Affero General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU Affero General Public License for more details.

   You should have received a copy of the GNU Affero General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>     // compile with -D_GNU_SOURCE for memmem()
#include <unistd.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>

#define T(s) #s
#define S(s) T(s)  // stringify argument
#define X(e) ((e) && (perror(__FILE__ ":" S(__LINE__) ": '" #e "'"), \
                      exit(EXIT_FAILURE), 1)) // check e, bail if true

static char E[LITR8X_SIZE] = S(LITR8X_MARK);  // implant egg here

static void * mm(const char *f, int pe, size_t *s) {
  struct stat sb; int pr  = PROT_READ,  fl = MAP_PRIVATE, fd; void *r;
  if (O_RDWR == pe) { pr |= PROT_WRITE; fl = MAP_SHARED; }
  X(0 > (fd = open(f, pe)));  // skip close(), leak fd
  X(0 != fstat(fd, &sb));  X(! S_ISREG(sb.st_mode));
  *s = (size_t)sb.st_size;  // return file size to caller in *s
  X(MAP_FAILED == (r = mmap(NULL, *s, pr, fl, fd, (off_t)0)));
  return r;
}

int main(int argc, char *argv[]) {
  if (1 == argc)  // lay own egg
    X(sizeof E != fwrite(E, (size_t)1, sizeof E, stdout));
  else if (4 == argc) {  // implant egg in chicken at mark
    size_t sc, se;  void *mark, *ckn = mm(argv[1], O_RDWR,   &sc),
                                *egg = mm(argv[2], O_RDONLY, &se);
    X(NULL == (mark = memmem(ckn, sc,     argv[3], strlen(argv[3]))));
    (void)memcpy(mark, egg, se);
  }
  else fprintf(stderr, "usage: %s [chicken egg mark]\n", argv[0]);
}
EOF

#####################################################################
echo "patch source code in t1"

cat <<EOF > screen.c.patch
--- screen.c.original	2024-01-05 22:50:11.906943766 -0800
+++ screen.c.modified	2024-01-07 02:14:38.910052600 -0800
@@ -1,3 +1,9 @@
+/* MODIFIED BY T. KELLY circa 5 Jan 2024 to become a literate executable.
+   See Drill Bits column "Literate Executables" in Sept/Oct 2022 ACM
+   _Queue_ magazine.  Search for "litr8x" below to see changes.
+   This file based on git master branch circa 3 January 2024.
+*/
+
 /* Copyright (c) 2010
  *      Juergen Weigert (jnweiger@immd4.informatik.uni-erlangen.de)
  *      Sadrul Habib Chowdhury (sadrul@users.sourceforge.net)
@@ -274,6 +280,13 @@
 	exit(0);
 }
 
+/* litr8x change */
+#define STRINGIFY2(s) #s
+#define STRINGIFY1(s) STRINGIFY2(s)
+static char litr8x_egg[LITR8X_SIZE] = STRINGIFY1(LITR8X_MARK);  // implant egg here
+#undef STRINGIFY1
+#undef STRINGIFY2
+
 int main(int argc, char **argv)
 {
 	int n;
@@ -292,6 +305,20 @@
 	char *multi_home = NULL;
 	bool cmdflag = 0;
 
+        /* litr8x change */
+        if (2 == argc && 0 == strcmp(argv[1], "--litr8x-egg-size")) {
+          printf("%zu\n", sizeof litr8x_egg);
+          exit(0);
+        }
+        if (2 == argc && 0 == strcmp(argv[1], "--litr8x-dump-txz")) {
+          size_t r = fwrite(litr8x_egg, (size_t)1, sizeof litr8x_egg, stdout);
+          if (r != sizeof litr8x_egg) {
+            perror("fwrite for litr8x dump failed");
+            exit(1);
+          }
+          exit(0);
+        }
+
 	/*
 	 *  First, close all unused descriptors
 	 *  (otherwise, we might have problems with the select() call)
EOF
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cp screen.c screen.c.original
patch screen.c screen.c.patch

#####################################################################
echo "copy screen literatizer script to t1"

cp --archive ../$sl .
chmod 700 $sl

#####################################################################
echo "create t2 tarball $t2"

cd ..
mv $b $b.$l8
tar cf $b.$l8.tar $b.$l8
xz --best $b.$l8.tar

#####################################################################
echo "test t2 tarball"

cp $t2 /tmp
cd /tmp
xzcat < $t2 | tar xf -
cd $b.$l8
./$sl

#####################################################################
echo "done"
echo ""
echo "    enjoy the newly created literate executable!"
echo ""
echo "    for example, to extract documentation from the exe:"
echo ""
echo '    /tmp/screen-5.0.1.litr8x/screen --litr8x-dump-txz \'
echo '        | xzcat | tar xOf - screen-5.0.1.litr8x/doc/screen.1 \'
echo '        | man -l -'
echo ""
echo ""
echo "TODO (possibly for maintainers, not me & Dr.):"
echo ""
echo "    1. mention literate executable feature in ChangeLog"
echo "    2. describe how to build literate executable in INSTALL file"
echo "    3. modify man page to mention literate executable feature"
echo ""

