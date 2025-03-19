-- Project Operations Module for NvimTree Context Menu
-- Provides project-related operations

local M = {}

-- Common project file templates
local project_templates = {
  [".editorconfig"] = [[
# EditorConfig is awesome: https://EditorConfig.org

# top-most EditorConfig file
root = true

# Unix-style newlines with a newline ending every file
[*]
end_of_line = lf
insert_final_newline = true
charset = utf-8
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

# 4 space indentation for Python files
[*.py]
indent_size = 4

# Tab indentation for Makefiles
[Makefile]
indent_style = tab
]],
  
  [".gitignore"] = [[
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Dependency directories
node_modules/
jspm_packages/
__pycache__/
.pytest_cache/
venv/
env/
.env/
.venv/

# Distribution / packaging
dist/
build/
*.egg-info/

# dotenv environment variable files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Editor directories and files
.idea/
.vscode/
*.swp
*.swo
*~
]],
  
  ["README.md"] = [[
# Project Name

A brief description of what this project does and who it's for.

## Installation

Install my-project with npm

```bash
  npm install my-project
  cd my-project
```

## Features

- Feature 1
- Feature 2
- Feature 3

## License

[MIT](https://choosealicense.com/licenses/mit/)
]],
  
  ["LICENSE"] = [[
MIT License

Copyright (c) YEAR AUTHOR

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]],

  [".prettierrc"] = [[
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false
}
]],

  [".eslintrc.json"] = [[
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "extends": [
    "eslint:recommended"
  ],
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "rules": {
    "indent": [
      "error",
      2
    ],
    "linebreak-style": [
      "error",
      "unix"
    ],
    "quotes": [
      "error",
      "single"
    ],
    "semi": [
      "error",
      "always"
    ]
  }
}
]]
}

-- Set a directory as project root
function M.set_as_project_root(node)
  if not node or not node.absolute_path then
    vim.notify("Invalid node", vim.log.levels.ERROR)
    return
  end
  
  -- Ensure it's a directory
  if not node.fs_stat or node.fs_stat.type ~= "directory" then
    vim.notify("Not a directory", vim.log.levels.ERROR)
    return
  end
  
  -- Change the current working directory
  vim.cmd("cd " .. vim.fn.fnameescape(node.absolute_path))
  vim.notify("Set project root to: " .. node.name, vim.log.levels.INFO)
  
  -- If nvim-tree API is available, refresh the tree
  local status_ok, api = pcall(require, "nvim-tree.api")
  if status_ok then
    api.tree.change_root(node.absolute_path)
    api.tree.reload()
  end
end

-- Create a common project file from template
function M.create_project_file(node)
  if not node or not node.absolute_path then
    vim.notify("Invalid node", vim.log.levels.ERROR)
    return
  end
  
  -- Ensure it's a directory
  if not node.fs_stat or node.fs_stat.type ~= "directory" then
    vim.notify("Not a directory", vim.log.levels.ERROR)
    return
  end
  
  -- Create a list of available templates
  local template_names = {}
  for name, _ in pairs(project_templates) do
    table.insert(template_names, name)
  end
  
  -- Sort template names
  table.sort(template_names)
  
  -- Let the user select a template
  vim.ui.select(template_names, {
    prompt = "Select project file to create:",
    format_item = function(item) return item end,
  }, function(choice)
    if not choice then return end
    
    local template = project_templates[choice]
    local target_path = node.absolute_path .. "/" .. choice
    
    -- Check if file already exists
    local stat = vim.loop.fs_stat(target_path)
    if stat then
      vim.ui.select({"Yes", "No"}, {
        prompt = choice .. " already exists. Overwrite?",
      }, function(confirm)
        if confirm == "Yes" then
          M.write_project_file(target_path, template, choice)
        end
      end)
    else
      M.write_project_file(target_path, template, choice)
    end
  end)
end

-- Write a project file
function M.write_project_file(path, content, filename)
  -- Replace YEAR with current year in LICENSE file
  if filename == "LICENSE" then
    content = content:gsub("YEAR", os.date("%Y"))
    
    -- Prompt for author name
    vim.ui.input({
      prompt = "Enter author name for LICENSE:",
      default = vim.fn.system("git config user.name"):gsub("\n", "") or "Your Name",
    }, function(author)
      if author and author ~= "" then
        content = content:gsub("AUTHOR", author)
        M.do_write_file(path, content, filename)
      end
    end)
  else
    M.do_write_file(path, content, filename)
  end
end

-- Perform the actual file write
function M.do_write_file(path, content, filename)
  local file = io.open(path, "w")
  if not file then
    vim.notify("Failed to create " .. filename, vim.log.levels.ERROR)
    return
  end
  
  file:write(content)
  file:close()
  
  vim.notify("Created " .. filename, vim.log.levels.INFO)
  
  -- If nvim-tree API is available, refresh the tree
  local status_ok, api = pcall(require, "nvim-tree.api")
  if status_ok then
    api.tree.reload()
  end
end

