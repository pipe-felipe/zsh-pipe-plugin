# Fedora test image for zsh-pipe-plugin.
FROM docker.io/library/fedora:latest

RUN dnf install -y zsh sudo git \
	&& dnf clean all \
	&& useradd -m -s /usr/bin/zsh tester \
	&& printf 'tester ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/tester \
	&& chmod 0440 /etc/sudoers.d/tester

COPY --chown=tester:tester tester.zshrc /home/tester/.zshrc

USER tester
WORKDIR /home/tester
CMD ["zsh"]
