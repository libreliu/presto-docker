FROM nvcr.io/nvidia/cuda:11.0.3-devel-ubuntu20.04

ENV DEBIAN_FRONTEND noninteractive
RUN ((sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list) \
       || (echo "APT mirror config untouched.");) \
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
                          intel-mkl-full \
                          cuda-samples-11-0 \
                          libmkl-full-dev \
                          openmpi-bin

ADD ./tempo /tempo
ENV PGPLOT_DIR /usr/lib/pgplot5
ENV LD_LIBRARY_PATH /presto/lib
# https://stackoverflow.com/questions/27093612/in-a-dockerfile-how-to-update-path-environment-variable
ADD ./links /links
ENV PATH="/links:/presto/bin:${PATH}"

# install TEMPO
ENV TEMPO /tempo
RUN (cd /tempo && autoreconf --install && ./configure && make && make install)

# install PRESTO_GPU
ADD ./presto_gpu /presto_gpu
ENV PRESTO /presto_gpu
ADD ./fftw_wisdom_icelake_asc.txt /presto_gpu/lib/fftw_wisdom.txt
RUN (cd /presto_gpu/src && make libpresto slalib) \
    && (cd /presto_gpu/src && make)

# install PRESTO-MKL
ADD ./presto-mkl /presto-mkl
ENV PRESTO /presto_mkl
ADD ./fftw_wisdom.txt /presto-mkl/lib/fftw_wisdom.txt
RUN (cd /presto-mkl/src && make libpresto slalib) \
    && (cd /presto-mkl/src && make)

# install PRESTO (with python)
ADD ./presto /presto
ENV PRESTO /presto
ADD ./fftw_wisdom.txt /presto/lib/fftw_wisdom.txt
RUN (cd /presto/src && make libpresto slalib) \
    && (cd /presto && pip3 install /presto) \ 
    && (cd /presto/src && make && make mpi)
RUN python3 tests/test_presto_python.py

RUN ln -s /usr/bin/python3 /usr/bin/python
WORKDIR /
