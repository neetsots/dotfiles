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
    let g:syntastic_error_symbol = 'X'
    let g:syntastic_style_error_symbol = '?'
    let g:syntastic_warning_symbol = '!'
    let g:syntastic_style_warning_symbol = '$'
    nnoremap <Leader>l :SyntasticCheck<CR> :SyntasticToggleMode<CR>
  Plug 'tell-k/vim-autopep8'
" >>>>


" Langage server manager
" <<<<
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
" >>>>

" Airline
" <<<<<
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  let g:airline#extensions#tabline#enabled = 1
  let g:airline_theme='wombat'

  let g:airline_powerline_fonts = 1

  if !exists('g:airline_symbols')
      let g:airline_symbols = {}
  endif

  " unicode symbols
  let g:airline_left_sep = '»'
  let g:airline_left_sep = '▶'
  let g:airline_right_sep = '«'
  let g:airline_right_sep = '◀'
  let g:airline_symbols.linenr = '␊'
  let g:airline_symbols.linenr = '␤'
  let g:airline_symbols.linenr = '¶'
  let g:airline_symbols.branch = '⎇'
  let g:airline_symbols.paste = 'ρ'
  let g:airline_symbols.paste = 'Þ'
  let g:airline_symbols.paste = '∥'
  let g:airline_symbols.whitespace = 'Ξ'

  " airline symbols
  let g:airline_left_sep = ''
  let g:airline_left_alt_sep = ''
  let g:airline_right_sep = ''
  let g:airline_right_alt_sep = ''
  let g:airline_symbols.branch = ''
  let g:airline_symbols.readonly = ''
  let g:airline_symbols.linenr = ''

" >>>>

" Syntax
" <<<<
  Plug 'othree/html5.vim'
  Plug 'cespare/vim-toml'
" >>>>

" Tags
" <<<<
  Plug 'craigemery/vim-autotag'
" >>>>
"
" Highlighting
" <<<<
  Plug 'octol/vim-cpp-enhanced-highlight'
  Plug 'rust-lang/rust.vim'
  Plug 'fatih/vim-go'
  Plug 'nvie/vim-flake8'
  Plug 'pangloss/vim-javascript'
  Plug 'plasticboy/vim-markdown'
  Plug 'stephpy/vim-yaml'
" >>>>
"
" Colorscheme
" <<<<
  Plug 'emmehandes/tetradic'
  Plug 'smallwat3r/vim-hashpunk-sw'
  Plug 'abnt713/vim-hashpunk'
  Plug 'kaicataldo/material.vim'
" <<<<
"
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
au BufWritePre * %s/\s\+$//e
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
colorscheme material
let g:material_theme_style = 'lighter'

"-- Remove tildes....
highlight EndOfBuffer guifg=None guibg=None
highlight Normal guibg=none
highlight NonText guibg=none
nmap ge :CocCommand explorer<CR>

set clipboard=unnamedplus
