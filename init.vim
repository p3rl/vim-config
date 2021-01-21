"//////////////////////////////////////////////////////////////////////////////
" Plugins
call plug#begin(stdpath('data') . '/plugged')
Plug 'lifepillar/vim-solarized8'
Plug 'sonph/onehalf', {'rtp': 'vim/'}
Plug 'bluz71/vim-nightfly-guicolors'
Plug 'lifepillar/vim-gruvbox8'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-vinegar'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'zigford/vim-powershell'
"Plug 'neovim/nvim-lspconfig'
Plug 'Rigellute/rigel'
Plug 'ghifarit53/tokyonight-vim'
call plug#end()

"//////////////////////////////////////////////////////////////////////////////
" Internal plugin(s)
exec 'source ' . stdpath('config') . '/p4.vim'
exec 'source ' . stdpath('config') . '/ue.vim'
exec 'source ' . stdpath('config') . '/agrep.vim'
"exec 'source ' . stdpath('config') . '/buffer.vim'
"//////////////////////////////////////////////////////////////////////////////
" Quickfix
function! s:read_psue_quickfix()
	call setqflist([])
	let l:root = getcwd()
	let l:psue_qf = l:root . '\.psue\quickfix.txt'
	exec printf('cfile %s', l:psue_qf)
endfunction

function! s:is_quickfix_window_open()
	for win_id in range(1, winnr('$'))
		let l:filetype = getwinvar(win_id, '&filetype')
		if l:filetype == 'qf'
			return 1
		endif
	endfor
	return 0
endfunction

function! s:toggle_quickfix_window(window_height)
	if (s:is_quickfix_window_open())
		exec 'cclose'
	else
		let l:height = a:window_height > 0 ? a:window_height : 10
		exec printf('botright copen %d', l:height)
	endif
endfunction

command! -nargs=? ToggleQuickFix call s:toggle_quickfix_window(<q-args>)
command! -nargs=0 ReadPSUEQuickFix call s:read_psue_quickfix()
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
set grepprg=rg\ --vimgrep
set grepformat^=%f:%l:%c:%m
"set grepprg=ugrep
autocmd QuickFixCmdPost *grep* bo cwindow 20
"autocmd QuickFixCmdPost *ugrep* bo cwindow 20
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
inoremap jj <Esc>
inoremap JJ <Esc>
inoremap jk <Esc>
inoremap JK <Esc>
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
nnoremap n nzz
nnoremap N Nzz
nnoremap S :%s/\<<C-R>=expand('<cword>')<CR>\>/<C-R>=expand('<cword>')<CR>/g<Left><Left>
noremap <C-n> :b#<CR>
vmap < <gv
vmap > >gv
inoremap <F5> <C-R>=strftime('%c')<CR>
inoremap <F9> PRAGMA_DISABLE_OPTIMIZATION
inoremap <S-F9> PRAGMA_ENABLE_OPTIMIZATION

" Mappings - Grep
nnoremap gw :vim <cword> %<CR>:copen<CR>
nnoremap Gw :G<space><C-R>=expand('<cword>')<CR>
nnoremap <F2> :Agrep<space><C-R>=expand('<cword>')<CR><CR>

" Mappings - Quickfix
nnoremap <silent><C-w>u :ToggleQuickFix 30<CR>
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
nnoremap <silent><A-Up> :resize +2<CR>
nnoremap <silent><A-Down> :resize -2<CR>
nnoremap <silent><A-Left> :vertical resize -2<CR>
nnoremap <silent><A-Right> :vertical resize +2<CR>

" Mappings - Diff
nnoremap <C-2> ]c
nnoremap <C-3> [c

" Mappings - Unreal
"nnoremap <F5> :UEbuildtarget<CR>
"nnoremap <C-F5> :UEbuildfile<CR>
"nnoremap <S-F5> :UEcancelbuild<CR>

" Mappings - P4
nnoremap <F4> :P4edit<CR>
nnoremap <S-F4> :P4revert<CR>:e! %<CR>

" Mappings - PSUE
nnoremap <F3> :ReadPSUEQuickFix<CR>

"//////////////////////////////////////////////////////////////////////////////
" FZF
let $FZF_DEFAULT_OPTS = '--layout=reverse'
let g:fzf_preview_window = ''
let g:fzf_buffers_jump = 1
let g:fzf_tags_command = 'ctags -R'
"let g:fzf_layout = { 'window': 'call FloatingFZF()' }
let g:fzf_layout = { 'down': '20%' }
let g:fzf_history_dir = stdpath('data') . '/fzf-history'

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

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#grep, <bang>0)

"//////////////////////////////////////////////////////////////////////////////
" Theme settings
set termguicolors
set background=light
"colorscheme onehalflight
"colorscheme rigel
colorscheme gruvbox8_hard
"colorscheme onehalfdark
"colorscheme nightfly
"colorscheme solarized8_high
"colorscheme tokyonight
let g:solarized_italics=1
let g:solarized_extra_hi_groups=1
let g:tokyonight_style = 'night' " available: night, storm
let g:tokyonight_enable_italic = 1

" Disable function highlighting (affects both C and C++ files)
let g:cpp_no_function_highlight = 0

" Enable highlighting of C++11 attributes
let g:cpp_attributes_highlight = 1

" Highlight struct/class member variables (affects both C and C++ files)
let g:cpp_member_highlight = 0

" Put all standard C and C++ keywords under Vim's highlight group 'Statement'
" (affects both C and C++ files)
let g:cpp_simple_highlight = 1

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
\	'colorscheme': 'gruvbox8',
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
"//////////////////////////////////////////////////////////////////////////////
" LSP
"lua <<EOF
"local nvim_lsp = require('nvim_lsp')
"nvim_lsp.clangd.setup { 
"	root_dir = nvim_lsp.util.root_pattern('compile_commands.json'),
"	cmd = { "clangd", "--background-index" }
"}
"EOF
"nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
"nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
"nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
"nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
"nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
"nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
"nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
"nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
"nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
