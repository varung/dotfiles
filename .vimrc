" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2002 May 28
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Switch Windows and maximize in one keypress
set wmh=0

map <C-C> :s/^/\/\//<CR>

let g:miniBufExplMapWindowNavVim = 1 
let g:miniBufExplMapWindowNavArrows = 1 
let g:miniBufExplMapCTabSwitchBufs = 1 
let g:miniBufExplModSelTarget = 1 

" make tab sizes smaller (4 instead of 8) and all spaces...
set sw=2
set ts=2
set ic
set expandtab
set smarttab
" set smartindent
set cindent
:set comments=sl:/**,mb:\ *,elx:\ */
"colorscheme darkblue
"color darkblue
vnoremap p <Esc>:let current_reg = @"<CR>gvs<C-R>=current_reg<CR><Esc>

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set ts=4
set autoindent		" always set autoindenting on

set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set hlsearch

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
syntax on
set hlsearch
"colorscheme darkblue

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

endif " has("autocmd")

nmap <space> za
nmap <F2> :cp<CR>
nmap <F3> :cn<CR>
nmap <F4> :grep <C-R>" *.cpp *.h <CR>
nmap <F5> :redraw! <CR>
nmap <F6> :tp<CR>
nmap <F7> :tn<CR>

"RENUMBER LINES, useful for lists
nmap <F8> :'<,'>! awk '/[0-9]+\. .*/ { $1 = i++ "."} {print}'<CR>
redraw!
let g:clang_cpp_options = '-std=c++11 -stdlib=libc++ -I../../redis_stuff/hiredis -I/usr/local/include'
let g:clang_cpp_completeopt = 'longest,menuone,preview'

"" VARUN ADDED
" fix meta-keys which generate <esc>a .. <esc>z
"let c='a'
"while c != 'z'
"    exec "set <M-".toupper(c).">=\e".c
"    exec "imap \e".c." <M-".toupper(c).">"
"    let c = nr2char(1+char2nr(c))
"endw 
"
"set nocompatible              " be iMproved, required
"filetype off                  " required
"
"" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
" call vundle#begin('~/some/path/here')
" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
Bundle 'solarnz/thrift.vim'
Plugin 'fatih/vim-go'
Plugin 'Shougo/neocomplete.vim'
Plugin 'justmao945/vim-clang'
Plugin 'majutsushi/tagbar'
Plugin 'Shougo/vimproc.vim'
Plugin 'Shougo/vimshell.vim'
Plugin 'vim-utils/vim-man'
Plugin 'mileszs/ack.vim'
Plugin 'easymotion/vim-easymotion'

call vundle#end()            " required
filetype plugin indent on    " required

let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
nmap s <Plug>(easymotion-overwin-f)

" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
" nmap s <Plug>(easymotion-overwin-f2)
" Turn on case insensitive feature
let g:EasyMotion_smartcase = 1
" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

set backupdir=$HOME/.backup
set backup
set writebackup
set directory=$HOME/.backup

nmap <C-b> :!ssh root@192.168.99.100 "cd /root/fuse-2.9.2/repfs; make;"<CR>
colorscheme elflord

execute pathogen#infect()
syntax on
filetype plugin indent on
colorscheme zellner

let g:ConqueTerm_CWInsert = 1
colorscheme elflord

au BufNewFile,BufRead *.cpp set syntax=cpp11
au BufNewFile,BufRead *.cc  set syntax=cpp11
au BufNewFile,BufRead *.hpp set syntax=cpp11

au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)

let g:neocomplete#enable_at_startup = 1 

function HighlightNearCursor()
  if !exists("s:highlightcursor")
    match Todo /\k*\%#\k*/
    let s:highlightcursor=1
  else
    match None
    unlet s:highlightcursor
  endif
endfunction
nnoremap <C-K> :call HighlightNearCursor()<CR>

let g:go_fmt_command = "goimports"
map <C-n> :lne<CR>
map <C-m> :lp<CR>

" from http://stevelosh.com/blog/2010/09/coming-home-to-vim/
set encoding=utf-8
set scrolloff=3
set autoindent
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set visualbell
set cursorline
set ttyfast
set ruler
set backspace=indent,eol,start
set laststatus=2
" set relativenumber
set undofile
let mapleader = ","

set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch
nnoremap <leader><space> :noh<cr>
nnoremap <tab> %
vnoremap <tab> %

set wrap
set textwidth=79
set formatoptions=qrn1
set colorcolumn=85

nnoremap j gj
nnoremap k gk

nnoremap ; :
inoremap jj <ESC>
nnoremap <leader>w <C-w>v<C-w>l


nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <silent> <F3> :YRShow<cr>
inoremap <silent> <F3> <ESC>:YRShow<cr>

