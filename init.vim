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
"quit fast
nnoremap <leader>q :q<CR>

"map switching panes
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l


"FZF related mappings
nnoremap <Leader>f :Files<CR>
nnoremap <Leader>bf :Buffers<CR>
nnoremap <silent> <Leader>p :Rg<CR>
nnoremap <Leader>bp :BLines<CR>

"nerd tree mappings
map <leader>nt :NERDTreeToggle<CR>
map <leader>nf :NERDTreeFind<CR>

"coc mappings
nmap <leader>gf <Plug>(coc-definition)

"tagbar mappings
map <leader>t :Tagbar<CR>

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

"select only text and not the line numbers
se mouse+=a


"remove trailing whitespaces to be compatible with IDEs
autocmd BufWritePre * %s/\s\+$//e


" Auto install Plug for both vim and nvim
" https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs '
			\ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


call plug#begin(stdpath('data') . '/plugged')

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

" Navigate seamlessly between vim and tmux panes
Plug 'christoomey/vim-tmux-navigator'

Plug 'tpope/vim-sensible'
Plug 'jiangmiao/auto-pairs'

" File system explorer for nvim that allows visual browsing of complex
" directory hierarchies
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

" Command line fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
let g:fzf_layout = { 'down': '~40%' }

" Fast grep tool
Plug 'mileszs/ack.vim'
" Prefer ripgrep if it's available since it's faster: rg > ag > ack
" (https://hackercodex.com/guide/vim-search-find-in-project/)
if executable('rg')
	let g:ackprg = 'rg -S --no-heading --vimgrep'
	let g:rg_derive_root='true'
elseif executable('ag')
	let g:ackprg = 'ag --vimgrep'
endif

" Floating terminal
" :FloatermNew opens a floaterm window
Plug 'voldikss/vim-floaterm'

" Session saving for neovim
Plug 'tpope/vim-obsession'

" Provides integration with `pandoc` document converter and also works with
" documents written in its markdown variant
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'

" Preview markdown on browser with synchronised scrolling
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() },
																			\'for': ['markdown', 'vim-plug']}

" Provides live preview of output PDF of LaTeX files
" A TeX engine (e.g. pdflatex) needs to be installed
" and a PDF viewer (e.g. evince)
Plug 'xuhdev/vim-latex-live-preview', {'for': 'tex' }
" let g:livepreview_previewer = 'evince'
" let g:livepreview_engine = 'pdflatex'

Plug 'neoclide/coc.nvim', { 'branch': 'release'}  "autocompletion

" Semantic highlighting for C++ that uses the LSP. For this plugin to work a
" compatible language server (LSP) and client (native in neovim) is needed.
" TODO(dimlek): may slow down performance
Plug 'jackguo380/vim-lsp-cxx-highlight'
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1

" LLVM comes with `clang-format` command line tool that can be used to
" auto-format a C++ file according to pre-defined rules. These rules can be
" applied on a per-project basis by putting a `.clang-format` config-file in
" the root of the project. This plugin enables formatting a buffer in nvim
" using a handy shortcut; by using :ClangFormat command, we can format a file
" according to the rules set in the `.clang-format` file.
"
" [NOTE]: Configuration should be close to `cpplint` config.
"
Plug 'rhysd/vim-clang-format'

Plug 'mbbill/undotree'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'

Plug 'morhetz/gruvbox'
let g:gruvbox_contrast_dark='medium'

Plug 'vim-airline/vim-airline'

" Syntax checking plugin
Plug 'vim-syntastic/syntastic'
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0

" cpplint is a static code checker for C++ that follows Google's C++ style
" guide [https://google.github.io/styleguide/cppguide.html]. For this to work
" cpplint tool need to be installed (e.g. pip install cpplint).
let g:syntastic_cpp_checkers = ['cpplint']
let g:syntastic_c_checkers = ['cpplint']
let g:syntastic_cpp_cpplint_exec = 'cpplint'

Plug 'majutsushi/tagbar'

call plug#end()


autocmd FileType cpp setlocal commentstring=//\ %s

" to make macos's Cmd + / work, remap it in iterm2:
" Preferences > Keys > Key bindings: map "Cmd + /" to "vim send gc"

runtime colors/desert.vim
autocmd VimEnter * colorscheme gruvbox
