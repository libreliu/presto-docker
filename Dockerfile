FROM ubuntu:20.04 AS presto-dev
LABEL maintainer="libreliu@foxmail.com"

ARG USE_APT_MIRROR=yes
ARG RUN_FFTW_WISDOM=yes

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
                          build-essential \
                          autoconf \
                          automake \
                          autotools-dev


ADD ./presto /presto
ADD ./tempo /tempo
ADD ./fftw_wisdom_i5_3210m.txt /presto/lib/fftw_wisdom_i5_3210m.txt
ENV PRESTO /presto
ENV TEMPO /tempo
ENV PGPLOT_DIR /usr/lib/pgplot5
ENV LD_LIBRARY_PATH /presto/lib
# https://stackoverflow.com/questions/27093612/in-a-dockerfile-how-to-update-path-environment-variable
ENV PATH="/presto/bin:${PATH}"

WORKDIR /
RUN (cd /presto/src && make libpresto slalib) \
    && (cd /presto && pip3 install /presto) \
    && (cd /presto/src && make) \
    # Tempo will be installed in /usr/local/bin
    && (cd /tempo && autoreconf --install && ./configure && make && make install) \
    && (test ${RUN_FFTW_WISDOM} = yes \
        && \
        (rm /presto/lib/fftw_wisdom_i5_3210m.txt && cd /presto/src && make makewisdom) \
        || \
        (echo "Wisdom not created. Defaults tested on i5-3210M is used." && \
         echo 'You may want to run "docker cp your_wisdom.txt <name>:/presto/lib/fftw_widsom"' && \
         mv /presto/lib/fftw_wisdom_i5_3210m.txt /presto/lib/fftw_wisdom.txt \
        );)

# RUN python3 tests/test_presto_python.py
