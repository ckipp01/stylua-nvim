# stylua-nvim

stylua-nvim is a minimal wrapper around the Lua code formatter,
[StyLua](https://github.com/JohnnyMorganz/StyLua). It does pretty much what
you'd expect it to do, format your Lua file using Stylua.

### Install
Make sure you have StyLua installed and then install this plugin:

```lua
use({"ckipp01/stylua-nvim"})
```

If you would like your plugin manager to automatically download Stylua for you, run the Stylua install command using your plugin managers hooks. For example in Packer, you can use the following:

```lua
use({"ckipp01/stylua-nvim", run = "cargo install stylua"})
```

### Docs

Everything you need should be in the [help
docs](https://github.com/ckipp01/stylua-nvim/blob/main/doc/stylua-nvim.txt).
