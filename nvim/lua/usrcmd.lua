local my_au = vim.api.nvim_create_augroup('my_au', {})
local aucmd = vim.api.nvim_create_autocmd

-- Just using `set fo-=cro` won't work since many filetypes set/expand `formatoption`
aucmd('filetype', {
	group = my_au,
	callback = function()
		vim.opt.fo = { j = true }
		vim.opt.shiftwidth = 3
		vim.opt.tabstop = 3
		vim.opt.softtabstop = 3
	end,
})

aucmd('CursorHold', {
	group = my_au,
	callback = function()
		local f = assert(
			io.open('/tmp/wz_nvim.txt', 'r'),
			'🫠 nvim usr autocmd|\n\tfailed to open wz_nvim.txt'
		)
		local theme = f:read '*l'
		f:close()
		vim.opt.background = theme
	end,
})

local usrcmd = vim.api.nvim_create_user_command
usrcmd('Make', function(opts)
	local cmd = '<cr> '
	local args = opts.args
	local extra = ''
	local ft = vim.bo.filetype
	if ft == 'rust' then -- langs which have to be compiled
		cmd = '!cargo '
		if args == '' then
			local path = vim.fn.expand '%:p'
			args = 'r '
			if string.find(path, '/src/bin') ~= nil then
				local _, l = string.find(path, '/src/bin/')
				local r = string.find(string.sub(path, l + 1), '/')
					or string.find(string.sub(path, l + 1), '%.')

				args = args .. '--bin ' .. string.sub(path, l + 1, l + r - 1)
			elseif vim.fn.expand '%' ~= 'main.rs' then
				args = 't '
			end
		else
			args = table.remove(opts.fargs, 1) -- insert 1st argument to `args`
		end
		table.insert(opts.fargs, 1, '-q')
		for _, a in ipairs(opts.fargs) do
			extra = extra .. ' ' .. a
		end
	elseif ft == 'cpp' or ft == 'c' then
		cmd = '!make '
	elseif ft == 'ruby' or ft == 'swift' or ft == 'lua' or ft == 'python' then -- langs which has interpreter
		local file = vim.fn.expand '%:t'
		local interpreter = ft
		if interpreter == 'python' then
			interpreter = interpreter .. '3'
		end
		if args == 't' then
			file = 'test.' .. ft
			args = ''
		end
		cmd = '!' .. interpreter .. ' ' .. file .. ' '
	elseif ft == 'html' then -- markup language
		cmd = '!open ' .. vim.fn.expand '%:t' .. ' '
	elseif ft == 'markdown' then
		cmd =
			[[lua if require('peek').is_open() then require('peek').close() else require('peek').open() end]]
		--'MarkdownPreviewToggle'
	end

	vim.cmd(cmd .. args .. extra)
end, { nargs = '*' })

usrcmd('RmSwap', function(_)
	vim.cmd '!rip ~/.local/state/nvim/swap'
end, {})
