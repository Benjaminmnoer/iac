FROM archlinux/archlinux:base-devel-20260401.0.509693

# Install packages
RUN pacman -Syu --noconfirm \
    git \
    opentofu \
    ansible \
    ansible-lint \
    sops \
    opencode \
    python-pip \
    trivy \
    && rm -rf /var/cache/pacman/pkg/*

# Create venv for checkov
RUN python -m venv /opt/checkov-venv \
    && /opt/checkov-venv/bin/pip install --no-cache-dir checkov \
    && ln -sf /opt/checkov-venv/bin/checkov /usr/local/bin/checkov
