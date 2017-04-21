"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => highlight c function, useage: copy the follows to syntax/c.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"������������������ļ����Ժ��������и���
" syn match cFunction "\<[a-zA-Z_][a-zA-Z_0-9]*\>[^()]*)("me=e-2
" syn match cFunction "\<[a-zA-Z_][a-zA-Z_0-9]*\>\s*("me=e-1
" hi cFunction gui=NONE guifg=#268bd2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => lightline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ ['mode', 'paste'],
      \             ['fugitive', 'readonly', 'filename', 'modified'] ],
      \   'right': [ [ 'lineinfo' ], ['percent'] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&filetype=="help"?"":&readonly?"??":""}',
      \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
      \   'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}'
      \ },
      \ 'component_visible_condition': {
      \   'readonly': '(&filetype!="help"&& &readonly)',
      \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
      \   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
      \ },
      \ 'separator': { 'left': ' ', 'right': ' ' },
      \ 'subseparator': { 'left': ' ', 'right': ' ' }
      \ }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Quickfix
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <F4>     :bo copen<CR>
map <C-F4>   :ccl<CR>
map <A-UP>   :cp<CR>
map <A-DOWN> :cn<CR>

map <leader>cc :botright cope<cr>
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
    "����ע�����ڲ��ϳ����еĸĽ�������·���еĿո����˲���Ľ��
    :silent !dir /b /s *.c *.cpp *.h *.s *.asm >cscope.files & "\%VIMRUNTIME\%\ctags.exe" -R --fields=+ianS --excmd=p --extra=+q --c++-kinds=+p --c-kinds=+p -L cscope.files & "\%VIMRUNTIME\%\cscope.exe" -Rbk
    if filereadable("cscope.out")
        silent cscope add cscope.out
        echo "���ؼ����ɹ�"
    else
        echo "���ؼ���ʧ��"
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

nmap <C-_>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-_>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-_>d :cs find d <C-R>=expand("<cword>")<CR><CR>

"F12��ݼ�,���µ�ǰĿ¼�µ�ctags��cscope.out�ļ�
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
" => Fencview
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"nmap <leader>fad :silent! FencAutoDetect<CR><CR>
nmap <C-F3> :silent! FencAutoDetect<CR><CR>

"let g:fencview_autodetect=1
"let g:fencview_auto_patterns='*.md'
            
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vimwiki
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:vimwiki_list = [{'path': 'D:\Wiki', 'path_html': 'D:\Wiki\html'}]
hi VimwikiHeader1 guifg=#FF0000
hi VimwikiHeader2 guifg=#00FF00
hi VimwikiHeader3 guifg=#FFFF00
hi VimwikiHeader4 guifg=#FF00FF
hi VimwikiHeader5 guifg=#00FFFF
hi VimwikiHeader6 guifg=#0000FF
let g:vimwiki_CJK_length = 1
" disable table mappings for INSERT mode.
let g:vimwiki_table_mappings=0
" Toggle checkbox of a list item on/off.
map  <Leader>tt <Plug>VimwikiToggleListItem
" Remove checkbox from list item.
" map <Leader><Space> <Plug>VimwikiRemoveSingleCB
" Remove checkboxes from all sibling list items.
" map <Leader><Space> <Plug>VimwikiRemoveCBInList
"
""""""""""""""""""""""""""""""
" => bufExplorer plugin
""""""""""""""""""""""""""""""
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
"�趨Linuxϵͳ��ctags�����λ��
"let Tlist_Ctags_Cmd = '/usr/bin/ctags'   
" ��ͬʱ��ʾ����ļ���tag��ֻ��ʾ��ǰ�ļ���
let Tlist_Show_One_File=1  
"���taglist���������һ�����ڣ����˳�vim
let Tlist_Exit_OnlyWindow=1  
"���Ҳര������ʾtaglist����
let Tlist_Use_Right_Window = 1       
" ȱʡ����£���˫��һ��tagʱ���Ż�������tag�����λ��
"let Tlist_Use_SingleClick= 1    
"������VIM���Զ���taglist����
let Tlist_Auto_Open=1 
"taglistʼ�ս����ļ��е�tag������taglist������û�д�
let Tlist_Process_File_Always=1 
"ͬʱ��ʾ����ļ��е�tagʱ����ʹtaglistֻ��ʾ��ǰ�ļ�tag�������ļ���tag�����۵�����
let Tlist_File_Fold_Auto_Close=1 
" Vimwiki support
let tlist_vimwiki_settings = 'wiki;h:Headers'
" Markdown support
let tlist_markdown_settings = 'markdown;h:Headers'
map <leader>tl :TlistToggle<CR>

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
" �ظ���һ�β���, ����repeat���, ��ǿ��
map <Leader><leader>. <Plug>(easymotion-repeat)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => mru
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>m :MRU<CR>
