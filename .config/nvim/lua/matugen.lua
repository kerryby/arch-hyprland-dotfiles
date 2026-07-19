 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#131314',
    base01 = '#1f2021',
    base02 = '#292a2b',
    base03 = '#8d9195',
    base04 = '#c3c7cb',
    base05 = '#e4e2e3',
    base06 = '#e4e2e3',
    base07 = '#e4e2e3',
    base08 = '#ffb4ab',
    base09 = '#d4c0d7',
    base0A = '#c1c7ce',
    base0B = '#b6c9d8',
    base0C = '#d4c0d7',
    base0D = '#b6c9d8',
    base0E = '#c1c7ce',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e4e2e3',          bg = '#131314' })
  hi('TelescopeBorder',         { fg = '#8d9195',             bg = '#131314' })
  hi('TelescopePromptNormal',   { fg = '#e4e2e3',          bg = '#131314' })
  hi('TelescopePromptBorder',   { fg = '#8d9195',             bg = '#131314' })
  hi('TelescopePromptPrefix',   { fg = '#b6c9d8',             bg = '#131314' })
  hi('TelescopePromptCounter',  { fg = '#c3c7cb',  bg = '#131314' })
  hi('TelescopePromptTitle',    { fg = '#131314',             bg = '#b6c9d8' })
  hi('TelescopePreviewTitle',   { fg = '#131314',             bg = '#c1c7ce' })
  hi('TelescopeResultsTitle',   { fg = '#131314',             bg = '#d4c0d7' })
  hi('TelescopeSelection',      { fg = '#e4e2e3',          bg = '#292a2b' })
  hi('TelescopeSelectionCaret', { fg = '#b6c9d8',             bg = '#292a2b' })
  hi('TelescopeMatching',       { fg = '#b6c9d8',             bold = true })
end

 -- Register a signal handler for SIGUSR1 (matugen updates)
 local signal = vim.uv.new_signal()
 signal:start(
   'sigusr1',
   vim.schedule_wrap(function()
     package.loaded['matugen'] = nil
     require('matugen').setup()
   end)
 )

 return M
