
"             _
"      _   __(_)___ ___  __________
"     | | / / / __ `__ \/ ___/ ___/
"    _| |/ / / / / / / / /  / /__
"   (_)___/_/_/ /_/ /_/_/   \___/
"
"   Standalone vimrc. No plugin dependencies — safe to drop on a server.
"   Daily driver is kickstart.nvim (see .config/nvim).
"
"   Useful commands:
"     gt / gT      change tab
"     C-w hjkl     change pane
"     za           toggle fold
"     w!!          save with sudo (cmap below)

set nocompatible

" Persistent undo
let vimDir = '$HOME/.vim'
let &runtimepath.=','.vimDir
if has('persistent_undo')
    let myUndoDir = expand(vimDir . '/undodir')
    call system('mkdir -p ' . myUndoDir)
    let &undodir = myUndoDir
    set undofile
endif

" Highlight trailing whitespace on the languages I care about
highlight BadWhitespace ctermbg=red guibg=red
au BufRead,BufNewFile *.v,*.hs,*.ts,*.go,*.md,*.js,*.py,*.pyw,*.c,*.h,*.lua,*.rs match BadWhitespace /\s\+$/

" Colors
syntax enable
set background=dark
if exists('+colorcolumn')
  set colorcolumn=80
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif

" Status line
set laststatus=2
set noshowmode
set ruler
set showcmd

" Encoding
set encoding=utf-8
set fileencoding=utf-8

" Splits open below and to the right
set splitbelow
set splitright

" UI
set cursorline
set number
set wrap
set confirm
set wildmenu
set mouse=a
set autoread
set gcr=a:blinkon0
au FocusGained * :redraw!

" Folding (built-in only — no SimpylFold dependency)
set foldmethod=indent
set foldlevel=99

" Indentation
filetype plugin indent on
set smartindent
set shiftwidth=4
set expandtab
set tabstop=4
set softtabstop=4
autocmd FileType html       setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType php        setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType typescript setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType yaml       setlocal ts=2 sts=2 sw=2 expandtab

" Search
set hlsearch
set incsearch
set ignorecase
set smartcase

" Remappings
nnoremap ; :
cmap w!! w !sudo tee > /dev/null %

" F-keys hook into .scripts/ helpers
map <F1> :w!<CR>:!aspell -t check %<CR>:e! %<CR>
map <F2> :w!<CR>:!smartrun %<CR>
map <F3> :w!<CR>:!smartcompile %<CR>
map <F4> :w!<CR>:!smartopen %<CR>:e! %<CR>
map <F5> :w!<CR>:!smartcompile %
