set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'
Bundle 'tpope/vim-fugitive'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/syntastic'
"Bundle 'daylerees/colour-schemes', { 'rtp': 'vim-themes/' }
"Bundle 'croaky/vim-colors-github'
"Bundle 'chriskempson/base16-vim'
"Bundle 'chriskempson/base16-vim'
Bundle 'scrooloose/nerdcommenter'
Bundle "kien/ctrlp.vim"
Bundle "mileszs/ack.vim"
Bundle "tpope/vim-surround"
Bundle "tpope/vim-markdown"
"vim-snipmate
Bundle "MarcWeber/vim-addon-mw-utils"
Bundle "tomtom/tlib_vim"
Bundle "garbas/vim-snipmate"
Bundle 'chriskempson/tomorrow-theme', {'rtp': 'vim/'}
"Bundle 'bling/vim-airline'
Bundle 'editorconfig/editorconfig-vim'
Bundle 'mattn/emmet-vim'
Bundle 'wavded/vim-stylus'
"Bundle 'Valloric/YouCompleteMe'
filetype on
"colorscheme base16-default
colorscheme Tomorrow-Night-Bright
set background=dark

python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup

filetype plugin indent on 	"required for vundle

let mapleader = ","
syntax on
set number
"set numberwidth=5
set ruler
set hidden "handle hidden buffers more liberally
set autoindent
set smartindent
set backspace=indent,eol,start
"set colorcolumn=80
set cursorline
"set gdefault
"set guifont=Source\ Code\ Pro\ for\ Powerline
"set guioptions-=Be
"set guioptions=aAc
"set hlsearch
set ignorecase
set incsearch

set list
set listchars=tab:▸\ ,eol:¬,nbsp:⋅

set noswapfile
set shell=/bin/sh
set showmatch
set smartcase

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

set visualbell
set winheight=999
set winheight=5
set winminheight=5
set winwidth=84
set laststatus=2
set pastetoggle=<F2>

set showcmd

" Quicker window movement
nnoremap <C-j> <C-W><C-J>
nnoremap <C-k> <C-W><C-K>
nnoremap <C-l> <C-W><C-L>
nnoremap <C-h> <C-W><C-H>

"nnoremap <S-J> :resize -5<CR>
"nnoremap <S-K> :resize +5<CR>
"nnoremap <S-L> :vertical resize +5<CR>
"nnoremap <S-H> :vertical resize -5<CR>
" Open new splits bottom and right
set splitbelow
set splitright

"Save with sudo permission, do w!!
cmap w!! %!sudo tee > /dev/null %

"NERDTree
map <C-n> :NERDTreeToggle<CR>
let g:nerdtree_tabs_open_on_gui_startup=0
let g:nerdtree_tabs_autoclose=1

"Syntastic
let g:syntastic_check_on_open=1
let g:syntastic_js_checker='jslint'
let g:syntastic_error_symbol='✗'
let g:syntastic_warning_symbol='⚠'

"Shift Tab'
imap <S-Tab> <C-o><<
"hi MatchParen cterm=none ctermbg=green ctermfg=blue
"hi CursorLine cterm=NONE ctermbg=darkred ctermfg=white
"highlight LineNr cterm=NONE ctermfg=grey ctermbg=white

""Syntastic Column
"hi SignColumn ctermbg=232
"hi SyntasticErrorSign ctermfg=darkred ctermbg=black
"hi SyntasticWarningSign ctermfg=214 ctermbg=black
"hi SyntasticErrorLine ctermfg=yellow ctermbg=black
"hi clear SyntasticError
"hi clear SyntasticWarning
"hi SyntasticError cterm=underline
"hi SyntasticWarning cterm=underline

hi SpellBad ctermbg=black ctermfg=200
":hi TabLineFill ctermfg=LightGreen ctermbg=white
":hi TabLine ctermfg=yellow ctermbg=gray
":hi TabLineSel ctermfg=Red ctermbg=Yellow

"folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=10      "deepest fold is 10 levels
set nofoldenable        "dont fold by default
set foldlevel=1         "this is just what i use

function! ToggleErrors()
  let old_last_winnr = winnr('$')
  lclose
  if old_last_winnr == winnr('$')
      " Nothing was closed, open syntastic error location panel
      Errors
  endif
endfunction
map <silent> <C-e> :call ToggleErrors()<CR>

"Source the vimrc file after saving it
if has("autocmd")
  autocmd bufwritepost .vimrc source $MYVIMRC
endif

nmap <leader>v :tabedit $MYVIMRC<CR>
nmap <leader>z :tabedit ~/.zshrc<CR>
nmap <silent> <leader>s :set spell!<CR>

" Set region to British English
set spelllang=en_gb

" Mouse support
set mouse=a
set ttymouse=xterm2
