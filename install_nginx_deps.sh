#pcre
if true; then
  cd /root
  wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.37.tar.gz
  tar -zxf pcre-8.37.tar.gz
  cd pcre-8.37
  ./configure
  make
  sudo make install
fi

if true; then
cd /root/
# zlib
wget http://zlib.net/zlib-1.2.8.tar.gz
tar -zxf zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure
make
sudo make install
fi

if true ; then
cd /root
#openssl
wget http://www.openssl.org/source/openssl-1.0.2f.tar.gz
tar -zxf openssl-1.0.2f.tar.gz
cd openssl-1.0.2f
./configure darwin64-x86_64-cc --prefix=/usr
make
sudo make install
fi
