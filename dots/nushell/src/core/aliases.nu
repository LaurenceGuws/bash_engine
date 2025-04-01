def ll [args: string = "."] { ls -la $args }
def l [args: string = "."] { ls $args }
def ping [args: string = "google.com"] { gping $args }

def allow [file: string = "."] { sudo chmod +x $file }
def own [file: string = ".", owner: string = "root"] { sudo chown $owner $file }
def yt [] { let invidious_instance = "https://vid.puffyan.us"; ytfzf -t }

# Libvirt & QEMU stack
def vmon [] { sudo systemctl start libvirtd.service qemu-kvm.service virtlockd.service virtlogd.service }
def vmoff [] { sudo systemctl stop libvirtd.service qemu-kvm.service virtlockd.service virtlogd.service }
def vmen [] { sudo systemctl enable libvirtd.service qemu-kvm.service virtlockd.service virtlogd.service }
def vmdis [] { sudo systemctl disable libvirtd.service qemu-kvm.service virtlockd.service virtlogd.service }

# Handling environment variables and dynamic aliases
def bot [args: string = ""] { ollama run $env.ACTIVE_BOT $args }

# Conditional editor/browser alias
def e [args: string = "."] { 
    if ($env.EDITOR | is-not-empty) { 
        ^$env.EDITOR $args
    } else { 
        print "EDITOR is not set" 
    }
}

def b [args: string = "."] { 
    if ($env.BROWSER | is-not-empty) { 
        ^$env.BROWSER $args
    } else { 
        print "BROWSER is not set" 
    }
}

