FROM --platform=$TARGETPLATFORM lscr.io/linuxserver/webtop:latest

# Install necessary build tools and libraries
RUN apk add --no-cache \
    build-base \
    libffi-dev \
    openssl-dev \
    zlib-dev \
    bzip2-dev \
    readline-dev \
    sqlite-dev \
    ncurses-dev \
    xz-dev \
    tk-dev \
    gdbm-dev \
    db-dev \
    libpcap-dev \
    linux-headers \
    curl \
    git \
    poetry \
    wget

# Switch to non-root user 'abc' before installing pyenv
USER abc

# Set environment variables for Python installation
ENV PYTHON_VERSION=3.12.0
ENV PYENV_ROOT="/home/abc/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PATH"

# Install pyenv as 'abc'
RUN curl https://pyenv.run | bash

# Add pyenv to PATH and initialize for 'abc'
RUN echo 'export PYENV_ROOT="/home/abc/.pyenv"' >> ~/.bashrc && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(pyenv init --path)"' >> ~/.bashrc && \
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc

# Set working directory
WORKDIR /app

# Copy project files
COPY --chown=abc:abc pyproject.toml poetry.lock /app/

# Install Python using pyenv as 'abc'
RUN /bin/bash -c "source ~/.bashrc && pyenv install ${PYTHON_VERSION}"

# Create a virtual environment as 'abc'
RUN /bin/bash -c "source ~/.bashrc && \
    $PYENV_ROOT/versions/${PYTHON_VERSION}/bin/python -m venv /app/venv"

# Activate the virtual environment and install dependencies using Poetry
RUN /bin/bash -c "source /app/venv/bin/activate && \
    poetry config virtualenvs.create false && \
    poetry install --no-root"

# Copy the rest of your application code
COPY --chown=abc:abc . /app/
