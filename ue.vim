"//////////////////////////////////////////////////////////////////////////////
" Unreal Vim plugin

let s:ue_relative_path_to_run_uat = 'Engine\Build\BatchFiles\RunUAT.bat'
let s:ue_engine_dir = ''
let s:ue_uat_dir = ''
let s:ue_run_uat_cmd = ''
let s:ue_uat_cmd = ''
let s:ue_ubt_cmd = ''

let s:ue_projects = []
let s:ue_current_project_id = -1

let s:project = ''
let s:platform = 'Win64'
let s:configuraton = 'Development'

let s:ue_buf_name = '[UE]'
let s_ue_buf_id = 0
let s:ue_ubt_job_id = 0
let s:ue_ubt_running = 0

function! s:on_stdout(job_id, data, event_type)
	if a:job_id == s:ue_ubt_job_id 
		call setbufvar(s:ue_buf_id, '&modifiable', 1)
		for line in a:data
			if strlen(line) != 0
				" Append build output to [UE] buffer
				let l:trimmed_line = substitute(line, '', '', 'g')
				call appendbufline(s:ue_buf_id, '$', l:trimmed_line)

				" Append errors to quickfix
				let l:ml = matchlist(trimmed_line, '\v(^.*)(\(\d*\)).*(error|warning).*(C\d{4})(.*)')
				if len(l:ml) != 0
					let l:filepath = l:ml[1]
					let l:linenr = l:ml[2][1: -2]
					let l:error = l:filepath . ':' . l:linenr . ': ' . l:ml[4] . ' ' . l:ml[5] 
					caddexpr l:error
				endif
			endif
		endfor
		call setbufvar(s:ue_buf_id, '&modifiable', 0)

		" Scroll to bottom of log window
		let l:cur_wnd = winnr()
		let l:ue_wnd = bufwinnr(s:ue_buf_id)
		if l:ue_wnd != -1 && l:cur_wnd
			silent exec l:ue_wnd . 'wincmd w'
			silent exec 'normal! G'
			silent exec l:cur_wnd . 'wincmd w'
		endif
	endif
endfunction

function! s:on_stderr(job_id, data, event)
	if a:job_id == s:ue_ubt_job_id
		let s:ue_ubt_running = 0
		let s:ue_ubt_job_id = 0
		call setbufvar(s:ue_buf_id, '&modifiable', 1)
		for line in a:data
			if strlen(line) != 0
				let l:trimmed_line = substitute(line, '', '', 'g')
				call appendbufline(s:ue_buf_id, '$', l:trimmed_line)
			endif
		endfor
		call setbufvar(s:ue_buf_id, '&modifiable', 0)
	endif
endfunction

function! s:on_exit(job_id, data, event)
	if a:job_id == s:ue_ubt_job_id
		let s:ue_ubt_running = 0
		let s:ue_ubt_job_id = 0
	endif
endfunction

function! s:is_ue_engine_dir(dir)
	return filereadable(expand(a:dir . '\' . s:ue_relative_path_to_run_uat))
endfunction

function! s:get_ubt_args(project, platform, configuration)
	return a:project . ' ' . a:platform . ' ' . a:configuration
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
	let s:project = a:project
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
	if strlen(s:project) == 0
		echo '[UE]: No active build target'
	endif

	if s:ue_ubt_running
		echo '[UE]: Unreal Build Tool already running...'
		return
	endif

	let l:build_args = s:get_ubt_args(s:project, s:platform, s:configuration)
	let l:build_args = a:0 ? l:build_args . ' ' . join(a:000, ' ') : l:build_args

	let l:job_cmd = s:ue_ubt_cmd . ' ' . l:build_args
	echo '[UE]: => ' . l:job_cmd

	" Clear quickfix
	call setqflist([])

	" Setup buffer
	let l:current_buffer = bufnr('%')
	let s:ue_buf_id = bufnr(s:ue_buf_name, 1)

	call setbufvar(s:ue_buf_id, '&buftype', 'nofile')
	call setbufvar(s:ue_buf_id, '&modifiable', 1)
	silent call deletebufline(s:ue_buf_id, 1, '$')
	call setbufvar(s:ue_buf_id, '&modifiable', 0)

	" Start UBT job
	let l:job_opts = {
		\ 'on_stdout': function('s:on_stdout'),
		\ 'on_stderr': function('s:on_stderr'),
		\ 'on_exit': function('s:on_exit')
	\}
	let s:ue_ubt_job_id = jobstart(l:job_cmd, l:job_opts)
	let s:ue_ubt_running = s:ue_ubt_job_id != 0
endfunction

function! ue#build_singlefile(...)
	let l:filename = expand('%p')
	let l:build_args = '-SingleFile=' . l:filename
	let l:build_args = a:0 ? l:build_args . ' ' . join(a:000, ' ') : l:build_args
	call ue#build_target(l:build_args)
endfunction

function! ue#cancel_build()
	if s:ue_ubt_running != 0 && s:ue_ubt_job_id != 0
		call jobstop(s:ue_ubt_job_id)
	endif
endfunction

function! ue#build(target,...)
	let l:target = matchstr(a:target, '\v^(client|server|game|editor)')
	if strlen(l:target) == 0
		echo '[UE]: Invalid target name (client|server|game|editor)'
	endif

	let l:platform = a:0 ? a:1 : 'win64'
	if strlen(matchstr(l:platform, '\v^(win32|win64|linux|ps4|android|switch)')) == 0
		echo '[UE]: Invalid platform (win32|win64|linux|ps4|android|switch)'
	endif

	let l:configuration = a:0 > 1 ? a:2 : 'development'

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
		call ue#build_target()
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
	echo '[UE]: ' . l:project_name . ' project added'
endfunction

function! ue#set_project(project_name)
	if strlen(a:project_name) == 0
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
		for l:i in range(0, len(s:ue_projects)-1)
			let l:project = s:ue_projects[l:i]
			if l:project.name == a:project_name
				let s:ue_current_project_id = l:i
				echo '[UE]: Project set to ' . a:project_name
			endif
		endfor
	endif
endfunction!

function! ue#init(ue_engine_dir)
	let s:ue_engine_dir = a:ue_engine_dir
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
endfunction

function! ue#try_init()
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
	if l:found != 0
		call ue#init(l:dir)
	endif
endfunction

"//////////////////////////////////////////////////////////////////////////////
" Commands

command! -nargs=+ UEinit call ue#init(<f-args>)
command! -nargs=0 UEtryinit call ue#try_init()
command! -nargs=1 UEaddproject call ue#add_project(<q-args>)
command! -nargs=? UEproject call ue#set_project(<q-args>)
command! -nargs=* UEbuild call ue#build(<f-args>)
command! -nargs=* UEbuildtarget call ue#build_target(<f-args>)
command! -nargs=* UEbuildfile call ue#build_singlefile(<f-args>)
command! -nargs=0 UEcancelbuild call ue#cancel_build()
