call plug#begin('~\nvim\plugged')
Plug 'nightsense/carbonized'
Plug 'lifepillar/vim-solarized8'
Plug 'jremmen/vim-ripgrep'
call plug#end()

" Theme
set encoding=utf-8
set termguicolors
set background=light
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

" Mappings
tnoremap <Esc> <C-\><C-n> 
nnoremap <C-N> :bnext<CR>
nnoremap <C-P> :bprev<CR>

