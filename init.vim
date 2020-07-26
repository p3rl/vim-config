"//////////////////////////////////////////////////////////////////////////////
" Plugins
call plug#begin(stdpath('data') . '/plugged')
Plug 'lifepillar/vim-solarized8'
Plug 'NLKNguyen/papercolor-theme'
Plug 'relastle/bluewery.vim'
Plug 'morhetz/gruvbox'
Plug 'sonph/onehalf', {'rtp': 'vim/'}
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-vinegar'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'zigford/vim-powershell'
call plug#end()
"//////////////////////////////////////////////////////////////////////////////
" Internal plugin(s)
exec 'source ' . stdpath('config') . '/p4.vim'
exec 'source ' . stdpath('config') . '/ue.vim'
"//////////////////////////////////////////////////////////////////////////////
" General settings
language en
syntax enable
set encoding=utf-8
set noshowmode
set tabstop=4
set softtabstop=4
"set expandtab
set shiftwidth=4
set autoindent
set smartindent
set cindent
set smarttab
set laststatus=2
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
"set grepprg=findstr\ /s\ /n
set grepprg=rg.exe\ -tcpp\ -tcs\ -tpy\ -th\ -tini\ -vimgrep
autocmd QuickFixCmdPost *grep* bo cwindow 20
set scrolloff=5
let g:netrw_fastbrowse = 0
set mouse=n
set clipboard=unnamedplus
filetype on
filetype plugin on
filetype indent on
"//////////////////////////////////////////////////////////////////////////////
" Commands
command! -nargs=+ G execute 'silent grep' <q-args>
command! CopyPath :let @+= expand("%:p") | echo expand("%:p")
command! ReloadBuffer :e %
command! ForceReloadBuffer :e! %
command! EditVimConfig exec printf(':e %s/init.vim', stdpath('config'))
command! EditGVimConfig exec printf(':e %s/ginit.vim', stdpath('config'))
command! Notes exec ':e c:/git/docs/ue/ue.md'
"//////////////////////////////////////////////////////////////////////////////
" Mappings
tnoremap <Esc> <C-\><C-n>
inoremap <C-space> <Esc>
noremap <silent> <Esc> :noh<CR>
noremap <C-Tab> :Buffers<CR>
noremap <C-p> :FZF .<CR>
cnoremap <C-space> <Esc>
nnoremap <F10> :CopyPath <CR>
nnoremap <silent><F9> :P4copydepotpath <CR>
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
nnoremap S :%s/\<<C-R>=expand('<cword>')<CR>\>/<C-R>=expand('<cword>')<CR>/g<Left><Left>
vmap < <gv
vmap > >gv
inoremap <F5> <C-R>=strftime('%c')<CR>

" Mappings - Grep
nnoremap gw :vim <cword> %<CR>:copen<CR>
nnoremap Gw :G<space><C-R>=expand('<cword>')<CR>

" Mappings - Quickfix
nnoremap <silent><C-w>u :copen<CR>
nnoremap <silent><C-w>i :cclose<CR>
nnoremap <silent><A-h> :cfirst<CR>
nnoremap <silent><A-j> :cn<CR>
nnoremap <silent><A-k> :cp<CR>

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

" Mappings - Diff
nnoremap <C-2> ]c
nnoremap <C-3> [c

" Mappings - Unreal
nnoremap <F5> :UEbuildtarget<CR>
nnoremap <C-F5> :UEbuildfile<CR>
nnoremap <S-F5> :UEcancelbuild<CR>
" Mappings - P4
nnoremap <F4> :P4edit<CR>
nnoremap <S-F4> :P4revert<CR>:e! %<CR>
"//////////////////////////////////////////////////////////////////////////////
" FZF
let $FZF_DEFAULT_OPTS = '--layout=reverse'
let g:fzf_preview_window = ''
"let g:fzf_layout = { 'window': 'call FloatingFZF()' }

function! FloatingFZF()
  let buf = nvim_create_buf(v:false, v:true)
  let height = float2nr(&lines * 0.3)
  let width = float2nr(&columns * 0.6)
  let horizontal = float2nr((&columns - width) / 2)
  let vertical = float2nr(&lines * 0.3)

  let opts = {
        \ 'relative': 'editor',
        \ 'row': vertical,
        \ 'col': horizontal,
        \ 'width': width,
        \ 'height': height
        \ }

  call nvim_open_win(buf, v:true, opts)
endfunction

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, spec, a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
"//////////////////////////////////////////////////////////////////////////////
" Theme settings
set termguicolors
set background=light
colorscheme onehalfdark
"colorscheme solarized8_high
"colorscheme bluewery
let g:solarized_italics=1
let g:solarized_extra_hi_groups=1
let g:gruvbox_italicize_comments=1
let g:gruvbox_contrast_dark=1

" PaperColor
let g:PaperColor_Theme_Options = {
 \	'language': {
 \		'cpp': {
 \			'highlight_standard_library': 1
 \		},
 \		'c': {
 \			'highlight_builtins' : 1
 \		}
 \	}
\}
"//////////////////////////////////////////////////////////////////////////////
" Lightline
function! LightlineFileNameHead()
	return expand("%:h")
endfunction

function! LightlineCurrentWorkingDir()
	return getcwd()
endfunction

function! LightlineBuildStatus()
	return g:ue_build_status_text
endfunction

let g:lightline = {
\	'colorscheme': 'onehalfdark',
\	'active': {
\		'left': [ [ 'readonly', 'filename', 'modified' ], [ 'head', 'buildstatus' ] ],
\	},
\	'component_function': {
\		'cwd': 'LightlineCurrentWorkingDir',
\		'head': 'LightlineFileNameHead',
\		'buildstatus': 'LightlineBuildStatus'
\	},
\ }
"//////////////////////////////////////////////////////////////////////////////
" UE
let g:ue_default_projects = [
	\ 'Samples/Games/ShooterGame/ShooterGame.uproject',
	\ 'FortniteGame/FortniteGame.uproject']

