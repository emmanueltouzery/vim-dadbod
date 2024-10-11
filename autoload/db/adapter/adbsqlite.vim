function! db#adapter#adbsqlite#canonicalize(url) abort
  return db#url#canonicalize_file(a:url)
endfunction

function! db#adapter#adbsqlite#input_extension(...) abort
  return 'sql'
endfunction

function! db#adapter#adbsqlite#output_extension(...) abort
  return 'dbout'
endfunction

function! db#adapter#adbsqlite#input(url, in) abort
  let parsed = db#url#parse(a:url)
  let flag = has_key(parsed.params, 'adb_flag') ? parsed.params.adb_flag : ''
  return ['bash', '-c', "adb " . flag . " shell \" echo '$(<" . a:in . ")' | sqlite3 -column -header " . db#url#file_path(a:url) . "\""]
endfunction

function! db#adapter#adbsqlite#auth_input() abort
  return v:false
endfunction

function! db#adapter#adbsqlite#tables(url) abort
  return db#systemlist(['bash', '-c', "adb shell \" echo '.tables' | sqlite3 " . db#url#file_path(a:url) . "\" | tr '\\r\\n' ' ' | sed 's/ \\+/\\n/g' | sort"])
endfunction

function! db#adapter#adbsqlite#massage(input) abort
  return a:input . "\n;"
endfunction
