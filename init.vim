call plug#begin('~\nvim\plugged')
Plug 'lifepillar/vim-solarized8'
Plug 'jremmen/vim-ripgrep'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-vinegar'
Plug 'junegunn/fzf'
call plug#end()

" Rg
set grepprg=rg\--vimgrep
"set grepformat=%f:%l:%m

set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe

"//////////////////////////////////////////////////////////////////////////////
" Perforce
"
function! s:P4Cmd(sCmd)
    let sReturn = ""
    let sCommandLine = "p4 " . a:sCmd
    let v:errmsg = ""
    let sReturn = system(sCommandLine)
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

"//////////////////////////////////////////////////////////////////////////////
" Theme
set termguicolors
set background=light
let g:lightline = {
      \ 'colorscheme': 'solarized',
      \ }
colorscheme solarized8_high
let g:solarized_italics=0
"set guifont=Fira\ Code\ Medium:h10

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

"//////////////////////////////////////////////////////////////////////////////
" Commands
command! CopyPath :let @+= expand("%:p")
command! PrintPath echo expand("%:p")
command! P4o !p4 open %
command! ReloadBuffer :e %
command! ForceReloadBuffer :e! %
command! EditVimConfig :e ~\AppData\Local\Nvim\init.vim
    
"//////////////////////////////////////////////////////////////////////////////
" Mappings
tnoremap <Esc> <C-\><C-n>
inoremap <C-space> <Esc>
"inoremap <S-space> <Esc>
noremap <silent> <Esc> :noh<CR>
noremap <F1> :FZF .<CR>
cnoremap <C-space> <Esc>
nnoremap <F9> :PrintPath <CR>
nnoremap <F10> :CopyPath <CR>
nnoremap <F11> :ReloadBuffer <CR>
nnoremap <C-F11> :ForceReloadBuffer <CR>
nnoremap <C-F12> :EditVimConfig <CR>
nnoremap <S-k> kzz
nnoremap <S-j> jzz

" Mappings - Perforce
map <silent> <S-F5> :echo <SID>P4FileOpen()<CR>
map <silent> <C-F5> :echo <SID>P4FileRevert()<CR>
map <silent> <S-F6> :echo <SID>P4FileChanges()<CR>

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
