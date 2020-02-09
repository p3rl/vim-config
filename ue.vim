"//////////////////////////////////////////////////////////////////////////////
" Unreal Vim plugin

let g:ue_is_initialized = 0
let g:ue_build_status_text = ''

let s:ue_relative_path_to_run_uat = 'Engine\Build\BatchFiles\RunUAT.bat'
let s:ue_engine_dir = ''
let s:ue_uat_dir = ''
let s:ue_run_uat_cmd = ''
let s:ue_uat_cmd = ''
let s:ue_ubt_cmd = ''

let s:ue_platforms = ['win64', 'ps4', 'linux', 'mac', 'ios', 'android', 'win32'] 

let s:ue_projects = []
let s:ue_current_project_id = -1

let s:build_target = ''
let s:platform = 'Win64'
let s:configuraton = 'Development'

let s:ue_buf_name = '[UE]'
let s_ue_buf_id = 0

let s:ue_build_watch_enabled = 0
let s:ubt_job_state = { 'job_id': -1, 'counter': 0, 'errors': [], 'status': '' }

function! s:on_ubt_event(job_id, data, event)
	if a:job_id != s:ubt_job_state.job_id
		return 0
	endif
	if a:event == 'stdout'
		call setbufvar(s:ue_buf_id, '&modifiable', 1)
		for line in a:data
			if strlen(line) != 0
				" Append build output to [UE] buffer
				let l:trimmed_line = substitute(line, '', '', 'g')
				call appendbufline(s:ue_buf_id, '$', l:trimmed_line)
				let s:ubt_job_state.counter += 1

				" Append errors to quickfix
				let l:ml = matchlist(trimmed_line, '\v(^.*)(\(\d*\)).*(error|warning).*(C\d{4})(.*)')
				if len(l:ml) != 0
					let l:filepath = l:ml[1]
					let l:linenr = l:ml[2][1: -2]
					let l:error = l:filepath . ':' . l:linenr . ': ' . l:ml[4] . ' ' . l:ml[5] 
					call add(s:ubt_job_state.errors, { 'filepath': l:filepath, 'linenr': l:linenr, 'type': l:ml[4], 'text': l:ml[5] })
					caddexpr l:error
				endif
			endif
		endfor
		call setbufvar(s:ue_buf_id, '&modifiable', 0)

		" Scroll to bottom of log window
		let l:ue_buf_winnr = bufwinnr(s:ue_buf_name)
		let l:ue_win_bufnr = winbufnr(l:ue_buf_winnr)
		if l:ue_win_bufnr == s:ue_buf_id
			call nvim_win_set_cursor(win_getid(l:ue_buf_winnr), [s:ubt_job_state.counter, 0])
		endif
	elseif a:event == 'exit' || a:event == 'stderr'
		let s:ubt_job_state.job_id = -1
		let l:num_errors = len(s:ubt_job_state.errors)
		echo '[UE]: Build finished ' . (l:num_errors == 0 ? '[OK]' : '[Errors: ' . l:num_errors . ']')
	else
		echo '[UE]: Unknown UBT event'
	endif
endfunction

