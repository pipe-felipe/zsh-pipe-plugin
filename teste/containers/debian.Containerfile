# Debian test image for zsh-pipe-plugin.
FROM docker.io/library/debian:latest

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y zsh sudo git \
	&& rm -rf /var/lib/apt/lists/* \
	&& useradd -m -s /usr/bin/zsh tester \
	&& printf 'tester ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/tester \
	&& chmod 0440 /etc/sudoers.d/tester

COPY --chown=tester:tester tester.zshrc /home/tester/.zshrc

USER tester
WORKDIR /home/tester
CMD ["zsh"]
