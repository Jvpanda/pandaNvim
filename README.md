# PandaNvim Guide

### Install Neovim
Install ['stable'](https://github.com/neovim/neovim/releases/tag/stable) and latest
['nightly'](https://github.com/neovim/neovim/releases/tag/nightly) of Neovim.
If you are experiencing issues, please make sure you have the latest versions.

### Install External Dependencies

#### External Requirements:
- `git`, `tar or unzip`, `curl`, rg (`ripgrep`), C Compiler (`clang, cl, gcc, or zig`)


#
Optional Requirements:
- Clipboard tool (xclip/xsel/win32yank or other depending on platform)
- Nerdfont, I prefer Jetbrains mono
- if on windows `cmake`, otherwise `make`
- cmake or make is only used for telescope fzf, but it is highly reccomended

#
### Existing Language Configuration Support
- This only supports the given lsps
- Do note that most of these can be downloaded and set to the local neovim environment with :PandaInstall package name
- Then just restart neovim

    <details><summary> Arduino </summary>
        <ul>
        <li> Download arduino CLI and Language Server </li>
        <li>Ensure they are on PATH </li>
        <li>To finish this installation, you need to install boards and packages necessary
            <br>Also note that the environment variable is set only within neovim
            <br>Commands to set up the initial environment:
            <br>arduino-cli config init
            <br>arduino-cli core update-index
            <br>arduino-cli core install arduino:avr:uno/Or any other
            <br>arduino-cli lib install "Library Name"</li>
        </ul>
    </details>

    <details><summary> CPP </summary>
        <ul>
        <li> Download Cmake, clangd, raddbg, and MSVC </li>
        <li> Ensure they are on PATH </li>
        </ul>
    </details>

    <details><summary> Gdscript </summary>
        <ul>
        <li> Godot must be open to use lsp</li>
        <li> Set "Use External Editor" to "On" and turn on advanced properties</li>
        <li> Set "Exec Path" to nvim</li>
        <li> Set "Exec Flags" to --server 127.0.0.1:6004 --remote-send "&ltC-\&gt&ltC-N&gt:n {file}&ltCR&gt{line}G{col}|"</li>
        </ul>
    </details>

    <details><summary> Go </summary>
        <ul>
        <li> Download Go and Gopls </li>
        <li> Ensure they are on PATH </li>
        </ul>
    </details>

    <details><summary> Lua </summary>
        <ul>
        <li> Download lua language server and stylua </li>
        <li> Ensure they are on PATH </li>
        </ul>
    </details>

    <details><summary> Python </summary>
        <ul>
        <li> Download pyright </li>
        <li> Note that pyright uses node js as a dependency </li>
        <li> Ideally this would be done a py environment with the PATH variable pointing to the scripts executables </li>
        </ul>
    </details>

</details>

#### Cloning this config

<details><summary> Linux and Mac Clone Location </summary>

```sh
"${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

</details>

<details><summary> Windows Config Location </summary>

```
"%localappdata%\nvim"
```

</details>
