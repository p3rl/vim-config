call plug#begin('~\nvim\plugged')
Plug 'lifepillar/vim-solarized8'
Plug 'arcticicestudio/nord-vim'
"Plug 'relastle/bluewery.vim'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-vinegar'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
call plug#end()

"//////////////////////////////////////////////////////////////////////////////
" Perforce
"
function! s:P4Cmd(sCmd)
    let sReturn = ""
    let sCommandLine = "p4 " . a:sCmd
    let v:errmsg = ""
    return system(sCommandLine)
    if v:errmsg == ""
        if match(sReturn, "Perforce password (P4PASSWD) invalid or unset\.") != -1
            let v:errmsg = "Not logged in to Perforce."
        elseif v:shell_error != 0
            let v:errmsg = sReturn
        else
            return sReturn
        endif
    endif
endfunction

function! s:P4BufferCmd(sCmd)
	return s:P4Cmd(a:sCmd . " " . expand("%:p")) 
endfunction

function! s:P4FileChanges()
	return s:P4BufferCmd("changes -m10")
endfunction

function! s:P4FileOpen()
	return s:P4BufferCmd("open")
endfunction

function! s:P4FileRevert()
	return s:P4BufferCmd("revert")
endfunction

function! P4FileLog()
	let filelog = s:P4BufferCmd("filelog")
	let lines = split(filelog, '\v\n')
	let changes = lines[1: -1]

	vsplit P4 FileLog
	normal! ggdG
    setlocal buftype=nofile

	for line in changes
		let tokens = split(line)
		let chr = tokens[1][1]
		call append(0, chr)
	endfor
endfunction

"//////////////////////////////////////////////////////////////////////////////
" FZF
let $FZF_DEFAULT_OPTS = '--layout=reverse'

let g:fzf_layout = { 'window': 'call FloatingFZF()' }

function! FloatingFZF()
  let buf = nvim_create_buf(v:false, v:true)
  let height = float2nr(&lines * 0.3)
  let width = float2nr(&columns * 0.6)
  let horizontal = float2nr((&columns - width) / 2)
  let vertical = 0

  let opts = {
        \ 'relative': 'editor',
        \ 'row': vertical,
        \ 'col': horizontal,
        \ 'width': width,
        \ 'height': height
        \ }

  call nvim_open_win(buf, v:true, opts)
endfunction

"//////////////////////////////////////////////////////////////////////////////
" Theme settings
set termguicolors
set background=dark
colorscheme nord
"colorscheme solarized8_high
"colorscheme bluewery
let g:solarized_italics=0
let g:nord_italic = 1

"//////////////////////////////////////////////////////////////////////////////
" Lightline
function! LightlineFileNameHead()
	return expand("%:h")
endfunction

let g:lightline = {
      \ 'colorscheme': 'nord',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified', 'filenamehead' ] ]
      \ },
      \ 'component_function': {
      \   'filenamehead': 'LightlineFileNameHead'
      \ },
      \ }

"//////////////////////////////////////////////////////////////////////////////
" UE
let g:ue_default_projects = [
	\ 'Samples\Games\ShooterGame\ShooterGame.uproject',
	\ 'FortniteGame\FortniteGame.uproject'
	\]

" Editing settings
syntax enable
set encoding=utf-8
set tabstop=4
set softtabstop=4
"set expandtab
set shiftwidth=4
set autoindent
set smartindent
set smarttab
set laststatus=2

"//////////////////////////////////////////////////////////////////////////////
" General settings
set splitright
set showmatch
set ignorecase
set number
set incsearch
set hlsearch
set backspace=indent,eol,start
set hidden
set nowrap
set noswapfile
set nobackup
set nowb
set cursorline
set autoread
set listchars=tab::.
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe
set grepprg=findstr\ /s\ /n
set scrolloff=5
let g:netrw_fastbrowse = 0

"//////////////////////////////////////////////////////////////////////////////
" Commands
command! -nargs=+ G execute 'silent grep' <q-args> | copen | redraw!
command! CopyPath :let @+= expand("%:p")
command! PrintPath echo expand("%:p")
command! ReloadBuffer :e %
command! ForceReloadBuffer :e! %
command! EditVimConfig :e ~\AppData\Local\Nvim\init.vim
command! EditGVimConfig :e ~\AppData\Local\Nvim\ginit.vim

nnoremap <F5> :UEbuild<CR>
    
"//////////////////////////////////////////////////////////////////////////////
" Mappings
tnoremap <Esc> <C-\><C-n>
inoremap <C-space> <Esc>
inoremap <C-return> <Esc>
noremap <silent> <Esc> :noh<CR>
noremap <C-p> :FZF .<CR>
noremap <C-Tab> :Buffers<CR>
cnoremap <C-space> <Esc>
nnoremap <F9> :PrintPath <CR>
nnoremap <F10> :CopyPath <CR>
nnoremap <F11> :ReloadBuffer <CR>
nnoremap <C-F11> :ForceReloadBuffer <CR>
nnoremap <C-F12> :EditVimConfig <CR>
nnoremap <S-F12> :EditGVimConfig <CR>
nnoremap <A-F12> :so % <CR>
nnoremap <S-k> kzz
nnoremap <S-j> jzz
nnoremap <silent> <F1> :copen<CR>
nnoremap <silent> <S-F1> :close<CR>
nnoremap n nzz
nnoremap N Nzz

" Mappings - Grep
nnoremap gw :vim <cword> %<CR>:copen<CR>

" Mappings - Quickfix
nnoremap <silent><C-w>u :copen<CR>
nnoremap <silent><C-w>i :cclose<CR>
nnoremap <silent><A-j> :cn<CR>
nnoremap <silent><A-k> :cp<CR>

" Mappings - Perforce
map <silent> <S-F5> :echo <SID>P4FileOpen()<CR>
map <silent> <C-F5> :echo <SID>P4FileRevert()<CR>
map <silent> <S-F6> :echo <SID>P4FileChanges()<CR>

" Mappings - Move
nnoremap <S-h> 0
nnoremap <S-l> $

" Mappings - Copy/Paste/Save
vnoremap <A-y> "*y
nnoremap <A-p> "*p
cnoremap <A-c>p <C-r>"
cnoremap <A-p> <C-r>*
nnoremap <C-s> :w<Cr>

" Mappings - Buffers
nnoremap <silent> <C-j> :bprev<CR>
nnoremap <silent> <C-k> :bnext<CR>

" Mappings - Windows
noremap <C-Down> <C-w>=

" Mappings - Auto close
" inoremap ( ()<Left>
inoremap { {}<Left>
inoremap [ []<Left>

" Mappings - CTag
noremap <F12> byw:tag<space><C-r>" <CR>

" Mappings - Windows
nnoremap <silent><A-Up> :resize +1<CR>
nnoremap <silent><A-Down> :resize -1<CR>
nnoremap <silent><A-Left> :vertical resize -1<CR>
nnoremap <silent><A-Right> :vertical resize +1<CR>

" Mappings - Windows
nnoremap <F5> :UEstartbuild<CR>
