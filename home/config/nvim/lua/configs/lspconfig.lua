local capabilities = require("cmp_nvim_lsp").default_capabilities()

local on_attach = function(client)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

local border = "rounded"

vim.diagnostic.config {
  virtual_text = {
    source = "if_many",
    spacing = 2,
    prefix = "●",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = border,
    source = "if_many",
  },
}

vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
  config = vim.tbl_deep_extend("force", config or {}, { border = border })
  return vim.lsp.handlers.hover(err, result, ctx, config)
end

vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
  config = vim.tbl_deep_extend("force", config or {}, { border = border })
  return vim.lsp.handlers.signature_help(err, result, ctx, config)
end

local servers = {
  html = {},
  cssls = {},
  gopls = {},
  rust_analyzer = {},
  pyright = {},
  zls = {
    cmd = {
      -- TODO fix
      "/home/kaki/Documents/custom_zls/zls",
    },
    enable_build_on_save = true,
    build_on_save_step = "check",
  },
  clangd = {
    cmd = {
      "clangd",
      "--background-index",
      "--compile-commands-dir=build",
      "--query-driver=/etc/profiles/per-user/kaarlo/bin/clang",
    },
    filetypes = { "c", "cpp", "h", "hpp" },
  },
  lua_ls = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".git" },
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        diagnostics = {
          globals = {
            "vim",
          },
        },
      },
    },
  },
  nil_ls = {
    cmd = { "nil" },
    filetypes = { "nix" },
  },
  tsserver = {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    root_dir = vim.fs.root(0, { "package.json", ".git" }),
  },
  qmlls = {
    cmd = { "qmlls", "-E" },
    filetypes = { "qml" },
  },
}

for name, opts in pairs(servers) do
  opts.capabilities = capabilities
  opts.on_attach = on_attach
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end
