
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

  " These keeps last two tmux buffer names. If TmuxBufferName() and lastbname
  " differ, this means tmux made some copies in other panes, creating new
  " buffer(s). If these two are same, but lastbname and prevbname are
  " different, this means tmux made a copy in the same pane: New buffer is
  " created before FocusLost can accurately update lastbname. Therefore,
  " FocusLost sets lastbname to newly created buffer. Lastly, when vim is
  " yanking to tmux buffer, prevbname is set to lastbname to avoid another copy
  " due to new buffer created as a result of this yank.
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
        \ echo s:lastbname . " " . s:TmuxBufferName() . " " . s:prevbname |
        \ if s:lastbname != s:TmuxBufferName() || s:lastbname != s:prevbname |
        \   echo "BINGO!" |
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
      autocmd FocusLost   * silent! call system('tmux loadb -',@")
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

