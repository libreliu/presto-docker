FROM nvidia/cuda:11.3.0-devel-ubuntu20.04 AS presto-cudev
LABEL maintainer="libreliu@foxmail.com"

ARG USE_APT_MIRROR=yes

# https://github.com/microsoft/WSL/issues/5682
# walkaround for silly NVIDIA who automatically jumps nvidia.com -> nvidia.cn
ENV DEBIAN_FRONTEND noninteractive
RUN (test ${USE_APT_MIRROR} = yes \
       && \
       (sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list) \
       || \
       (echo "APT mirror config untouched.");) \
    && apt-key adv --fetch-keys https://developer.download.nvidia.cn/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub \
    && sh -c 'echo "deb https://developer.download.nvidia.cn/compute/cuda/repos/ubuntu2004/x86_64 /" > /etc/apt/sources.list.d/cuda.list' \
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
                          autotools-dev \
                          intel-mkl \
    && apt-get clean

# git is used for tempo's get_version_id.sh

ADD ./presto /presto
ADD ./tempo /tempo
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
    && (cd /tempo && autoreconf --install && ./configure && make && make install)

# RUN python3 tests/test_presto_python.py
