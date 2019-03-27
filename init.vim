call plug#begin('~\nvim\plugged')
Plug 'lifepillar/vim-solarized8'
Plug 'jremmen/vim-ripgrep'
Plug 'ctrlpvim/ctrlp.vim'
call plug#end()

" Rg
set grepprg=rg\ --vimgrep\ --no-heading
set grepformat=%f:%l:%m

" CtrlP
let g:ctrlp_by_filename = 1
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'w'
let g:ctrlp_user_command = 'fd -e h -e hpp -e c -e cpp --type f --color never "" %s'
let g:ctrlp_root_markers= ['.p4ignore.txt', '.git']
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe

" Theme
set encoding=utf-8
set termguicolors
set background=dark
colorscheme solarized8

" Editing settings
syntax enable
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4
set autoindent
set smartindent
set smarttab

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

" Commands
command! CopyPath :let @+= expand("%:p")

" Mappings
tnoremap <Esc> <C-\><C-n>
nnoremap <silent> <C-Tab> :bnext<CR>
inoremap <A-i> <Esc>
noremap <C-i> :noh<CR>/
noremap <silent> <Esc> :noh<CR>
noremap <F1> :CtrlP .<CR>

" Mappings - Copy/Pase
vnoremap <a-y> "*y
nnoremap <a-p> "*p
cnoremap <a-c>p <C-r>"

" Mappings - Windows
nnoremap <C-Right> :vsplit<CR>
nnoremap <C-Up> :split<CR>
noremap <C-Down> <C-w>=

" Mappings - Auto close
inoremap ( ()<Left>
inoremap { {}<Left>

