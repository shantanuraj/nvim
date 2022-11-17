require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "astro", "bash", "c", "cpp", "css", "dockerfile", "gitignore", "go", "gomod", "html", "http", "java", "javascript", "jsdoc", "json", "json5", "jsonc", "kotlin", "latex", "make", "markdown", "markdown_inline", "python", "regex", "ruby", "rust", "sql", "scss", "svelte", "toml", "tsx", "typescript", "vim", "vue", "yaml" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,
}

