
# vim-tmux-clipboard

Things get nasty when I need to copy lines of text from vim into tmux's
clipboard, especially when multiple split-windows are opened. So I created this
super simple plugin, which provides seemless integration for vim and tmux's
clipboard.


vim-tmux-clipboard automatically copy yanked text into tmux's clipboard, and
copy tmux's clipboard content into vim's quote(`"`) register, known as unnamed
register. It also make multiple vim processes on top of the same tmux session
act like they're sharing the same clipboard.


## Requirements

- neovim. This is due to vim dosen't support the `TextYankPost` event.
- [tmux-plugins/vim-tmux-focus-events](https://github.com/tmux-plugins/vim-tmux-focus-events)

