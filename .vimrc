" 
" William Matthews' .vimrc file
" 
" todos:
"   highlighting for other languages (custom greek letters etc)
"
" useful commands:
" gt/gT change tab
" ctrl-W hjkl, change pane
" ctrl p, fuzzy search
" !gt cd to fuzzy search
" za toggle fold
" crtl-N toggle NERDTree
" 
""""""""""""""""BEGIN VUNDLE""""""""""""""""
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

"""""" colorschemes
Plugin 'sjl/badwolf'
"Plugin 'altercation/vim-colors-solarized'

"""""" visual modes & UI enhancement
Plugin 'itchyny/lightline.vim'
Plugin 'nathanaelkane/vim-indent-guides' "check if needed

" NERDTree
Plugin 'scrooloose/nerdtree'
" GIT Plugin for NERDTree is not working!
Plugin 'Xuyuanp/nerdtree-git-plugin'

"""""" functional commands
" use gc to comment out a block visually highlighted
Plugin 'tomtom/tcomment_vim'
" use :WordCount to get number of words 
Plugin 'ChesleyTan/wordCount.vim'
" automatically align things
Plugin 'godlygeek/tabular'  "check if needed
" Improve Folding
Plugin 'tmhedberg/SimpylFold'
Plugin 'Konfekt/FastFold'
" Improve indenting for Python
Plugin 'vim-scripts/indentpython.vim'


"""""" GIT integration
Plugin 'airblade/vim-gitgutter'

call vundle#end()            " required
filetype plugin indent on    " required

""""""""""""""""END VUNDLE""""""""""""""""
" Setup for persistant undo

" Put plugins and dictionaries in this dir
let vimDir = '$HOME/.vim'
let &runtimepath.=','.vimDir

" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
    let myUndoDir = expand(vimDir . '/undodir')
    " Create dirs
    call system('mkdir ' . vimDir)
    call system('mkdir ' . myUndoDir)
    let &undodir = myUndoDir
    set undofile
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" bad whitespace flagger

"define bad white space highlight group
highlight BadWhitespace ctermbg=red guibg=red

" highlight bad whitespace
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" colorscheme settings

" highlight syntax
syntax enable

" colorscheme
colorscheme badwolf
set background=dark
"colorscheme solarized

" badwolf settings
"let g:badwolf_darkgutter = 1
"let g:badwolf_tabline = 3
"let g:badwolf_css_props_highlight = 1

" line at column 80
if exists('+colorcolumn')
  set colorcolumn=80
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""
" lightline settings
set laststatus=2
set noshowmode

let g:lightline = {
      \ 'colorscheme': 'powerline',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified', 'wordcount', 'time' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head',
      \   'wordcount':'MyWordCount'
      \ },
      \ }


"""""""""""""""""""""""""""""""""""""""""""""""""""""
"NERDTREE settings
let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-indent-guides settings
let g:indent_guides_guide_size = 1
let g:indent_guides_color_change_percent = 3
let g:indent_guides_enable_on_vim_startup = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Folding Options
let g:SimpylFold_docstring_preview = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GENERAL VIM SETTINGS

" default encoding option
set encoding=utf-8
set fileencoding=utf-8

" create new splits below and to the right
set splitbelow
set splitright

" line no and position
set ruler
set cursorline
set number

" make wrapping words behave nicely
set wrap

" enable folding
set foldmethod=indent
set foldlevel=99

" Confirm I want to save before quitting
set confirm

" Nicely List Files When Searching with a :sp for example
set wildmenu

" Shows the commands I'm typing like a :w showing as w
set showcmd

" Various settings to make tabs better"
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
autocmd FileType html setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType php setlocal ts=2 sts=2 sw=2 expandtab

" Search customisation
set hlsearch
set incsearch
set ignorecase
set smartcase

" Enable mouse usage"
set mouse=a
filetype indent on  " automatic indentation as you type.
set autoread        " read changes to file that happen on disk
set gcr=a:blinkon0  " disable cursor blink

" redraw on focus gain
au FocusGained * :redraw!

" REMAPPINGS

" Makes the colon map to the semicolon - useful when entering commands"
nnoremap ; :

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" File Interaction Commands

" spellcheck
map <F1> :w!<CR>:!aspell -t check %<CR>:e! %<CR>
" run file
map <F2> :w!<CR>:!smartrun %<CR>
" compile file
map <F3> :w!<CR>:!smartcompile %<CR>
" open file
map <F4> :w!<CR>:!smartopen %<CR>:e! %<CR>
" debug compile
map <F5> :w!<CR>:!smartcompile %

" tabularise bar remap for align - calls align when bar is pressed
inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a

" toggle NERDTREE with CTRL-N
map <C-n> :NERDTreeToggle<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FUNCTIONS
" get the file's word count (only for appropriate files)
function! MyWordCount()
    let _ = ['pandoc', 'text', 'md', 'markdown', 'tex']
    if index(_, &filetype) == -1
        return ""
    else
        return wordCount#WordCount()
    endif
endfunction

" align for tabularise
function! s:align()
  let p = '^\s*|\s.*\s|\s*$'
  if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
    let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
    let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
    Tabularize/|/l1
    normal! 0
    call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
  endif
endfunction
