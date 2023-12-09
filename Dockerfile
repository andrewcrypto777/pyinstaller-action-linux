FROM ubuntu:22.04
SHELL ["/bin/bash", "-i", "-c"]

ARG PYTHON_VERSION=3.10.1
ARG PYINSTALLER_VERSION=5.3

ENV PYPI_URL=https://pypi.python.org/
ENV PYPI_INDEX_URL=https://pypi.python.org/simple
ENV PYENV_VERSION=${PYTHON_VERSION}

COPY entrypoint.sh /entrypoint.sh

RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository ppa:ubuntu-toolchain-r/test

RUN apt-get update \
    && apt-get install -y curl wget build-essential make git

RUN curl https://pyenv.run | sh

# install newest openssl (for py3.10 and py3.11)

RUN wget https://www.openssl.org/source/openssl-1.1.1s.tar.gz
RUN tar xf openssl-1.1.1s.tar.gz
WORKDIR $HOME/openssl-1.1.1s
RUN ./config
RUN make
RUN make install

# install python

RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /etc/profile
RUN echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> /etc/profile
RUN echo 'eval "$(pyenv init -)"' >> /etc/profile
RUN export PATH="$HOME/.pyenv/bin:$PATH"
RUN eval "$(pyenv init -)"
RUN eval "$(pyenv virtualenv-init -)"

RUN apt-get install -y zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev liblzma-dev libncursesw5-dev libffi-dev
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc \
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc \
    && source ~/.bashrc \
    && echo 'eval "$(pyenv init -)"' >> ~/.bashrc \
    && source ~/.bashrc \
    && pyenv install -v $PYTHON_VERSION



RUN pip install pyinstaller==$PYINSTALLER_VERSION \
    && mkdir /src/ \
    && chmod +x /entrypoint.sh

VOLUME /src/
WORKDIR /src/

ENTRYPOINT ["/entrypoint.sh"]
