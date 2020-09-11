let s:grep_cmd = 'rg'
let s:grep_job_state = { 'job_id': -1, 'matches': 0 }

function! s:on_grep_event(job_id, data, event)
	if a:job_id == s:grep_job_state.job_id
		if a:event == 'stdout'
			if len(a:data) > 0
				let l:matches = []
				for l:line in a:data
					if strlen(l:line) > 0
						call add(l:matches, l:line)
					endif
				endfor
				caddexpr l:matches
				let s:grep_job_state.matches += len(l:matches)
			endif
		else
			echo printf('Found %d matches', s:grep_job_state.matches)
			let s:grep_job_state = { 'job_id': -1, 'matches': 0 }
		endif
	endif
endfunction

function! agrep#run(arg)
	if s:grep_job_state.job_id > 0
		call jobstop(s:grep_job_state.job_id)
	endif

	let s:grep_job_state = { 'job_id': -1, 'matches': 0 }
	call setqflist([])
	let l:cwd = getcwd()

	let l:job_opts = {
		\ 'on_stdout': function('s:on_grep_event'),
		\ 'on_stderr': function('s:on_grep_event'),
		\ 'on_exit': function('s:on_grep_event'),
		\ 'cwd': l:cwd
	\}

	let l:args = [s:grep_cmd, '--vimgrep', a:arg, './']
	let s:grep_job_state.job_id = jobstart(l:args, l:job_opts)

	if s:grep_job_state.job_id > 0
		execute 'botright copen 20'
	else
		echo 'Error running: ' . string(l:args)
	endif
endfunction

function! agrep#stop()
	if s:grep_job_state.job_id > 0
		call jobstop(s:grep_job_state.job_id)
	endif
endfunction

command! -nargs=1 Agrep call agrep#run(<q-args>)
command! -nargs=0 Agrepstop call agrep#stop()
