expand() {
 cd /root;
 curl -L $1 | tar xzvf -; 
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/env.sh

export LUAJIT_LIB=/usr/local/lib/
export LUAJIT_INC=/usr/local/include/luajit-2.0/

STAGE=${1:-prereq}

case $STAGE in

prereq)
apt-get update
apt-get install -y libssl-dev curl sudo chrpath gcc g++ strace
curl -L https://github.com/aktau/github-release/releases/download/v0.6.2/linux-amd64-github-release.tar.bz2 | tar --strip-components=3 -xvjf -;
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
# patch nginx to use custom name
sed -i "s/nginx:\ /${NGINX_NAME}: /" src/os/unix/ngx_setproctitle.c
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
mkdir -p /usr/local/nginx/logs/
cp -t /usr/local/nginx/lib/ /root/lua-cjson-2.1.0/cjson.so /usr/local/lib/libluajit-5.1.so.2
cd /usr/local/nginx/
for i in `LD_VERBOSE=1 LD_TRACE_LOADED_OBJECTS=1 ./nginx -v | grep "=>"| awk '{ print $4}' | sort -u | grep so  | grep -v 'pthread' | grep -v 'libc\.' | grep -v 'ld-linux'`; do 
	echo "copying in lib $i"
	cp $i lib/; 
done
chrpath /usr/local/nginx/nginx -r '${ORIGIN}/lib'
cp -t /usr/local/nginx /root/dotfiles/nginx.conf
mv /usr/local/nginx/nginx /usr/local/nginx/$NGINX_NAME

# rename folder: unnecessary in chroot
#mv /usr/local/nginx /usr/local/$NGINX_NAME
#tar -czvf /root/$NGINX_NAME.tgz /usr/local/$NGINX_NAME
#rm -rf /usr/local/$NGINX_NAME
;&

chrootify)
# make chroot folder
rm -rf $cdir
mkdir -p $cdir/{bin,usr,lib,usr/lib,dev,sys,tmp,proc,var}
chmod a+rwx $cdir/tmp
cp /bin/bash $cdir/bin/bash

# copy minimum files needed in there
cp -r -t $cdir --parents /usr/local/nginx

# copy every library we use
for i in `LD_VERBOSE=1 LD_TRACE_LOADED_OBJECTS=1 /usr/local/nginx/$NGINX_NAME | grep "=>"| awk '{ print $4}' | sort -u | grep so`; do 
	echo "copying in lib $i"
	cp -t $cdir --parents $i;
done

# get the files not in /usr/local/nginx
# nginx_chroot_files is a list of files that were open'ed successfully during a strace
# includes some extra ones not above
for i in $(cat ~/dotfiles/nginx_chroot_files); do
	cp -t $cdir --parents $i
done 
# the loader itself
# cp -t $cdir --parents /lib64/ld-linux-x86-64.so.2


cat <<-EOF >> $cdir/mount.sh
	#!/bin/bash
	# mount it
	mount -t proc proc $cdir/proc
	mount -t sysfs -o rw,noexec,nosuid,nodev none $cdir/sys
	mount -o bind /dev $cdir/dev
	mount -o bind /var $cdir/var
	
EOF

cat <<-EOF >> $cdir/umount.sh
	#!/bin/bash
	umount $cdir/{proc,sys,dev,var}
EOF

cat <<-EOF >> $cdir/run.sh
	#!/bin/bash
	chroot $cdir /usr/local/nginx/$NGINX_NAME
EOF
chmod +x $cdir/{mount.sh,umount.sh,run.sh}

# TODO: it may be possible to create a script that mounts, runs, and then umounts on exit, assuming nginx runs in foreground

# TODO: install node and webterminal?
tar -czvf /root/cloudlabs_bundle.tgz $pdir

;&

testinstall)
#rm -rf /usr/local/$NGINX_NAME
#tar -xzvf /root/$NGINX_NAME.tgz -C/

;&
release)
VERSION=v1.7.1
/root/github-release release -s $GITHUB_TOKEN -u varung -r dotfiles -t $VERSION
/root/github-release upload -s $GITHUB_TOKEN -u varung -r dotfiles -t $VERSION -n cloudlabs_bundle.tgz -f /root/cloudlabs_bundle.tgz


;;

# package the chroot version
# copies more libs to the chroot folder using combination of strace and ldd to pull out everything
# hit lua which tests cjson
esac

