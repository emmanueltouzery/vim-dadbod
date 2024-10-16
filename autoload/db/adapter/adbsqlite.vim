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
  " at first i had -column but it's buggy with multibyte: https://sqlite.org/forum/forumpost/d443792afc
  " so use column to align the columns+awk to add a separator line between
  " headers and contents.
  " About the awk gsub: https://stackoverflow.com/a/68371463/516188
  " the dos2unix is laziness. fs there is a better way...
  return ['bash', '-c', "adb " . flag . " shell \" echo '$(<" . a:in . ")' | sqlite3 -header " . db#url#file_path(a:url) . "\" | column -t '-s|' '-o │ ' | awk 'NR == 2 { s = sprintf(\"%*s\\n\", length($0), \"\"); gsub(\".\", \"═\", s); print(s); } { print }' | dos2unix"]
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
