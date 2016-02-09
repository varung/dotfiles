bash install.sh 
bash install_gcc.sh 

#pcre
cd /root
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.37.tar.gz
tar -zxf pcre-8.37.tar.gz
cd pcre-8.37
./configure
make
sudo make install

# zlib
cd /root/
wget http://zlib.net/zlib-1.2.8.tar.gz
tar -zxf zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure
make
sudo make install

apt-get install libssl-dev

wget http://nginx.org/download/nginx-1.9.11.tar.gz
tar -xzvf nginx-1.9.11.tar.gz 
cd nginx-1.9.11

./configure \
  --sbin-path=/usr/local/nginx/nginx \
  --conf-path=/usr/local/nginx/nginx.conf \
  --pid-path=/usr/local/nginx/nginx.pid \
  --with-pcre=../pcre-8.37 \
  --with-zlib=../zlib-1.2.8 \
  --with-http_ssl_module \
  --with-stream_ssl_module \
  --with-stream \
  --with-mail

make 
