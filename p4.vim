"//////////////////////////////////////////////////////////////////////////////
" Perforce Vim Plugin

let s:p4_info = {}

let s:p4_print_buf_name = '[P4 Print]'
let s:p4_print_buf_id = 0

function! s:open_p4_buffer(buf_name)
	let l:buf_id = bufnr(a:buf_name, 1)
	exec 'b ' . l:buf_id
	exec 'setlocal buftype=nofile'
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

function! s:p4_file_open()
	echo s:p4_buffer_cmd('open')
endfunction

function! s:p4_file_revert()
	echo s:p4_buffer_cmd('revert')
endfunction

function! s:p4_file_log()
	let l:log = s:p4_buffer_cmd('filelog')
	if strlen(l:log) != 0
		call setqflist([])
		let l:reg = '\v.*#(\d*)\s\w*\s(\d*)\s\w*\s\w*\s(\d{4}\/\d{2}\/\d{2})\s\w*\s([a-zA-Z0-9\._\-]*)\@([a-zA-Z0-9\._\-]*)\s\(text\)\s(.*)'
		let l:format = '%4s | %9s | %10s | %20S | %40s | %s'
		caddexpr printf(l:format, '#Rev', '#CL', 'Date', 'Author', 'Workspace', 'Text')
		caddexpr '-----------------------------------------------------------------------------------------------------------------------------------'
		let l:line_index = 2
		for l:line in split(l:log, '\n')[1:-2]
			let l:tokens = matchlist(l:line, l:reg)
			if len(l:tokens) > 3
				caddexpr printf(l:format, l:tokens[1], l:tokens[2], l:tokens[3], l:tokens[4], l:tokens[5], l:tokens[6])
			endif
		endfor
	endif
	bo copen 20
endfunction

function! s:p4_opened()
	echo s:p4_cmd('opened')
endfunction

function! s:p4_print(...)
	let l:rev = a:0 ? a:1 : 'head'
	let l:filename = expand("%:p")
	let s:p4_print_buf_id = s:open_p4_buffer(s:p4_print_buf_name)
	let l:content = s:p4_cmd('print' . ' ' . l:filename . '#'. l:rev)
	call append(0, split(l:content, '\n'))
	exec 'setlocal nomodifiable'
	exec 'silent normal! gg'
endfunction

"//////////////////////////////////////////////////////////////////////////////
" Public API

function! p4#edit(...)
	let l:args = 'edit' . (a:0 ? ' ' . join(a:000, ' ') : '')
	echo s:p4_buffer_cmd(l:args)
endfunction

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

"//////////////////////////////////////////////////////////////////////////////
" Commands

command! -nargs=* P4info call p4#info(<f-args>)
command! -nargs=0 P4open call s:p4_file_open()
command! -nargs=0 P4revert call s:p4_file_revert()
command! -nargs=0 P4filelog call s:p4_file_log()
command! -nargs=0 P4opened call s:p4_opened()
command! -nargs=* P4print call s:p4_print(<f-args>)
command! -nargs=* P4edit call p4#edit(<f-args>)
