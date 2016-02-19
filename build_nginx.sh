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

apt-get install -y libssl-dev

cd /root
wget http://luajit.org/download/LuaJIT-2.0.3.tar.gz
tar -xzvf LuaJIT-2.0.3.tar.gz 
cd LuaJIT-2.0.3
make;
make install;

export LUAJIT_LIB=/usr/local/lib/
export LUAJIT_INC=/usr/local/include/luajit-2.0/

cd /root;
wget https://github.com/simpl/ngx_devel_kit/archive/v0.2.19.tar.gz
tar -xzvf v0.2.19.tar.gz 

cd /root;
wget https://github.com/openresty/lua-nginx-module/archive/v0.10.0.tar.gz
tar -xzvf v0.10.0.tar.gz 

cd /root
wget wget http://nginx.org/download/nginx-1.9.7.tar.gz
tar -xzvf nginx-1.9.7.tar.gz 



cd /root
wget http://www.kyne.com.au/~mark/software/download/lua-cjson-2.1.0.tar.gz
tar -xzvf lua-cjson-2.1.0.tar.gz
cd lua-cjson-2.1.0 
CPATH=/usr/local/include/luajit-2.0/ make

cd /root/nginx-1.9.7
./configure --sbin-path=/usr/local/nginx/nginx --conf-path=/usr/local/nginx/nginx.conf --pid-path=/usr/local/nginx/nginx.pid --with-ld-opt="-Wl,-rpath,SSORIGINS/lib" --with-pcre=../pcre-8.37 --with-zlib=../zlib-1.2.8  --with-http_ssl_module  --with-stream_ssl_module --with-stream --add-module=/root/ngx_devel_kit-0.2.19 --add-module=/root/lua-nginx-module-0.10.0

make  -j 2
make install;

cp /root/lua-cjson-2.1.0/cjson.so /usr/local/nginx/lib/
cp /usr/local/lib/libluajit-5.1.so.2 /usr/local/nginx/lib/
cd /usr/local/nginx/
for i in `LD_VERBOSE=1 LD_TRACE_LOADED_OBJECTS=1 ./nginx -v | grep "=>"| awk '{ print $4}' | sort -u | grep so`; do cp $i lib/; done

chrpath /usr/local/nginx/nginx -r '${ORIGIN}/lib'

cp /root/dotfiles/nginx.conf /usr/local/nginx/
tar -czvf nginx.tgz /usr/local/nginx


