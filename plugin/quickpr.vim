function! QuickPr(...)

" PR Id or Url can be passed in, otherwise we ask for it.

let s:pr_url = a:1

if a:0 < 1
  call inputsave()
  let s:pr_url = input('URL or id of pull request: ')
  call inputrestore()
endif

" Extract the id of the pull request
let s:pr_id_start = stridx(s:pr_url, "pull/") + strlen("pull/")
let s:pr_id = strpart(s:pr_url, s:pr_id_start)
let s:pr_id_end = stridx(s:pr_id, "/")
if s:pr_id_end > -1
    let s:pr_id = strpart(s:pr_url, 0, s:pr_id_end)
endif

" Extract the org and repo name
let s:pr_org_start = stridx(s:pr_url, ".com/") + strlen(".com/")
let s:pr_org_end = stridx(s:pr_url, "/", s:pr_org_start)
let s:pr_org = strpart(s:pr_url, s:pr_org_start, s:pr_org_end - s:pr_org_start)

let s:pr_repo_end = stridx(s:pr_url, "/", s:pr_org_end + 1)
let s:pr_repo = strpart(s:pr_url, s:pr_org_end + 1, s:pr_repo_end - s:pr_org_end)

let s:token = readfile(expand('~/.quickpr'))

if !exists('g:quickpr_github_api_base')
      let g:quickpr_github_api_base = 'https://api.github.com/'
endif

let s:url = g:quickpr_github_api_base . 'repos/' . s:pr_org . '/' . s:pr_repo . 'pulls/' . s:pr_id . '/comments'
echom s:url

let s:request = 'curl -su "' . s:token[0] . '" "' . s:url . '"'
echom s:request

let s:response = system(s:request)
let s:comments = json_decode(s:response)
let s:qflines = []
for comment in s:comments
  let s:user = comment['user']['login']
  let s:diff_hunk = comment['diff_hunk']
  let s:position  = comment['original_position']
  let s:hunk_position_start = stridx(s:diff_hunk, "+")
  let s:hunk_position_end = stridx(s:diff_hunk, ",", s:hunk_position_start) - 1
  let s:hunk_position = strpart(s:diff_hunk, s:hunk_position_start + 1, s:hunk_position_end - s:hunk_position_start)
  let s:abs_position = s:hunk_position + s:position
  let s:body = substitute(comment['body'], "\n", " ", "")
  let s:path = comment['path']
  let s:qfline = s:path . ":" . s:abs_position . ": [" . s:user . "] " . s:body
  let s:qflines = add(s:qflines, s:qfline)
endfor
let s:qfexp = join(s:qflines, "\n")
cexp(s:qfexp)
endfunction
