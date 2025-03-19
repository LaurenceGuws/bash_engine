# NvimTree Context Menu Modules

This directory contains modular components for the NvimTree context menu system. Each module focuses on a specific type of functionality.

## Context Menu Structure

The context menu system uses the following files:

- `context_menu.lua` - Main entry point that directly imports the modules
- `basic_menu.lua` - Contains basic menu operations
- `modules/` - Contains specialized functionality modules

## Available Modules

### Copy Operations (`copy_operations.lua`)

Functionality for copying various forms of file paths and names:

- `copy_name_only(node)`: Copies just the filename without extension
- `copy_extension_only(node)`: Copies just the file extension
- `copy_relative_path(node)`: Copies the path relative to current working directory
- `copy_absolute_path(node)`: Copies the full absolute path
- `copy_directory_path(node)`: Copies the directory containing the file
- `create_copy_submenu(node, is_folder)`: Creates a complete submenu for all copy operations

### File Operations (`file_operations.lua`)

File-related operations including creation and external app handling:

- `create_file_with_template(node, is_folder, api, fzf_lua)`: Create files from templates
- `create_symlink(node, api)`: Create a symlink to the current file/folder
- `open_with_app(node, fzf_lua)`: Open files with external applications
- `create_file_operations_menu(node, is_folder, api, fzf_lua)`: Creates a complete submenu for file operations

### Git Operations (`git_operations.lua`)

Git-related functionality for repositories and files:

- `git_diff_file(node, cwd)`: Shows diff for current file
- `git_log_file(node, fzf_lua, cwd)`: Shows git log for current file
- `git_blame_file(node, fzf_lua, cwd)`: Shows git blame for current file
- `git_stashes(node, is_folder, fzf_lua, cwd)`: Shows git stashes
- `git_unpushed_commits(node, is_folder, cwd)`: Shows unpushed commits
- `git_status(node, is_folder, fzf_lua, cwd)`: Shows git status for repository
- `git_branches(node, is_folder, fzf_lua, cwd)`: Shows git branches
- `create_git_submenu(node, is_folder, is_git_repo, fzf_lua)`: Creates a complete submenu for git operations

### Search Operations (`search_operations.lua`)

Advanced search functionality for files and content:

- `find_files(node, is_folder, fzf_lua)`: Find files in directory
- `live_grep(node, is_folder, fzf_lua)`: Search file content
- `grep_word(node, is_folder, fzf_lua)`: Search for specific word
- `find_by_extension(node, is_folder, fzf_lua)`: Find files by extension
- `find_recent_files(node, is_folder, fzf_lua)`: Find recently modified files
- `create_search_submenu(node, is_folder, fzf_lua)`: Creates a complete submenu for search operations

### Archive Operations (`archive_operations.lua`)

Functionality for working with zip, tar, and other archive formats:

- `check_tools()`: Checks if necessary archive tools are available
- `extract_archive(node, api)`: Extracts an archive to a directory
- `create_zip_archive(node, is_folder, api)`: Creates a new zip archive
- `create_archive_submenu(node, is_folder, api)`: Creates a complete submenu for archive operations

### Bookmark Operations (`bookmark_operations.lua`)

Functionality for bookmarking files and directories:

- `load_bookmarks()`: Loads bookmarks from JSON file
- `save_bookmarks(bookmarks)`: Saves bookmarks to JSON file
- `add_bookmark(node)`: Adds current node to bookmarks
- `remove_bookmark(node)`: Removes a bookmark
- `goto_bookmark(bookmark, api)`: Opens a bookmarked file/directory
- `show_bookmarks(api, fzf_lua)`: Shows all bookmarks with FZF
- `create_bookmark_submenu(node, api, fzf_lua)`: Creates a complete submenu for bookmark operations

### Filesystem Operations (`filesystem_operations.lua`)

Advanced filesystem operations for files and directories:

- `show_file_details(node)`: Shows detailed file information
- `calculate_directory_size(node)`: Calculates size of a directory recursively
- `change_permissions(node)`: Changes file permissions
- `change_owner(node)`: Changes file ownership
- `find_duplicates(node, is_folder)`: Finds duplicate files in directory
- `find_large_files(node, is_folder)`: Finds large files in directory
- `create_filesystem_submenu(node, is_folder)`: Creates a complete submenu for filesystem operations

### External Application Operations (`external_app_operations.lua`)

Functionality for integrating with external applications:

- `open_in_file_manager(node)`: Opens the file/directory in file manager
- `open_terminal_here(node)`: Opens terminal in the directory
- `open_with_default_app(node)`: Opens file with default application
- `open_with_specific_app(node)`: Opens file with a specific application
- `view_in_pager(node)`: Views file content in a pager (less/more)
- `create_external_app_submenu(node, is_folder)`: Creates a complete submenu for external application operations

### Project Operations (`project_operations.lua`)

Project management functionality:

- `set_as_project_root(node)`: Sets a directory as the project root
- `create_project_file(node)`: Creates a common project file from template
- `create_gitignore(node)`: Creates a .gitignore file with templates for various project types
- `init_git_repo(node)`: Initializes a git repository
- `create_project_submenu(node, is_folder)`: Creates a complete submenu for project operations

### Filter Operations (`filter_operations.lua`)

Visually enhanced and colorful filtering of files and folders in the explorer:

- **Key Features**:
  - Color-coded status indicators for active/inactive filters
  - Themed icons for all filter operations
  - Attractive floating window for filter status display
  - Visual feedback on filter actions
  - Filter counts and status displayed in the menu

- **Functions**:
  - `active_filters`: Stores current filter settings with visual tracking
  - `filter_presets`: Stores saved filter configurations
  - `toggle_dotfiles()`: Toggle visibility of dotfiles with color status indicators
  - `toggle_gitignored()`: Toggle visibility of Git ignored files with visual feedback
  - `filter_by_extension()`: Add file extension to filter list with highlighted input
  - `remove_extension_filter()`: Remove extension from filter list with colorized selection
  - `filter_by_pattern()`: Add pattern to filter list with themed prompts
  - `remove_pattern_filter()`: Remove pattern from filter list with visual selection
  - `save_filter_preset()`: Save current filters as a named preset with confirmation
  - `load_filter_preset()`: Load a saved filter preset with highlighted options
  - `delete_filter_preset()`: Delete a saved filter preset with visual confirmation
  - `show_active_filters()`: Display currently active filters in a stylized floating window
  - `reset_filters()`: Clear all active filters with visual feedback
  - `create_filter_submenu(node)`: Creates a complete colorful submenu for filter operations

## Module Structure

Each module follows a consistent pattern:
- Individual functions for specific operations
- A `create_X_submenu` function that returns a formatted menu for FZF-Lua

## Example Usage

```lua
-- Import a module
local copy_operations = require("plugins.ui.exp.menus.modules.copy_operations")

-- Use a specific function
copy_operations.copy_absolute_path(node)

-- Create a submenu for advanced operations
local copy_submenu = copy_operations.create_copy_submenu(node, is_folder)
```

## Adding New Modules

To add a new module:

1. Create a new `.lua` file in this directory
2. Follow the module pattern with individual functions and a submenu creator
3. Import it in the context_menu.lua file
4. Add it to the advanced categories section 