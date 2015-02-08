hi! CurrentSearchEntry guibg=green ctermbg=4

function! s:ClearHighlighting()
    if exists('s:match_id')
        call matchdelete(s:match_id)
        unlet s:match_id
    endif
endfunction

function! s:HighlightCurrentSearch()
    let word = @/
    let word = matchstr(word, '\<\zs.\+\ze\>') 
    let length = strlen(word)

    if length == 0 | return | endif

    call s:ClearHighlighting()

    let pos = 0
    let left = ''
    let right = word
    let parts = []
    while pos < length
        call add(parts, '\%(' . left . '\%#' . right . '\)')
        let left = word[0:pos]
        let right = word[pos + 1:]
        let pos += 1
    endwhile
    let rg = '\c' . join(parts, '\|')
    let s:match_id = matchadd('CurrentSearchEntry', rg)
endfunction

function! s:ClearSearch()
    let s:previous_search = @/ 
    let @/ = ""
    let s:last_search = ''
    call s:ClearHighlighting()
endfunction

let s:last_search = ''
let s:previous_search = ''
function! s:DetectSearch()
    let word = @/
    if word != '' && word != s:last_search
        let s:last_search = word
        call s:HighlightCurrentSearch()
    elseif word == '' && s:last_search != ''
        call s:ClearSearch()
    endif
endfunction

function! s:SetPreviousSearchQuery()
    let current_search = @/
    if s:previous_search != '' && current_search == ''
        let @/ = s:previous_search
    endif
endfunction

autocmd CursorMoved * call <SID>DetectSearch()
autocmd VimEnter * call <SID>ClearSearch()
autocmd VimLeave * call <SID>ClearSearch()
set noek
nnoremap <silent><ESC> :silent! :call <SID>ClearSearch()<RETURN><ESC>
nnoremap <silent>n :silent! :call <SID>SetPreviousSearchQuery()<RETURN>:silent! normal! n<RETURN>
nnoremap <silent>N :silent! :call <SID>SetPreviousSearchQuery()<RETURN>:silent! normal! N<RETURN>
