"//////////////////////////////////////////////////////////////////////////////
let s:mru_buffers = []
let s:mru_max_count = 10
let s:mru_filetypes = ['cpp', 'cs']
let s:mru_win_id = 0
let s:mru_buf_id = 0
"//////////////////////////////////////////////////////////////////////////////
fun! s:is_valid_filetype(filetype)
	for l:valid_type in s:mru_filetypes
		if l:valid_type == a:filetype
			return 1
		endif
	endfor
	return 0
endfun

fun! s:on_buf_enter(bufnr_string)
	let l:bufnr = str2nr(a:bufnr_string)
	let l:filetype = getbufvar(l:bufnr, '&filetype')
	if s:is_valid_filetype(l:filetype)
		call filter(s:mru_buffers, 'v:val != l:bufnr')
		if len(s:mru_buffers) >= s:mru_max_count
			call remove(s:mru_buffers, -1)		
		endif
		call insert(s:mru_buffers, l:bufnr)
	endif
endfun

fun! s:on_win_leave()
	if s:mru_win_id
		call s:close_window()
	endif
endfun

fun! s:open_window()
	let s:mru_buf_id = nvim_create_buf(v:false, v:true)
	let opts = {
        \ 'relative': 'editor',
        \ 'row': 0,
        \ 'col': 0,
        \ 'width': float2nr(&columns),
        \ 'height': 1
        \ }
	let s:mru_win_id = nvim_open_win(s:mru_buf_id, v:true, opts)

	let l:text = ''
	let l:idx = 1
	for l:nr in s:mru_buffers
		let l:fullname = bufname(l:nr)
		let l:text = l:text . printf('[#%d %s] ', l:idx, fnamemodify(l:fullname, ":t"))
		let l:idx = l:idx + 1
	endfor
	call setbufline(s:mru_buf_id, 1, l:text)
endfun

fun! s:close_window()
	if s:mru_win_id
		let l:win_id = win_id2win(s:mru_win_id)
		let s:mru_win_id = 0
		exec l:win_id . 'wincmd q'
		exec s:mru_buf_id . 'bw'
		let s:mru_buf_id = 0
	endif
endfun
"//////////////////////////////////////////////////////////////////////////////
fun! buffer#list()
	for l:nr in s:mru_buffers
		echo bufname(l:nr)
	endfor
endfun

fun! buffer#toggle()
	if s:mru_win_id
		call s:close_window()
	else
		call s:open_window()
	endif
endfun
"//////////////////////////////////////////////////////////////////////////////
" Auto commands
augroup BufferMRU
	au!
	au BufEnter * call s:on_buf_enter(expand('<abuf>'))
	au BufLeave * call s:on_win_leave()
augroup END
