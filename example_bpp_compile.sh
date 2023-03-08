#constructing bpp:
#see instruction here: https://github.com/BioPP/bpp-documentation/wiki/Installation
#Note: adjust all path according to your own path!

PROJECTDIR=$HOME/.software/bpp/
PROJECTDIR2=$HOME/.software/BPP/

mkdir -p $PROJECTDIR/
mkdir -p $PROJECTDIR2/

cd $PROJECTDIR

#rather use the stable release here:
#bpp-core:
wget https://github.com/BioPP/bpp-core/archive/refs/tags/v2.4.1.zip
unzip v2.4.1.zip 
rm v2.4.1.zip 
#bpp-seq:
wget https://github.com/BioPP/bpp-seq/archive/refs/tags/v2.4.1.zip
unzip v2.4.1.zip 
rm v2.4.1.zip 
#and repeat for each pipeline !
wget https://github.com/BioPP/bpp-popgen/archive/refs/tags/v2.4.1.zip
unzip v2.4.1.zip 
rm v2.4.1.zip 
#bpp-phyl:
wget https://github.com/BioPP/bpp-phyl/archive/refs/tags/v2.4.1.zip
unzip v2.4.1.zip 
rm v2.4.1.zip 
#bppsuite:
wget https://github.com/BioPP/bpp-suite/archive/refs/tags/v2.4.1.zip
unzip v2.4.1.zip 
rm v2.4.1.zip 


############# NOW INSTALL ALL TOOL ONE BY ONE #################################
#bpp-core
cd bpp-core

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX="/home/quentin/.software/BPP/" ../
make -j8
make install

export CPATH=$CPATH://home/quentin/.software/bpp/include/
export LIBRARY_PATH=$LIBRARY_PATH:/home/quentin/.software/bpp/lib64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH://home/quentin/.software/bpp/lib64

#bpp-seq
cd ../../bpp-seq
mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX="/home/quentin/.software/BPP/" ../
make 
make install

#bbp-popgen
cd ../../bpp-popgen
mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX="/home/quentin/.software/BPP/" ../
make 
make install

#bpp-phyl:
cd ../../bpp-phyl
mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX="/home/quentin/.software/BPP/" ../
make 
make install

#bbp-suite
cd ../../bppsuite
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX="/home/quentin/.software/BPP/" ../
make 
make install

### then install seq_stat:
#g++ -std=c++14  -g seq_stat.cpp -o seq_stat  -I$HOME/local/bpp/dev/include/ -L$HOME/local/bpp/dev/lib64/ -DVIRTUAL_COV=yes -Wall -lbpp-seq -lbpp-core -lbpp-popgen
