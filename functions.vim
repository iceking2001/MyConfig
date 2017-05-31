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
    silent "cd"

    if has("win16") || has("win32")
        "以下注释是在不断尝试中的改进，对于路径中的空格，有了不错的解决
        :silent !dir /b /s *.c *.cc *.cpp *.h *.s *.asm >cscope.files & "\%VIMRUNTIME\%\ctags.exe" -R --fields=+ianS --excmd=p --extra=+q --c++-kinds=+p --c-kinds=+p -L cscope.files & "\%VIMRUNTIME\%\cscope.exe" -Rbk
    else
        "以下注释是在不断尝试中的改进，对于路径中的空格，有了不错的解决
        :silent !find . -regex '.*\.c|.*\.cc\|.*\.cpp\|.*\.h\|.*\.s\|.*\.asm' | ls |sed "s:^:`pwd`/:" >cscope.files & "ctags" -R --fields=+ianS --excmd=p --extra=+q --c++-kinds=+p --c-kinds=+p -L cscope.files & "cscope" -Rbk
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
