def themes [
        option: string  
        --value: string
] {
    if $option == null {
        print $"--value YOUR_THEME required"
        return null

    } else if $option != "getAll" and $option != "getCurrent" and $option != "set" {
        print $"--value must be getAll, getCurrent or set"
        return null

    } else if $option == "getAll" {
        let themes = (ls $env.NU_THEME_DIR | get name | path parse | get stem)
        for theme in $themes {
            print $"($theme)"
        }
        return $themes

    } else if $option == "getCurrent" {
        print $"($env.NU_ACTIVE_THEME)"
        return $"($env.NU_ACTIVE_THEME)"

    } else if $option == "set" {
        if $value == null {
            print $"--value YOUR_THEME required"
            return null
        } else {
            $env.NU_ACTIVE_THEME = $value
            
            # Update config.nu automatically
            let config_path = ($env.NU_HOME | path join 'config.nu')
            let config_content = (open $config_path)

            let updated_content = ($config_content | lines | each {|line|
                if ($line | str starts-with "source src/themes/") {
                    $"source src/themes/($value).nu"
                } else {
                    $line
                }
            } | str join "\n")

            $updated_content | save -f $config_path
            print $"Updated theme to '($value)' and persisted in config.nu"
        }
    }
}
