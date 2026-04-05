FROM archlinux/archlinux:base-devel-20260401.0.509693

# Install packages
RUN pacman -Syu --noconfirm \
    git \
    talosctl \
    kubectl \
    cilium-cli \
    opentofu \
    ansible \
    opencode

ENTRYPOINT ["/bin/bash", "-c", "opencode web --hostname 0.0.0.0 --port 4096 --cors 'http://localhost'"]
