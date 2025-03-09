# Wofi - Configuration and Styling Guide

## Introduction

Wofi's configuration format is simple, using key-value pairs in snake case. Most config options match command line options, with a few additional options only accessible via wofi's config file.

Mode-specific options for built-in modes use the format `mode-example_opt=val`. For example, dmenu has an option called `parse_action` which would be placed in the config as `dmenu-parse_action=true`.

Comments begin with `#`. To include a literal `#` character, escape it with a backslash (`\#`). To include a backslash, escape it as well (`\\`).

## Configuration Options

Most options match the command flags found in wofi(1) using snake_case format. Some are unique to the config file.

| Option | Description |
|--------|-------------|
| `style=PATH` | Specifies the CSS file to use as the stylesheet. |
| `stylesheet=PATH` | CSS file path (relative to `$XDG_CONFIG_HOME/wofi`, not current working directory). |
| `color=PATH` | Specifies the colors file to use. |
| `colors=PATH` | Colors file path (relative to `$XDG_CONFIG_HOME/wofi`, not current working directory). |
| `show=MODE` | Specifies the mode to run in. |
| `mode=MODE` | Identical to `show`. |
| `width=WIDTH` | Menu width in pixels or percent (default: 50%). Use % suffix for percent. |
| `height=HEIGHT` | Menu height in pixels or percent (default: 40%). Use % suffix for percent. |
| `prompt=PROMPT` | Sets the prompt in the search box (default: name of the mode). |
| `xoffset=OFFSET` | Sets the x offset from the location in pixels (default: 0). |
| `x=OFFSET` | Identical to `xoffset`. |
| `yoffset=OFFSET` | Sets the y offset from the location in pixels (default: 0). |
| `y=OFFSET` | Identical to `yoffset`. |
| `normal_window=BOOL` | If true, runs wofi in a normal window instead of using wlr-layer-shell (default: false). |
| `allow_images=BOOL` | If true, allows image escape sequences to be processed and rendered (default: false). |
| `allow_markup=BOOL` | If true, allows pango markup to be processed and rendered (default: false). |
| `cache_file=PATH` | Cache file location (default: `$XDG_CACHE_HOME/wofi-<mode name>` or `~/.cache/wofi-<mode name>`). |
| `term=TERM` | Terminal to use when running a program in a terminal. |
| `password=CHARACTER` | Runs wofi in password mode using the specified character. |
| `exec_search=BOOL` | If true, activating a search with enter executes the search, not the first result (default: false). |
| `hide_scroll=BOOL` | If true, hides scroll bars (default: false). |
| `matching=MODE` | Matching mode: `contains` or `fuzzy` (default: `contains`). |
| `insensitive=BOOL` | If true, enables case insensitive search (default: false). |
| `parse_search=BOOL` | If true, parses out image escapes and pango for searching (default: false). |
| `location=LOCATION` | Specifies the location (default: center). |
| `no_actions=BOOL` | If true, disables multiple actions for modes that support it (default: false). |
| `lines=LINES` | Specifies the height in number of lines instead of pixels. |
| `columns=COLUMNS` | Number of columns to display (default: 1). |
| `sort_order=ORDER` | Default sort order: `default` or `alphabetical`. |
| `gtk_dark=BOOL` | If true, uses the dark variant of the current GTK theme (default: false). |
| `search=STRING` | Specifies something to search for immediately on opening. |
| `monitor=STRING` | Sets the monitor to open on. |
| `orientation=ORIENTATION` | Orientation: `horizontal` or `vertical` (default: `vertical`). |
| `halign=ALIGN` | Horizontal alignment for the scrolled area: `fill`, `start`, `end`, or `center` (default: `fill`). |
| `content_halign=ALIGN` | Horizontal alignment for individual entries: `fill`, `start`, `end`, or `center` (default: `fill`). |
| `valign=ALIGN` | Vertical alignment for the scrolled area. Defaults depend on orientation. |
| `filter_rate=RATE` | Rate at which search results are updated in milliseconds (default: 100). |
| `image_size=SIZE` | Size of images in pixels when images are enabled (default: 32). |

### Keyboard Configuration

| Option | Description | Default |
|--------|-------------|---------|
| `key_up=KEY` | Key to move up | Up arrow |
| `key_down=KEY` | Key to move down | Down arrow |
| `key_left=KEY` | Key to move left | Left arrow |
| `key_right=KEY` | Key to move right | Right arrow |
| `key_forward=KEY` | Key to move forward | Tab |
| `key_backward=KEY` | Key to move backward | Shift+Tab |
| `key_submit=KEY` | Key to submit an action | Return |
| `key_exit=KEY` | Key to exit wofi | Escape |
| `key_pgup=KEY` | Key to move one page up | Page_Up |
| `key_pgdn=KEY` | Key to move one page down | Page_Down |
| `key_expand=KEY` | Key to expand/contract multi-action entries | None |
| `key_hide_search=KEY` | Key to hide/show the search bar | None |

### Additional Settings

| Option | Description | Default |
|--------|-------------|---------|
| `line_wrap=MODE` | Line wrap mode: `off`, `word`, `char`, or `word_char` | `off` |
| `global_coords=BOOL` | Use global compositor space for x/y offsets | `false` |
| `hide_search=BOOL` | Hide the search bar | `false` |
| `dynamic_lines=BOOL` | Dynamically shrink to fit visible lines | `false` |
| `layer=LAYER` | Layer to open on: `background`, `bottom`, `top`, or `overlay` | `top` |

## CSS Selectors

Any GTK widget can be selected using its CSS node name. Wofi provides certain widgets with names and classes for easy styling.

| Selector | Description |
|----------|-------------|
| `#window` | The window itself |
| `#outer-box` | Box containing everything |
| `#input` | The search bar |
| `#scroll` | Scrolled window containing entries |
| `#inner-box` | Box containing all entries |
| `#img` | All images in entries displayed in image mode |
| `#text` | All text in entries |
| `#unselected` | All entries currently unselected (prefer `#entry` instead) |
| `#selected` | All entries currently selected (prefer `#entry:selected` instead) |
| `.entry` | Class attached to all entries (prefer `#entry` instead) |
| `#entry` | All entries |

## Colors

The colors file should contain new-line separated hex values in standard HTML format (starting with `#`).

Reference colors in CSS with:
- `--wofi-color<n>` where `<n>` is the line number minus 1 (returns format: `#FFFFFF`)
- `--wofi-rgb-color<n>` where `<n>` is the line number minus 1 (returns format: `255, 255, 255`)

Example usage with rgba:
```css
background-color: rgba(--wofi-rgb-color0, 0.8);
```

This would set the background color to the first color in your colors file with 80% opacity. 