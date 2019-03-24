call plug#begin('~\nvim\plugged')
Plug 'nightsense/carbonized'
Plug 'lifepillar/vim-solarized8'
Plug 'jremmen/vim-ripgrep'
call plug#end()

set encoding=utf-8
set termguicolors
set background=light
colorscheme solarized8

syntax enable
set tabstop=4
set expandtab
set shiftwidth=4
set autoindent
set smartindent

set splitright
set showmatch
set ignorecase
set number
set incsearch
set hlsearch
set backspace=indent,eol,start

tnoremap <Esc> <C-\><C-n> 
