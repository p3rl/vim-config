"//////////////////////////////////////////////////////////////////////////////
" Perforce Vim Plugin

"							  [rev]		  [cl]  [action]      [date]							[user]				[text]
let s:p4_file_log_regex = '\v.*#(\d*)\s\w*\s(\d*)\s(\w*)\s\w*\s([\d]{4}\/[\d]{2}\/[\d]{2})\s\w*\s([\w._-]*@[\w._-]*)\s\(\w*\)\s(.*)'

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
	let l:reg3 = '\v.*#(\d*)\s\w*\s(\d*)\s\w*\s\w*\s(\d{4}\/\d{2}\/\d{2})\s\w*\s([a-zA-Z0-9\._\-]*)\@([a-zA-Z0-9\._\-]*)(.*)'
	let l:log = s:p4_buffer_cmd('filelog')
	if strlen(l:log) != 0
	echo printf('%3S %15s %15s %20S %40S %40S', '#Rev', '#CL', 'Date', 'Author', 'Workspace', 'Text')
	for l:line in split(l:log, '\n')[1:-2]
		let l:tokens = matchlist(l:line, l:reg3)
		if len(l:tokens) > 3
			echo printf('%3S %15s %15s %20S %40S %40S', l:tokens[1], l:tokens[2], l:tokens[3], l:tokens[4], l:tokens[5], l:tokens[6])
		endif
	endfor
	endif
endfunction

"//////////////////////////////////////////////////////////////////////////////
" Commands

command! -nargs=0 P4open call s:p4_file_open()
command! -nargs=0 P4revert call s:p4_file_revert()
command! -nargs=0 P4filelog call s:p4_file_log()
