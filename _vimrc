if has("win16") || has("win32") || has("win64")
    source $VIMRUNTIME/vimrc_example.vim
    source $VIMRUNTIME/mswin.vim

    behave mswin

    set diffexpr=MyDiff()
    function MyDiff()
        let opt = '-a --binary '
        if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
        if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
        let arg1 = v:fname_in
        if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
        let arg2 = v:fname_new
        if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
        let arg3 = v:fname_out
        if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
        if $VIMRUNTIME =~ ' '
            if &sh =~ '\<cmd'
                if empty(&shellxquote)
                    let l:shxq_sav = ''
                    set shellxquote&
                endif
                let cmd = '"' . $VIMRUNTIME . '\diff"'
            else
                let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
            endif
        else
            let cmd = $VIMRUNTIME . '\diff'
        endif
        silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
        if exists('l:shxq_sav')
            let &shellxquote=l:shxq_sav
        endif
    endfunction
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer: 
"       Amir Salihefendic
"       http://amix.dk - amix@amix.dk
"
" Version: 
"       6.0 - 01/04/17 14:24:34 
"
" Blog_post: 
"       http://amix.dk/blog/post/19691#The-ultimate-Vim-configuration-on-Github
"
" Awesome_version:
"       Get this config, nice color schemes and lots of plugins!
"
"       Install the awesome version from:
"
"           https://github.com/amix/vimrc
"
" Syntax_highlighted:
"       http://amix.dk/vim/vimrc.html
"
" Raw_version: 
"       http://amix.dk/vim/vimrc.txt
"
" Sections:
"    -> General
"    -> VIM user interface
"    -> Colors and Fonts
"    -> Files and backups
"    -> Text, tab and indent related
"    -> Visual mode related
"    -> Moving around, tabs and buffers
"    -> Status line
"    -> Editing mappings
"    -> vimgrep searching and cope displaying
"    -> Spell checking
"    -> Misc
"    -> Helper functions
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FILE: 
"       functions.vim
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Delete trailing white space on save, useful for some filetypes ;)
function! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun

function! <SID>BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")

    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif

    if bufnr("%") == l:currentBufNum
        new
    endif

    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunction

" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    endif
    return ''
endfunction

function! DeleteTillSlash()
    let g:cmd = getcmdline()

    if has("win16") || has("win32")
        let g:cmd_edited = substitute(g:cmd, "\\(.*\[\\\\]\\).*", "\\1", "")
    else
        let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*", "\\1", "")
    endif

    if g:cmd == g:cmd_edited
        if has("win16") || has("win32")
            let g:cmd_edited = substitute(g:cmd, "\\(.*\[\\\\\]\\).*\[\\\\\]", "\\1", "")
        else
            let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*/", "\\1", "")
        endif
    endif   

    return g:cmd_edited
endfunc

function! CurrentFileDir(cmd)
    return a:cmd . " " . expand("%:p:h") . "/"
endfunc

function! CmdLine(str)
    exe "menu Foo.Bar :" . a:str
    emenu Foo.Bar
    unmenu Foo
endfunction 

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'gv'
        "call CmdLine("Ack '" . l:pattern . "' " )
        call CmdLine("Ack! \"" . l:pattern . "\"")
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

function! UpdateTagsAndCscope()
    if filereadable("cscope.out")
        silent cscope kill cscope.out
    endif

    if has("win16") || has("win32") || has("win64")
        "以下注释是在不断尝试中的改进，对于路径中的空格，有了不错的解决
        exec "silent !dir /b /s *.c *.cc *.cpp *.h *.s *.asm *.py *.js > cscope.files & " . $VIMRUNTIME . "\\ctags.exe -R --fields=+ianS --excmd=p --extra=+q --c++-kinds=+p --c-kinds=+p -L cscope.files & " . $VIMRUNTIME . "\\cscope.exe -Rbk -i cscope.files"
    else
        "以下注释是在不断尝试中的改进，对于路径中的空格，有了不错的解决
        :silent !find . -regex '.*\.c|.*\.cc\|.*\.cpp\|.*\.h\|.*\.s\|.*\.asm\|.*\.py\|.*\.js' | ls |sed "s:^:`pwd`/:" >cscope.files & "ctags" -R --fields=+ianS --excmd=p --extra=+q --c++-kinds=+p --c-kinds=+p -L cscope.files & "cscope" -Rbk
    endif

    if filereadable("cscope.out")
        silent cscope add cscope.out
    else  
        let cscope_file=findfile("cscope.out", ".;")  
        let cscope_pre=matchstr(cscope_file, ".*/")  
        if !empty(cscope_file) && filereadable(cscope_file)  
            exe "cs add" cscope_file cscope_pre  
        endif        
    endif  

    exec "UpdateTypesFile"
endfunction

