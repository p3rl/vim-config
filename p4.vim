"//////////////////////////////////////////////////////////////////////////////
" Perforce Vim Plugin

let s:cpo_save = &cpo
set cpo&vim

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
    let l:result = system('p4 ' . a:cmd)
	return l:result
endfunction

function! s:p4_buffer_cmd(cmd)
	return s:p4_cmd(a:cmd . ' ' . expand("%:p")) 
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
" Commands

command! -nargs=0 P4open call s:p4_file_open()
command! -nargs=0 P4revert call s:p4_file_revert()
command! -nargs=0 P4filelog call s:p4_file_log()
command! -nargs=0 P4opened call s:p4_opened()
command! -nargs=* P4print call s:p4_print(<f-args>)

let &cpo = s:cpo_save
unlet s:cpo_save
