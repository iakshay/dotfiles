set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#rc()

"vim needs a more POSIX compatible shell than fish
if &shell =~# 'fish$'
    set shell=bash
endif

" automatically install and use vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" required!
Plug 'w0rp/ale'
Plug 'Lokaltog/vim-easymotion'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'mileszs/ack.vim'
Plug 'tpope/vim-surround'
Plug 'majutsushi/tagbar'
Plug 'itchyny/lightline.vim'
"Plug 'chriskempson/tomorrow-theme', {'rtp': 'vim/'}
Plug 'altercation/vim-colors-solarized'
Plug 'tpope/vim-markdown'
"Plug 'wting/rust.vim'
Plug 'gnattishness/cscope_maps'
Plug 'universal-ctags/ctags'
"Plug 'wikitopian/hardmode'
"Plug 'fatih/vim-go'
Plug 'derekwyatt/vim-scala'
Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': { -> coc#util#install()}}        " LSP client + autocompletion plugin

"Configuration for vim-scala
au BufRead,BufNewFile *.sbt set filetype=scala

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

" trailing whitespace
" https://sartak.org/2011/03/end-of-line-whitespace-in-vim.html
autocmd InsertEnter * syn clear EOLWS | syn match EOLWS excludenl /\s\+\%#\@!$/
autocmd InsertLeave * syn clear EOLWS | syn match EOLWS excludenl /\s\+$/
highlight EOLWS ctermbg=red guibg=red

function! <SID>StripTrailingWhitespace()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction
nmap <silent> <Leader><space> :call <SID>StripTrailingWhitespace()<CR>

" Configuration for coc.nvim

" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Some server have issues with backup files, see #649
set nobackup
set nowritebackup

" Better display for messages
set cmdheight=2

" Use <c-space> for trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[c` and `]c` for navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Remap for do codeAction of current line
nmap <leader>ac <Plug>(coc-codeaction)

" Remap for do action format
nnoremap <silent> F :call CocAction('format')<CR>

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

" Notify coc.nvim that <enter> has been pressed.
" Currently used for the formatOnType feature.
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
      \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Metals specific commands
" Start Metals Doctor
command! -nargs=0 MetalsDoctor :call CocRequestAsync('metals', 'workspace/executeCommand', { 'command': 'doctor-run' })
" Manually start build import
command! -nargs=0 MetalsImport :call CocRequestAsync('metals', 'workspace/executeCommand', { 'command': 'build-import' })
" Manually connect with the build server
command! -nargs=0 MetalsConnect :call CocRequestAsync('metals', 'workspace/executeCommand', { 'command': 'build-connect' })
