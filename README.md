# presto-docker
Dockerized PRESTO, https://github.com/scottransom/presto

## Helpful Development commands
- Build: `docker build -t presto-cudev:1 .`
- Run: `docker run -it --gpus all --name presto-cutest presto-cudev:1 /bin/bash`
  - Don't close the shell!
  - **(Arch walkaround)** `docker run -it --gpus all --device /dev/nvidia0 --device /dev/nvidia-uvm --device /dev/nvidia-uvm-tools --device /dev/nvidiactl --name presto-cutest presto-cudev:1 /bin/bash` 
- Copy data: `docker cp some_where/presto-data/ presto-cutest:/`
- Test run in `presto-cutest`: `cd /presto-data && python3 pipeline.py GBT_Lband_PSR.fil`
  - **(!)** Depending on the script, you may want to run `ln -s /usr/bin/python3 /usr/bin/python`. But this will probably break apt or other programs relying on the fact that `python` refers to python2, so use with care.

## Notice
- `latex2html` not included. You have to convert ps outside this docker
  - `prepfold` will call ps2img, which is located in the `latex2html` package
    But the dependency involved is *GIGANTIC*.

## Related:
- Bug on new arch: 
  - https://aur.archlinux.org/packages/nvidia-container-toolkit/
  - Note: only need to install `nvidia-container-toolkit` to use, no `nvidia-container-runtime` stuff required.
  - Working walkaround:
    - editing the `/etc/nvidia-container-runtime/config.toml` and change `#no-cgroups=false` to `no-cgroups=true`
    - start with `docker run --rm --gpus all --device /dev/nvidia0 --device /dev/nvidia-uvm --device /dev/nvidia-uvm-tools --device /dev/nvidiactl  nvidia/cuda:11.3.0-devel-ubuntu20.04 nvidia-smi`

