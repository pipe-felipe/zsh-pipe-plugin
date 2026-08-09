# Arch Linux test image for zsh-pipe-plugin.
# Includes base-devel/git so `update` (pacman + aur-update-all/makepkg) can be
# exercised for real, not just mocked.
FROM docker.io/library/archlinux:base

RUN pacman -Syu --noconfirm --needed zsh sudo git base-devel \
	&& useradd -m -s /usr/bin/zsh tester \
	&& printf 'tester ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/tester \
	&& chmod 0440 /etc/sudoers.d/tester

COPY --chown=tester:tester tester.zshrc /home/tester/.zshrc

USER tester
WORKDIR /home/tester
CMD ["zsh"]
