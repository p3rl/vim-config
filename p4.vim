"//////////////////////////////////////////////////////////////////////////////
" Perforce Vim Plugin

let s:p4_info = {}

let s:p4_print_buf_name = 'P4'
let s:p4_print_buf_id = 0

function! s:open_p4_buffer(buf_name)
	let l:buf_id = bufnr(a:buf_name, 1)
	exec 'b ' . l:buf_id
	exec 'setlocal buftype=nofile'
	exec 'setlocal noswapfile'
	exec 'setlocal modifiable'
	exec 'silent normal! ggdG'
	return l:buf_id
endfunction

function! s:p4_cmd(cmd)
	return system('p4 ' . a:cmd)
endfunction

function! s:p4_buffer_cmd(cmd)
	return s:p4_cmd(a:cmd . ' ' . expand("%:p")) 
endfunction

function! s:p4_get_info()
	if empty(s:p4_info)
		let l:info = s:p4_cmd('info')
		if strlen(l:info) == 0
			echo '[P4]: Error, not in a perforce root'
			return 0
		endif
		for l:line in split(l:info, '\n')
			let l:tokens = matchlist(l:line, '\vUser\sname:\s([0-9a-zA-Z_\-\.@]*)$')
			if len(l:tokens)
				call extend(s:p4_info, { 'username': l:tokens[1] })
			endif
			let l:tokens = matchlist(l:line, '\vClient\sname:\s([0-9a-zA-Z_\-\.@]*)$')
			if len(l:tokens)
				call extend(s:p4_info, { 'client_name': l:tokens[1] })
			endif
			let l:tokens = matchlist(l:line, '\vClient\shost:\s([0-9a-zA-Z_\-\.@]*)$')
			if len(l:tokens)
				call extend(s:p4_info, { 'client_host': l:tokens[1] })
			endif
			let l:tokens = matchlist(l:line, '\vClient\sroot:\s([0-9a-zA-Z_\-\.@\\\:]*)$')
			if len(l:tokens)
				call extend(s:p4_info, { 'client_root': l:tokens[1] })
			endif
			let l:tokens = matchlist(l:line, '\vClient\sstream:\s([0-9a-zA-Z_\-\.\/]*)$')
			if len(l:tokens)
				call extend(s:p4_info, { 'client_stream': l:tokens[1] })
			endif
			let l:tokens = matchlist(l:line, '\vClient\saddress:\s(.*)$')
			if len(l:tokens)
				call extend(s:p4_info, { 'client_address': l:tokens[1] })
			endif
			let l:tokens = matchlist(l:line, '\vServer\saddress:\s(.*)$')
			if len(l:tokens)
				call extend(s:p4_info, { 'server_address': l:tokens[1] })
			endif
		endfor
	endif
	return s:p4_info
endfunction

function! s:p4_file_revert()
	echo s:p4_buffer_cmd('revert')
endfunction

function! s:p4_file_log()
	let l:log = s:p4_buffer_cmd('filelog')
	if strlen(l:log) != 0
		call setqflist([])
		let l:reg = '\v.*#(\d*)\s\w*\s(\d*)\s\w*\s\w*\s(\d{4}\/\d{2}\/\d{2})\s\w*\s([a-zA-Z0-9\._\-]*)\@([a-zA-Z0-9\._\-]*)\s\(text\)\s(.*)'
		let l:format = '%-5s %-10s %-11s %-30s %s'
		caddexpr printf(l:format, 'Rev', 'CL', 'Date', 'Author', 'Text')
		caddexpr '----------------------------------------------------------------------------------------------------'
		let l:line_index = 2
		for l:line in split(l:log, '\n')[1:-2]
			let l:tokens = matchlist(l:line, l:reg)
			if len(l:tokens) > 3
				caddexpr printf(l:format, l:tokens[1], l:tokens[2], l:tokens[3], l:tokens[4], l:tokens[6])
			endif
		endfor
	endif
	bo copen 20
endfunction

function! s:p4_opened()
	echo s:p4_cmd('opened')
endfunction

function s:p4_get_file_content(filepath, revision)
	return s:p4_cmd('print -q' . ' ' . a:filepath . '#'. a:revision)
endfunction

function! s:p4_print(...)
	let l:revision = a:0 ? a:1 : 'head'
	let l:content = s:p4_get_file_content(expand("%:p"), l:revision)
	let s:p4_print_buf_id = s:open_p4_buffer(s:p4_print_buf_name)
	call append(0, split(l:content, '\n'))
	exec 'setlocal nomodifiable'
	exec 'silent normal! gg'
endfunction

function! s:p4_on_quickfix_event(event)
endfunction

function! s:p4_where(...)
	let l:filepath = get(a:000, 0, expand("%:p"))
	let l:result = s:p4_cmd('where ' . l:filepath)
	if strlen(l:result)
		let l:lines = split(l:result)
		if len(l:lines) == 3
			return { 'depot': l:lines[0], 'client': l:lines[1], 'local': l:lines[2] }
		endif
	endif
endfunction

function! s:p4_depot_path()
	let l:fileinfo = s:p4_where()
	if len(l:fileinfo) > 1
		return get(l:fileinfo, 'depot', '')
	endif
