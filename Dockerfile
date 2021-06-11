FROM archlinux:latest

# System upgrade
RUN pacman --noconfirm --needed -Syu
RUN pacman --noconfirm --needed -S git sudo base-devel

# Create a bench user and switch to them
RUN useradd bench -m
RUN passwd -d bench
RUN chown bench:bench /home/bench
RUN echo "bench ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER bench

# Install paru
RUN git clone https://aur.archlinux.org/paru.git /tmp/paru && cd /tmp/paru && makepkg -si --noconfirm

# Install dependencies
RUN paru --noconfirm --needed -S rust clang make libelf bpf libbpf lib32-glibc phoronix-test-suite apparmor meson bc unzip

# Install BPFContain
RUN git clone --branch will-dev https://github.com/willfindlay/bpfcontain-rs /tmp/bpfcontain-rs && cd /tmp/bpfcontain-rs && cargo install --debug --path .

# Set up phoronix test suite
RUN yes | pts enterprise-setup

# Set environment vartiables
ENV PTS_TESTS="osbench apache build-linux-kernel"
ENV PATH $PATH:/home/bench/.cargo/bin

# Install pts tests
RUN pts install $PTS_TESTS

# Copy over files
COPY . /benches
COPY ./config/pts/user-config.xml /home/bench/.phoronix-test-suite/user-config.xml

# Set workdir to /benches
WORKDIR /benches
