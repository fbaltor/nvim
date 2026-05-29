-- Yank the visual selection together with a markdown header naming the file
-- (path relative to the git root) and the selected line range, then drop it in
-- the system clipboard. Built for pasting code into chat/PRs/docs with context.
-- The body is the exact selection: charwise keeps partial first/last lines,
-- linewise/blockwise behave accordingly. The header's L<a>-<b> reports the line
-- span the selection touches.
local M = {}

-- File path relative to the enclosing git repo's root. Falls back to the path
-- relative to nvim's cwd when the buffer isn't inside a repo (or git is absent),
-- and returns nil for buffers with no file on disk.
local function repo_relative_path()
  local abs = vim.fn.expand '%:p'
  if abs == '' then
    return nil
  end
  local dir = vim.fn.expand '%:p:h'
  local root = vim.fn.systemlist({ 'git', '-C', dir, 'rev-parse', '--show-toplevel' })[1]
  if vim.v.shell_error == 0 and root and root ~= '' then
    return abs:sub(#root + 2) -- strip "<root>/"
  end
  return vim.fn.expand '%:.'
end

-- Raw start/end positions of the active selection (visual anchor 'v' and
-- cursor '.'), read live so they are valid while still in visual mode, before
-- the '< / '> marks are committed on exit.
local function selection_bounds()
  return vim.fn.getpos('v'), vim.fn.getpos('.')
end

function M.yank()
  local path = repo_relative_path()
  if not path then
    vim.notify('yank-context: buffer has no file path', vim.log.levels.WARN)
    return
  end

  local p1, p2 = selection_bounds()
  local lines = vim.fn.getregion(p1, p2, { type = vim.fn.mode() })
  local first = math.min(p1[2], p2[2])
  local last = math.max(p1[2], p2[2])
  local range = first == last and ('L%d'):format(first) or ('L%d-%d'):format(first, last)

  local block = table.concat({
    ('%s (%s)'):format(path, range),
    '```' .. vim.bo.filetype,
    table.concat(lines, '\n'),
    '```',
  }, '\n')

  vim.fn.setreg('+', block)
  -- Leave visual mode, mirroring a normal `y`.
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
  vim.notify(('yank-context: %s (%s)'):format(path, range))
end

function M.setup()
  vim.keymap.set('x', '<leader>y', M.yank, { desc = 'Yank selection + file/line context' })
end

return M
