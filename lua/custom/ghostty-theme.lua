-- Sync nvim's colorscheme to Ghostty's active terminal theme.
-- Resolves Ghostty's effective theme (override file, else the base light/dark
-- default), maps it to a matching nvim colorscheme, and live-reloads via a file
-- watch. Themes without a mapped colorscheme fall back to a palette-generated
-- look built straight from the Ghostty theme file's 16 ANSI colors.
local uv = vim.uv or vim.loop

local M = {}

local CONFIG_DIR = vim.fn.expand '~/.config/ghostty'
local OVERRIDE_FILE = CONFIG_DIR .. '/current-theme.conf'
local BASE_CONFIG = CONFIG_DIR .. '/config'
local THEME_DIRS = {
  CONFIG_DIR .. '/themes',
  '/run/current-system/sw/share/ghostty/themes',
}

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

local function read_lines(path)
  if vim.fn.filereadable(path) == 0 then
    return nil
  end
  return vim.fn.readfile(path)
end

local function trim(s)
  return (s:gsub('^%s*(.-)%s*$', '%1'))
end

-- Single theme name from the override file, or nil when cleared/absent or when
-- it holds a light:/dark: pair (resolved from the base config instead).
local function read_override()
  local lines = read_lines(OVERRIDE_FILE)
  if not lines then
    return nil
  end
  for _, line in ipairs(lines) do
    local val = line:match '^%s*theme%s*=%s*(.+)$'
    if val then
      val = trim(val)
      if val ~= '' and not val:find ':' then
        return val
      end
    end
  end
  return nil
end

-- Parses the base config's `theme = light:A, dark:B` line; falls back to the
-- known Solarized defaults if absent.
local function read_base_defaults()
  local light, dark = 'iTerm2 Solarized Light', 'iTerm2 Solarized Dark'
  local lines = read_lines(BASE_CONFIG)
  if lines then
    for _, line in ipairs(lines) do
      local val = line:match '^%s*theme%s*=%s*(.+)$'
      if val and val:find ':' then
        local l = val:match 'light:%s*([^,]+)'
        local d = val:match 'dark:%s*([^,]+)'
        if l then light = trim(l) end
        if d then dark = trim(d) end
      end
    end
  end
  return light, dark
end

local function resolve_theme_file(name)
  for _, dir in ipairs(THEME_DIRS) do
    local p = dir .. '/' .. name
    if vim.fn.filereadable(p) == 1 then
      return p
    end
  end
  return nil
end

-- Crude themed look built from a Ghostty theme file's 16 ANSI colors + bg/fg.
-- Used for any Ghostty theme without a mapped nvim colorscheme.
local function palette_fallback(name)
  local path = resolve_theme_file(name)
  if not path then
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

local function apply(name)
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
  palette_fallback(name)
end

function M.sync()
  local name = read_override()
  if name then
    vim.schedule(function()
      apply(name)
    end)
    return
  end
  -- Override cleared: follow the base config's light/dark default per GNOME.
  local light, dark = read_base_defaults()
  vim.system({ 'gsettings', 'get', 'org.gnome.desktop.interface', 'color-scheme' }, { text = true }, function(res)
    local pick = (res.code == 0 and res.stdout:match 'prefer%-dark') and dark or light
    vim.schedule(function()
      apply(pick)
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
  -- Debounce: Ghostty's truncate+write can fire two events per switch.
  watcher:start(OVERRIDE_FILE, {}, function(err)
    if err then
      return
    end
    timer:stop()
    timer:start(50, 0, function()
      vim.schedule(M.sync)
    end)
  end)
end

function M.setup()
  M.sync()
  start_watch()
  -- Re-sync once plugins are installed/ready (handles cold first launch).
  vim.api.nvim_create_autocmd('User', { pattern = 'VeryLazy', once = true, callback = M.sync })

  vim.keymap.set('n', '<leader>tr', M.sync, { desc = 'Refresh theme from Ghostty' })
  vim.keymap.set('n', '<leader>ts', function()
    vim.system { 'ghostty-theme', 'next' }
  end, { desc = 'Next Ghostty theme' })
end

return M
