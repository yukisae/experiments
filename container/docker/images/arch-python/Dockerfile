FROM cx/arch-base

CMD ["/usr/bin/ipython"]

RUN ( \
	pacman -Suy --noconfirm && \
	pacman -S --noconfirm python ipython && \
	pacman -S --noconfirm python-yaml && \
	pacman -Scc --noconfirm && \
	rm /var/lib/pacman/sync/* \
)


# RUN pacman -Suy --noconfirm
# RUN pacman -S --noconfirm python-yaml
