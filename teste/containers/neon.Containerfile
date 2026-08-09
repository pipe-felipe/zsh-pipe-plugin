# KDE neon has no official minimal container image, and it is Ubuntu-based,
# so this starts from Ubuntu (neon's current base) and overwrites
# /etc/os-release with neon's real identification fields. That is enough to
# exercise `_neon_is_supported`; it is not a full neon desktop.
FROM docker.io/library/ubuntu:22.04

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y zsh sudo git \
	&& rm -rf /var/lib/apt/lists/* \
	&& useradd -m -s /usr/bin/zsh tester \
	&& printf 'tester ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/tester \
	&& chmod 0440 /etc/sudoers.d/tester \
	&& printf 'NAME="KDE neon"\nID=neon\nID_LIKE="ubuntu debian"\nPRETTY_NAME="KDE neon 6.2"\nVERSION_CODENAME=jammy\n' > /etc/os-release

COPY --chown=tester:tester tester.zshrc /home/tester/.zshrc

USER tester
WORKDIR /home/tester
CMD ["zsh"]
