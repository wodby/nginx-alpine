FROM wodby/nginx-actions-alpine:dev
MAINTAINER Ivan Gaas <ivan.gaas@gmail.com>

RUN export NGX_VER="1.9.3" && \
    export NGX_UP_VER="0.9.0" && \
    export NGX_LUA_VER="0.9.16" && \
    export NGX_NDK_VER="0.2.19" && \
    export NGX_NXS_VER="0.54rc3" && \
    export LUAJIT_LIB="/usr/lib/" && \
    export LUAJIT_INC="/usr/include/luajit-2.0/" && \
# Prepare build tools for compiling some applications from source code
    apk --update add openssl-dev pcre-dev zlib-dev luajit-dev geoip-dev build-base autoconf libtool && \
## Download nginx and its modules source code
    wget -qO- http://nginx.org/download/nginx-${NGX_VER}.tar.gz | tar xz -C /tmp/ && \
    wget -qO- https://github.com/simpl/ngx_devel_kit/archive/v${NGX_NDK_VER}.tar.gz | tar xz -C /tmp/ && \
    wget -qO- https://github.com/downloads/masterzen/nginx-upload-progress-module/archive/nginx_uploadprogress_module-${NGX_UP_VER}.tar.gz | tar xz -C /tmp/ && \
    wget -qO- https://github.com/openresty/lua-nginx-module/archive/v${NGX_LUA_VER}.tar.gz | tar xz -C /tmp/ && \
    wget -qO- https://github.com/nbs-system/naxsi/archive/${NGX_NXS_VER}.tar.gz | tar xz -C /tmp/ && \
## Make and install nginx with module
    cd /tmp/nginx-${NGX_VER} && \
    ./configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx/nginx.pid \
      --lock-path=/var/run/nginx/nginx.lock --http-client-body-temp-path=/var/lib/nginx/tmp/client_body \
      --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi \
      --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi \
      --user=nginx --group=nginx --with-pcre-jit --with-http_ssl_module --with-http_realip_module \
      --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module \
      --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module \
      --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-mail \
      --with-mail_ssl_module --with-http_spdy_module --with-ipv6 --with-threads --with-stream --with-stream_ssl_module \
      --with-http_geoip_module --with-ld-opt="-Wl,-rpath,/usr/lib/" --add-module=/tmp/ngx_devel_kit-${NGX_NDK_VER}/ \
      --add-module=/tmp/masterzen-nginx-upload-progress-module-a788dea/ --add-module=/tmp/lua-nginx-module-${NGX_LUA_VER}/ \
      --add-module=/tmp/naxsi-${NGX_NXS_VER}/naxsi_src/ && make -j2 && make install && \
## Clean packages
    apk del openssl-dev pcre-dev zlib-dev luajit-dev geoip-dev build-base autoconf libtool && \
## Install depends
    apk add --update libssl1.0 libcrypto1.0 pcre zlib luajit geoip && \
    addgroup -S -g 101 nginx && adduser -HS -u 100 -h /var/www/localhost/htdocs -s /sbin/nologin -G nginx nginx && \
    adduser nginx wodby && \
    mkdir -p /var/lib/nginx/tmp && \
    chmod 755 /var/lib/nginx && \
    chmod -R 777 /var/lib/nginx/tmp && \
## Finish
    rm -rf /var/cache/apk/* /tmp/*

#COPY rootfs /