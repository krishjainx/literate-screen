About This Project
-------------------

This past winter break I worked with Dr. Kelley, who is an independent researcher formerly at HP Labs. He works with talented students from many universities on open source software projects. I worked on enhancing GNU screen to make it a "literate executable" capable of outputting its own source code tarball. Screen is a fundamental utility in Unix-like systems that has remained relevant since its inception in 1987. Literate executables carry around all of their own source code (and documentation, and whatever else the tarball contains), making it easy for users to scrutinize the exact source corresponding to the executable on their $PATH.

A recent paper explains how to make any C/C++ program literate, expands on the advantages of literate executables, and literate-izes the GNU grep utility as an example:

https://dl.acm.org/doi/10.1145/3570938

I worked with the paper's author (Dr. Kelly) and the screen enhancement is in the process of getting suggestions from the community and maintainer. It will (hopefully) soon be upstreamed.

The basic idea is to transform an "illiterate" tarball (call it "t1") into a literate one ("t2"); t2 builds a literate screen executable that can dump t2 to stdout. Running the "literatize.csh" script we wrote transforms t1 into a literate t2, which is then tested in /tmp/ to confirm that t2 can build an executable that emits t2 on demand. The literatize script will end with a hint about how to extract the manpage from the executable. We ran our tests on Linux Fedora.

If you find this interesting, happy to chat. Feel free to email me : kjain@fedoraproject.org or krish.jain@rochester.edu
