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