function! UpdateTagsAndCscope2()

    let proj_path = FindRootDirectory()

    if !empty(proj_path)
        let proj_path = proj_path."\\.project\\"
        if isdirectory(proj_path)
            exec "cd ".proj_path
        endif
    endif

    if filereadable("cscope.out")
        silent cscope kill cscope.out
    endif

    if has("win16") || has("win32") || has("win64")
        "以下注释是在不断尝试中的改进，对于路径中的空格，有了不错的解决
        exec "silent !dir .. /b /s *.c *.cc *.cpp *.h *.s *.asm *.py *.js > cscope.files & " . $VIMRUNTIME . "\\ctags.exe -R --fields=+ianS --excmd=p --extra=+q --c++-kinds=+p --c-kinds=+p -L cscope.files & " . $VIMRUNTIME . "\\cscope.exe -Rbk -i cscope.files"
    else
        "以下注释是在不断尝试中的改进，对于路径中的空格，有了不错的解决
        :silent !find . -regex '.*\.c|.*\.cc\|.*\.cpp\|.*\.h\|.*\.s\|.*\.asm\|.*\.py\|.*\.js' | ls |sed "s:^:`pwd`/:" >cscope.files & "ctags" -R --fields=+ianS --excmd=p --extra=+q --c++-kinds=+p --c-kinds=+p -L cscope.files & "cscope" -Rbk
    endif

    if filereadable("cscope.out")
        silent cscope add cscope.out
    else  
        let cscope_file=findfile("cscope.out", ".;")  
        let cscope_pre=matchstr(cscope_file, ".*/")  
        if !empty(cscope_file) && filereadable(cscope_file)  
            exe "cs add" cscope_file cscope_pre  
        endif        
    endif  

    exec "UpdateTypesFileOnly"
    exec "redraw!"
    exec "cd -"
endfunction

function! UpdateTagHighlight()
    if filereadable("tags")
        call TagHighlight#Generation#UpdateAndRead(1)
        exec "UpdateTypesFileOnly"
        return
    endif

    let tags_file=findfile("tags", ",;")
    let tags_pre=matchstr(tags_file, ".*/")
    if !empty(tags_file) && filereadable(tags_file)  
        exec "cd " tags_pre
        call TagHighlight#Generation#UpdateAndRead(1)
        exec "UpdateTypesFileOnly"
        exec "cd -"
        return
    endif        

    let proj_path=finddir(".project", ",;")
    if !empty(proj_path)
        exec "cd " proj_path
        let tags_file=getcwd()."\\tags"
        if filereadable(tags_file)
            call TagHighlight#Generation#UpdateAndRead(1)
        endif
        exec "cd -"
        return 
    endif
endfunction

" 打开共享文件链接
function! VimwikiLinkHandler(link)
    " Use Vim to open external files with the 'vfile:' scheme.  E.g.:
    "   1) [[vfile:~/Code/PythonProject/abc123.py]]
    "   2) [[vfile:./|Wiki Home]]
    let link = a:link
    if link =~# '^vfile:'
        let link = link[1:]
    else
        return 0
    endif
    if link == ''
        echomsg 'Vimwiki Error: Unable to resolve link!'
        return 0
    else
        "exe 'tabnew ' . fnameescape(link_infos.filename)
        execute '!start explorer ' . link 
        return 1
    endif
endfunction

function MyCompile()
    silent exec "w"
    let v:statusmsg = ''
    silent exec "make"
    if empty(v:statusmsg)
        echo "Compliation successful"
    endif
    exec "botright cwindow"
endfunc

"定义Run函数
function MyRun()
    exec ":call MyCompile()"
    echo "Run ".expand('%:t:r').".exe"
    if &filetype == 'c' || &filetype == 'cpp'
        exec "!%<.exe"
    elseif &filetype == 'java'
        exec "!java %<"
    endif
endfunc

"定义Debug函数，用来调试程序
function MyDebug()
    exec ":call MyCompile()"
    echo "Gdb ".expand('%:t:r').".exe"
    "C程序
    if &filetype == 'c'
        exec "!gdb %<.exe"
    elseif &filetype == 'cpp'
        exec "!gdb %<.exe"
        "Java程序
    elseif &filetype == 'java'
        exec "!jdb %<"
    endif
endfunc

