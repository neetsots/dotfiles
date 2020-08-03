"**********************************************************************
" NVIM Configuration
"**********************************************************************
let mapleader="\<Space>"

if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.config/nvim/plugged')
" Research
" <<<<
  Plug 'jremmen/vim-ripgrep'
        map <Leader>R :Rg<CR>
  Plug 'junegunn/fzf'
        map <Leader>f :FZF<CR>
  Plug 'majutsushi/tagbar'
        map <Leader>t :TagbarToggle<CR>
" >>>>

" Linting
" <<<<
  Plug 'tell-k/vim-autopep8'
" >>>>

" Langage server manager
" <<<<
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
        nmap <Leader>n :CocCommand explorer<CR>
" >>>>

" Colorscheme
" <<<<
  Plug 'emmehandes/tetradic'
" <<<<

" Tags
" <<<<
  Plug 'craigemery/vim-autotag'
" >>>>
"
" Syntax
" <<<<
  Plug 'othree/html5.vim'
  Plug 'cespare/vim-toml'
  Plug 'fatih/vim-go'
  Plug 'octol/vim-cpp-enhanced-highlight'
  Plug 'rust-lang/rust.vim'
  Plug 'nvie/vim-flake8'
  Plug 'pangloss/vim-javascript'
  Plug 'plasticboy/vim-markdown'
  Plug 'stephpy/vim-yaml'
  Plug 'jacoborus/tender.vim'
" >>>>

" Git
" <<<<
  Plug 'airblade/vim-gitgutter'
  Plug 'tpope/vim-fugitive'
  Plug 'junegunn/gv.vim'
" >>>>
call plug#end()

"-- Basic configuration -----------------------------------------------
syntax on
set number
ino <C-c> <Esc>
nnoremap <Leader>lv :so ~/.config/nvim/init.vim<CR>

"-- Splits ------------------------------------------------------------
set splitright
set splitbelow
nmap <Leader>v :vsp<CR>
nmap <Leader>h :sp<CR>
nnoremap  <C-j>  <C-W><C-J>↲
nnoremap  <C-k>  <C-W><C-K>↲
nnoremap  <C-l>  <C-W><C-L>↲
nnoremap  <C-h>  <C-W><C-H>↲

"-- Buffers management ------------------------------------------------
nmap <Leader>b :ls<CR>:buffer<Space>

"-- NVIM searching ----------------------------------------------------
set hlsearch
set incsearch
set smartcase
set showmatch

"-- NVIM replace ------------------------------------------------------
nnoremap <Leader>r :%s/\<<C-r><C-w>\>/
inoremap <C-e> <C-n><C-p>
nnoremap <esc>^[ <esc>^[

"-- Trailing ----------------------------------------------------------
au BufWritePre *.rs,*.go,*.txt,*.c*,*.py %s/\s\+$//e
au BufNewFile,BufRead,BufEnter config set filetype=toml
au BufNewFile,BufRead,BufEnter *.cpp,*.hpp set omnifunc=omni#cpp#complete#Main
au BufWinLeave *.py !autopep8 %:p

"-- Yaml --------------------------------------------------------------
autocmd FileType yaml execute
      \'syn match yamlBlockMappingKey /^\s*\zs.*\ze\s*:\%(\s\|$\)/'

"-- Completion --------------------------------------------------------
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | silent! pclose | endif

"-- Search ------------------------------------------------------------
nnoremap <Leader>s :Rg <C-r><C-w><CR>

"-- Copy / Paste ------------------------------------------------------
nnoremap <Leader>Y "*y<CR>
nnoremap <Leader>y "+y<CR>

"-- Python function help ----------------------------------------------
nnoremap <buffer> H :<C-u>execute "!pydoc3 " . expand("<cword>")<CR>

"-- General configuration ---------------------------------------------
set shell=zsh
set showbreak=↪\
set listchars=tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨
set list
set mouse=a
set directory=~/.config/nvim/swap/

set nofoldenable
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set noshiftround
set lazyredraw
set termguicolors
set background=dark
colorscheme tetradric

set clipboard=unnamedplus
set cursorline

"-- Statusline
function! GitBranch()
  return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatuslineGit()
  let l:branchname = GitBranch()
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

let g:currentMode={
       \ 'n'  : '%#NormalColor#',
       \ 'v'  : '%#VisualColor#',
       \ 'V'  : '%#VisualColor#',
       \ '' : '%#VisualColor#',
       \ 'i'  : '%#InsertColor#',
       \ 'R'  : '%#ReplaceColor#',
       \ 'c'  : '',
       \}

function! Modline(statusline) abort
  let modus = mode(1)
  let lab = get(g:currentMode, modus, modus)
  return lab.a:statusline
endfunction
set statusline&
if empty(&statusline)
  set statusline=%{StatuslineGit()}
  set statusline+=%f\ %m❯%=\  
  set statusline+=❮\ %{&fileencoding?&fileencoding:&encoding}\ ❮\ %p%%\ ❮\ %l:%c\ 
endif
let statusline=&statusline
set statusline=%!Modline(statusline)
set noshowmode
