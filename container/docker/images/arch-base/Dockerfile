FROM archlinux/base

CMD ["/bin/bash", "-il"]

COPY mirrorlist /etc/pacman.d/
RUN ( \
	pacman -Suy --noconfirm && \
	pacman -S --noconfirm iproute2 iputils openbsd-netcat && \
	pacman -S --noconfirm grep neovim && \
	pacman -Scc --noconfirm && \
	rm /var/lib/pacman/sync/* \
)
# RUN pacman -Sy --noconfirm
# RUN pacman -S --noconfirm grep
