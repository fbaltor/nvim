-- Sync nvim's colorscheme to Ghostty's active terminal theme.
-- `ghostty-theme resolve` is the single source of truth: it prints the effective
-- theme as "<name>\t<theme-file>" (the override if one is set, else the base
-- config's light/dark default for the current GNOME mode). This module maps
-- <name> to a matching nvim colorscheme, or — for an unmapped theme — builds a
-- look straight from the theme file's 16 ANSI colors. Re-syncs live via a file
-- watch on the override file.
local uv = vim.uv or vim.loop

local M = {}

local CONFIG_DIR = vim.fn.expand '~/.config/ghostty'
local OVERRIDE_FILE = CONFIG_DIR .. '/current-theme.conf'

-- Ghostty theme name -> matching nvim colorscheme. `bg` sets vim.o.background;
-- `pre` runs before :colorscheme (for schemes configured via globals).
local MAP = {
  ['Catppuccin Latte'] = { scheme = 'catppuccin-latte', bg = 'light' },
  ['Catppuccin Frappe'] = { scheme = 'catppuccin-frappe', bg = 'dark' },
  ['Catppuccin Mocha'] = { scheme = 'catppuccin-mocha', bg = 'dark' },
  ['Gruvbox Light'] = { scheme = 'gruvbox', bg = 'light' },
  ['Gruvbox Dark'] = { scheme = 'gruvbox', bg = 'dark' },
  ['Everforest Light Med'] = { scheme = 'everforest', bg = 'light', pre = function() vim.g.everforest_background = 'medium' end },
  ['Everforest Dark Hard'] = { scheme = 'everforest', bg = 'dark', pre = function() vim.g.everforest_background = 'hard' end },
  ['Rose Pine Dawn'] = { scheme = 'rose-pine-dawn', bg = 'light' },
  ['Rose Pine'] = { scheme = 'rose-pine-main', bg = 'dark' },
  ['Rose Pine Moon'] = { scheme = 'rose-pine-moon', bg = 'dark' },
  ['GitHub Light Default'] = { scheme = 'github_light_default', bg = 'light' },
  ['GitHub Dark'] = { scheme = 'github_dark_default', bg = 'dark' },
  ['iTerm2 Solarized Light'] = { scheme = 'solarized', bg = 'light' },
  ['iTerm2 Solarized Dark'] = { scheme = 'solarized', bg = 'dark' },
  ['Dracula'] = { scheme = 'dracula', bg = 'dark' },
  ['TokyoNight Storm'] = { scheme = 'tokyonight-storm', bg = 'dark' },
  ['Kanagawa Wave'] = { scheme = 'kanagawa-wave', bg = 'dark' },
  ['Nord'] = { scheme = 'nord', bg = 'dark' },
}

local function trim(s)
  return (s:gsub('^%s*(.-)%s*$', '%1'))
end

-- Crude themed look built from a Ghostty theme file's 16 ANSI colors + bg/fg.
-- Used for any Ghostty theme without a mapped nvim colorscheme. `path` is the
-- theme file resolved by `ghostty-theme resolve`.
local function palette_fallback(path)
  if not (path and path ~= '' and vim.fn.filereadable(path) == 1) then
    return
  end
  local pal, bg, fg = {}, nil, nil
  for _, line in ipairs(vim.fn.readfile(path)) do
    local key, val = line:match '^%s*([%w%-]+)%s*=%s*(.+)$'
    if key == 'palette' then
      local idx, color = val:match '^(%d+)%s*=%s*(#%x+)'
      if idx then
        pal[tonumber(idx)] = color
      end
    elseif key == 'background' then
      bg = trim(val)
    elseif key == 'foreground' then
      fg = trim(val)
    end
  end
  if not (bg and fg) then
    return
  end
  local r = tonumber(bg:sub(2, 3), 16) or 0
  local g = tonumber(bg:sub(4, 5), 16) or 0
  local b = tonumber(bg:sub(6, 7), 16) or 0
  vim.o.background = (0.299 * r + 0.587 * g + 0.114 * b) < 128 and 'dark' or 'light'

  for i = 0, 15 do
    if pal[i] then
      vim.g['terminal_color_' .. i] = pal[i]
    end
  end

  vim.cmd 'hi clear'
  local set = vim.api.nvim_set_hl
  set(0, 'Normal', { fg = fg, bg = bg })
  set(0, 'NormalNC', { fg = fg, bg = bg })
  set(0, 'NormalFloat', { fg = fg, bg = bg })
  set(0, 'EndOfBuffer', { fg = pal[8] })
  set(0, 'Comment', { fg = pal[8], italic = true })
  set(0, 'LineNr', { fg = pal[8] })
  set(0, 'CursorLineNr', { fg = pal[3] })
  set(0, 'String', { fg = pal[2] })
  set(0, 'Function', { fg = pal[4] })
  set(0, 'Keyword', { fg = pal[5] })
  set(0, 'Statement', { fg = pal[5] })
  set(0, 'Type', { fg = pal[3] })
  set(0, 'Constant', { fg = pal[6] })
  set(0, 'Identifier', { fg = pal[4] })
  set(0, 'Special', { fg = pal[6] })
  set(0, 'PreProc', { fg = pal[5] })
  set(0, 'Error', { fg = pal[9] })
  set(0, 'Visual', { bg = pal[8] })
  for from, to in pairs {
    ['@comment'] = 'Comment',
    ['@string'] = 'String',
    ['@function'] = 'Function',
    ['@keyword'] = 'Keyword',
    ['@type'] = 'Type',
    ['@constant'] = 'Constant',
    ['@variable'] = 'Identifier',
    ['@punctuation'] = 'Special',
  } do
    set(0, from, { link = to })
  end
end

local function apply(name, path)
  local entry = MAP[name]
  if entry then
    vim.o.background = entry.bg or 'dark'
    if entry.pre then
      entry.pre()
    end
    if pcall(vim.cmd.colorscheme, entry.scheme) then
      return
    end
  end
  palette_fallback(path)
end

-- Parse one "<name>\t<theme-file>" line from `ghostty-theme resolve`. Returns
-- the theme name (nil on failure/empty) and the theme-file path (nil when none).
local function parse_resolve(res)
  if not res or res.code ~= 0 then
    return nil, nil
  end
  local out = vim.split(res.stdout or '', '\n', { plain = true })[1] or ''
  local name, path = out:match '^([^\t]*)\t?(.*)$'
  name = trim(name or '')
  if name == '' then
    return nil, nil
  end
  path = (path and path ~= '') and trim(path) or nil
  return name, path
end

-- Async re-sync: ask the script for the effective theme, apply on the main loop.
function M.sync()
  vim.system({ 'ghostty-theme', 'resolve' }, { text = true }, function(res)
    local name, path = parse_resolve(res)
    if not name then
      return
    end
    vim.schedule(function()
      apply(name, path)
    end)
  end)
end

local watcher, timer
local function start_watch()
  if not uv then
    return
  end
  watcher = uv.new_fs_event()
  timer = uv.new_timer()
  if not (watcher and timer) then
    return
  end
  -- Debounce: Ghostty's truncate+write can fire two events per switch. 15ms
  -- still coalesces those (they land sub-millisecond apart) while keeping nvim
  -- close behind the terminal's instant OSC repaint, minimizing the switch flash.
  watcher:start(OVERRIDE_FILE, {}, function(err)
    if err then
      return
    end
    timer:stop()
    timer:start(15, 0, function()
      vim.schedule(M.sync)
    end)
  end)
end

function M.setup()
  -- First sync runs synchronously so nvim launches already-themed — avoids a
  -- flash of the default colorscheme while the async resolve round-trips.
  local ok, res = pcall(function()
    return vim.system({ 'ghostty-theme', 'resolve' }, { text = true }):wait(200)
  end)
  local name, path = parse_resolve(ok and res or nil)
  if name then
    apply(name, path)
  end

  start_watch()
  -- Re-sync once plugins are installed/ready (handles cold first launch).
  vim.api.nvim_create_autocmd('User', { pattern = 'VeryLazy', once = true, callback = M.sync })

  vim.keymap.set('n', '<leader>tr', M.sync, { desc = 'Refresh theme from Ghostty' })
  vim.keymap.set('n', '<leader>ts', function()
    vim.system { 'ghostty-theme', 'next' }
  end, { desc = 'Next Ghostty theme' })
end

return M
