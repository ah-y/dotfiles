local usrcmd = vim.api.nvim_create_user_command
usrcmd('Make', function(opts)
	local cmd = '<cr> '
	local args = opts.args
	local extra = ''
	local ft = vim.bo.filetype
	if ft == 'rust' then -- langs which have to be compiled
		cmd = '!cargo '
		if args == '' then
			args = 'r -q'
		else
			args = table.remove(opts.fargs, 1)
			table.insert(opts.fargs, 1, '-q')
			for _, a in ipairs(opts.fargs) do
				extra = ' ' .. extra .. ' ' .. a
			end
		end
	elseif ft == 'cpp' or ft == 'c' then
		cmd = '!make '
	elseif ft == 'swift' or ft == 'lua' then -- langs which has interpreter
		local file = vim.fn.expand '%:t'
		if args == 't' then
			file = 'test.' .. ft
			args = ''
		end
		cmd = '!' .. ft .. ' ' .. file .. ' '
	elseif ft == 'html' then -- markup language
		cmd = '!open ' .. vim.fn.expand '%:t' .. ' '
	end

	vim.cmd(cmd .. args .. extra)
end, { nargs = '*' })