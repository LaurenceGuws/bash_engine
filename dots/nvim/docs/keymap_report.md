# Neovim Keymap Reference

This document provides a comprehensive overview of all keymaps defined in the Neovim configuration.

## Table of Contents
- [Basic Navigation & Editing](#basic-navigation--editing)
- [Comment Functionality](#comment-functionality)
- [Movement & Selection](#movement--selection)
- [Buffer Management](#buffer-management)
- [LSP/Code Navigation](#lspcode-navigation)
- [Find/Search Operations](#findsearch-operations)
- [Diagnostics & Toggles](#diagnostics--toggles)
- [Git Operations](#git-operations)
- [Debug Operations](#debug-operations)
- [Database Operations](#database-operations)
- [UI & Window Management](#ui--window-management)
- [Markdown](#markdown)
- [File Explorer](#file-explorer)
- [Which-Key Specific](#which-key-specific)

## Basic Navigation & Editing

| Mode | Key Mapping | Action | Source |
|------|-------------|--------|--------|
| n | `;` | Enter Command Mode | keymaps.lua:6 |
| i | `jk` | Exit Insert Mode | keymaps.lua:7 |
| n,i,v | `<C-s>` | Save File | keymaps.lua:71 |
| n | `<C-a>` | Select All | keymaps.lua:74 |
| v | `<C-c>` | Copy | keymaps.lua:78 |
| n | `<C-v>` | Paste | keymaps.lua:82 |
| v | `<C-x>` | Cut | keymaps.lua:86 |
| n | `<C-z>` | Undo | keymaps.lua:90 |
| n | `<C-y>` | Redo | keymaps.lua:94 |
| n | `<C-f>` | Find in File | keymaps.lua:98 |
| n | `<C-p>` | Find Files | keymaps.lua:103 |
| i | `<C-Space>` | Toggle Completions | keymaps.lua:19 |

## Comment Functionality

| Mode | Key Mapping | Action | Source |
|------|-------------|--------|--------|
| n | `<C-_>` | Toggle Comment (line) | keymaps.lua:11 |
| n | `<C-/>` | Toggle Comment (line) | keymaps.lua:12 |
| v | `<C-_>` | Toggle Comment (visual) | keymaps.lua:13 |
| v | `<C-/>` | Toggle Comment (visual) | keymaps.lua:14 |
| i | `<C-_>` | Toggle Comment | keymaps.lua:15 |
| i | `<C-/>` | Toggle Comment | keymaps.lua:16 |
| n | `gc` | Toggle Comment | *Default in Comment.nvim (overlapping)* |
| n | `gcc` | Toggle Comment Line | *Default in Comment.nvim (overlapping)* |

## Movement & Selection

| Mode | Key Mapping | Action | Source |
|------|-------------|--------|--------|
| n | `<C-Right>`, `<C-l>` | Move to end of word | keymaps.lua:23,32 |
| n | `<C-Left>`, `<C-h>` | Move to beginning of word | keymaps.lua:24,33 |
| n | `<C-Up>`, `<C-k>` | Move up one paragraph | keymaps.lua:25,34 |
| n | `<C-Down>`, `<C-j>` | Move down one paragraph | keymaps.lua:26,35 |
| i | `<C-Right>`, `<C-l>` | Move to end of word | keymaps.lua:27,36 |
| i | `<C-Left>`, `<C-h>` | Move to beginning of word | keymaps.lua:28,37 |
| i | `<C-Up>`, `<C-k>` | Move up one paragraph | keymaps.lua:29,38 |
| i | `<C-Down>`, `<C-j>` | Move down one paragraph | keymaps.lua:30,39 |
| n | `<S-Right/Left/Up/Down>` | Selection keys | keymaps.lua:43-46 |
| i | `<S-Right/Left/Up/Down>` | Selection keys | keymaps.lua:47-50 |
| v | `<S-Right/Left/Up/Down>` | Extend selection | keymaps.lua:51-54 |
| n | `<C-S-Right>` | Select to end of word | keymaps.lua:58 |
| n | `<C-S-Left>` | Select to beginning of word | keymaps.lua:59 |
| i | `<C-S-Right>` | Select to end of word | keymaps.lua:60 |
| i | `<C-S-Left>` | Select to beginning of word | keymaps.lua:61 |
| v | `<C-S-Right>` | Extend selection to end of word | keymaps.lua:62 |
| v | `<C-S-Left>` | Extend selection to beginning of word | keymaps.lua:63 |

## Buffer Management

| Mode | Key Mapping | Action | Source |
|------|-------------|--------|--------|
| n | `<leader>bn` | Next Buffer | keymaps.lua:66, snacks.lua:185 |
| n | `<leader>bp` | Previous Buffer | keymaps.lua:67, snacks.lua:184 |
| n | `<leader>bd` | Close Buffer | keymaps.lua:68 |
| n | `<leader>bc` | Close Buffer | snacks.lua:211 |
| n | `<Tab>` | Next Buffer | snacks.lua:186 |
| n | `<S-Tab>` | Previous Buffer | snacks.lua:187 |
| n | `<leader>fb` | Find Buffers | keymaps.lua:275 |
| n | `<leader>fbb` | Buffer List | keymaps.lua:136 |
| n | `<leader>fbu` | Buffers | keymaps.lua:144 |
| n | `<leader>fbc` | Search Current Buffer | keymaps.lua:152 |

## LSP/Code Navigation

| Mode | Key Mapping | Action | Source |
|------|-------------|--------|--------|
| n | `K` | Hover | lspconfig.lua:105, mason.lua:166 |
| n | `gd` | Go to Definition | lspconfig.lua:100, mason.lua:167 |
| n | `gD` | Go to Declaration | lspconfig.lua:101 |
| n | `gr` | Go to References | lspconfig.lua:102, mason.lua:168 |
| n | `gi` | Go to Implementation | lspconfig.lua:103 |
| n | `gt` | Go to Type Definition | lspconfig.lua:104 |
| n | `<C-k>` | Signature Help | lspconfig.lua:106 |
| n | `<leader>rn` | Rename | lspconfig.lua:107 |
| n | `<leader>ca` | Code Action | lspconfig.lua:108 |
| n | `<leader>f` | Format | lspconfig.lua:109 |
| n | `<leader>ws` | Workspace Symbol | lspconfig.lua:110 |
| n | `[d` | Go to Previous Warning/Error | lspconfig.lua:113-119 |
| n | `]d` | Go to Next Warning/Error | lspconfig.lua:120-126 |
| n | `[e` | Go to Previous Error | lspconfig.lua:127-133 |
| n | `]e` | Go to Next Error | lspconfig.lua:134-140 |
| n | `<leader>q` | Set Location List | lspconfig.lua:141 |

## Find/Search Operations

| Mode | Key Mapping | Action | Source |
|------|-------------|--------|--------|
| n | `<leader>ff` | Find Files | keymaps.lua:108 |
| n | `<leader>fh` | Find Hidden Files | keymaps.lua:117 |
| n | `<leader>fr` | Find Recent Files | keymaps.lua:126 |
| n | `<leader>fg` | Find Git Files | keymaps.lua:268 |
| n | `<leader>fgf` | Find Git Files | keymaps.lua:170 |
| n | `<leader>fgg` | Live Grep | keymaps.lua:162 |
| n | `<leader>/` | Search Text | keymaps.lua:282 |

## Diagnostics & Toggles

| Mode | Key Mapping | Action | Source |
|------|-------------|--------|--------|
| n | `<leader>tt` | Toggle Trouble Panel | keymaps.lua:198, lspconfig.lua:142 |
| n | `<leader>td` | Toggle Document Diagnostics / Theme Debug Info | keymaps.lua:199,252, lspconfig.lua:143 |
| n | `<leader>tw` | Toggle Workspace Diagnostics | keymaps.lua:200, lspconfig.lua:144 |
| n | `<leader>tdi` | Toggle Inline Diagnostics | keymaps.lua:201-206 |
| n | `<leader>tds` | Toggle Diagnostic Signs | keymaps.lua:207-212 |
| n | `<leader>tdu` | Toggle Diagnostic Underlines | keymaps.lua:213-218 |
| n | `<leader>tf` | Format Current Buffer | keymaps.lua:219 |
| n | `<leader>tfs` | Toggle Format on Save | keymaps.lua:220 |
| n | `<leader>tdc` | Copy Buffer Diagnostics | keymaps.lua:223-225 |
| n | `<leader>tdp` | Project Error List | keymaps.lua:226-228 |
| n | `<leader>tda` | Aggressive Project Lint | keymaps.lua:229-231 |
| n | `<leader>tc` | Theme Picker | keymaps.lua:234-251 |
| n | `<leader>tn` | Toggle Notification Log | keymaps.lua:184 |

## Git Operations

| Mode | Key Mapping | Action | Source |
|------|-------------|--------|--------|
| n | `<leader>tgb` | Git Blame Toggle | git.lua:236 |
| n | `<leader>tgc` | Git Changes Toggle | git.lua:260 |
| n | `<leader>tgw` | Git Worktree Toggle | git.lua:276 |
| n | `<leader>tgl` | Git Log Toggle | git.lua:292 |
| n | `<leader>tgn` | Git Number Toggle | git.lua:308 |
| n | `<leader>tgd` | Git Diff Toggle | git.lua:325 |

## Debug Operations

| Mode | Key Mapping | Action | Source |
|------|-------------|--------|--------|
| n | `<leader>db` | Toggle Breakpoint | dap_config.lua:101 |
| n | `<leader>dB` | Set Breakpoint with Condition | dap_config.lua:102-104 |
| n | `<leader>dl` | Step Into | dap_config.lua:105 |
| n | `<leader>dj` | Step Over | dap_config.lua:106 |
| n | `<leader>dk` | Step Out | dap_config.lua:107 |
| n | `<leader>dc` | Continue | dap_config.lua:108 |
| n | `<leader>dr` | Open REPL | dap_config.lua:109 |
| n | `<leader>du` | Toggle UI | dap_config.lua:110 |

## Database Operations

| Mode | Key Mapping | Action | Source |
|------|-------------|--------|--------|
| n | `<leader>dt` | Toggle Database UI | keymaps.lua:187 |
| n | `<leader>du` | Open Database UI | keymaps.lua:188 |
| n | `<leader>da` | Add New Database Connection | keymaps.lua:189-194 |
| n | `<leader>df` | Find Database Buffer | keymaps.lua:195 |

## UI & Window Management

| Mode | Key Mapping | Action | Source |
|------|-------------|--------|--------|
| n | `q` | Close window (special buffers) | autocmds.lua:50, lsp_utils.lua:650, ansi.lua:107 |
| n | `<Esc>` | Close window (special buffers) | lsp_utils.lua:651 |
| n | `<leader>ta` | ANSI Terminal | ansi.lua:58 |

## Markdown

| Mode | Key Mapping | Action | Source |
|------|-------------|--------|--------|
| n | `<leader>md` | Toggle Markdown Rendering | keymaps.lua:180 |
| n | `<leader>mr` | Render Markdown | keymaps.lua:181 |

## File Explorer

| Mode | Key Mapping | Action | Source |
|------|-------------|--------|--------|
| n | `<leader>e` | Toggle File Explorer | keymaps.lua:257-260 |

## Which-Key Specific

| Mode | Key Mapping | Action | Source |
|------|-------------|--------|--------|
| n | `<leader>?` | Buffer Local Keymaps (which-key) | which_key.lua:112-114 |
| n | `<leader>W` | Window Commands (Hydra) | which_key.lua:117-122 |

## Overlapping Keymaps

The following keymaps have been identified as overlapping by which-key health check:

1. `gc` overlaps with `gcc` (Comment plugin defaults)
2. `<Space>td` overlaps with `<Space>tdp`, `<Space>tds`, etc. (diagnostics & theme debug)
3. `<Space>tf` overlaps with `<Space>tfs` (format commands)
4. `<Space>fb` overlaps with `<Space>fbu`, `<Space>fbc`, `<Space>fbb` (buffer commands)
5. `<Space>fg` overlaps with `<Space>fgf`, `<Space>fgg` (git/grep commands) 