endfunction

function! s:p4_copy_depot_path()
	let l:depot_path = s:p4_depot_path()
	if len(l:depot_path) > 0
		let @+= l:depot_path
		echo 'Copied -> ' . l:depot_path
	endif
endfunction

"//////////////////////////////////////////////////////////////////////////////
" Public API

function! p4#info(...)
	let l:all_info = a:0 ? strlen(matchstr(a:1, '-all')) != 0 : 0
	if l:all_info
		echo s:p4_cmd('info')
	else
		let l:info = s:p4_get_info()
		let l:fmt = '  %-15s %s'
		echo '[P4]: Info:'
		echo printf(l:fmt, 'username:', l:info.username)
		echo printf(l:fmt, 'client name:',l:info.client_name)
		echo printf(l:fmt, 'client stream:', l:info.client_stream)
		echo printf(l:fmt, 'client root:', l:info.client_root)
	endif
endfunction

function! p4#edit(...)
	let l:args = 'edit' . (a:0 ? ' ' . join(a:000, ' ') : '')
	echo s:p4_buffer_cmd(l:args)
endfunction

function! p4#diff(...)
	let l:rev = a:0 ? a:1 : 'head'
	let l:filename = expand("%:p")
	let l:content = s:p4_cmd('print -q' . ' ' . l:filename . '#'. l:rev)

	if strlen(l:content)
		silent exec 'only'
		exec 'difft'
		let l:remote_buf_id = bufnr(s:p4_print_buf_name, 1)
		call setbufvar(l:remote_buf_id, '&modifiable', 1)
		exec 'vert sb ' . l:remote_buf_id
		call deletebufline(l:remote_buf_id, 1, '$')
		call setbufline(l:remote_buf_id, 1, split(l:content, '\n'))
		call setbufvar(l:remote_buf_id, '&modifiable', 0)
		exec 'difft'
	endif

endfunction

function p4#difftool(...)
	let l:left_rev = 'head'
	let l:right_rev = 'workspace'

	if a:0 > 2
		echo '[P4]: Invalid number of arguments'
		return
	endif

	if a:0 == 2
		let l:left_rev = a:1
		let l:right_rev = a:2
	elseif a:0 == 1
		let l:right_rev = a:1
	endif

	let l:fileinfo = s:p4_where()
	let l:args = { 'left': { 'title': '', 'path': '' }, 'right': { 'title': '', 'path': '' } }

	if l:right_rev == 'workspace'
		let l:args.right.title = l:fileinfo.local
		let l:args.right.path = l:fileinfo.local
	else
		let l:tmp_filename = printf('%s-%s', tempname(), fnamemodify(l:fileinfo.local, ":t"))
		let l:content = s:p4_get_file_content(l:fileinfo.local, l:right_rev)
		call writefile(split(l:content, '\n'), l:tmp_filename)	

		let l:args.right.title = l:fileinfo.depot . '#' . l:right_rev
		let l:args.right.path = l:tmp_filename
	endif

	let l:tmp_filename = printf('%s-%s', tempname(), fnamemodify(l:fileinfo.local, ":t"))
	let l:content = s:p4_get_file_content(l:fileinfo.local, l:left_rev)
	call writefile(split(l:content, '\n'), l:tmp_filename)	

	let l:args.left.title = l:fileinfo.depot . '#' . l:left_rev
	let l:args.left.path = l:tmp_filename

	let l:job_cmd = printf('p4merge.exe -nl %s -nr %s %s %s', l:args.left.title, l:args.right.title, l:args.left.path, l:args.right.path)
	let l:job_opts = { 'deatch': 1 }
	call jobstart(l:job_cmd, l:job_opts)
	"call system(printf('p4merge.exe -nl %s -nr %s %s %s', l:args.left.title, l:args.right.title, l:args.left.path, l:args.right.path))
endfunction

"//////////////////////////////////////////////////////////////////////////////
" Commands

command! -nargs=* P4info call p4#info(<f-args>)
command! -nargs=0 P4revert call s:p4_file_revert()
command! -nargs=0 P4filelog call s:p4_file_log()
command! -nargs=0 P4opened call s:p4_opened()
command! -nargs=* P4print call s:p4_print(<f-args>)
command! -nargs=* P4edit call p4#edit(<f-args>)
command! -nargs=* P4diff call p4#diff(<f-args>)
command! -nargs=* P4difftool call p4#difftool(<f-args>)
command! -nargs=* P4depotpath call s:p4_depot_path()
command! -nargs=* P4copydepotpath call s:p4_copy_depot_path()

"//////////////////////////////////////////////////////////////////////////////
" Auto commands
augroup quickfix_events
	autocmd!
	autocmd WinEnter * if &buftype == 'quickfix' | call s:p4_on_quickfix_event('win_enter')
	autocmd WinLeave * if &buftype == 'quickfix' | call s:p4_on_quickfix_event('win_leave')
	autocmd BufWinEnter quickfix call s:p4_on_quickfix_event('buf_win_enter')
	autocmd BufWinLeave quickfix call s:p4_on_quickfix_event('buf_win_leave')
augroup END

