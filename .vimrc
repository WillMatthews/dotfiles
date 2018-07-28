" 
" William Matthews' .vimrc file
" 
" Edited 28 Jul 2018
" 
" Created on William-Dell (inspiron)
" 
" todos:
"   add LaTeX plugins
"   add a clock
"   highlighting for other languages (custom greek letters etc)
"
"
"
" 
" 
""""""""""""""""BEGIN VUNDLE""""""""""""""""
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
" call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"""""""""""""""""""""""""""""""""" BEGIN VUNDLE PACKS
"""""" colorschemes
Plugin 'sjl/badwolf'

"""""" visual modes & UI enhancement
Plugin 'junegunn/goyo.vim'
Plugin 'itchyny/lightline.vim'
" Plugin 'mopp/sky-color-clock.vim' couldn't make this work :(
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'Valloric/YouCompleteMe'
" NERDTree
Plugin 'scrooloose/nerdtree'
" GIT PLUGIN IS NOT WORKING!!!!
Plugin 'Xuyuanp/nerdtree-git-plugin'


"""""" file navigation
Plugin 'ctrlpvim/ctrlp.vim'

"""""" functional command
" use gc to comment out a block visually highlighted
Plugin 'tomtom/tcomment_vim'
" use :WordCount to get number of words 
Plugin 'ChesleyTan/wordCount.vim'
" automatically align things
Plugin 'godlygeek/tabular'
" brackets, etc manipulation
Plugin 'tpope/vim-surround'


"""""" advanced
Plugin 'iamcco/markdown-preview.vim'
Plugin 'Raimondi/delimitMate'
Plugin 'JuliaEditorSupport/julia-vim'

"""""" GIT integration
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'

"""""""""""""""""""""""""""""""""" END VUNDLE PACKS

call vundle#end()            " required
filetype plugin indent on    " required

""""""""""""""""END VUNDLE""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""
"
"  \/      BEGIN MAIN SECTION      \/
"  \/      BEGIN MAIN SECTION      \/
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
" colorscheme settings
" highlight syntax
syntax enable

" colorscheme
colorscheme badwolf

" another word

" badwolf settings
let g:badwolf_darkgutter = 1
"let g:badwolf_tabline = 3
let g:badwolf_css_props_highlight = 1


""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
      \   'wordcount':'MyWordCount',
      \   'time': 'MyTime'
      \ },
      \ }

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" Julia Editor
"let g:latex_to_unicode_auto = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""
"NERDTREE settings
"autocmd vimenter * NERDTree

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-indent-guides settings
let g:indent_guides_guide_size = 1
let g:indent_guides_color_change_percent = 3
let g:indent_guides_enable_on_vim_startup = 1


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GENERAL VIM SETTINGS

" create new splits below and to the right
set splitbelow
set splitright

" line no and position
set ruler
set cursorline
set number

" make wrapping words behave nicely
set wrap

" Confirm I want to save before quitting
set confirm

" Nicely List Files When Searching with a :sp for example
set wildmenu

" Shows the commands I'm typing like a :w showing as w
set showcmd

" Various settings to make tabs better"
set expandtab
set softtabstop=4

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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" REMAPPINGS

" Makes the colon map to the semicolon - useful when entering commands"
nnoremap ; :

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" File Interaction Commands
" map <F1> 
map <F2> :w!<CR>:!aspell -t check %<CR>:e! %<CR>
map <F3> :w!<CR>:!pdflatex %<CR>:e! %<CR>
map <F4> :w!<CR>:!xdg-open $(basename % .tex <Bar> awk '{print $1".pdf"}') <CR>:e! %<CR>

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

" get the current time (for status bar etc)
function! MyTime()
    let time = strftime('%a %e %b%m %R %z') 
    return time
    " fix this! time is broken 
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




