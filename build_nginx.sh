#bash install.sh 

expand() {
 cd /root;
 curl -L $1 | tar xzvf -; 
}

export LUAJIT_LIB=/usr/local/lib/
export LUAJIT_INC=/usr/local/include/luajit-2.0/

STAGE=${1:-prereq}

case $STAGE in

prereq)
apt-get install -y libssl-dev curl sudo chrpath gcc g++
curl -L https://github.com/c4milo/github-release/releases/download/v1.0.8/github-release_v1.0.8_linux_amd64.tar.gz | tar xzvf -; 
;&

pcre)
expand ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.37.tar.gz
cd pcre-8.37
./configure
make
sudo make install
;&

zlib)
expand http://zlib.net/zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure
make
sudo make install
;&

luajit)
expand http://luajit.org/download/LuaJIT-2.0.3.tar.gz
cd LuaJIT-2.0.3
make
make install
;&

ngx_devel)
expand https://github.com/simpl/ngx_devel_kit/archive/v0.2.19.tar.gz
;&

lua-nginx-module)
expand https://github.com/openresty/lua-nginx-module/archive/v0.10.0.tar.gz
;&

cjson)
expand http://www.kyne.com.au/~mark/software/download/lua-cjson-2.1.0.tar.gz
cd lua-cjson-2.1.0 
CPATH=/usr/local/include/luajit-2.0/ make
;&

nginx)
expand http://nginx.org/download/nginx-1.9.7.tar.gz
cd /root/nginx-1.9.7
./configure --sbin-path=/usr/local/nginx/nginx --conf-path=/usr/local/nginx/nginx.conf --pid-path=/usr/local/nginx/nginx.pid --with-ld-opt="-Wl,-rpath,SSORIGINS/lib" --with-pcre=../pcre-8.37 --with-zlib=../zlib-1.2.8  --with-http_ssl_module  --with-stream_ssl_module --with-stream --add-module=/root/ngx_devel_kit-0.2.19 --add-module=/root/lua-nginx-module-0.10.0

make  -j 2
;&

package)
# clean anything there from before
rm -rf /usr/local/nginx

# install stuff
cd /root/nginx-1.9.7
make install;
# package the non-chroot version, does not include libc,pthread
mkdir -p /usr/local/nginx/lib/
cp -t /usr/local/nginx/lib/ /root/lua-cjson-2.1.0/cjson.so /usr/local/lib/libluajit-5.1.so.2
cd /usr/local/nginx/
for i in `LD_VERBOSE=1 LD_TRACE_LOADED_OBJECTS=1 ./nginx -v | grep "=>"| awk '{ print $4}' | sort -u | grep so  | grep -v 'pthread' | grep -v 'libc\.' | grep -v 'ld-linux'`; do 
	echo "copying in lib $i"
	cp $i lib/; 
done
chrpath /usr/local/nginx/nginx -r '${ORIGIN}/lib'
cp -t /usr/local/nginx /root/dotfiles/nginx.conf
tar -czvf /root/nginx.tgz /usr/local/nginx
rm -rf /usr/local/nginx
;&

testinstall)
rm -rf /usr/local/nginx
tar -xzvf /root/nginx.tgz -C/
;&

release)
GITHUB_TOKEN=a9803e7217bd61758ab82381904f777b63a48604
#github-release varung/dotfiles <tag> <branch> <description> "<files>"

NAME=dotfiles
VERSION=v1.3
latest_tag=$(git describe --tags `git rev-list --tags --max-count=1`);
comparison="$latest_tag..HEAD";
if [ -z "$latest_tag" ]; then comparison=""; fi;
changelog=$(git log $comparison --oneline --no-merges --reverse);
./github-release varung/${NAME} ${VERSION} "$(git rev-parse --abbrev-ref HEAD)" "**Changelog**<br/>$changelog" '/root/nginx.tgz';
git pull


;;

# package the chroot version
# copies more libs to the chroot folder using combination of strace and ldd to pull out everything
# hit lua which tests cjson
esac

