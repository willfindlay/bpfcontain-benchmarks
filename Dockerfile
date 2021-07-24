FROM archlinux:latest

# System upgrade
ARG CACHE_DATE=2021-07-21
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
RUN paru --noconfirm --needed -S rust clang make libelf bpf libbpf lib32-glibc phoronix-test-suite apparmor meson bc unzip bcc python python-pip python-bcc

# Install BPFContain
ARG CACHE_DATE=2021-07-21
RUN git clone https://github.com/willfindlay/bpfcontain-rs /tmp/bpfcontain-rs && cd /tmp/bpfcontain-rs && cargo install --path .

# Install BPFBox
ARG CACHE_DATE=2021-07-22
RUN git clone --branch=thesis-benchmarks https://github.com/willfindlay/bpfbox /tmp/bpfbox && cd /tmp/bpfbox && sudo make package

# Set up phoronix test suite
RUN yes | pts enterprise-setup

ARG CACHE_DATE=2021-07-23
# Set environment vartiables
#ENV PTS_TESTS="osbench apache build-linux-kernel"
ENV PTS_TESTS="ipc-benchmark"
ENV PATH $PATH:/home/bench/.cargo/bin

# Install pts tests
RUN pts install $PTS_TESTS

# Copy over files
COPY . /benches
COPY ./config/pts/user-config.xml /home/bench/.phoronix-test-suite/user-config.xml
RUN sudo ln -s /tmp/bpfbox/bin/bpfboxd /benches/bpfboxd

# Set workdir to /benches
WORKDIR /benches
