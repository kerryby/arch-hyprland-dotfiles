 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#16130f',
    base01 = '#231f1b',
    base02 = '#2e2925',
    base03 = '#9c8e82',
    base04 = '#d3c4b6',
    base05 = '#eae1db',
    base06 = '#eae1db',
    base07 = '#eae1db',
    base08 = '#ffb4ab',
    base09 = '#c5cb90',
    base0A = '#dcc2a9',
    base0B = '#eebe8a',
    base0C = '#c5cb90',
    base0D = '#eebe8a',
    base0E = '#dcc2a9',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#eae1db',          bg = '#16130f' })
  hi('TelescopeBorder',         { fg = '#9c8e82',             bg = '#16130f' })
  hi('TelescopePromptNormal',   { fg = '#eae1db',          bg = '#16130f' })
  hi('TelescopePromptBorder',   { fg = '#9c8e82',             bg = '#16130f' })
  hi('TelescopePromptPrefix',   { fg = '#eebe8a',             bg = '#16130f' })
  hi('TelescopePromptCounter',  { fg = '#d3c4b6',  bg = '#16130f' })
  hi('TelescopePromptTitle',    { fg = '#16130f',             bg = '#eebe8a' })
  hi('TelescopePreviewTitle',   { fg = '#16130f',             bg = '#dcc2a9' })
  hi('TelescopeResultsTitle',   { fg = '#16130f',             bg = '#c5cb90' })
  hi('TelescopeSelection',      { fg = '#eae1db',          bg = '#2e2925' })
  hi('TelescopeSelectionCaret', { fg = '#eebe8a',             bg = '#2e2925' })
  hi('TelescopeMatching',       { fg = '#eebe8a',             bold = true })
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
