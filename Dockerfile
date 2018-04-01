FROM amazonlinux:latest

RUN yum install -y gcc gcc-c++ freetype-devel \
                   yum-utils findutils openssl-devel libjpeg-devel \
                   zlib-devel python3-devel python-devel libpng-devel freetype-devel libcurl-devel

RUN yum -y groupinstall development

RUN curl https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tar.xz | tar -xJ \
    && cd Python-3.6.1 \
    && ./configure --prefix=/usr/local --enable-shared \
    && make \
    && make install \
    && cd .. \
    && rm -rf Python-3.6.1

ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

RUN pip3 install cython numpy --no-binary numpy

RUN mkdir /tmp/gdallambda
RUN yum install wget -y

RUN wget https://github.com/OSGEO/proj.4/archive/4.9.2.tar.gz && \
         tar -zvxf 4.9.2.tar.gz && \
         cd proj.4-4.9.2/ && \
         mkdir /tmp/gdallambda/local && \
         ./configure --prefix=/tmp/gdallambda/local && \
         make && \
         make install

RUN yum install python27-devel python27-pip -y

RUN wget http://download.osgeo.org/gdal/2.2.4/gdal-2.2.4.tar.gz && \
    tar -zxvf gdal-2.2.4.tar.gz && \
    cd gdal-2.2.4 && \
    ./configure --prefix=/tmp/gdallambda/local --with-geos --with-static-proj4=/tmp/gdallambda/local --with-curl --with-python && \
    make && \
    make install

RUN cd gdal-2.2.4/swig/python && python3 setup.py install

RUN cd /usr/local/lib/python3.6/site-packages/GDAL-2.2.4-py3.6-linux-x86_64.egg && \
    mv o* ../ && \
    mv g* ../

RUN find /usr/local/lib/python3.6/site-packages -type f -name '*.pyc' | while read f; do n=$(echo $f | sed 's/__pycache__\///' | sed 's/.cpython-36//'); cp $f $n; done;
RUN find /usr/local/lib/python3.6/site-packages -type d -a -name '__pycache__' -print0 | xargs -0 rm -rf
