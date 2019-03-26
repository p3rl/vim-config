call plug#begin('~\nvim\plugged')
Plug 'lifepillar/vim-solarized8'
Plug 'jremmen/vim-ripgrep'
Plug 'ctrlpvim/ctrlp.vim'
call plug#end()

" CtrlP
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_user_command = 'fd --type f --color never "" %s'
let g:ctrlp_root_markers= ['.p4ignore', '.git']
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe

" Theme
set encoding=utf-8
set termguicolors
set background=dark
colorscheme solarized8

" Editing settings
syntax enable
set tabstop=4
set expandtab
set shiftwidth=4
set autoindent
set smartindent

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

" Mappings
tnoremap <Esc> <C-\><C-n>
nnoremap <silent> <C-Tab> :bnext<CR>
inoremap <A-i> <Esc>
noremap <C-i> :noh<CR>/
noremap <silent> <Esc> :noh<CR>

" Mappings - Copy/Pase
vnoremap <a-y> "*y
nnoremap <a-p> "*p
cnoremap <a-c>p <C-r>"

" Mappings - Windows
nnoremap <C-Right> :vsplit<CR>
nnoremap <C-Up> :split<CR>

" Mappings - Auto close
inoremap ( ()<Left>
inoremap { {}<Left>

" Commands
command! CopyPath :let @+= expand("%:p")

