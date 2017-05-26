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

let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

" themes are automatically selected based on the matching colorscheme. this
" can be overridden by defining a value. >
let g:airline_theme='dark'
" 是否打开tabline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline#extensions#quickfix#quickfix_text = 'Quickfix'
let g:airline#extensions#quickfix#location_text = 'Location'
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Quickfix
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <F4>     :botright cwindow<CR>
map <C-F4>   :ccl<CR>
map <A-UP>   :cp<CR>
map <A-DOWN> :cn<CR>

map <leader>cc :botright cwindow<cr>
map <leader>ccl :ccl<cr>
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
function! UpdateTagsAndCscope()
    if filereadable("cscope.out")
        silent cscope kill cscope.out
    endif
    silent "cd"
    "以下注释是在不断尝试中的改进，对于路径中的空格，有了不错的解决
    :silent !dir /b /s *.c *.cc *.cpp *.h *.s *.asm >cscope.files & "\%VIMRUNTIME\%\ctags.exe" -R --fields=+ianS --excmd=p --extra=+q --c++-kinds=+p --c-kinds=+p -L cscope.files & "\%VIMRUNTIME\%\cscope.exe" -Rbk
    if filereadable("cscope.out")
        silent cscope add cscope.out
    else  
        let cscope_file=findfile("cscope.out", ".;")  
        let cscope_pre=matchstr(cscope_file, ".*/")  
        if !empty(cscope_file) && filereadable(cscope_file)  
            exe "cs add" cscope_file cscope_pre  
        endif        
    endif  
 endfunction
 
set tags=./tags;,tags
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
  if filereadable("cscope.out")
      cs add cscope.out
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
nmap <silent> <C-F12> :call UpdateTagsAndCscope()<CR>

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
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd FileType c set omnifunc=ccomplete#Complete
autocmd FileType cpp set omnifunc=omni#cpp#complete#Main

" automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
set completeopt=menuone,menu,longest,preview

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
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif

" Enable snipMate compatibility feature.
let g:neosnippet#enable_snipmate_compatibility = 1

" Tell Neosnippet about the other snippets
let g:neosnippet#snippets_directory='D:/vim/vimfiles/bundle/vim-snippets/snippets'

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
let g:vimwiki_list = [{'path': 'D:\Wiki', 'path_html': 'D:\Wiki\html', 'syntax': 'markdown', 'auto_tags': 1}]
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

autocmd FileType wiki setlocal cocu=""
autocmd FileType wiki,md,mkd setlocal shiftwidth=2
autocmd FileType wiki,md,mkd setlocal tabstop=2

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
autocmd FileType * nested :call tagbar#autoopen(0)
map <leader>tl :TagbarToggle<CR>
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => CtrlP
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlp_map = '<leader>p'
let g:ctrlp_cmd = 'CtrlP'
map <Leader>f :CtrlPMRU<CR>
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
let g:TagHighlightSettings['CtagsExecutable'] = 'ctags.exe'
let g:TagHighlightSettings['LanguageDetectionMethods'] = ['Extension', 'FileType']
let g:TagHighlightSettings['FileTypeLanguageOverrides'] =  {'tagbar': 'c'}
let g:TagHighlightSettings['EnableCscope'] = 'True'
let g:TagHighlightSettings['CscopeOnlyIfPresent'] = 'True'
"autocmd User TagHighlightAfterRead call airline#load_theme()
autocmd FileType c,cpp,h,java,py :silent call TagHighlight#Generation#UpdateAndRead(1)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Astyle Format Code
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au FileType c,cpp setlocal equalprg=astyle\ -A1\ -xV\ -xk\ -Y\ -m0\ -M80\ -f\ -p\ -xg\ -H\ -k3\ -W3\ -y\ -J\ -xy\ --mode=c

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => compile
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType c    setlocal makeprg=gcc\ -Wall\ %\ -g\ -o\ %<.exe
autocmd FileType cpp  setlocal makeprg=g++\ -Wall\ %\ -g\ -o\ %<.exe
autocmd FileType java setlocal makeprg=javac\ %
autocmd FileType c,cpp compiler gcc 

func MyCompile()
    silent exec "w"
    let v:statusmsg = ''
    silent exec "make"
    if empty(v:statusmsg)
        echo "Compliation successful"
    endif
    exec "botright cwindow"
endfunc

"定义Run函数
func MyRun()
    exec ":call MyCompile()"
    echo "Run ".expand('%:t:r').".exe"
    if &filetype == 'c' || &filetype == 'cpp'
        exec "!%<.exe"
    elseif &filetype == 'java'
        exec "!java %<"
    endif
endfunc

"定义Debug函数，用来调试程序
func MyDebug()
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
"结束定义Debug
"设置程序的运行和调试的快捷键F5和Ctrl-F5
map <F5>   :call MyCompile()<CR>
map <C-F5> :call MyDebug()<CR>
map <F6>   :call MyRun()<CR>
