" vim-cool - Disable hlsearch when you are done searching.
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.0.2
" License:	MIT License
" Location:	plugin/cool.vim
" Website:	https://github.com/romainl/vim-cool

if exists("g:loaded_cool") || v:version < 703 || &compatible
    finish
endif
let g:loaded_cool = 1

let s:save_cpo = &cpo
set cpo&vim

let s:saveh = &highlight
augroup Cool
    autocmd!
    " toggle coolness when hlsearch is toggled
    autocmd OptionSet hlsearch call <SID>PlayItCool(v:option_old, v:option_new)
    autocmd OptionSet highlight let s:saveh = &highlight
augroup END

function! s:StartHL()
    silent! if v:hlsearch && !search('\%#\zs'.@/,'cnW')
        call <SID>StopHL()
    endif
endfunction

function! s:StopHL()
    if !v:hlsearch || mode() isnot 'n'
        return
    else
        silent call feedkeys("\<Plug>(StopHL)", 'm')
    endif
endfunction

function! s:AuNohlsearch()
    noau set highlight+=l:-
    " toggle highlighting, a workaround for :nohlsearch in autocmds
    autocmd Cool Insertleave *
                \ noau let &highlight = s:saveh | autocmd! Cool InsertLeave *
    return ''
endfunction

function! s:PlayItCool(old, new)
    if a:old == 0 && a:new == 1
        " nohls --> hls
        "   set up coolness
        noremap  <silent><Plug>(StopHL) :<C-U>nohlsearch<cr>
        noremap! <expr> <Plug>(StopHL) exists('*execute') ?
                    \ execute('nohlsearch')[-1] : <SID>AuNohlsearch()

        autocmd Cool CursorMoved * call <SID>StartHL()
        autocmd Cool InsertEnter * call <SID>StopHL()
    elseif a:old == 1 && a:new == 0
        " hls --> nohls
        "   tear down coolness
        nunmap <Plug>(StopHL)
        unmap! <expr> <Plug>(StopHL)

        autocmd! Cool CursorMoved
        autocmd! Cool InsertEnter
    else
        " nohls --> nohls
        "   do nothing
        return
    endif
endfunction

" play it cool
call <SID>PlayItCool(0, &hlsearch)

let &cpo = s:save_cpo
