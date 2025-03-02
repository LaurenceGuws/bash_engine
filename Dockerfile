FROM archlinux:latest

# Update system and install dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm sudo base-devel git bash wget \
    unzip neovim fzf ripgrep tree kubectl helm jq luarocks go bash-completion

# Set up non-root user with sudo access
RUN useradd -m -G wheel -s /bin/bash bashuser && \
    echo "bashuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/bashuser && \
    chmod 440 /etc/sudoers.d/bashuser

# Copy the repo into a temporary location first to get the yq installer
COPY --chown=root:root . /tmp/profile/

# Install yq using the profile's installer script
RUN chmod +x /tmp/profile/src/core/installers/yq.sh && \
    /tmp/profile/src/core/installers/yq.sh

# Switch to non-root user
USER bashuser
WORKDIR /home/bashuser

# Install yay (AUR helper)
RUN git clone https://aur.archlinux.org/yay-bin.git && \
    cd yay-bin && \
    makepkg -si --noconfirm && \
    cd .. && \
    rm -rf yay-bin

# Install AUR packages (with proper flag to skip GPG verification in container)
RUN yay -S --noconfirm --mflags="--skippgpcheck" \
    bun-bin \
    1password-cli \
    way-clipboard \
    fd \
    lazygit \
    nnn \
    zellij \
    zoxide \
    bat \
    btop \
    chromium \
    neofetch \
    ytfzf \
    ghostty \
    lsd \
    nerd-fonts-complete

# Copy the repo into user's profile directory (proper location)
RUN rm -rf /home/bashuser/profile
COPY --chown=bashuser:bashuser . /home/bashuser/profile/

# Set up the bash profile
RUN cd /home/bashuser/profile && \
    chmod +x install_profile.sh && \
    ./install_profile.sh

# Set default command to our startup script
CMD ["/bin/bash"] 