-- Create a .gitignore file with predefined templates for common project types
function M.create_gitignore(node)
  if not node or not node.absolute_path then
    vim.notify("Invalid node", vim.log.levels.ERROR)
    return
  end
  
  -- Ensure it's a directory
  if not node.fs_stat or node.fs_stat.type ~= "directory" then
    vim.notify("Not a directory", vim.log.levels.ERROR)
    return
  end
  
  -- Templates for different project types
  local gitignore_templates = {
    ["Node.js"] = [[
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Dependency directories
node_modules/
jspm_packages/

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Output of 'npm pack'
*.tgz

# dotenv environment variables file
.env
.env.test

# Next.js build output
.next/

# Nuxt.js build / generate output
.nuxt/
dist/
]],
    ["Python"] = [[
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# Distribution / packaging
dist/
build/
*.egg-info/

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# Virtual environments
env/
venv/
ENV/
.env/
.venv/

# Jupyter Notebook
.ipynb_checkpoints
]],
    ["Go"] = [[
# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary, built with 'go test -c'
*.test

# Output of the go coverage tool
*.out

# Dependency directories
/vendor/
/go.sum
]],
    ["Rust"] = [[
# Generated by Cargo
/target/

# Remove Cargo.lock from gitignore if creating an executable
Cargo.lock

# These are backup files generated by rustfmt
**/*.rs.bk
]],
    ["Java"] = [[
# Compiled class file
*.class

# Log file
*.log

# BlueJ files
*.ctxt

# Package Files
*.jar
*.war
*.nar
*.ear
*.zip
*.tar.gz
*.rar

# virtual machine crash logs
hs_err_pid*

# Maven
target/
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties
dependency-reduced-pom.xml
]],
    ["C++"] = [[
# Prerequisites
*.d

# Compiled Object files
*.slo
*.lo
*.o
*.obj

# Precompiled Headers
*.gch
*.pch

# Compiled Dynamic libraries
*.so
*.dylib
*.dll

# Compiled Static libraries
*.lai
*.la
*.a
*.lib

# Executables
*.exe
*.out
*.app

# CMake
CMakeLists.txt.user
CMakeCache.txt
CMakeFiles
CMakeScripts
Testing
Makefile
cmake_install.cmake
install_manifest.txt
compile_commands.json
CTestTestfile.cmake
_deps
build/
]],
    ["Custom (Generic)"] = project_templates[".gitignore"],
  }
  
  -- Let the user select a project type
  local project_types = {}
  for type_name, _ in pairs(gitignore_templates) do
    table.insert(project_types, type_name)
  end
  
  vim.ui.select(project_types, {
    prompt = "Select project type for .gitignore:",
    format_item = function(item) return item end,
  }, function(choice)
    if not choice then return end
    
    local template = gitignore_templates[choice]
    local target_path = node.absolute_path .. "/.gitignore"
    
    -- Check if file already exists
    local stat = vim.loop.fs_stat(target_path)
    if stat then
      vim.ui.select({"Yes", "No"}, {
        prompt = ".gitignore already exists. Overwrite?",
      }, function(confirm)
        if confirm == "Yes" then
          M.do_write_file(target_path, template, ".gitignore")
        end
      end)
    else
      M.do_write_file(target_path, template, ".gitignore")
    end
  end)
end

-- Initialize a git repository
function M.init_git_repo(node)
  if not node or not node.absolute_path then
    vim.notify("Invalid node", vim.log.levels.ERROR)
    return
  end
  
  -- Ensure it's a directory
  if not node.fs_stat or node.fs_stat.type ~= "directory" then
    vim.notify("Not a directory", vim.log.levels.ERROR)
    return
  end
  
  -- Check if directory already has a .git folder
  local git_dir = node.absolute_path .. "/.git"
  local stat = vim.loop.fs_stat(git_dir)
  if stat and stat.type == "directory" then
    vim.notify("Git repository already exists", vim.log.levels.WARN)
    return
  end
  
  -- Initialize git repository
  local cmd = "cd " .. vim.fn.shellescape(node.absolute_path) .. " && git init"
  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify("Initialized git repository in " .. node.name, vim.log.levels.INFO)
        
        -- Ask if the user wants to create a .gitignore file
        vim.ui.select({"Yes", "No"}, {
          prompt = "Create a .gitignore file?",
        }, function(choice)
          if choice == "Yes" then
            M.create_gitignore(node)
          end
        end)
        
        -- If nvim-tree API is available, refresh the tree
        local status_ok, api = pcall(require, "nvim-tree.api")
        if status_ok then
          api.tree.reload()
        end
      else
        vim.notify("Failed to initialize git repository", vim.log.levels.ERROR)
      end
    end,
  })
end

-- Create a submenu for project operations
function M.create_project_submenu(node, is_folder)
  if not node then return nil end
  
  -- Project operations only apply to folders
  if not is_folder then return nil end
  
  local items = {
    { "Set as Project Root", function() M.set_as_project_root(node) end },
    { "Create Project File", function() M.create_project_file(node) end },
    { "Create .gitignore", function() M.create_gitignore(node) end },
  }
  
  -- Check if directory already has a .git folder
  local git_dir = node.absolute_path .. "/.git"
  local stat = vim.loop.fs_stat(git_dir)
  if not (stat and stat.type == "directory") then
    table.insert(items, { "Initialize Git Repository", function() M.init_git_repo(node) end })
  end
  
  return {
    title = "Project Operations",
    icon = "📋 ",
    items = items,
    item_icon = function(title)
      if string.match(title, "Root") then
        return "🏠 "
      elseif string.match(title, "Project File") then
        return "📄 "
      elseif string.match(title, "gitignore") then
        return "🙈 "
      elseif string.match(title, "Git") then
        return "🔄 "
      else
        return "📋 "
      end
    end
  }
end

return M 