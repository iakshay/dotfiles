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
Bundle 'scrooloose/nerdcommenter'
Bundle "kien/ctrlp.vim"
"Bundle 'mileszs/ack.vim'
Bundle "tpope/vim-surround"

Bundle 'chriskempson/tomorrow-theme', {'rtp': 'vim/'}
Bundle 'editorconfig/editorconfig-vim'
Bundle 'mattn/emmet-vim'
Bundle "tpope/vim-markdown"
Bundle 'wavded/vim-stylus'
Bundle 'wting/rust.vim'

Bundle 'wikitopian/hardmode'
Bundle 'tpope/vim-dispatch'
Bundle 'sjl/gundo.vim'
"Ultisnips
Bundle 'SirVer/ultisnips'
Bundle 'godlygeek/tabular'
"Bundle 'Valloric/YouCompleteMe'
Bundle 'tpope/vim-eunuch'
Bundle 'tpope/vim-unimpaired'
Bundle 'tpope/vim-scriptease'
filetype on
colorscheme Tomorrow-Night-Bright
set background=dark

"solarized
"set background=light
"colorscheme solarized
"let g:solarized_termcolors=16
"hi SignColumn ctermbg=lightgrey guibg=lightgrey

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
set title
set list
set listchars=tab:▸\ ,eol:¬,nbsp:⋅,extends:❯,precedes:❮

set noswapfile
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
set splitbelow
set splitright

set showcmd

"folding settings
"set foldmethod=indent   "fold based on indent
"set foldnestmax=10      "deepest fold is 10 levels
"set nofoldenable        "dont fold by default
"set foldlevel=1         "this is just what i use

set history=1000
set undofile
set undoreload=10000


" }}}
" Wildmenu completion {{{

set wildmenu
set wildmode=list:longest

set wildignore+=.hg,.git,.svn                    " Version control
set wildignore+=*.aux,*.out,*.toc                " LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg   " binary images
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest " compiled object files
set wildignore+=*.spl                            " compiled spelling word lists
set wildignore+=*.sw?                            " Vim swap files
set wildignore+=*.DS_Store                       " OSX bullshit

set wildignore+=*.luac                           " Lua byte code

set wildignore+=migrations                       " Django migrations
set wildignore+=*.pyc                            " Python byte code

set wildignore+=*.orig                           " Merge resolution files

" }}}
" Convenience mappings ---------------------------------------------------- {{{

" Fuck you, help key.
noremap  <F1> :checktime<cr>
inoremap <F1> <esc>:checktime<cr>

" Clean trailing whitespace
nnoremap <leader>ww mz:%s/\s\+$//<cr>:let @/=''<cr>`z

" Stop it, hash key.
inoremap # X<BS>#

" Kill window
nnoremap K :q<cr>

" Man
nnoremap M K

" Toggle line numbers
nnoremap <leader>n :setlocal number!<cr>

" Sort lines
nnoremap <leader>s vip:!sort<cr>
vnoremap <leader>s :!sort<cr>

" Tabs
nnoremap <leader>( :tabprev<cr>
nnoremap <leader>) :tabnext<cr>

" Wrap
nnoremap <leader>W :set wrap!<cr>

"searching and movement
noremap <silent> <leader><space> :noh<cr>:call clearmatches()<cr>

" Made D behave
nnoremap D d$

" Keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv

" Same when jumping around
nnoremap g; g;zz
nnoremap g, g,zz
nnoremap <c-o> <c-o>zz

" Easier to type, and I never use the default behavior.
noremap H ^
noremap L $
vnoremap L g_

"upper case
nnoremap <C-u> gUiw
inoremap <C-u> <esc>gUiwea

" Split line (sister to [J]oin lines)
" The normal use of S is covered by cc, so don't worry about shadowing it.
nnoremap S i<cr><esc>^mwgk:silent! s/\v +$//<cr>:noh<cr>`w

" Source
vnoremap <leader>S y:@"<CR>
nnoremap <leader>S ^vg_y:execute @@<cr>:echo 'Sourced line.'<cr>

" Indent Guides {{{

let g:indentguides_state = 0
function! IndentGuides() " {{{
    if g:indentguides_state
        let g:indentguides_state = 0
        2match None
    else
        let g:indentguides_state = 1
        execute '2match IndentGuides /\%(\_^\s*\)\@<=\%(\%'.(0*&sw+1).'v\|\%'.(1*&sw+1).'v\|\%'.(2*&sw+1).'v\|\%'.(3*&sw+1).'v\|\%'.(4*&sw+1).'v\|\%'.(5*&sw+1).'v\|\%'.(6*&sw+1).'v\|\%'.(7*&sw+1).'v\)\s/'
    endif
endfunction " }}}
hi def IndentGuides guibg=#303030 ctermbg=234
nnoremap <leader>I :call IndentGuides()<cr>


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
"for solarized
"hi CursorLineNr ctermbg=red ctermfg=white
"let g:syntastic_enable_signs=1
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
nmap <leader>tm :tabedit ~/.tmux.conf<CR>
nmap <silent> <leader>s :set spell!<CR>

" Set region to British English
set spelllang=en_gb

" Mouse support
set mouse=a
set ttymouse=xterm2
set hlsearch

let g:HardMode_level = "wannabe"
autocmd VimEnter,BufNewFile,BufReadPost * silent! call HardMode()
nnoremap <leader>h <Esc>:call ToggleHardMode()<CR>
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsListSnippets="<c-tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
"let g:UltiSnipsEditSplit="vertical"

"for buffers
nnoremap <silent><leader>b :CtrlPBuffer<CR>

"Ack
let g:ackprg = 'ag --nogroup --nocolor --column'

"latex
"au Filetype tex set makeprg=latexmk\ %
"autocmd BufWritePost *.tex echom system("pdflatex % &&  open -g -a Preview %:r.pdf")

"Gundo
nnoremap <leader>g :GundoToggle<CR>
" Indent Guides {{{

let g:indentguides_state = 0
function! IndentGuides() " {{{
    if g:indentguides_state
        let g:indentguides_state = 0
        2match None
    else
        let g:indentguides_state = 1
        execute '2match IndentGuides /\%(\_^\s*\)\@<=\%(\%'.(0*&sw+1).'v\|\%'.(1*&sw+1).'v\|\%'.(2*&sw+1).'v\|\%'.(3*&sw+1).'v\|\%'.(4*&sw+1).'v\|\%'.(5*&sw+1).'v\|\%'.(6*&sw+1).'v\|\%'.(7*&sw+1).'v\)\s/'
    endif
endfunction " }}}
hi def IndentGuides guibg=#303030 ctermbg=234
nnoremap <leader>I :call IndentGuides()<cr>

