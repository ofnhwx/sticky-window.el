# sticky-window.el

Emacs package for managing "sticky" (fixed) windows that persist across window operations.

## Features

- **Persistent Windows**: Sticky windows are preserved when using `delete-other-windows` (C-x 1)
- **Protected Layout**: Prevents deletion of the last non-sticky window
- **Auto-resize**: Sticky windows automatically maintain their size when the frame changes
- **Flexible Positioning**: Create sticky windows on any side (left, right, top, bottom)
- **Dedicated Windows**: Sticky windows are dedicated to their buffers

## Installation

### Manual Installation

1. Clone this repository or download `sticky-window.el`
2. Add to your Emacs configuration:

```elisp
(add-to-list 'load-path "/path/to/sticky-window")
(require 'sticky-window)
```

### Using straight.el

```elisp
(straight-use-package
 '(sticky-window :type git :host github :repo "ofnhwx/sticky-window"))
```

## Usage

### Enable the mode

```elisp
(sticky-window-mode 1)
```

### Create a sticky window

```elisp
;; Create a sticky window on the left with default size (30% of frame width)
(sticky-window-create "*Buffer Name*" 'left)

;; Create a sticky window on the right with 40% width
(sticky-window-create "*Buffer Name*" 'right 0.4)

;; Create a sticky window at the bottom with 200 pixels height
(sticky-window-create "*Buffer Name*" 'bottom 200)
```

### Example configurations

```elisp
;; Create a sticky file tree on the left
(sticky-window-create (dired-noselect "~/") 'left 0.25)

;; Create a sticky terminal at the bottom
(sticky-window-create "*eshell*" 'bottom 0.3)

;; Create a sticky compilation buffer on the right
(sticky-window-create "*compilation*" 'right 0.35)
```

## Configuration

### Customize default size

```elisp
(setq sticky-window-default-size 0.25)  ; Default to 25% of frame size
```

You can also customize through `M-x customize-group RET sticky-window RET`.

## API

### Functions

- `sticky-window-create (buffer side &optional size)` - Create a sticky window
  - `buffer`: Buffer to display
  - `side`: Position ('left, 'right, 'top, 'bottom)
  - `size`: Optional size (0.0-1.0 for ratio, >1.0 for pixels)

- `sticky-window-p (window)` - Check if a window is sticky

- `sticky-window-list` - Get list of all sticky windows

- `sticky-window-mode` - Global minor mode to enable sticky window functionality

## How it works

Sticky windows are implemented using:
- Window parameters to mark windows as sticky
- Advice on `delete-other-windows` and `delete-window` to preserve sticky windows
- Window size change hooks to maintain window sizes
- Side windows for predictable placement

## Requirements

- Emacs 28.1 or later

## License

GPL-3.0-or-later

## Author

ofnhwx

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ofnhwx/sticky-window.
