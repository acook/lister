FROM crystallang/crystal:0.36.1-alpine
WORKDIR /app
COPY . .

# dependencies
RUN apk add libmagic

# work around alpine not shipping with static libmagic.a
RUN apk add libtool autoconf automake
RUN mkdir -p /opt/src
# zlib
RUN cd /opt/src && git clone https://github.com/madler/zlib.git && cd zlib && ./configure --static --64 && make
# bz2
RUN cd /opt/src && git clone git://sourceware.org/git/bzip2.git && cd bzip2 && make
# file/libmagic
RUN cd /opt/src && git clone https://github.com/file/file.git
RUN cd /opt/src/file && SH_LIBTOOL='/usr/share/build-1/libtool' autoreconf -f -i
RUN cd /opt/src/file && CFLAGS="-static" ./configure --prefix=/usr --datadir=/usr/share --enable-static --disable-xzlib
RUN cd /opt/src/file && make LDFLAGS="-all-static"

# by default just run the tests
CMD ["crystal", "spec"]
