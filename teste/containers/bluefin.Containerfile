# Bluefin itself ships as an OCI/bootc image (ghcr.io/ublue-os/bluefin), but
# that image is several GB and assumes a booted ostree/bootc system, so its
# `ujust` recipes don't behave the same in a plain container. This instead
# synthesizes the one marker file `_bluefin_is_supported` actually checks, on
# top of Fedora (Bluefin's real base), which is enough to verify that the
# Bluefin handler wins detection over the Fedora handler. `ujust` is stubbed
# since the real recipes aren't installed here.
FROM docker.io/library/fedora:latest

RUN dnf install -y zsh sudo git \
	&& dnf clean all \
	&& useradd -m -s /usr/bin/zsh tester \
	&& printf 'tester ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/tester \
	&& chmod 0440 /etc/sudoers.d/tester \
	&& mkdir -p /usr/share/ublue-os \
	&& printf '{"image-name": "bluefin", "image-tag": "stable", "image-vendor": "ublue-os"}\n' > /usr/share/ublue-os/image-info.json \
	&& printf '#!/bin/sh\necho "[stub] ujust $*"\n' > /usr/local/bin/ujust \
	&& chmod +x /usr/local/bin/ujust

COPY --chown=tester:tester tester.zshrc /home/tester/.zshrc

USER tester
WORKDIR /home/tester
CMD ["zsh"]
