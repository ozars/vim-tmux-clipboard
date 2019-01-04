
function! s:TmuxBufferName()
  let l:list = systemlist('tmux list-buffers -F"#{buffer_name}"')
  if len(l:list)==0
    return ""
  else
    return l:list[0]
  endif
endfunction

function! s:TmuxBuffer()
  return system('tmux show-buffer')
endfunction

function! s:Enable()

  if $TMUX==''
    " not in tmux session
    return
  endif

  let s:lastbname=""
  let s:prevbname=""

  " if support TextYankPost
  if exists('##TextYankPost')==1
    " @"
    augroup vimtmuxclipboard
      autocmd!
      autocmd FocusLost    *
        \ let s:prevbname = s:lastbname |
        \ let s:lastbname = s:TmuxBufferName()
      autocmd FocusGained  *
        \ if s:lastbname != s:TmuxBufferName() || s:lastbname != s:prevbname |
        \   let @" = s:TmuxBuffer() |
        \ endif
      autocmd TextYankPost *
        \ silent! call system('tmux loadb -',join(v:event["regcontents"],"\n")) |
        \ let s:lastbname = s:TmuxBufferName() |
        \ let s:prevbname = s:lastbname |
    augroup END
    let @" = s:TmuxBuffer()
  else
    " vim doesn't support TextYankPost event
    " This is a workaround for vim
    augroup vimtmuxclipboard
      autocmd!
      autocmd FocusLost * silent! call system('tmux loadb -',@")
      autocmd FocusGained * let @" = s:TmuxBuffer()
    augroup END
    let @" = s:TmuxBuffer()
  endif

endfunction

call s:Enable()

  " " workaround for this bug
  " if shellescape("\n")=="'\\\n'"
  "   let l:s=substitute(l:s,'\\\n',"\n","g")
  "   let g:tmp_s=substitute(l:s,'\\\n',"\n","g")
  "   ");
  "   let g:tmp_cmd='tmux set-buffer ' . l:s
  " endif
  " silent! call system('tmux loadb -',l:s)

