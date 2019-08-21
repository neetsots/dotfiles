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

" Linting
" <<<<
    Plug 'scrooloose/syntastic'

    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 0
    let g:syntastic_check_on_wq = 0
    let g:syntastic_check_on_w = 0
"    let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': [],'passive_filetypes': [] }
    nnoremap <Leader>l :SyntasticCheck<CR> :SyntasticToggleMode<CR>
  Plug 'tell-k/vim-autopep8'
" >>>>

" StatusLine
" <<<<
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
        let g:airline_powerline_fonts = 1
        let g:airline#extensions#tabline#enabled = 1
        let g:airline_theme='dracula'
    Plug 'edkolev/tmuxline.vim'
        let g:tmuxline_separators = {
            \ 'left' : '',
            \ 'left_alt' : '',
            \ 'right' : '',
            \ 'right_alt' : '',
            \ 'space' : ' '}

" >>>>

" IPython
" <<<<
    Plug 'Vigemus/iron.nvim'
" >>>>

" Completion
" <<<<
  Plug 'shougo/deoplete.nvim'
      let g:deoplete#enable_at_startup = 1
  Plug 'deoplete-plugins/deoplete-jedi'
  Plug 'sebastianmarkow/deoplete-rust'
    let g:deoplete#sources#rust#racer_binary='$HOME/.cargo/bin/racer'
  Plug 'tpope/vim-surround'
" >>>>

" Syntax
" <<<<
  Plug 'mattn/emmet-vim'
  Plug 'othree/html5.vim'
  Plug 'rhysd/open-pdf.vim'
  Plug 'thanethomson/vim-jenkinsfile'
  Plug 'cespare/vim-toml'
  Plug 'leafgarland/typescript-vim'
" >>>>
"
" Highlighting
" <<<<
  Plug 'emmehandes/tetradic'
  Plug 'dracula/dracula-theme', {'as': 'dracula'}
  Plug 'octol/vim-cpp-enhanced-highlight'
  Plug 'rust-lang/rust.vim'
  Plug 'fatih/vim-go'
  Plug 'nvie/vim-flake8'
  Plug 'pangloss/vim-javascript'
  Plug 'plasticboy/vim-markdown'
  Plug 'dag/vim-fish'
  Plug 'stephpy/vim-yaml'

" >>>>
"
" Jupyter Notebooks
" <<<<
  Plug 'bfredl/nvim-ipy'
" >>>>
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

"-- StatusLine --------------------------------------------------------
"function! InsertStatuslineColor(mode)
"  if a:mode == 'i'
"    hi statusline guibg=#6ecdff
"    hi left guifg=#222327 guibg=#6ecdff
"    hi right guifg=#222327 guibg=#6ecdff
"  elseif a:mode == 'r'
"    hi StatusLine guibg=#f3425c
"    hi left guifg=#222327 guibg=#f3425c
"    hi right guifg=#222327 guibg=#f3425c
"  else
"    hi statusline guibg=#222327
"    hi left guifg=#6ecdff guibg=#222327
"    hi right guifg=#6effa0 guibg=#222327
"  endif
"endfunction
"
"au InsertEnter * call InsertStatuslineColor(v:insertmode)
"au InsertChange * call InsertStatuslineColor(v:insertmode)
"au InsertLeave * call InsertStatuslineColor("normal")
"hi left guifg=#6ecdff guibg=#222327
"hi right guifg=#6effa0 guibg=#222327
"
"set laststatus=2
"set statusline=
"set statusline+=%#left#
"set statusline+=\|\ %f
"set statusline+=\ \"\uE0A3"\ %m
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"set statusline+=%=
"set statusline+=%#right#
"set statusline+=\ \/\ %{&fileencoding?&fileencoding:&encoding}
"set statusline+=\ \/\ %{&fileformat}
"set statusline+=\ \/\ %l:%c
"set statusline+=\ (%p%%)

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
colorscheme tetradic
set shell=bash

nnoremap <Leader>s :Rg <C-r><C-w><CR>
"nnoremap <Leader>k :resize +5<CR>
"nnoremap <Leader>j :resize -5<CR>
"nnoremap <Leader>l :vertical resize +5<CR>
"nnoremap <Leader>h :vertical resize -5<CR>
set showbreak=↪\
set listchars=tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨
set list
set mouse=a
set directory=.config/nvim/swap/

noremap <Leader>y "*y
noremap <Leader>Y "+y
set nofoldenable
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set noshiftround
set lazyredraw

nnoremap <Leader>y :"*y<CR>
nnoremap <Leader>Y :"+y<CR>

luafile $HOME/.config/nvim/plugins.lua
