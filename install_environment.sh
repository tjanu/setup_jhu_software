#!/bin/sh

basedir="$(dirname $0)"
oldpwd="`pwd`"
cd $basedir
basedir="`pwd`"
cd $oldpwd

installdir="$HOME/.local"

echo "Checking for cmake..."
if [ ! -f ${installdir}/bin/cmake ]
then
	workdir="${basedir}/cmake"
	mkdir -p $workdir;
	(cd ${workdir} && rm -rf *)
	(cd $workdir && wget http://www.cmake.org/files/v2.8/cmake-2.8.6.tar.gz)
	(cd $workdir && tar xzf cmake-2.8.6.tar.gz)
	(cd $workdir/cmake-2.8.6; sh bootstrap --prefix=$installdir; make; make install)
fi

echo "Checking for git..."
if [ ! -f ${installdir}/bin/git ]
then
	workdir="$basedir/git-scm"
	mkdir -p $workdir
	(cd $workdir && rm -rf *)
	(cd $workdir && wget --no-check-certificate https://github.com/gitster/git/tarball/master)
	(cd $workdir && tar xzf gitster-*.tar.gz)
	rm -rf $workdir/*.tar.gz
	(cd $workdir/gitster-*; autoconf; ./configure --prefix=$installdir; make; make install)
fi

# Install quicknet
echo "Checking for quicknet..."
workdir="${basedir}/quicknet"
qndir="${workdir}/quicknet-v3_31"
if [ ! -f ${qndir}/qnsfwd ]
then
    mkdir -p ${workdir}
    (cd $workdir && rm -rf *
    wget ftp://ftp.icsi.berkeley.edu/pub/real/davidj/quicknet-v3_31.tar.gz
    tar xzf quicknet-v3_31.tar.gz
    cd quicknet-v3_31; ./configure --prefix=$installdir; make; make install)
fi

echo "Checking for pfile_utils..."
workdir="${basedir}/pfile_utils"
if [ ! -f ${installdir}/bin/pfile_info ]
then
    mkdir -p ${workdir}
    (cd ${workdir} && rm -rf *
    wget ftp://ftp.icsi.berkeley.edu/pub/real/davidj/pfile_utils-v0_51.tar.gz
    tar xzf pfile_utils-v0_51.tar.gz
    cd pfile_utils-v0_51/; ./configure --prefix=$installdir --with-quicknet=$qndir; make; make install)
fi

echo "Checking for dpwelib... (feacalc/feacat dependency)"
workdir="${basedir}/dpwelib"
dpwedir="${workdir}/dpwelib-2009-02-24"
if [ ! -f ${dpwedir}/libdpwe.a ]
then
    mkdir -p ${workdir}
    (cd $workdir
    rm -rf *
    wget http://www.icsi.berkeley.edu/~dpwe/projects/sprach/dpwelib-2009-02-24.tar.gz
    tar xzf dpwelib-2009-02-24.tar.gz
    cd dpwelib-2009-02-24
    chmod u+w config.sub
    cp ${basedir}/patches/dpwelib/config.sub .
    ./configure --prefix=$installdir; make; make install)
fi

echo "Checking for rasta... (feacalc dependency)"
workdir="${basedir}/rasta"
rastadir="${workdir}/build"
if [ ! -f ${rastadir}/librasta.a ]
then
    mkdir -p ${workdir}
    (cd ${workdir}
    rm -rf *
    wget http://www.icsi.berkeley.edu/~dpwe/projects/sprach/icsi-scenic-tools-20110715.tar.gz
#    wget ftp://ftp.icsi.berkeley.edu/pub/real/dpwe/rasta-2001-04-13.tar.gz
    tar xzf icsi-scenic-tools-20110715.tar.gz
    cp ${basedir}/patches/rasta/CMakeLists.txt icsi-scenic-tools-20110715/rasta
    mkdir -p build
    cd build
    ${installdir}/bin/cmake -DCMAKE_INSTALL_PREFIX=${installdir} ../icsi-scenic-tools-20110715/rasta
    make
    make install
    )
fi

echo "Checking for feacalc..."
if [ ! -f ${installdir}/bin/feacalc ]
then
    workdir="${basedir}/feacalc"
    mkdir -p ${workdir}
    (cd ${workdir}
    rm -rf *
    wget ftp://ftp.icsi.berkeley.edu/pub/real/davidj/feacalc-0.91.tar.gz
    tar xzf feacalc-0.91.tar.gz
    cd feacalc-0.91
    ./configure --with-dpwelib=${dpwedir} --with-rasta=${rastadir} --with-quicknet=${qndir} --prefix=${installdir}
    make
    make install
    )
fi

echo "Checking for feacat..."
workdir="${basedir}/feacat"
if [ ! -f ${installdir}/bin/feacat ]
then
    mkdir -p ${workdir}
    (cd $workdir
    rm -rf *
    wget ftp://ftp.icsi.berkeley.edu/pub/real/davidj/feacat-1.01.tar.gz
    tar xzf feacat-1.01.tar.gz
    cd feacat-1.01
    ./configure --with-dpwelib=${dpwedir} --with-quicknet=${qndir} --prefix=${installdir}
    make
    make install
    )
fi

echo "Checking for cfdlp..."
workdir="${basedir}/cfdlp"
if [ ! -f ${installdir}/bin/cfdlp ]
then
   mkdir -p ${workdir}
   (cd ${workdir}
   rm -rf *
   ${installdir}/bin/git clone git://github.com/tjanu/cfdlp.git
   mkdir build
   cd build
   ${installdir}/bin/cmake -DCMAKE_INSTALL_PREFIX=${installdir} ../cfdlp
   make
   make install
   )
fi


echo "############################################"
echo "# Installation of all packages successful! #"
echo "############################################"
echo
echo "Don't forget to add the following line to your .bashrc if not already present:"
echo "export PATH=\${PATH}:${installdir}/bin"
echo
echo "Thank you for your patience :-)"
