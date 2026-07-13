" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Search down into subfolders, provide tab completion for all file-related
" taskfiletype
set path+=**

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Turn syntax highlighting on.
syntax on

" Add numbers to each line on the left-hand side.
set number

" Set shift width to 4 spaces.
set shiftwidth=4

" Set tab width to 4 columns.
set tabstop=4

" Use space characters instead of tabs.
set expandtab

" Do not save backup files.
set nobackup

" Do not let cursor scroll below or above N number of lines when scrolling.
set scrolloff=10

" Do not wrap lines. Allow long lines to extend as far as the line goes.
set nowrap

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" Don't ignore capital letters during search.
set noignorecase

" Override the ignorecase option if searching for capital letters.
" This will allow you to search specifically for capital letters.
set smartcase

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set showmode

" Show matching words during a search.
set showmatch

" Use highlighting when doing a search.
set hlsearch

" Set the commands to save in history default number is 20.
set history=1000

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" Fold code
set foldmethod=syntax
set foldlevel=99

" Change cursor based on insert or normal mode
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
"let &t_SI = "\<Esc>]12;green\x7"
"let &t_EI = "\<Esc>]12;orange\x7"
autocmd VimLeave * silent !echo -ne "\033]112\007"

" Visual highlight color
highlight Visual ctermfg=Black ctermbg=DarkYellow guifg=Black guibg=DarkYellow


" PLUGINS ---------------------------------------------------------------- {{{

" Install vim-plug and run :PlugInstall to install
"call plug#begin('~/.vim/plugged')
"  Plug 'dense-analysis/ale'
"  Plug 'preservim/nerdtree'
"call plug#end()

" }}}


" MAPPINGS --------------------------------------------------------------- {{{

" register leader
let mapleader = " "

" clear search
nnoremap <esc> :noh<return><esc>

" Change line, better use S for this.
nmap cc 1S

" Copy Word
nmap ,c yiw

" Select word
nmap ,v viw

" Delete word without yanking
nnoremap d "_d
vnoremap d "_d

" Yanking and Deleting
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
nnoremap J mzJ`z

" replace currently selected text with default register
" without yanking it
vnoremap <leader>p "_dP

" Center screen when jumping to next match
nnoremap n nzz
nnoremap N Nzz
vnoremap n nzz
vnoremap N Nzz

" Center screen when moving up and down
nnoremap <C-u> <C-u>zz
nnoremap <C-o> <C-d>zz
vnoremap <C-u> <C-u>zz
vnoremap <C-o> <C-d>zz

" Center screen when moving up and down
nnoremap <C-u> <C-u>zz
nnoremap <C-o> <C-d>zz
vnoremap <C-u> <C-u>zz
vnoremap <C-o> <C-d>zz

" easy window navigation
" nnoremap <a-k> gT
" nnoremap <a-j> gt
nnoremap <tab> gt
nnoremap <s-tab> gT

" Navigate Window
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" clear the search buffer when hitting return
nnoremap <leader><cr> :nohlsearch<cr>

" Resize split windows using arrow keys by pressing:
" CTRL+UP, CTRL+DOWN, CTRL+LEFT, or CTRL+RIGHT.
noremap <c-up> <c-w>+
noremap <c-down> <c-w>-
noremap <c-left> <c-w>>
noremap <c-right> <c-w><

" NERDTree specific mappings.
" Map the F3 to toggle NERDTree open and close.
nnoremap <F3> :NERDTreeToggle<cr>

" }}}

nnoremap <leader>fa :FZF<cr>

" VIMSCRIPT -------------------------------------------------------------- {{{

" This will enable code folding.
" Use the marker method of folding.
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" More Vimscripts code goes here.

" }}}


" STATUS LINE ------------------------------------------------------------ {{{

" Clear status line when vimrc is reloaded.
set statusline=

" Status line left side.
set statusline+=\ %F\ %M\ %R

" Use a divider to separate the left side from the right side.
set statusline+=%=

" Show the status on the second to last line.
set laststatus=2

" }}}

" GOLANG ----------------------------------------------------------------- {{{
autocmd BufWritePre *.go :silent %!goimports

" }}}
