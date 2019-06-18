set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#rc()

"vim needs a more POSIX compatible shell than fish
if &shell =~# 'fish$'
    set shell=bash
endif

" let Vundle manage Vundle
" required!
Plugin 'VundleVim/Vundle.vim'
Plugin 'w0rp/ale'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plugin 'junegunn/fzf.vim'
Plugin 'mileszs/ack.vim'
Plugin 'tpope/vim-surround'
Plugin 'majutsushi/tagbar'
Plugin 'itchyny/lightline.vim'
"Plugin 'chriskempson/tomorrow-theme', {'rtp': 'vim/'}
Plugin 'altercation/vim-colors-solarized'
Plugin 'tpope/vim-markdown'
"Plugin 'wting/rust.vim'
Plugin 'gnattishness/cscope_maps'
Plugin 'universal-ctags/ctags'
"Plugin 'wikitopian/hardmode'
"Plugin 'fatih/vim-go'
filetype on
colorscheme solarized
set background=light

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
set ignorecase
set incsearch
set title
set list
set listchars=tab:▸\ ,eol:¬,nbsp:⋅,extends:❯,precedes:❮

set noswapfile
set smartcase

" Softtabs, 3 spaces
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
set undoreload=10000

" Set region to British English
set spelllang=en_gb

" Mouse support
set mouse=a
"set ttymouse=xterm2
set hlsearch

" }}}
" Wildmenu completion {{{

set wildmenu
set wildmode=list:longest

set wildignore+=.hg,.git,.svn,build             " Version control
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


"searching and movement
noremap <silent> <leader><space> :noh<cr>:call clearmatches()<cr>

" Made D behave
" nnoremap D d$

" Keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv

" Same when jumping around
nnoremap g; g;zz
nnoremap g, g,zz
nnoremap <c-o> <c-o>zz

" Easier to type, and I never use the default behavior.
"noremap H ^
"noremap L $
"vnoremap L g_

"upper case
nnoremap <C-u> gUiw
inoremap <C-u> <esc>gUiwea

" Split line (sister to [J]oin lines)
" The normal use of S is covered by cc, so don't worry about shadowing it.
nnoremap S i<cr><esc>^mwgk:silent! s/\v +$//<cr>:noh<cr>`w

" Source
vnoremap <leader>S y:@"<CR>
nnoremap <leader>S ^vg_y:execute @@<cr>:echo 'Sourced line.'<cr>

" Quicker window movement
nnoremap <C-j> <C-W><C-J>
nnoremap <C-k> <C-W><C-K>
nnoremap <C-l> <C-W><C-L>
nnoremap <C-h> <C-W><C-H>

"Save with sudo permission, do w!!
cmap w!! %!sudo tee > /dev/null %

"NERDTree
map <C-n> :NERDTreeToggle<CR>
let g:nerdtree_tabs_open_on_gui_startup=0
let g:nerdtree_tabs_autoclose=1

"Syntastic
"let g:syntastic_check_on_open=0
"let g:syntastic_js_checker='jslint'
"let g:syntastic_error_symbol='✗'
"let g:syntastic_warning_symbol='⚠'
"for solarized
"hi CursorLineNr ctermbg=red ctermfg=white
"let g:syntastic_enable_signs=1
"Shift Tab'
imap <S-Tab> <C-o><<

hi SpellBad ctermbg=black ctermfg=200


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



let g:HardMode_level = "wannabe"
"autocmd VimEnter,BufNewFile,BufReadPost * silent! call HardMode()
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
nmap <leader>s :TagbarToggle<CR>
"Ack
let g:ackprg = 'ag --nogroup --nocolor --column'

cnoreabbrev Ack Ack!
nnoremap <Leader>a :Ack!<Space>
let g:ale_fixers = {'cpp': ['clang-format']}
let g:ale_fix_on_save = 1
let g:ale_linters = {}
let g:ale_linters_explicit = 1

nmap ; :Buffers<CR>
nmap <Leader>t :Files<CR>
nmap <Leader>r :Tags<CR>

nmap \r :!tmux send-keys -t right C-p C-j <CR><CR>
nmap \h :!tmux send-keys -t right C-p C-j <CR><CR>

" copy to host clipboard
" https://sunaku.github.io/tmux-yank-osc52.html#osc-52-the-new-way
function! Yank(text) abort
  let escape = system('yank', a:text)
  if v:shell_error
    echoerr escape
  else
    call writefile([escape], '/dev/tty', 'b')
  endif
endfunction
noremap <silent> <Leader>y y:<C-U>call Yank(@0)<CR>
