"//////////////////////////////////////////////////////////////////////////////
" Plugins

call plug#begin(stdpath('data') . '/plugged')
Plug 'lifepillar/vim-solarized8'
Plug 'NLKNguyen/papercolor-theme'
Plug 'relastle/bluewery.vim'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-vinegar'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
"Plug 'octol/vim-cpp-enhanced-highlight'
call plug#end()

exec 'source ' . stdpath('config') . '/p4.vim'
exec 'source ' . stdpath('config') . '/ue.vim'

"//////////////////////////////////////////////////////////////////////////////
" FZF
let $FZF_DEFAULT_OPTS = '--layout=reverse'
let g:fzf_preview_window = ''
let g:fzf_layout = { 'window': 'call FloatingFZF()' }

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

"//////////////////////////////////////////////////////////////////////////////
" Theme settings

set termguicolors
set background=light
"colorscheme PaperColor
colorscheme solarized8_high
"colorscheme bluewery
let g:solarized_italics=1
let g:solarized_extra_hi_groups=1

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

" Lightline
function! LightlineFileNameHead()
	return expand("%:h")
endfunction

let g:lightline = {
\	'colorscheme': 'solarized8',
\	'active': {
\		'left': [ [ 'mode', 'paste' ], [ 'readonly', 'filename', 'modified', 'filenamehead' ] ],
\	},
\	'component_function': {
\		'filenamehead': 'LightlineFileNameHead',
\		'ue_build_status': 'UEBuildStatus'
\	},
\ }

"//////////////////////////////////////////////////////////////////////////////
" UE
let g:ue_default_projects = [
	\ 'Samples/Games/ShooterGame/ShooterGame.uproject',
	\ 'FortniteGame/FortniteGame.uproject']

"//////////////////////////////////////////////////////////////////////////////
" General settings
language en
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
set grepprg=rg.exe\ -tcpp\ -tcs\ -tpy\ --vimgrep
autocmd QuickFixCmdPost *grep* bo cwindow 20
set scrolloff=5
let g:netrw_fastbrowse = 0
set mouse=n
set clipboard=unnamedplus

"//////////////////////////////////////////////////////////////////////////////
" Commands
command! -nargs=+ G execute 'silent grep' <q-args>
command! CopyPath :let @+= expand("%:p") | echo 'Copied -> ' . expand("%:p")
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
nnoremap <silent><C-F10> :P4copydepotpath <CR>
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

inoremap <F5> <C-R>=strftime('%c')<CR>

" Mappings - Grep
nnoremap gw :vim <cword> %<CR>:copen<CR>

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

" Mappings - Diff
nnoremap <C-2> ]c
nnoremap <C-3> [c

" Mappings - Unreal
nnoremap <F5> :UEbuildtarget<CR>
nnoremap <C-F5> :UEbuildfile<CR>
nnoremap <S-F5> :UEcancelbuild<CR>
