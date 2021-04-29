# presto-docker
Dockerized PRESTO, https://github.com/scottransom/presto

## Helpful Development commands
- Build: `docker build -t presto-dev:1 .`
- Run: `docker run -it --name presto-test presto-dev:1 /bin/bash`
  - Don't close the shell!
- Copy data: `docker cp some_where/presto-data/ presto-test:/`
- Test run in `presto-test`: `cd /presto-data && python3 pipeline.py GBT_Lband_PSR.fil`