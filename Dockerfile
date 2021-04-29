FROM ubuntu:20.04 AS presto-dev
LABEL maintainer="libreliu@foxmail.com"

ARG USE_APT_MIRROR=yes

ENV DEBIAN_FRONTEND noninteractive
RUN (test ${USE_APT_MIRROR} = yes \
       && \
       (sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list) \
       || \
       (echo "APT mirror config untouched.");) \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y tzdata \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && apt-get install -y python3 \
                          python3-pip \
                          python3-numpy \
                          python3-future \
                          python3-six \
                          python3-scipy \
                          python3-astropy \
                          gfortran \
                          pgplot5 \
                          libx11-dev \
                          libglib2.0-dev \
                          libcfitsio-dev \
                          libpng-dev \
                          libfftw3-dev \
                          build-essential


ADD ./presto /presto
ENV PRESTO /presto
ENV LD_LIBRARY_PATH /presto/lib

WORKDIR /presto
RUN (cd /presto/src && make libpresto slalib) \
    && (cd /presto && pip3 install /presto)

# RUN python3 tests/test_presto_python.py
