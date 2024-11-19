### Install Neovim

Kickstart.nvim targets *only* the latest
['stable'](https://github.com/neovim/neovim/releases/tag/stable) and latest
['nightly'](https://github.com/neovim/neovim/releases/tag/nightly) of Neovim.
If you are experiencing issues, please make sure you have the latest versions.

### Install External Dependencies

External Requirements:
- Basic utils: `git`, `make`, `unzip`, C Compiler (`gcc`), `zig`
- Extra optional dependencies: node js for pyright, python,cmake
- Clipboard tool (xclip/xsel/win32yank or other depending on platform)
- Jetbrains mono nerdfont

#### Clone kickstart.nvim

<details><summary> Linux and Mac </summary>

```sh
git clone https://github.com/jvpanda/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

</details>

<details><summary> Windows </summary>

If you're using `cmd.exe`:

```
git clone https://github.com/jvpanda/kickstart.nvim.git "%localappdata%\nvim"
```

</details>

#### Linux Install Recipe
<details><summary>Ubuntu Install Steps</summary>

```
sudo apt update
sudo apt install make gcc ripgrep unzip git xclip neovim curl cmake python3 nodejs
sudo snap install zig --classic --beta
only needed if there's a new computer that only utilized Linux
wget https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip
Then lookup the rest.
```

</details>
