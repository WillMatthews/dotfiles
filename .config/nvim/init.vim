set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
let g:copilot_filetypes = {'markdown': v:true, 'yaml': v:true, 'json': v:true, 'javascript': v:true, 'typescript': v:true, 'html': v:true, 'css': v:true, 'scss': v:true, 'vim': v:true, 'sh': v:true, 'python': v:true, 'rust': v:true, 'go': v:true, 'java': v:true, 'c': v:true, 'cpp': v:true, 'lua': v:true, 'ruby': v:true, 'php': v:true, 'sql': v:true, 'dockerfile': v:true, 'plaintext': v:true}


call plug#begin()
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
call plug#end()
