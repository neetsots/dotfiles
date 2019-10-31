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

" Linting
" <<<<
  Plug 'scrooloose/syntastic'
      let g:syntastic_always_populate_loc_list = 1
      let g:syntastic_auto_loc_list = 1
      let g:syntastic_loc_list_height = 3
      let g:syntastic_check_on_open = 0
      let g:syntastic_check_on_wq = 0
      let g:syntastic_check_on_w = 0
      let g:syntastic_error_symbol = 'XX'
      let g:syntastic_style_error_symbol = '??'
      let g:syntastic_warning_symbol = '!!'
      let g:syntastic_style_warning_symbol = '~~'
      nnoremap <Leader>l :SyntasticCheck<CR> :SyntasticToggleMode<CR>
  Plug 'tell-k/vim-autopep8'
" >>>>

" Langage server manager
" <<<<
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
" >>>>

" Syntax
" <<<<
  Plug 'mattn/emmet-vim'
  Plug 'othree/html5.vim'
  Plug 'rhysd/open-pdf.vim'
  Plug 'cespare/vim-toml'
  Plug 'leafgarland/typescript-vim'
" >>>>
"
" Highlighting
" <<<<
  Plug 'emmehandes/tetradic'
  Plug 'abnt713/vim-hashpunk'
  Plug 'octol/vim-cpp-enhanced-highlight'
  Plug 'rust-lang/rust.vim'
  Plug 'fatih/vim-go'
  Plug 'nvie/vim-flake8'
  Plug 'pangloss/vim-javascript'
  Plug 'plasticboy/vim-markdown'
  Plug 'stephpy/vim-yaml'
" >>>>
"
" Git
" <<<<
  Plug 'airblade/vim-gitgutter'
  Plug 'tpope/vim-fugitive'
  Plug 'junegunn/gv.vim'
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
au BufWinLeave *.py !autopep8 %:p

"-- Jupyter notebooks -------------------------------------------------
autocmd Filetype ipynb nmap <silent><Leader>jb :VimpyterInsertPythonBlock<CR>
autocmd Filetype ipynb nmap <silent><Leader>js :VimpyterStartJupyter<CR>
autocmd Filetype ipynb nmap <silent><Leader>jn :VimpyterStartNteract<CR>

"-- Yaml --------------------------------------------------------------
autocmd FileType yaml execute
      \'syn match yamlBlockMappingKey /^\s*\zs.*\ze\s*:\%(\s\|$\)/'

"-- Completion --------------------------------------------------------
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | silent! pclose | endif

set background=dark
let ayucolor="dark"
colorscheme tetradic
set shell=bash

nnoremap <Leader>s :Rg <C-r><C-w><CR>
set showbreak=↪\
set listchars=tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨
set list
set mouse=a
set directory=.config/nvim/swap/

set nofoldenable
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set noshiftround
set lazyredraw

set clipboard+=unnamedplus
