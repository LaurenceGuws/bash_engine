#!/bin/bash

# System Updater Function
arch_story() {
    local messages=(
        "Writing a 500-line bash script to rename files alphabetically."
        "Installing every TUI application because GUIs are evil."
        "Configuring fail2ban on a computer with no network access."
        "Making alias for an alias that aliases another alias."
        "Setting up ClamAV and never running a scan."
        "Trying to rice GRUB because 2 seconds of boot time needs themes."
        "Installing three different clipboard managers 'just in case.'"
        "Writing a script to check if scripts are running correctly."
        "Setting up a mail server to send myself system notifications."
        "Creating a fancy login screen that I skip with autologin."
        "Tweaking laptop lid behavior settings without owning a laptop."
        "Installing every markdown editor to write a TODO.md I'll never read."
        "Setting up full disk encryption for my meme folder."
        "Creating a custom DNS server to block ads I never see."
        "Writing a shell function to calculate shell function performance."
        "Installing multiple file managers but using 'cd' anyway."
        "Setting up hardware acceleration for a text editor."
        "Making a script to check if my scripts have correct shebang lines."
        "Creating a system restore point before installing a wallpaper."
        "Setting up a cron job to remind me not to create unnecessary cron jobs."
        "Installing three different notification systems but enabling DND."
        "Writing a manual for scripts that only I will use."
        "Setting up network bonding on a single network card."
        "Creating a ramdisk for storing temporary files I never delete."
        "Installing every music player but using YouTube in browser."
        "Setting up hibernation support on a desktop that never sleeps."
        "Making a script to organize screenshots I never take."
        "Installing security tools to protect my collection of wallpapers."
        "Setting up a firewall rule for each individual pixel on my screen."
        "Creating a swap file larger than my RAM just to be safe."
        "Writing a script to detect if I'm writing too many scripts."
        "Setting up a VM to test if my VM settings are correct."
        "Installing compilers for languages I don't know yet."
        "Making a backup script that backs up other backup scripts."
        "Setting up disk quotas on a single-user system."
        "Creating a custom kernel module to blink my LED faster."
        "Installing three different temperature monitors in case two break."
        "Writing a script to automatically update my update scripts."
        "Trying a dark theme but switching back because I can't read it outdoors."
        "Explaining why recompiling the kernel is a necessary life skill at dinner."
        "Tiling windows perfectly just to fullscreen a browser."
        "Converting my old scripts to Python for no real reason."
        "Switching my primary editor to see if my productivity improves."
        "Realizing the coffee spill was the reason my keyboard shortcuts broke."
        "Updating my color scheme because the current one feels 'dated.'"
        "Installing Global Protect VPN just to watch Netflix US."
        "Adding zsh and oh-my-zsh to feel like a real 'pro', then go back to bash."
        "Reformatting my laptop before a presentation because 'everything will be quicker.'"
        "Switching from sysvinit to OpenRC for 'fun', spending days recovering."
        "Learning git submodules and immediately regretting every past decision."
        "Re-adding desktop icons because it turns out they were useful all along."
        "Compiling my own drivers, just to roll back to the stable version later."
        "Contemplating if /dev/null is really just a metaphor for life."
        "Realizing my CPU fan sounds exactly like the void calling my name."
        "Converting my consciousness to a systemd service, one unit at a time."
        "My system is stable and I feel empty inside."
        "Distro-hopping won't fill the void, but I'll try anyway."
        "sudo pacman -R existence"
        "Maybe the real package conflicts were the friends we made along the way."
        "If a system updates in the forest and no one is around to see it..."
        "Writing a script to find meaning in endless terminal output."
        "rm -rf /thoughts/existential_crisis/* && touch enlightenment"
        "The AUR is infinite, and so is my despair."
        "What if we're all just processes waiting to be killed -9?"
        "Organizing dotfiles won't organize my life, but here we are."
        "Running stress tests to feel something."
        "Every failed build brings me closer to digital nirvana."
        "Turns out happiness wasn't in the AUR after all."
        "My uptime is longer than my last relationship."
        "grep -r 'meaning' / > /dev/null 2>&1"
        "Perhaps Arch isn't the answer, but what was the question?"
        "killall emotions && systemctl start enlightenment"
        "The terminal is dark and so is my soul."
        "Compiling the kernel won't compile my scattered thoughts."
        "Moving /home to /void for better spiritual alignment."
        "The only stable release is accepting that nothing is stable."
        "I don't always test my scripts, but when I do, I test in production."
        "Realizing that like my file system, I too am fragmenting."
        "chmod 000 feelings/*"
        "Even cron can't schedule inner peace."
        "Disk usage: 98%, Soul usage: Empty"
        "Is breaking my system just a cry for help?"
        "Writing a daemon to watch over my lost soul."
        "The only symlink I need is to self-acceptance."
        "Trying to pacman -S happiness --noconfirm"
        "Error: Purpose not found in current scope"
        "There's no package manager for emotional dependencies."
        "systemctl status existence returns 'inactive (dead)'"
        "All these mirrors but I still can't reflect on myself."
        "The real root access was the journey within."
        "Mounting /dev/soul to /mnt/void"
        "No amount of cores can parallel process this emptiness."
        "Recompiling my personality with -O3 optimization."
        "GRUB is just a bootloader, but aren't we all just loading something?"
        "The ping to my dreams is timing out."
        "Unable to resolve inner conflicts, merging anyway."
        "Trying to find myself in the process tree."
        "My life has more race conditions than my shell scripts."
        "Forking processes won't fork my reality."
        "Each failed mount point is just another metaphor."
        "The only thing more broken than my system is my spirit."
        "Writing an init script to bootstrap my consciousness."
        "Moving emotional baggage to /tmp, but it persists after reboot."
        "Configuring kernel parameters won't reconfigure my destiny."
        "Searching for truth in core dumps."
        "The dmesg of my soul is full of errors."
        "Every orphaned process reminds me of my solitude."
        "They say RTFM, but I can barely read."
        "Playing with neofetch because actual work is too hard."
        "Even my error messages are disappointed in me."
        "My git history is cleaner than my life choices."
        "Pretending I understand regular expressions."
        "Writing scripts to automate my incompetence."
        "Making my desktop rice prettier won't make me better at coding."
        "These kernel parameters won't optimize my self-worth."
        "My package management is more organized than my life."
        "Finally fixed the bug - it was me all along."
        "Compiling from source to feel like a real developer."
        "Using vim but with the skill of notepad."
        "Creating contingency scripts for my contingency scripts because trust issues."
        "My code review history is just a series of apologies."
        "Making my prompt more complex to compensate for something."
        "Organizing dotfiles won't organize my scattered thoughts."
        "Using fancy shell functions to hide my basic command knowledge."
        "These compilation flags won't compile away my insecurities."
        "Looking for my wife in /usr/bin... found a broken symlink."
        "Reinstalling Arch for the third time this week because it's 'fun.'"
        "Reading 12 Arch Wiki tabs to fix a 5-second boot delay."
        "Manually sorting pacman mirrors for no reason other than vibes."
        "Replacing perfectly functional software with something that requires compiling."
        "Realizing the AUR package doesn't work because I forgot to update mirrors again."
        "Adding 15 new aliases to .bashrc because typing is overrated."
        "Trying another tiling window manager because my rice isn't minimal enough."
        "Debugging a script I wrote at 3 AM to save 0.2 seconds per command."
        "Breaking my desktop environment to make the terminal look cooler."
        "Wondering why \`makepkg\` takes hours, only to realize I forgot the dependencies."
        "Creating a new partition to test a different desktop environment... again."
        "Spending 5 hours tweaking dotfiles only to switch to a new setup tomorrow."
        "Installing a kernel patch for performance, but now the sound doesn't work."
        "Switching to Wayland and then back to Xorg for the 10th time."
        "Writing a custom script to check for updates that I'll never use."
        "Setting up Arch on a USB stick just to prove I can."
        "Reading through 100 comments on an AUR package instead of working."
        "Adding an obscure package to pacman.conf because the default wasn't edgy enough."
        "Customizing my GRUB theme to match my desktop wallpaper."
         "These syntax highlights won't highlight my achievements."
        "My shell completion is more complete than my training."
        "Using docker to containerize my imposter syndrome."
        "Making my own tools because I can't understand existing ones."
        "These configs are more consistent than my coding style."
        "My error handling is like my life handling - nonexistent."
        "Writing wrappers to hide my wrapper anxiety."
        "Using fancy terminals to mask basic skills."
        "Making aliases because full commands expose my ignorance."
        "These package versions are more up-to-date than my knowledge."
        "My background processes are more processed than my emotions."
        "Creating functions to function despite dysfunction."
        "Using pipes to channel my inadequacies."
        "Making scripts because GUI would be too straightforward."
         "My backup strategy is better than my life strategy."
        "Writing man pages for scripts that shouldn't exist."
        "Even shellcheck is disappointed in me."
        "Making elaborate scripts to avoid learning proper solutions."
        "ulimit -a shows no limits, yet I feel so constrained."
        "Background processes can't process my background thoughts."
        "Trying to pipe existential output to /dev/null"
        "Creating a tmpfs for temporary happiness."
        "Pushing to origin/master but pulling from void/darkness"
        "Running life.sh in an infinite loop, waiting for Ctrl+C"
        "Checking entropy levels of my decision making."
        "Failed to mount /mnt/purpose: No such file or directory"
        "Loading consciousness modules into the kernel of being."
        "Finding zen in endless dependency chains."
        "The only sandbox is the universe itself."
        "Redirecting stdout to the void, stderr to my journal."
        "Realizing I'm just a user in someone else's system."
        "Unable to establish connection with reality."
        "Making everything verbose except my social skills."
        "These debug flags won't debug my career choices."
        "My dependency tree is more dependable than me."
        "Using CLI tools to avoid facing my GUI fears."
        "Configuring UFW rules for a laptop that never leaves home."
        "Installing three different AUR helpers because choices matter."
        "Setting up a Kubernetes cluster to run htop in a container."
        "Making everything pipe into lolcat because logs need rainbows."
        "Creating systemd services for scripts that run once a year."
        "Spending hours finding the perfect emoji for git commit messages."
        "Setting up auto-mounting for drives I don't own."
        "Every segfault is just a reminder of my mortality."
        "The CPU cycles, and so do my thoughts."
        "Maybe I should refactor my life choices."
        "Trying to escape the shell, but ending up in another shell."
        "Even fsck can't repair what's broken inside."
        "The only thing more nested than my functions is my anxiety."
        "Creating entropy by randomizing my life choices."
        "My code is like my life choices - poorly documented and questionable."
        "Writing another script I'm not qualified to maintain."
        "Pretending to understand systemd while crying internally."
        "Stack Overflow said I'm doing it wrong... again."
        "Making my prompt prettier won't make me a better developer."
        "Running diagnostics to figure out why I'm like this."
        "Installing developer tools I'll never be good enough to use."
        "My commits are as meaningful as my contributions to society."
        "Even my shell thinks I make bad decisions."
        "Using arch btw... because I hate myself just enough."
        "Creating another alias to hide my command line incompetence."
        "These configs won't fix my personality defects."
        "Documenting my mistakes and calling them features."
        "Making my terminal transparent like my facade of competence."
        "Blaming the AUR for my personal shortcomings."
        "My bash scripts are like my life - mostly undefined behavior."
        "Adding comments to code I don't understand myself."
        "My system is stable but my skills aren't."
        "Using arch because ubuntu would be admitting defeat."
        "These rice screenshots won't improve my coding ability."
        "Customizing my terminal won't customize my career prospects."
        "Making everything modular except my understanding."
        "My dotfiles are more maintained than my relationships."
        "These keybindings won't bind my life together."
        "Writing functions to hide my functional inadequacies."
        "My git commits are more committed than I am."
        "Using tmux to multiply my inefficiencies."
        "Making scripts to automate problems I created."
        "These environment variables won't improve my environment."
        "Replacing my terminal font because the 'e' didn't look right."
        "Recompiling my window manager because the default keybinds annoyed me."
        "Looking for my dotfiles... oh, I symlinked them to an external drive. Again."
        "Installing another terminal emulator because my current one feels 'bloated.'"
        "Searching for the perfect GTK theme even though I barely use GTK apps."
        "Spending an hour on r/unixporn instead of finishing my configs."
        "Realizing my system is broken because I alias everything to 'sudo pacman.'"
        "Using 'btm' instead of 'top' because ASCII graphs are life now."
        "Trying to compile a browser from source but gave up after the first error."
        "Editing my polybar config while my CPU overheats for no reason."
        "Replacing my bash prompt for the 100th time because the spacing felt 'off.'"
        "Turning off animations to save 3ms of CPU time because why not."
        "Looking up how to fix something, only to find the solution was 'use another distro.'"
        "Compiling everything from source because precompiled binaries are for cowards."
        "Writing a bash script to automate tasks I’ll probably never do again."
        "Trying to explain to my friends why I need five terminals open at once."
        "Breaking my system just to prove I can fix it."
        "Spending hours ricing my desktop and then realizing I never actually use it."
        "Replacing 'ls' with a custom script to print file names in Comic Sans."
        "Realizing I deleted /home instead of clearing cache. Again."
        "Optimizing boot time by 2ms but breaking Bluetooth in the process."
        "Trying a new shell because bash isn't 'modern' enough."
        "Switching back to vim after trying every neovim config on GitHub."
        "Writing a pacman hook that breaks if you sneeze near the keyboard."
        "Replacing Xorg with Wayland just to see if it still breaks everything. It does."
        "Configuring my system to boot into tmux directly because GUIs are overrated."
        "Explaining to my cat why systemd isn't that bad while updating packages."
        "Moving from i3-gaps to bspwm because the gaps weren't gappy enough."
        "Spending 3 hours configuring neofetch to show the perfect ASCII art."
        "Writing a script to automate script writing, recursion intended."
        "Installing every PDF viewer in existence to find the 'perfect' one."
        "Clearing package cache to free up 50MB on a 2TB drive."
        "Trying to remember which config file controls my config files."
        "Running 'pacman -Syu' twice because the first time didn't feel right."
        "Switching to fish shell because the autocomplete animations are pretty."
        "Making my terminal transparent just to make it opaque again."
        "Creating a custom keyboard layout because QWERTY is too mainstream."
        "Downloading the entire AUR because 'what if the internet goes down?'"
        "Installing 15 different system monitors to check which uses less RAM."
        "Writing a blog post about minimalism while installing 500 packages."
        "Organizing dotfiles into categories, subcategories, and sub-subcategories."
        "Trying to explain to Windows users why I need 7 text editors."
        "Setting up SSH keys for the 100th time because I forgot the passphrase."
        "Making backups of backups because you can never be too careful."
        "Configuring multi-monitor setup only to use one screen anyway."
        "Adding RGB support to terminal because productivity needs colors."
        "Creating a custom package repository for three packages."
        "Spending a day optimizing startup time to save 0.5 seconds."
        "Installing every font on GitHub just to use Fira Code."
        "Using Docker to run a calculator because isolation is important."
        "Setting up dual boot just to never use the other OS."
        "Trying to remember why I aliased 'cd' to something else."
        "Customizing PS1 prompt to show git branch, weather, and moon phase."
        "Moving /home to a new partition at 2 AM because why not?"
        "Installing a lightweight WM on a 64GB RAM machine."
        "Writing a script to randomly change wallpapers every 5 seconds."
        "My system logs are more logical than my decisions."
        "Using command line because I can't design UIs."
        "Making everything automated except my personal growth."
        "These shell options won't give me better options in life."
        "My file permissions are more restrictive than my potential."
        "Using Linux because Windows would be too user-friendly."
        
    )

    # Handle cleanup on exit (Ctrl+C)
    trap 'echo "Exiting updater..."; exit 0' SIGINT SIGTERM

    while true; do
        sleep $((RANDOM % 5 + 1))

        # Balanced Log Level Distribution
        case $((RANDOM % 10)) in
            0|1|2) level="trace" ;;    # 30% TRACE
            3|4) level="debug" ;;      # 20% DEBUG
            5|6) level="info" ;;       # 20% INFO
            7) level="warning" ;;      # 10% WARNING
            8) level="error" ;;        # 10% ERROR
            9) level="fatal" ;;        # 10% FATAL
        esac

        # Pick a message
        case $level in
            *) message="${messages[RANDOM % ${#messages[@]}]}" ;;
        esac

        # Log output
        blog -l "$level" "$message"
    done
}

wiki_life(){
    arch_story | spinner --speed 200 --style arrow --message "PLEASE LET ME FINISH!"
}