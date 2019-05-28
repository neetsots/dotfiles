"**********************************************************************
"
" NVIM Configuration
"
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
  Plug 'scrooloose/nerdtree'
        map <Leader>n :NERDTreeToggle<CR>
" >>>>

" Completion
" <<<<
  Plug 'shougo/deoplete.nvim'
	  let g:deoplete#enable_at_startup = 1
  Plug 'deoplete-plugins/deoplete-jedi'
" >>>>

" Syntax
" <<<<
  Plug 'mattn/emmet-vim'
  Plug 'othree/html5.vim'
  Plug 'rhysd/open-pdf.vim'
  Plug 'cespare/vim-toml'
" >>>>
"
" Highlighting
" <<<<
  Plug 'emmehandes/tetradic'
  Plug 'octol/vim-cpp-enhanced-highlight'
  Plug 'rust-lang/rust.vim'
  Plug 'fatih/vim-go'
  Plug 'nvie/vim-flake8'
  Plug 'pangloss/vim-javascript'
  Plug 'plasticboy/vim-markdown'
  Plug 'dag/vim-fish'
" >>>>
"
" Jupyter Notebooks
" <<<<
  Plug 'bfredl/nvim-ipy'
" >>>>
" Git
" <<<<
  Plug 'tpope/vim-fugitive'
  Plug 'airblade/vim-gitgutter'
" >>>>
call plug#end()

"-- Basic configuration -----------------------------------------------
set termguicolors
syntax on
set number
ino <C-c> <Esc>
nnoremap <Leader>lv :so ~/.config/nvim/init.vim<CR>

"-- Splits ------------------------------------------------------------
nmap <Leader>v :vsp<CR>
nmap <Leader>h :sp<CR>
nnoremap  <C-j>  <C-W><C-J>↲
nnoremap  <C-k>  <C-W><C-K>↲
nnoremap  <C-l>  <C-W><C-L>↲
nnoremap  <C-h>  <C-W><C-H>↲

"-- Buffers management ------------------------------------------------
nmap <Leader>b :ls<CR>:buffer<Space>

"-- StatusLine --------------------------------------------------------
set laststatus=2
set statusline=
set statusline+=%#Type#
set statusline+=\|\ %f
set statusline+=\ \\\ %m
set statusline+=%=
set statusline+=%#Conditional#
set statusline+=\ \/\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\ \/\ %{&fileformat}
set statusline+=\ \/\ %l:%c
set statusline+=\ (%p%%)

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
au BufWritePre * %s/\s\+$//e
au BufNewFile,BufRead,BufEnter *.cpp,*.hpp set omnifunc=omni#cpp#complete#Main

"-- Jupyter notebooks -------------------------------------------------
autocmd Filetype ipynb nmap <silent><Leader>jb :VimpyterInsertPythonBlock<CR>
autocmd Filetype ipynb nmap <silent><Leader>js :VimpyterStartJupyter<CR>
autocmd Filetype ipynb nmap <silent><Leader>jn :VimpyterStartNteract<CR>

"-- Completion --------------------------------------------------------
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | silent! pclose | endif

set background=dark
colorscheme tetradic
set shell=bash

nnoremap <Leader>s :Rg <C-r><C-w><CR>
nnoremap <Leader>k :resize +5<CR>
nnoremap <Leader>j :resize -5<CR>
nnoremap <Leader>l :vertical resize +5<CR>
nnoremap <Leader>h :vertical resize -5<CR>
set showbreak=↪\
set listchars=tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨
set list
set mouse=a
set directory=.config/nvim/swap/

noremap <Leader>y "*y
noremap <Leader>Y "+y
set nofoldenable
set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab
set noshiftround
set lazyredraw

nnoremap <Leader>y :"*y<CR>
nnoremap <Leader>Y :"+y<CR>