function! s:is_ue_engine_dir(dir)
	return filereadable(expand(a:dir . '\' . s:ue_relative_path_to_run_uat))
endfunction

function! s:try_find_engine_dir()
	let l:cwd = getcwd()
	let l:dir = l:cwd
	while 1
		let l:found = s:is_ue_engine_dir(l:dir) 
		cd..
		let l:parentdir = getcwd()
		if l:found || l:parentdir == l:dir
			break
		endif
		let l:dir = l:parentdir
	endwhile
	exec 'cd ' . l:cwd
	return l:found ? l:dir : ''
endfunction

function! s:get_ubt_args(project, platform, configuration)
	return a:project . ' ' . a:platform . ' ' . a:configuration . ' -NoLog'
endfunction

function! s:get_current_project()
	if s:ue_current_project_id != -1
		return s:ue_projects[s:ue_current_project_id]
	endif
endfunction

function! s:get_project_by_name(project_name)
	for l:project in s:ue_projects
		if l:project.name ==? project_namne
			return l:project
		endif
	endfor
endfunction

function! s:get_project_build_target(project, target)
	for l:build_target in a:project.build_targets
		if l:build_target =~ a:target
			return l:build_target
		endif
	endfor
endfunction

function! s:set_target(project, platform, configuration)
	let s:build_target = a:project
	let s:platform = a:platform
	if strlen(s:platform) == 0
		s:platform = 'Win64'
	endif
	let s:configuration = a:configuration
	if strlen(s:configuration) == 0
		s:configuration = 'Development'
	endif
endfunction

"//////////////////////////////////////////////////////////////////////////////
" Public API

function! ue#build_target(...)
	if strlen(s:build_target) == 0
		echo '[UE]: No active build target'
		return 0
	endif

	if s:ubt_job_state.job_id > 0
		echo '[UE]: Build already running...'
		return 0
	endif

	let l:build_args = s:get_ubt_args(s:build_target, s:platform, s:configuration)
	let l:build_args = a:0 ? l:build_args . ' ' . join(a:000, ' ') : l:build_args

	let l:job_cmd = s:ue_ubt_cmd . ' ' . l:build_args

	" Clear build state
	call setqflist([])
	let s:ubt_job_state = { 'job_id': -1, 'counter': 0, 'errors': [], 'status': '' }

	" Setup buffer
	let s:ue_buf_id = bufnr(s:ue_buf_name, 1)

	call setbufvar(s:ue_buf_id, '&buftype', 'nofile')
	call setbufvar(s:ue_buf_id, '&modifiable', 1)
	silent call deletebufline(s:ue_buf_id, 1, '$')
	silent! call setbufline(s:ue_buf_id, 1, 'Run => ' . l:job_cmd)
	call setbufvar(s:ue_buf_id, '&modifiable', 0)

	" Start UBT job
	let l:job_opts = {
		\ 'on_stdout': function('s:on_ubt_event'),
		\ 'on_stderr': function('s:on_ubt_event'),
		\ 'on_exit': function('s:on_ubt_event')
	\}
	let s:ubt_job_state.job_id = jobstart(l:job_cmd, l:job_opts)

	if s:ubt_job_state.job_id > 0
		echo '[UE]: => ' . fnamemodify(s:ue_ubt_cmd, ':t') . ' ' . l:build_args
	else
		echo '[UE]: => ' . fnamemodify(s:ue_ubt_cmd, ':t') . ' ' . 'failed to start'
	endif
endfunction

function! ue#build_singlefile(...)
	let l:filename = expand('%p')
	let l:build_args = '-SingleFile=' . l:filename
	let l:build_args = a:0 ? l:build_args . ' ' . join(a:000, ' ') : l:build_args
	call ue#build_target(l:build_args)
endfunction

function! ue#cancel_build()
	if s:ubt_job_state.job_id > 0
		call jobstop(s:ubt_job_state.job_id)
	endif
endfunction

function! ue#build(target,...)
	let l:target = matchstr(a:target, '\v^(client|server|game|editor)')
	if strlen(l:target) == 0
		echo '[UE]: Invalid target name (client|server|game|editor)'
	endif

	let l:platform = get(a:000, 0, 'win64')
	if strlen(matchstr(l:platform, '\v^(win32|win64|linux|ps4|android|switch)')) == 0
		echo '[UE]: Invalid platform (win32|win64|linux|ps4|android|switch)'
	endif

	let l:configuration = get(a:000, 1, 'development')
	let l:additional_args = a:0 > 2 ? join(a:000[2:-1], ' ') : ''

	if strlen(matchstr(l:configuration, '\v^(debug|development|test|shipping)')) == 0
		echo '[UE]: Invalid configuration (debug|development|test|shipping)'
	endif

	let l:project = s:get_current_project()
	if empty(l:project)
		echo '[UE]: No active project'
		return 0
	endif
	let l:target = s:get_project_build_target(l:project, a:target)

	if strlen(l:target) != 0
		call s:set_target(l:target, l:platform, l:configuration)
		call ue#build_target(l:additional_args)
	endif
endfunction

function! s:ue_build_watch_trigger()
	if !s:ubt_job_state.job_id
		silent! call ue#build_target()
	endif
endfunction

function! ue#build_watch(mode)
	if a:mode ==? 'on' && !s:ue_build_watch_enabled
		echo '[UE]: Build watch on'
		let s:ue_build_watch_enabled = 1
	elseif a:mode ==? 'off' && s:ue_build_watch_enabled
		echo '[UE]: Build watch off'
		let s:ue_build_watch_enabled = 0
	endif
endfunction

function! ue#add_project(path)
	let l:project_path = fnamemodify(a:path, ':p')
	if filereadable(l:project_path) == 0
		echo '[UE]: Invalid project file "' . l:project_path . '"'
		return
	endif

	let l:project_name = fnamemodify(a:path, ':t')[0: -10]

	" Find project build targets
	let l:build_targets = []
	let l:project_dir = fnamemodify(l:project_path, ':h')
	let l:build_target_files = split(globpath(l:project_dir . '\Source', '*.Target.cs'), '\n')
	for build_target_file in l:build_target_files
		let l:target_name = fnamemodify(build_target_file, ':t')[0 : -11]
		call add(l:build_targets, l:target_name)
	endfor

	if len(l:build_targets) == 0
		echo '[UE]: Failed to find valid build targets in "' . l:project_dir . '\Source' . '"'
		return
	endif

	let l:project = {
		\ 'name': l:project_name,
		\ 'path': l:project_path,
		\ 'build_targets': l:build_targets
	\}

	call add(s:ue_projects, l:project)
endfunction

function! ue#set_project(arg)
	if strlen(a:arg) == 0
		" Display current project
		if s:ue_current_project_id != -1
			let l:project = s:ue_projects[s:ue_current_project_id]
			let l:info = l:project.name
			let l:info = l:info . ' ('
			for l:target in l:project.build_targets
				let l:info = l:info . l:target . ' '
			endfor
			let l:info = l:info . ')'
			echo l:info
		else
			echo '[UE]: No project set'
		endif
	else
		if a:arg == '-list'
			" List all available projects
			for l:i in range(0, len(s:ue_projects)-1)
				let l:project = s:ue_projects[l:i]
				let l:info = l:project.name
				let l:info = l:info . ' ('
				for l:target in l:project.build_targets
					let l:info = l:info . l:target . ' '
				endfor
				let l:info = l:info . ')'
				echo l:info
				endfor
		else
			" Set project by name
			for l:i in range(0, len(s:ue_projects)-1)
				let l:project = s:ue_projects[l:i]
				if l:project.name == a:arg
					let s:ue_current_project_id = l:i
					echo '[UE]: Project set to ' . a:project_name
				endif
			endfor
		endif
	endif
endfunction!

function! ue#init(...)
	if a:0 && s:is_ue_engine_dir(a:1)
		let l:engine_dir = a:1
	else
		let l:engine_dir = s:try_find_engine_dir()
	end

	if strlen(l:engine_dir) == 0
		echoerr '[UE]: Invalid engine dir'
		return
	endif

	let s:ue_engine_dir = l:engine_dir
	let s:ue_uat_dir = s:ue_engine_dir . '\' . 'Engine\Binaries\DotNET\'
	let s:ue_run_uat_cmd = s:ue_uat_dir . 'RunUAT.bat'
	let s:ue_uat_cmd = s:ue_uat_dir . 'AutomationTool.exe'
	let s:ue_ubt_cmd = s:ue_uat_dir . 'UnrealBuildTool.exe'

	echo '[UE]: Engine directory set to "' . s:ue_engine_dir . '"'

	if len(g:ue_default_projects) != 0
		for l:project_path in g:ue_default_projects
			call ue#add_project(s:ue_engine_dir . '\' . l:project_path)
		endfor
	endif

	if len(s:ue_projects) != 0 && s:ue_current_project_id == -1
		let s:ue_current_project_id = 0
	endif

	let g:ue_is_initialized = 1 
endfunction

"//////////////////////////////////////////////////////////////////////////////
" Commands

function s:ue_complete_build_args(arg, cmd, cursor_pos)
	if a:cursor_pos < 9
		return ['editor', 'client', 'server', 'game']
	elseif a:cursor_pos > 16
		return ['development', 'test', 'shipping']
	else
		return s:ue_platforms
	endif
endfunction

command! -nargs=* UEinit call ue#init(<f-args>)
command! -nargs=1 UEaddproject call ue#add_project(<q-args>)
command! -nargs=? UEproject call ue#set_project(<q-args>)
command! -nargs=* -complete=customlist,s:ue_complete_build_args UEbuild call ue#build(<f-args>)
command! -nargs=* UEbuildtarget call ue#build_target(<f-args>)
command! -nargs=* UEbuildfile call ue#build_singlefile(<f-args>)
command! -nargs=1 UEbuildwatch call ue#build_watch(<f-args>)
command! -nargs=0 UEcancelbuild call ue#cancel_build()

"//////////////////////////////////////////////////////////////////////////////
" Auto commands
augroup build_watch
	autocmd!
	autocmd BufWritePost *
		\ if s:ue_build_watch_enabled && (&filetype == 'cpp') |
			\ call s:ue_build_watch_trigger() |
		\ endif
augroup END

