"mapping leader key to <space>
let mapleader=" "

"unmap arrow keys since they are useless
noremap <Up> <nop>
noremap <Down> <nop>
noremap <Left> <nop>
noremap <Right> <nop>

"save fast
nnoremap <leader>w :w<CR>
"save & exit fast
nnoremap <leader>x :wq<CR>

nnoremap <leader>q :q<CR>

"map switching panes
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <c-l> <c-w>l

"fuzzy finding mappings
nmap <Leader>f :Files<CR>
"nerd tree mappings
nmap <Leader>n :NERDTreeToggle<CR>

" Switch between tabs
nmap <leader>1 1gt
nmap <leader>2 2gt
nmap <leader>3 3gt
nmap <leader>4 4gt
nmap <leader>5 5gt
nmap <leader>6 6gt
nmap <leader>7 7gt
nmap <leader>8 8gt
nmap <leader>9 9gt

map <leader>t :tabnew<CR>
map <leader>\ :vsplit<CR>
map <leader>- :split<CR>
map <leader>= <C-w>=


nnoremap <silent> <Leader>p :Rg <C-R><C-W><CR>


"number of visual spaces per tab
set tabstop=2
"number of spaces when pressing > or <
set shiftwidth=2
"copying and pasting from vim to clipboard and vice versa
set clipboard=unnamed,unnamedplus
"speed up on large files"
set lazyredraw


" ignore pattern for wildmenu
set wildignore+=*.a,*.o,*.pyc,*~,*.swp,*.tmp
set wildmode=list:longest,full

"show line numbers
set number
"enable auto indenting
set autoindent
"visual automcomplete for command menu
set wildmenu
"highlight current line
"set cursorline


"highlight matching
set showmatch
"search as characters are entered
set incsearch
"highlight matches
set hlsearch

"load filetype-specific indent files
filetype indent on
"enable syntax highlighting
syntax on


" ###### APPEARANCE ########
set termguicolors
let g:airline_theme='gruvbox'
"let g:solarized_termcolors=256


"select only text and not the line numbers
se mouse+=a


"remove trailing whitespaces to be compatible with IDEs
autocmd BufWritePre * %s/\s\+$//e



"open NERDTree automatically when vim starts up opening a directory
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif

"open NERDTree automatically if no files are specified
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif


call plug#begin()
Plug 'christoomey/vim-tmux-navigator'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
let g:fzf_layout = { 'down': '~30%' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'morhetz/gruvbox'
let g:gruvbox_contrast_dark='soft'
Plug 'sheerun/vim-polyglot'
Plug 'w0rp/ale'
let g:airline#extensions#ale#enabled = 1
let g:ale_completion_enabled = 1
call plug#end()

set background=dark
colorscheme gruvbox
