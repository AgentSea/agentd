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
    wget

# Set environment variables for Python installation
ENV PYTHON_VERSION=3.12.0
ENV PYENV_ROOT="/config/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PATH"

# Install pyenv as root
RUN curl https://pyenv.run | bash

# Change ownership of pyenv directories to user 'abc'
RUN chown -R abc:abc /config/.pyenv

# Add pyenv to PATH and initialize for all users
RUN echo 'export PYENV_ROOT="/config/.pyenv"' >> /etc/profile.d/pyenv.sh && \
    echo 'export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"' >> /etc/profile.d/pyenv.sh && \
    echo 'eval "$(pyenv init --path)"' >> /etc/profile.d/pyenv.sh && \
    echo 'eval "$(pyenv init -)"' >> /etc/profile.d/pyenv.sh

# Create the application directory and set ownership to 'abc'
RUN mkdir -p /config/app && chown -R abc:abc /config/app

# Switch to non-root user 'abc'
USER abc

# Set working directory to '/config/app'
WORKDIR /config/app

# Set HOME environment variable to /config/app
ENV HOME=/config/app

# Copy project files
COPY --chown=abc:abc pyproject.toml poetry.lock /config/app/

# Install Python using pyenv as 'abc'
RUN /bin/bash -c "pyenv install ${PYTHON_VERSION}"

# Create a virtual environment as 'abc'
RUN /bin/bash -c "$PYENV_ROOT/versions/${PYTHON_VERSION}/bin/python -m venv /config/app/venv"

# Update PATH to include the virtual environment's bin directory
ENV PATH="/config/app/venv/bin:$PATH"

# Install poetry into the virtual environment
RUN /bin/bash -c "pip install poetry"

# Install dependencies using Poetry within the virtual environment
RUN /bin/bash -c "poetry config virtualenvs.create false && poetry install --no-root"

# Copy the rest of your application code
COPY --chown=abc:abc . /config/app/

# Expose the port that your application will run on
EXPOSE 8000

