FROM archlinux:latest

# System upgrade
RUN pacman --noconfirm --needed -Syu

# Create a build user and switch to them
RUN useradd build -m
RUN passwd -d build
RUN chown build:build /home/build
RUN echo "build ALL=(ALL) NOPASSWD: /usr/bin/pacman" >> /etc/sudoers

# Install paru
RUN pacman --noconfirm --needed -S git sudo base-devel
USER build
RUN git clone https://aur.archlinux.org/paru.git /tmp/paru && cd /tmp/paru && makepkg -si --noconfirm
USER root

# Install dependencies
USER build
RUN paru --noconfirm --needed -S rust clang make libelf bpf libbpf lib32-glibc phoronix-test-suite
USER root

# Copy over files
COPY . /benches
