# presto-docker
Dockerized PRESTO, https://github.com/scottransom/presto

## Helpful Development commands
- Build: `docker build -t presto-dev:1 .`
  - To skip wisdom creation and use repository defaults (generated on i5-3210m), use
    `docker build -t presto-dev:1 --build-arg RUN_FFTW_WISDOM=no .`
- Run: `docker run -it --name presto-test presto-dev:1 /bin/bash`
  - Don't close the shell!
- Copy data: `docker cp some_where/presto-data/ presto-test:/`
- Test run in `presto-test`: `cd /presto-data && python3 pipeline.py GBT_Lband_PSR.fil`
  - **(!)** Depending on the script, you may want to run `ln -s /usr/bin/python3 /usr/bin/python`. But this will probably break apt or other programs relying on the fact that `python` refers to python2, so use with care.

## Notice
- `latex2html` not included. You have to convert ps outside this docker
  - `prepfold` will call ps2img, which is located in the `latex2html` package
    But the dependency involved is *GIGANTIC*.