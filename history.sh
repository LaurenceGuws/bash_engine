
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..
paru -S brave-bin zen-browser-bin
paru -S 1password 1password-cli gitkraken gitkraken-cli
sudo pacman -S chromium
paru -S libgnome-keyring
paru -S jq unzip
paru -S fzf
paru -S openssh
paru -S neovim
mkdir -p ~/.config/bash_completion
paru -S barrier
rm -rf ./paru/
paru -S zoxide nnn npm
wget https://download.docker.com/linux/static/stable/x86_64/docker-28.0.1.tgz -qO- | tar xvfz - docker/docker --strip-components=1
mv ./docker /usr/local/bin
sudo mv ./docker /usr/local/bin
paru -S neofetch
sudo systemctl enable sshd
paru -S tree-sitter-cli
paru -S --needed - < packages.txt
