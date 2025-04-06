#!/bin/bash
# Dependencies setup script that builds everything from source

setup(){
    BUILD_DIR="$HOME/.deps_build"
    INSTALL_PREFIX="$HOME/.local"
    
    # Create build directory if it doesn't exist
    mkdir -p "$BUILD_DIR"
    mkdir -p "$INSTALL_PREFIX"
    
    # Add local bin to PATH if not already there
    if [[ ":$PATH:" != *":$INSTALL_PREFIX/bin:"* ]]; then
        export PATH="$INSTALL_PREFIX/bin:$PATH"
    fi
    
    check_dependency(){
        dependency="$1"
        if [ -z "$dependency" ]; then
            echo "Dependency name required"
            return 1
        fi
        command -v "$dependency" >/dev/null 2>&1
        return $?
    }
    
    # Basic build tools that need to be installed via package manager
    ensure_build_essentials(){
        local pkg_mgr
        if command -v pacman >/dev/null 2>&1; then
            pkg_mgr="pacman"
            pacman -S --needed base-devel cmake git curl wget
        elif command -v apt-get >/dev/null 2>&1; then
            pkg_mgr="apt"
            apt-get install -y build-essential cmake git curl wget
        elif command -v dnf >/dev/null 2>&1; then
            pkg_mgr="dnf"
            dnf install -y @development-tools cmake git curl wget
        elif command -v zypper >/dev/null 2>&1; then
            pkg_mgr="zypper"
            zypper install -y -t pattern devel_basis cmake git curl wget
        elif command -v brew >/dev/null 2>&1; then
            pkg_mgr="brew"
            brew install cmake git curl wget
        else
            echo "Warning: No supported package manager found for installing build essentials"
            echo "Please make sure you have compilers and build tools installed"
        fi
    }
    
    # Download source code - supports git, http, and local paths
    download_source(){
        local name="$1"
        local source_url="$2"
        local version="$3"
        local source_type="$4"
        
        # Create a directory for this dependency
        local build_path="$BUILD_DIR/$name"
        mkdir -p "$build_path"
        
        echo "Downloading source for $name${version:+ version $version}"
        
        # If source already exists and no version specified, skip download
        if [ -d "$build_path/source" ] && [ -z "$version" ]; then
            echo "Source directory already exists for $name, skipping download"
            return 0
        fi
        
        # Remove old source if it exists
        rm -rf "$build_path/source"
        mkdir -p "$build_path/source"
        
        # Download based on source type
        case "$source_type" in
            git)
                git clone "$source_url" "$build_path/source"
                if [ -n "$version" ]; then
                    cd "$build_path/source" && git checkout "$version"
                fi
                ;;
            http|https)
                if [[ "$source_url" =~ \.tar\.gz$ ]] || [[ "$source_url" =~ \.tgz$ ]]; then
                    curl -L "$source_url" | tar xz -C "$build_path/source" --strip-components=1
                elif [[ "$source_url" =~ \.tar\.bz2$ ]]; then
                    curl -L "$source_url" | tar xj -C "$build_path/source" --strip-components=1
                elif [[ "$source_url" =~ \.tar\.xz$ ]]; then
                    curl -L "$source_url" | tar xJ -C "$build_path/source" --strip-components=1
                elif [[ "$source_url" =~ \.zip$ ]]; then
                    tmp_file="$build_path/temp.zip"
                    curl -L "$source_url" -o "$tmp_file"
                    unzip -q "$tmp_file" -d "$build_path/temp"
                    
                    # Find the main directory in the zip
                    main_dir=$(find "$build_path/temp" -mindepth 1 -maxdepth 1 -type d | head -1)
                    if [ -d "$main_dir" ]; then
                        mv "$main_dir"/* "$build_path/source/"
                    else
                        mv "$build_path/temp"/* "$build_path/source/"
                    fi
                    
                    rm -rf "$build_path/temp" "$tmp_file"
                else
                    echo "Unsupported archive format for $source_url"
                    return 1
                fi
                ;;
            local)
                # Source is a local path
                cp -r "$source_url"/* "$build_path/source/"
                ;;
            *)
                echo "Unsupported source type: $source_type"
                return 1
                ;;
        esac
        
        return 0
    }
    
    # Build and install the package
    build_and_install(){
        local name="$1"
        local build_type="$2"
        local configure_opts="${3:-}"
        
        local build_path="$BUILD_DIR/$name"
        
        if [ ! -d "$build_path/source" ]; then
            echo "Source directory for $name not found"
            return 1
        fi
        
        echo "Building $name with $build_type"
        
        cd "$build_path/source"
        
        # Create build directory for out-of-source builds
        mkdir -p "$build_path/build"
        
        case "$build_type" in
            cmake)
                cd "$build_path/build"
                cmake "$build_path/source" -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" $configure_opts
                make -j$(nproc)
                make install
                ;;
            autotools)
                cd "$build_path/source"
                [ -f "./autogen.sh" ] && ./autogen.sh
                [ -f "./bootstrap" ] && ./bootstrap
                ./configure --prefix="$INSTALL_PREFIX" $configure_opts
                make -j$(nproc)
                make install
                ;;
            meson)
                cd "$build_path/build"
                meson setup "$build_path/source" --prefix="$INSTALL_PREFIX" $configure_opts
                ninja
                ninja install
                ;;
            make)
                cd "$build_path/source"
                make -j$(nproc) PREFIX="$INSTALL_PREFIX" $configure_opts
                make install PREFIX="$INSTALL_PREFIX"
                ;;
            cargo)
                cd "$build_path/source"
                cargo build --release
                cp target/release/$name "$INSTALL_PREFIX/bin/"
                ;;
            go)
                cd "$build_path/source"
                go build -o "$INSTALL_PREFIX/bin/$name" .
                ;;
            npm)
                cd "$build_path/source"
                npm install
                npm run build
                npm link
                ;;
            pip)
                cd "$build_path/source"
                pip install --user .
                ;;
            custom)
                cd "$build_path/source"
                # Custom build commands should be in configure_opts
                eval "$configure_opts"
                ;;
            none)
                # Just copy binary if it exists
                if [ -f "$build_path/source/$name" ]; then
                    mkdir -p "$INSTALL_PREFIX/bin"
                    cp "$build_path/source/$name" "$INSTALL_PREFIX/bin/"
                    chmod +x "$INSTALL_PREFIX/bin/$name"
                fi
                ;;
            *)
                echo "Unsupported build type: $build_type"
                return 1
                ;;
        esac
        
        echo "$name built and installed successfully"
        return 0
    }
    
    # Install a dependency
    install_dependency(){
        pkg_name="$1"
        version="$2"
        
        # Skip if package name is empty
        if [ -z "$pkg_name" ] || [ "$pkg_name" = "-" ] || [ "$pkg_name" = "null" ]; then
            return 0
        fi
        
        # Skip empty or null versions
        if [ "$version" = "null" ]; then
            version=""
        fi
        
        # Check if already installed
        if check_dependency "$pkg_name"; then
            echo "$pkg_name is already installed"
            return 0
        fi
        
        echo "Building and installing $pkg_name${version:+ version $version}"
        
        # Get source and build info
        local source_url=$(yq eval ".sources.$pkg_name.url" "dependencies.yaml")
        local source_type=$(yq eval ".sources.$pkg_name.type" "dependencies.yaml")
        local build_type=$(yq eval ".sources.$pkg_name.build_type" "dependencies.yaml")
        local configure_opts=$(yq eval ".sources.$pkg_name.configure_opts" "dependencies.yaml")
        
        # Use defaults if not specified
        if [ "$source_url" = "null" ]; then
            case "$pkg_name" in
                neovim)
                    source_url="https://github.com/neovim/neovim.git"
                    source_type="git"
                    build_type="cmake"
                    ;;
                nvimpager)
                    source_url="https://github.com/lucc/nvimpager.git"
                    source_type="git"
                    build_type="make"
                    ;;
                xclip)
                    source_url="https://github.com/astrand/xclip.git"
                    source_type="git"
                    build_type="autotools"
                    ;;
                wl-clipboard)
                    source_url="https://github.com/bugaevc/wl-clipboard.git"
                    source_type="git"
                    build_type="meson"
                    ;;
                kitty)
                    source_url="https://github.com/kovidgoyal/kitty.git"
                    source_type="git"
                    build_type="custom"
                    configure_opts="python3 setup.py linux-package --prefix \"$INSTALL_PREFIX\""
                    ;;
                alacritty)
                    source_url="https://github.com/alacritty/alacritty.git"
                    source_type="git"
                    build_type="cargo"
                    ;;
                lazygit)
                    source_url="https://github.com/jesseduffield/lazygit.git"
                    source_type="git"
                    build_type="go"
                    ;;
                ripgrep)
                    source_url="https://github.com/BurntSushi/ripgrep.git"
                    source_type="git"
                    build_type="cargo"
                    ;;
                fd)
                    source_url="https://github.com/sharkdp/fd.git"
                    source_type="git"
                    build_type="cargo"
                    ;;
                stylua)
                    source_url="https://github.com/JohnnyMorganz/StyLua.git"
                    source_type="git"
                    build_type="cargo"
                    ;;
                prettier)
                    source_url="https://github.com/prettier/prettier.git"
                    source_type="git"
                    build_type="npm"
                    ;;
                # Add more defaults for common packages
                *)
                    echo "No source information for $pkg_name and no default available"
                    return 1
                    ;;
            esac
        fi
        
        if [ "$source_type" = "null" ]; then
            if [[ "$source_url" == git* ]]; then
                source_type="git"
            elif [[ "$source_url" == http* ]]; then
                source_type="http"
            else
                source_type="local"
            fi
        fi
        
        if [ "$build_type" = "null" ]; then
            # Try to guess build type based on files in repo
            if [ -f "$BUILD_DIR/$pkg_name/source/CMakeLists.txt" ]; then
                build_type="cmake"
            elif [ -f "$BUILD_DIR/$pkg_name/source/configure" ]; then
                build_type="autotools"
            elif [ -f "$BUILD_DIR/$pkg_name/source/meson.build" ]; then
                build_type="meson"
            elif [ -f "$BUILD_DIR/$pkg_name/source/Makefile" ]; then
                build_type="make"
            elif [ -f "$BUILD_DIR/$pkg_name/source/Cargo.toml" ]; then
                build_type="cargo"
            elif [ -f "$BUILD_DIR/$pkg_name/source/go.mod" ]; then
                build_type="go"
            elif [ -f "$BUILD_DIR/$pkg_name/source/package.json" ]; then
                build_type="npm"
            elif [ -f "$BUILD_DIR/$pkg_name/source/setup.py" ]; then
                build_type="pip"
            else
                build_type="custom"
            fi
        fi
        
        if [ "$configure_opts" = "null" ]; then
            configure_opts=""
        fi
        
        # Download the source
        download_source "$pkg_name" "$source_url" "$version" "$source_type"
        
        # Build and install
        build_and_install "$pkg_name" "$build_type" "$configure_opts"
        
        return $?
    }
    
    process_dependencies(){
        local category="$1"
        local yaml_path="${2:-$category}"
        
        if [ -z "$category" ]; then
            echo "Category required"
            return 1
        fi
        
        # Check if yq is available
        if ! check_dependency "yq"; then
            echo "Installing yq for YAML parsing"
            ensure_build_essentials
            
            # Build yq from source
            download_source "yq" "https://github.com/mikefarah/yq.git" "" "git"
            build_and_install "yq" "go" ""
            
            if ! check_dependency "yq"; then
                echo "Failed to build yq. Please install manually: https://github.com/mikefarah/yq"
                exit 1
            fi
        fi
        
        # Check if category exists in YAML
        if ! yq eval ".$yaml_path" "dependencies.yaml" | grep -q .; then
            echo "Category '$yaml_path' not found in dependencies.yaml"
            return 1
        fi
        
        # Get requirement type
        local req_type=$(yq eval ".$yaml_path.required" "dependencies.yaml")
        
        # Handle missing or null requirement type
        if [ -z "$req_type" ] || [ "$req_type" = "null" ]; then
            echo "Warning: No requirement type specified for $yaml_path, assuming 'all'"
            req_type="all"
        fi
        
        case "$req_type" in
            all)
                process_all_deps "$yaml_path"
                ;;
            one)
                process_one_dep "$yaml_path"
                ;;
            children)
                process_children "$yaml_path"
                ;;
            *)
                echo "Unknown requirement type: $req_type"
                return 1
                ;;
        esac
    }
    
    process_all_deps(){
        local yaml_path="$1"
        local deps_output=$(yq eval ".$yaml_path | keys" "dependencies.yaml")
        
        # Filter out the "required" key and empty/null values
        local deps=$(echo "$deps_output" | grep -v "required" | grep -v "^-$" | grep -v "^null$")
        
        if [ -z "$deps" ]; then
            echo "No dependencies found for $yaml_path"
            return 0
        fi
        
        for dep in $deps; do
            # Skip if dependency name is empty or null
            if [ -z "$dep" ] || [ "$dep" = "-" ] || [ "$dep" = "null" ]; then
                continue
            fi
            
            local version=$(yq eval ".$yaml_path.$dep" "dependencies.yaml")
            
            # Skip empty or null versions
            if [ "$version" = "null" ]; then
                version=""
            fi
            
            if ! check_dependency "$dep"; then
                install_dependency "$dep" "$version"
            else
                echo "$dep is already installed"
            fi
        done
    }
    
    process_one_dep(){
        local yaml_path="$1"
        local deps_output=$(yq eval ".$yaml_path | keys" "dependencies.yaml")
        
        # Filter out the "required" key and empty/null values
        local deps=$(echo "$deps_output" | grep -v "required" | grep -v "^-$" | grep -v "^null$")
        
        if [ -z "$deps" ]; then
            echo "No dependencies found for $yaml_path"
            return 0
        fi
        
        # Check if any of the dependencies are installed
        local installed=false
        for dep in $deps; do
            # Skip if dependency name is empty or null
            if [ -z "$dep" ] || [ "$dep" = "-" ] || [ "$dep" = "null" ]; then
                continue
            fi
            
            if check_dependency "$dep"; then
                echo "$dep is already installed"
                installed=true
                break
            fi
        done
        
        # If none are installed, install the first one
        if [ "$installed" = false ]; then
            local first_dep=$(echo "$deps" | head -n 1)
            if [ -n "$first_dep" ] && [ "$first_dep" != "-" ] && [ "$first_dep" != "null" ]; then
                local version=$(yq eval ".$yaml_path.$first_dep" "dependencies.yaml")
                
                # Skip empty or null versions
                if [ "$version" = "null" ]; then
                    version=""
                fi
                
                install_dependency "$first_dep" "$version"
            fi
        fi
    }
    
    process_children(){
        local yaml_path="$1"
        local children_output=$(yq eval ".$yaml_path | keys" "dependencies.yaml")
        
        # Filter out the "required" key and empty/null values
        local children=$(echo "$children_output" | grep -v "required" | grep -v "^-$" | grep -v "^null$")
        
        if [ -z "$children" ]; then
            echo "No children found for $yaml_path"
            return 0
        fi
        
        for child in $children; do
            # Skip if child name is empty or null
            if [ -z "$child" ] || [ "$child" = "-" ] || [ "$child" = "null" ]; then
                continue
            fi
            
            process_dependencies "$child" "$yaml_path.$child"
        done
    }
    
    # Make sure build essentials are installed
    ensure_build_essentials
    
    # Process main categories
    echo "Setting up dependencies from source..."
    
    # Check if dependencies.yaml exists
    if [ ! -f "dependencies.yaml" ]; then
        echo "Error: dependencies.yaml not found in current directory"
        return 1
    fi
    
    # Process the main categories
    process_dependencies "clipboard"
    process_dependencies "terminal"
    process_dependencies "tools"
    
    echo "All dependencies have been built and installed from source!"
    echo "You may need to add $INSTALL_PREFIX/bin to your PATH if it's not already there."
}

# Run the setup function
setup

