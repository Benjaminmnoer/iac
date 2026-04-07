FROM archlinux/archlinux:base-devel-20260401.0.509693

# Install packages
RUN pacman -Syu --noconfirm \
    git \
    talosctl \
    kubectl \
    cilium-cli \
    opentofu \
    ansible \
    ansible-lint \
    sops \
    opencode \
    && rm -rf /var/cache/pacman/pkg/*
