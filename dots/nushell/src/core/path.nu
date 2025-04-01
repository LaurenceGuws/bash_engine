# paths.nu

# Description:
# - All these paths will be added to your Nushell PATH.
# - Keys in this file are just for readability.

let ROCM_BIN_PATH = "/opt/rocm-6.2.3/bin"
let DOCKER_PLUGIN_PATH = "/usr/lib/docker/cli-plugins"
let USR_BIN_PATH = "/usr/bin"
let HELM_LS = "/usr/local/bin"
let PIPER_PATH = "/usr/local/bin/piper"
let CARGO_PATH = $"($env.HOME)/.cargo/bin"
let LOCAL_BIN_PATH = $"($env.HOME)/.local/bin"
let NODE_PATH = $"($env.HOME)/.nvm/versions/node/v20.18.1/bin"
let GO_PATH = $"/usr/local/go/bin:($env.HOME)/go/bin"
let BUN_PATH = $"($env.HOME)/.bun/bin:($env.HOME)/node_modules/.bin:($env.HOME)/.cache/.bun/bin:($env.HOME)/.cache/.bun/install/global/bin"
let SNAP_PATH = "/var/lib/snapd/snap/bin"
let JAVA_LSP = $"($env.HOME)/.local/share"
let KREW = $"($env.HOME)/.krew/bin"
let JBANG = $"($env.HOME)/.sdkman/candidates/jbang/0.123.0/bin"
let QUARKUS = $"($env.HOME)/.sdkman/candidates/quarkus/3.19.1/bin"

# Append paths to Nushell's PATH variable correctly as a single colon-separated string
$env.PATH = $"($env.PATH):($ROCM_BIN_PATH):($DOCKER_PLUGIN_PATH):($USR_BIN_PATH):($HELM_LS):($PIPER_PATH):($CARGO_PATH):($LOCAL_BIN_PATH):($NODE_PATH):($GO_PATH):($BUN_PATH):($SNAP_PATH):($JAVA_LSP):($KREW):($JBANG):($QUARKUS)"