function OpenBrowers(name)
    exec ":update"     

    let l:browers = {
        "cr" : "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    }

    exec "silent! start ". l:browers[a:name] . expand("%")
endfunction
"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File:
"       basic.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember
set history=500

" Enable filetype plugins
filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","

" Fast saving
nmap <leader>w :w!<cr>

" :W sudo saves the file 
" (useful for handling the permission-denied error)
"command W w !sudo tee % > /dev/null


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Avoid garbled characters in Chinese language windows OS
"let $LANG='en' 
"set langmenu=en
"source $VIMRUNTIME/delmenu.vim
"source $VIMRUNTIME/menu.vim
set encoding=utf-8
set termencoding=utf-8

set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
set fileencoding=utf-8
set ambiwidth=double
set fileformats=unix,dos,mac

if has("win16") || has("win32") || has("win64")
    set langmenu=zh_CN.UTF-8
    language messages zh_CN.UTF-8
    " 解决中文菜单乱码
    source $VIMRUNTIME/delmenu.vim
    source $VIMRUNTIME/menu.vim
endif

" Turn on the WiLd menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=.git\*,.hg\*,.svn\*
else
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

if has('win32') || has('win64')
    if (v:version == 704 && has("patch393")) || v:version > 704
        set renderoptions=type:directx,
                    \gamma:1.5,contrast:0.5,geom:1,
                    \renmode:5,taamode:1,level:0.5
    endif
    autocmd GUIEnter * sim ~x
    "set lines=100
    "set columns=240
    winpos 0 0
endif

"Always show current position
set ruler

" Height of the command bar
set cmdheight=2

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases 
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch 

" Don't redraw while executing macros (good performance config)
set lazyredraw 

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch 
" How many tenths of a second to blink when matching brackets
set mat=2

" 任何时候都显示隐藏字符
set cocu=niv
" 在n模式下隐藏字符
"set cocu=n 

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Properly disable sound on errors on MacVim
if has("gui_macvim")
    autocmd GUIEnter * set vb t_vb=
endif

" Add a bit extra margin to the left
set foldcolumn=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable 

" Enable 256 colors palette in Gnome Terminal
if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif

" Set extra options when running in GUI mode
if has("gui_running")
    set guioptions-=T
    set guioptions-=e
    set t_Co=256
    set guitablabel=%M\ %t
endif

set helplang=cn

" resovle the cursor is not block in the cygwin Terminal.
let s:cygwin = 0
if s:cygwin
    let &t_ti.="\e[1 q"
    let &t_SI.="\e[5 q"
    let &t_EI.="\e[1 q"
    let &t_te.="\e[0 q"
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"=> Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile
set noundofile

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set ci 
set wrap "Wrap lines
set nu

""""""""""""""""""""""""""""""
" => Visual mode related
""""""""""""""""""""""""""""""
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
map <space> /
map <c-space> ?

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Smart way to move between windows
nmap <C-j> <C-W>j
nmap <C-k> <C-W>k
nmap <C-h> <C-W>h
nmap <C-l> <C-W>l
nmap <Leader>rs :res -10<CR>
nmap <leader>ra :res +10<CR>

" Close the current buffer
"map <leader>bd :Bclose<cr>:tabclose<cr>gT

" Close all the buffers
"map <leader>ba :bufdo bd<cr>

"map <leader>l :bnext<cr>
"map <leader>h :bprevious<cr>

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <A-LEFT>   :-tabnext<cr>
map <A-RIGHT>  :+tabnext<cr>
" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>

"map <leader>tm :tabmove 
"map <leader>t<leader> :tabnext<cr>


" Let 'tl' toggle between this and the last accessed tab
" let g:lasttab = 1
" nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
" autocmd TabLeave * let g:lasttab = tabpagenr()

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers 
try
    set switchbuf=useopen,usetab,newtab
    set stal=2
catch
endtry

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif


""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

" Format the status line
"set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character
map 0 ^

" Move a line of text using ALT+[jk] or Command+[jk] on mac
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

if has("mac") || has("macunix")
    nmap <D-j> <M-j>
    nmap <D-k> <M-k>
    vmap <D-j> <M-j>
    vmap <D-k> <M-k>
endif

if has("autocmd")
    autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Spell checking
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

" Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vimdiff
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <Leader>df :vertical diffsplit<space>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>mm mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Quickly open a buffer for scribble
map <leader>ob :tabedit ~/buffer<cr>

" Quickly open a markdown buffer for scribble
"map <leader>x :e ~/buffer.md<cr>

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>

" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FILE: 
"       extend.vim
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => GUI related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set font according to system
if has("mac") || has("macunix")
    set gfn=Hack:h14,Source\ Code\ Pro:h15,Menlo:h15
elseif has("win16") || has("win32")
    "set gfn=Hack:h12,DejaVu\ Sans\ Mono\ for\ Powerline:h11,Bitstream\ Vera\ Sans\ Mono:h11
    set gfn=Hack:h11:Inziu\ IosevkaCC\ SC:h12,DejaVu\ Sans\ Mono\ for\ Powerline:h11,Bitstream\ Vera\ Sans\ Mono:h11

elseif has("gui_gtk2")
    set gfn=Hack\ 12,Source\ Code\ Pro\ 11,Bitstream\ Vera\ Sans\ Mono\ 11
elseif has("linux")
    set gfn=Hack\ 12,Source\ Code\ Pro\ 11,Bitstream\ Vera\ Sans\ Mono\ 11
elseif has("unix")
    set gfn=Monospace\ 11
endif

" Disable scrollbars (real hackers don't use scrollbars for navigation!)
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L

" Colorscheme
try
    "colorscheme solarized
    if has("unix")
    augroup mycolor
        au!
        autocmd BufReadPost * colorscheme evening
        autocmd BufReadPost * hi VertSplit guibg=#31312D guifg=#526A83 ctermfg=White ctermbg=Black term=none cterm=none gui=none
    augroup END
    else
        colorscheme evening
        autocmd BufReadPost * hi VertSplit guibg=#31312D guifg=#526A83 ctermfg=White ctermbg=Black term=none cterm=none gui=none
    endif
catch
endtry

set background=dark

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Fast editing and reloading of vimrc configs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("win16") || has("win32") || has("win64")
    map <leader>e :e! $vim/_vimrc<cr>
else
    map <leader>e :e! ~/.vimrc
endif
"autocmd! bufwritepost ~/.vim_runtime/my_configs.vim source ~/.vim_runtime/my_configs.vim


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Turn persistent undo on 
"    means that you can undo even when you close a buffer/VIM
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" try
"     set undodir=~/.vim_runtime/temp_dirs/undodir
"     set undofile
" catch
" endtry


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Command mode related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Smart mappings on the command line
cno $h e ~/
cno $d e ~/Desktop/
cno $j e ./
cno $c e <C-\>eCurrentFileDir("e")<cr>

" $q is super useful when browsing on the command line
" it deletes everything until the last slash 
cno $q <C-\>eDeleteTillSlash()<cr>

" Bash like keys for the command line
cnoremap <C-A>		<Home>
cnoremap <C-E>		<End>
cnoremap <C-K>		<C-U>

cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" Map ? to something useful
"map ? $
"cmap ? $
"imap ? $


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Parenthesis/bracket
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
vnoremap $1 <esc>`>a)<esc>`<i(<esc>
vnoremap $2 <esc>`>a]<esc>`<i[<esc>
vnoremap $3 <esc>`>a}<esc>`<i{<esc>
vnoremap $$ <esc>`>a"<esc>`<i"<esc>
vnoremap $q <esc>`>a'<esc>`<i'<esc>
vnoremap $e <esc>`>a"<esc>`<i"<esc>

" Map auto complete of (, ", ', [
inoremap $1 ()<esc>i
inoremap $2 []<esc>i
inoremap $3 {}<esc>i
inoremap $4 {<esc>o}<esc>O
inoremap $q ''<esc>i
inoremap $e ""<esc>i


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General abbreviations
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
iab xdate <c-r>=strftime("%d/%m/%y %H:%M:%S")<cr>
"}}}

let s:use_config=1
if s:use_config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FILE: 
"       vundle.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
if has("win16") || has("win32") || has("win64")
    set rtp+=D:/Vim/vimfiles/bundle/Vundle.vim/
    call vundle#begin("D:/Vim/vimfiles/bundle/")
endif

if has("unix")
    set rtp+=~/.vim/bundle/Vundle.vim/
    call vundle#begin("~/.vim/bundle/")
endif
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
if has("lua")
    Plugin 'Shougo/neocomplete.vim'
    Plugin 'Shougo/neosnippet'
    Plugin 'Shougo/neosnippet-snippets'
else
    Plugin 'exvim/ex-autocomplpop'
    Plugin 'ervandew/supertab'
endif
Plugin 'honza/vim-snippets'
Plugin 'altercation/vim-colors-solarized'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-scripts/bufexplorer.zip'
"Plugin 'itchyny/lightline.vim'
Plugin 'vimwiki/vimwiki'
Plugin 'tpope/vim-commentary'
Plugin 'godlygeek/tabular'
"Plugin 'vim-scripts/taglist.vim'
Plugin 'majutsushi/tagbar'
Plugin 'vim-scripts/TagHighlight'
Plugin 'easymotion/vim-easymotion'
Plugin 'yegappan/mru'
Plugin 'kien/ctrlp.vim'
Plugin 'mileszs/ack.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'flazz/vim-colorschemes'
Plugin 'mbbill/fencview'
Plugin 'hail2u/vim-css3-syntax'     
Plugin 'pangloss/vim-javascript'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'vim-syntastic/syntastic'
Plugin 'airblade/vim-rooter'
Plugin 'vimcn/vimcdoc'
"Plugin 'amiorin/vim-project'
"SnipMate depends on vim-addon-mw-utils and tlib.
"Plugin 'MarcWeber/vim-addon-mw-utils'
"Plugin 'tomtom/tlib_vim'
"Plugin 'garbas/vim-snipmate'
"Plugin 'hallison/vim-markdown'
" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
"Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FILE: 
"       plugin_config.vim
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => highlight c function, useage: copy the follows to syntax/c.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"来自王垠的著名配置文件，对函数名进行高亮
" syn match cFunction "\<[a-zA-Z_][a-zA-Z_0-9]*\>[^()]*)("me=e-2
" syn match cFunction "\<[a-zA-Z_][a-zA-Z_0-9]*\>\s*("me=e-1
" hi cFunction gui=NONE guifg=#268bd2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => lightline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"let g:lightline = {
"      \ 'colorscheme': 'wombat',
"      \ 'active': {
"      \   'left': [ ['mode', 'paste'],
"      \             ['fugitive', 'readonly', 'filename', 'modified'] ],
"      \   'right': [ [ 'lineinfo' ], ['percent'] ]
"      \ },
"      \ 'component': {
"      \   'readonly': '%{&filetype=="help"?"":&readonly?"??":""}',
"      \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
"      \   'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}'
"      \ },
"      \ 'component_visible_condition': {
"      \   'readonly': '(&filetype!="help"&& &readonly)',
"      \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
"      \   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
"      \ },
"      \ 'separator': { 'left': ' ', 'right': ' ' },
"      \ 'subseparator': { 'left': ' ', 'right': ' ' }
"      \ }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Airline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_powerline_fonts = 1
let Powerline_symbols='fancy'  

if has("win16") || has("win32")
    let g:airline_left_sep = ''
    let g:airline_left_alt_sep = ''
    let g:airline_right_sep = ''
    let g:airline_right_alt_sep = ''
    let g:airline_symbols.branch = ''
    let g:airline_symbols.readonly = ''
    let g:airline_symbols.linenr = ''
elseif has("unix")
    let g:airline_left_sep = '▶'
    let g:airline_right_sep = '◀'
    let g:airline_symbols.linenr = '¶'
    let g:airline_symbols.maxlinenr = '☰'
    let g:airline_symbols.branch = '⎇'
    let g:airline_symbols.paste = '∥'
    let g:airline_symbols.notexists = '∄'
    let g:airline_symbols.whitespace = 'Ξ'
endif


" themes are automatically selected based on the matching colorscheme. this
" can be overridden by defining a value. >
let g:airline_theme='dark'
" 是否打开tabline
"let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline#extensions#quickfix#quickfix_text = 'Quickfix'
let g:airline#extensions#quickfix#location_text = 'Location'
let g:airline#extensions#syntastic#enabled = 1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Quickfix
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <F4>     :botright cwindow<CR>
map <C-F4>   :ccl<CR>
map <A-UP>   :cp<CR>
map <A-DOWN> :cn<CR>

map <leader>cw :botright cwindow<cr>
map <leader>ccl :ccl<cr>
map <leader>cn  :cnext<CR>
map <leader>cp  :cpreviouse<CR>

map <leader>lw :botright lwindow<cr>
map <leader>lcl :lclose<cr>
map <leader>ln  :lnext<CR>
map <leader>lp  :lpreviouse<CR>
"map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Ack searching and cope displaying
"    requires ack.vim - it's much better than vimgrep/grep
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use the the_silver_searcher if possible (much faster than Ack)
if executable('ag')
    let g:ackprg = 'ag --vimgrep --smart-case --ignore *.out'
endif
" When you press gv you Ack after the selected text
vnoremap <silent> gv :call VisualSelection('gv', '')<CR>
" Open Ack and put the cursor in the right position
map <leader>g :Ack 
" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>r :call VisualSelection('replace', '')<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Ctags
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set tags=./.project/tags;./tags;,tags
" configure tags - add additional tags here or comment out not-used ones
" set tags+=~/.vim/tags/cpp_files

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => cscope setting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("cscope")
    "set csprg=/usr/bin/cscope
    set csto=1
    set cst
    set nocsverb
    " display in quickfix,":bo cw" or "cw" to open quickfix.
    set cscopequickfix=s-,c-,d-,i-,t-,e-
    " add any database in current directory
    let cscope_pre = finddir(".project", ".;")
    if isdirectory(cscope_pre)
        if filereadable("cscope.out")
            exec "cs add cscope.out" cscope_pre
        endif
    else
        if filereadable("cscope.out")
            cs add cscope.out
        endif
    endif
    set csverb
endif

"0 or s: Find this C symbol
nmap <C-_>s :cs find s <C-R>=expand("<cword>")<CR><CR>
"1 or g: Find this definition
nmap <C-_>g :cs find g <C-R>=expand("<cword>")<CR><CR>
"2 or d: Find functions called by this function
nmap <C-_>d :cs find d <C-R>=expand("<cword>")<CR><CR>
"3 or c: Find functions calling this function
nmap <C-_>c :cs find c <C-R>=expand("<cword>")<CR><CR>
"4 or t: Find this text string
nmap <C-_>t :cs find t <C-R>=expand("<cword>")<CR><CR>
"6 or e: Find this egrep pattern
nmap <C-_>e :cs find e <C-R>=expand("<cword>")<CR><CR>
"7 or f: Find this file
nmap <C-_>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
"8 or i: Find files #including this file
nmap <C-_>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
"9 or a: Find places where this symbol is assigned a value
nmap <C-_>a :cs find a <C-R>=expand("<cword>")<CR><CR>

"F12快捷键,更新当前目录下的ctags与cscope.out文件
nmap <silent> <C-F12> :call UpdateTagsAndCscope2()<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => OmniCppComplete
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let OmniCpp_NamespaceSearch = 1
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
let OmniCpp_MayCompleteDot = 1 " autocomplete after .
let OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
let OmniCpp_MayCompleteScope = 1 " autocomplete after ::
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]

" Enable omni completion.
augroup omni
    au!
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    autocmd FileType c set omnifunc=ccomplete#Complete
    autocmd FileType cpp set omnifunc=omni#cpp#complete#Main
augroup END

" automatically open and close the popup menu / preview window
autocmd CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
set completeopt=menuone,menu,longest,preview

if has("lua")
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => Neocomplete
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "Note: This option must be set in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
    " Disable AutoComplPop.
    let g:acp_enableAtStartup = 0
    " Use neocomplete.
    let g:neocomplete#enable_at_startup = 1
    " Use smartcase.
    let g:neocomplete#enable_smart_case = 1
    " Set minimum syntax keyword length.
    let g:neocomplete#sources#syntax#min_keyword_length = 3

    " Define dictionary.
    let g:neocomplete#sources#dictionary#dictionaries = {
                \ 'default' : '',
                \ 'vimshell' : $HOME.'/.vimshell_hist',
                \ 'scheme' : $HOME.'/.gosh_completions'
                \ }

    " Define keyword.
    if !exists('g:neocomplete#keyword_patterns')
        let g:neocomplete#keyword_patterns = {}
    endif
    let g:neocomplete#keyword_patterns['default'] = '\h\w*'

    " Plugin key-mappings.
    inoremap <expr><C-g>     neocomplete#undo_completion()
    inoremap <expr><C-l>     neocomplete#complete_common_string()

    " Recommended key-mappings.
    " <CR>: close popup and save indent.
    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    function! s:my_cr_function()
        "return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
        " For no inserting <CR> key.
        return pumvisible() ? "\<C-y>" : "\<CR>"
    endfunction
    " <TAB>: completion.
    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    inoremap <expr><A-TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-o>"
    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    " Close popup by <Space>.
    "inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

    " AutoComplPop like behavior.
    let g:neocomplete#enable_auto_select = 1

    " Shell like behavior(not recommended).
    "set completeopt+=longest
    "let g:neocomplete#enable_auto_select = 1
    "let g:neocomplete#disable_auto_complete = 1

    " Enable heavy omni completion.
    if !exists('g:neocomplete#sources#omni#input_patterns')
        let g:neocomplete#sources#omni#input_patterns = {}
    endif
    "let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
    "let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
    "let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

    " For perlomni.vim setting.
    " https://github.com/c9s/perlomni.vim
    "let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => Neosnippet
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Plugin key-mappings.
    " Note: It must be "imap" and "smap".  It uses <Plug> mappings.
    imap <C-k>     <Plug>(neosnippet_expand_or_jump)
    smap <C-k>     <Plug>(neosnippet_expand_or_jump)
    xmap <C-k>     <Plug>(neosnippet_expand_target)

    " SuperTab like snippets behavior.
    " Note: It must be "imap" and "smap".  It uses <Plug> mappings.
    imap <C-k>     <Plug>(neosnippet_expand_or_jump)
    "imap <expr><TAB>
    " \ pumvisible() ? "\<C-n>" :
    " \ neosnippet#expandable_or_jumpable() ?
    " \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
    smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
                \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

    " For conceal markers.
    "if has('conceal')
    "    set conceallevel=2 concealcursor=niv
    "endif

    " Enable snipMate compatibility feature.
    let g:neosnippet#enable_snipmate_compatibility = 1

    " Tell Neosnippet about the other snippets
    let g:neosnippet#snippets_directory='D:/vim/vimfiles/bundle/vim-snippets/snippets'
else
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => supertab
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    let g:SuperTabDefaultCompletionType="context"
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Fencview
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"nmap <leader>fad :silent! FencAutoDetect<CR><CR>
nmap <C-F3> :silent! FencAutoDetect<CR><CR>

"let g:fencview_autodetect=1
"let g:fencview_auto_patterns='*.md'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vimwiki
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("win16") || has("win32")
    let g:vimwiki_list = [{'path': 'D:\Wiki', 'path_html': 'D:\Wiki\html', 'syntax': 'markdown', 'auto_tags': 1}]
else
    let g:vimwiki_list = [{'path': '~/Wiki', 'path_html': '~/Wiki/html', 'syntax': 'markdown', 'auto_tags': 1}]
endif

"let g:vimwiki_ext2syntax = {'.md': 'markdown', '.mkd': 'markdown' }
"let g:vimwiki_listsyms = '✗○◐●✓'
hi VimwikiHeader1 guifg=#FF0000
hi VimwikiHeader2 guifg=#00FF00
hi VimwikiHeader3 guifg=#FFFF00
hi VimwikiHeader4 guifg=#FF00FF
hi VimwikiHeader5 guifg=#00FFFF
hi VimwikiHeader6 guifg=#0000FF

let g:vimwiki_hl_cb_checked = 1
let g:vimwiki_CJK_length = 1
let g:vimwiki_use_mouse = 1
" disable table mappings for INSERT mode.
let g:vimwiki_table_mappings=0
" Toggle checkbox of a list item on/off.
map  <Leader>tt <Plug>VimwikiToggleListItem
" Remove checkbox from list item.
" map <Leader><Space> <Plug>VimwikiRemoveSingleCB
" Remove checkboxes from all sibling list items.
" map <Leader><Space> <Plug>VimwikiRemoveCBInList

augroup wiki
    au!
    autocmd BufRead,BufNewFile *.md,*mkd set filetype=markdown
    autocmd BufRead,BufNewFile *.wiki set filetype=wiki
    autocmd FileType wiki,md,mkd setlocal cocu=""
    autocmd FileType wiki,md,mkd setlocal shiftwidth=2
    autocmd FileType wiki,md,mkd setlocal tabstop=2
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => bufExplorer plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:bufExplorerDefaultHelp=0
let g:bufExplorerShowRelativePath=1
let g:bufExplorerFindActive=1
let g:bufExplorerSortBy='name'
map <leader>be :BufExplorer<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Nerd Tree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:NERDTreeWinPos = "left"
let NERDTreeShowHidden=0
let NERDTreeIgnore = ['\.pyc$', '__pycache__']
let g:NERDTreeWinSize=35
let NERDTreeShowBookmarks=1
map <leader>nn :NERDTreeToggle<cr>
map <leader>nb :NERDTreeFromBookmark<Space>
map <leader>nf :NERDTreeFind<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Taglist
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"设定Linux系统中ctags程序的位置
"let Tlist_Ctags_Cmd = '/usr/bin/ctags'   
" 不同时显示多个文件的tag，只显示当前文件的
"let Tlist_Show_One_File=1  
"如果taglist窗口是最后一个窗口，则退出vim
"let Tlist_Exit_OnlyWindow=1  
"在右侧窗口中显示taglist窗口
"let Tlist_Use_Right_Window = 1       
" 缺省情况下，在双击一个tag时，才会跳到该tag定义的位置
"let Tlist_Use_SingleClick= 1    
"在启动VIM后，自动打开taglist窗口
"let Tlist_Auto_Open=1 
"taglist始终解析文件中的tag，不管taglist窗口有没有打开
"let Tlist_Process_File_Always=1 
"同时显示多个文件中的tag时，可使taglist只显示当前文件tag，其它文件的tag都被折叠起来
"let Tlist_File_Fold_Auto_Close=1 
" Vimwiki support
"let tlist_vimwiki_settings = 'wiki;h:Headers'
" Markdown support
"let tlist_markdown_settings = 'markdown;h:Headers'
"map <leader>tl :TlistToggle<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => TagBar
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("gui_running")
    let g:tagbar_expand = 1
endif
let g:tagbar_autoshowtag = 1
let g:tagbar_sort=0
" Add support for markdown files in tagbar.
let g:tagbar_type_markdown = {
            \ 'ctagstype' : 'markdown',
            \ 'kinds'     : [
            \ 'h:header',
            \ ],
            \ 'sort'    : 0
            \ }

" vimwiki support
let g:tagbar_type_vimwiki = {
            \ 'ctagstype' : 'wiki',
            \ 'kinds'     : [
            \ 'h:header',
            \ ],
            \ 'sort'    : 0
            \ }

let g:tagbar_type_javascript = {
            \ 'ctagstype': 'javascript',
            \ 'kinds': [
            \ 'c:classes',
            \ 'n:modules',
            \ 'v:variables',
            \ 'm:members',
            \ 'i:interfaces',
            \ 'e:enums',
            \ 'f:functions',
            \ ],
            \ 'sort'    : 0
            \ }

autocmd FileType * nested :call tagbar#autoopen(0)
map <leader>tl :TagbarToggle<CR>
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => CtrlP
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlp_map = '<leader>p'
let g:ctrlp_cmd = 'CtrlP'
map <Leader>ff :CtrlPMRU<CR>
let g:ctrlp_custom_ignore = {
            \ 'dir':  '\v[\/]\.(git|hg|svn|rvm)$',
            \ 'file': '\v\.(exe|so|dll|zip|tar|tar.gz|pyc)$',
            \ }
let g:ctrlp_working_path_mode=0
let g:ctrlp_match_window_bottom=1
let g:ctrlp_max_height=15
let g:ctrlp_match_window_reversed=0
let g:ctrlp_mruf_max=500
let g:ctrlp_follow_symlinks=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => easymotion 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:EasyMotion_smartcase = 1
"let g:EasyMotion_startofline = 0 " keep cursor colum when JK motion
map <Leader><leader>h <Plug>(easymotion-linebackward)
map <Leader><Leader>j <Plug>(easymotion-j)
map <Leader><Leader>k <Plug>(easymotion-k)
map <Leader><leader>l <Plug>(easymotion-lineforward)
" 重复上一次操作, 类似repeat插件, 很强大
map <Leader><leader>. <Plug>(easymotion-repeat)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => tabular 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"if exists(":Tabularize")
"    nmap <Leader>tg= :Tabularize /=<CR>
"    vmap <Leader>tg= :Tabularize /=<CR>
"    nmap <Leader>tg| :Tabularize /|<CR>
"    vmap <Leader>tg| :Tabularize /|<CR>
"    nmap <Leader>tg: :Tabularize /:\zs<CR>
"    vmap <Leader>tg: :Tabularize /:\zs<CR>
"endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => mru
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>mu :MRU<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TagHighlight
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if ! exists('g:TagHighlightSettings')
    let g:TagHighlightSettings = {}
endif
let g:TagHighlightSettings['TagFileName'] = 'tags'
if has("unix")
    let g:TagHighlightSettings['CtagsExecutable'] = 'ctags'
else
    let g:TagHighlightSettings['CtagsExecutable'] = 'ctags.exe'
endif
let g:TagHighlightSettings['LanguageDetectionMethods'] = ['Extension', 'FileType']
let g:TagHighlightSettings['FileTypeLanguageOverrides'] =  {'tagbar': 'c'}
let g:TagHighlightSettings['EnableCscope'] = 'True'
let g:TagHighlightSettings['CscopeOnlyIfPresent'] = 'True'
let g:TagHighlightSettings['DoNotGenerateTags'] = 'True'                    
"autocmd User TagHighlightAfterRead call airline#load_theme()
"autocmd FileType c,cpp,h,java,py :call UpdateTagHighlight()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Astyle Format Code
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("unix")
    " version 2.6+
    autocmd FileType c,cpp setlocal equalprg=astyle\ -A1\ -xk\ -Y\ -m0\ -M80\ -f\ -p\ -xg\ -H\ -k3\ -W3\ -y\ -J\ -xy\ --mode=c
else
    " version 3.0+
    autocmd FileType c,cpp setlocal equalprg=astyle\ -A1\ -xV\ -xk\ -Y\ -m0\ -M80\ -f\ -p\ -xg\ -H\ -k3\ -W3\ -y\ -J\ -xy\ --mode=c
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => compile
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup makeCnf
    au!
    autocmd FileType c    setlocal makeprg=gcc\ -Wall\ %\ -g\ -o\ %<.exe
    autocmd FileType cpp  setlocal makeprg=g++\ -Wall\ %\ -g\ -o\ %<.exe
    autocmd FileType java setlocal makeprg=javac\ %
    autocmd FileType c,cpp compiler gcc 
augroup END


"结束定义Debug
"设置程序的运行和调试的快捷键F5和Ctrl-F5
map <F5>   :call MyCompile()<CR>
map <C-F5> :call MyDebug()<CR>
map <F6>   :call MyRun()<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => syntastic
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" javascript
let g:syntastic_javascript_checkers = ['jslint']
let g:syntastic_javascript_jslint_args = "--white --nomen --regexp --browser --devel --windows --sloppy --vars"
" cpp
let g:syntastic_cpp_checkers = ['cppcheck']
let g:syntastic_cpp_cppcheck_exec = "C:\\Program Files\\Cppcheck\\cppcheck.exe"
let g:syntastic_cpp_cppcheck_args = "--enable=all"

" 设置错误符号
"let g:syntastic_error_symbol='✗'
" 设置警告符号
"let g:syntastic_warning_symbol='⚠'

hi SyntasticWarningSign guifg=black guibg=yellow
hi SyntasticErrorSign guifg=white guibg=red

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_stl_format = "[%E{Err: %fe #%e}%B{, }%W{Warn: %fw #%w}]"

nmap <leader>ln :lnext<CR>
nmap <leader>lp :lprevious<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-rooter
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_patterns = ['.project/', '.git/']

map <F2> :call OpenBrowers("cr")<CR>
"}}}
endif
