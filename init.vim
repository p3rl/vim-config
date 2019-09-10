call plug#begin('~\nvim\plugged')
Plug 'lifepillar/vim-solarized8'
Plug 'jremmen/vim-ripgrep'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'morhetz/gruvbox'
Plug 'srcery-colors/srcery-vim'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-vinegar'
"Plug 'nixprime/cpsm'
call plug#end()

" Rg
set grepprg=rg\--vimgrep
"set grepformat=%f:%l:%m

" CtrlP
let g:ctrlp_by_filename = 1
let g:ctrlp_use_caching = 1
let g:ctrlp_max_files = 0
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'w'
let g:ctrlp_user_command = 'fd -e h -e hpp -e c -e cpp --type f --color never "" %s'
let g:ctrlp_root_markers= ['.p4ignore.txt', '.git']
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe

"//////////////////////////////////////////////////////////////////////////////
" Theme
let g:lightline = {
      \ 'colorscheme': 'solarized',
      \ }
set termguicolors
set background=light
colorscheme solarized8_high
let g:solarized_italics=0
"set background=light
"colorscheme srcery
"set guifont=Consolas:h10
set guifont=Fira\ Code\ Medium:h10
"set guifont=Fantasque\ Sans\ Mono\:h11

"//////////////////////////////////////////////////////////////////////////////
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

"//////////////////////////////////////////////////////////////////////////////
" Commands
command! CopyPath :let @+= expand("%:p")
command! PrintPath echo expand("%:p")
command! PFourOpen !p4 open %
command! P4o !p4 open %
command! ReloadBuffer :e %
command! ForceReloadBuffer :e! %
command! EditVimConfig :e ~\AppData\Local\Nvim\init.vim
    
"//////////////////////////////////////////////////////////////////////////////
" Mappings
tnoremap <Esc> <C-\><C-n>
inoremap <C-space> <Esc>
noremap <silent> <Esc> :noh<CR>
noremap <F1> :CtrlP .<CR>
cnoremap <C-space> <Esc>
nnoremap <Tab> /
nnoremap <F9> :PrintPath <CR>
nnoremap <F10> :CopyPath <CR>
nnoremap <F11> :ReloadBuffer <CR>
nnoremap <C-F11> :ForceReloadBuffer <CR>
nnoremap <C-F1> :EditVimConfig <CR>
nnoremap <S-k> kzz
nnoremap <S-j> jzz

" Mappings - Perforce
nnoremap <S-F5> :PFourOpen <CR>

" Mappings - Move
nnoremap <S-h> 0
nnoremap <S-l> $

" Mappings - Copy/Paste
vnoremap <A-y> "*y
nnoremap <A-p> "*p
cnoremap <A-c>p <C-r>"
cnoremap <A-p> <C-r>*

" Mappings - Buffers
nnoremap <silent> <C-j> :bprev<CR>
nnoremap <silent> <C-k> :bnext<CR>

" Mappings - Windows
nnoremap <C-Right> :vsplit<CR>
nnoremap <C-Up> :split<CR>
noremap <C-Down> <C-w>=

" Mappings - Auto close
" inoremap ( ()<Left>
inoremap { {}<Left>
inoremap [ []<Left>

" Mappings - CTag
noremap <F12> byw:tag<space><C-r>" <CR>
