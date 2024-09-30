### Install Neovim

Kickstart.nvim targets *only* the latest
['stable'](https://github.com/neovim/neovim/releases/tag/stable) and latest
['nightly'](https://github.com/neovim/neovim/releases/tag/nightly) of Neovim.
If you are experiencing issues, please make sure you have the latest versions.

### Install External Dependencies

External Requirements:
- Basic utils: `git`, `make`, `unzip`, C Compiler (`gcc`)
- Extra dependencies: zig, node js for pyright, python,cmake, microsoft build tools
- Clipboard tool (xclip/xsel/win32yank or other depending on platform)
- Jetbrains mono nerdfont

#### Clone kickstart.nvim

<details><summary> Windows </summary>

If you're using `cmd.exe`:

```
git clone https://github.com/jvpanda/kickstart.nvim.git "%localappdata%\nvim"
```

If you're using `powershell.exe`

```
git clone https://github.com/jvpanda/kickstart.nvim.git "${env:LOCALAPPDATA}\nvim"
```

</details>

### FAQ

* What if I want to "uninstall" this configuration:
  * See [lazy.nvim uninstall](https://github.com/folke/lazy.nvim#-uninstalling) information
	* May need to run a fancy looking command if my fzm is giving me problemos

