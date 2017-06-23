"//////////////////////////////////////////////////////////
"
" ミニマルなプログラミング開発環境(Vim 8.0)
"
" # 出来ること
"
" * 簡単なコード補完
" * スニペットの展開(<Tab> キー)
" * ソースコードの実行(:QuickRun)
" * アウトライン表示(:Unite outline)
" * ファイラ表示(:VimFiler)
" * 静的コードチェック(:WatchdogsRun or ファイル保存時 or 一定時間触ってない時)
"
"
" # その他
"
" * vimrc の編集(:EditVimrc)
" * vimrc 保存時に自動的に反映
"
"//////////////////////////////////////////////////////////

" スクリプトの文字コードを指定する
scriptencoding utf-8

" 各種設定
" スタート時のみ設定する
if has('vim_starting')
	" vi 互換を無効にして vim の便利な機能を有効にする
	set nocompatible

	" こっちだと vi 互換になる
	" set compatible
endif


if !executable("git")
	echo "Please install git."
	finish
endif

" reset augroup
augroup my_vimrc
	autocmd!
augroup END
command! -bang -nargs=*
\   MyAutoCmd
\   autocmd<bang> my_vimrc <args>

"//////////////////////////////////////////////////////////
"
" 各種環境変数の設定
"
"//////////////////////////////////////////////////////////

" プラグインの保存ディレクトリ
let s:vimplugin_dir = expand(exists("$VIMPLUGIN_DIR") ? $VIMPLUGIN_DIR : '~/.vim/bundle')
let s:vimrc = expand("<sfile>:p")


"//////////////////////////////////////////////////////////
"
" dein.vim のインストール
"
"//////////////////////////////////////////////////////////

let s:dein_dir = s:vimplugin_dir . "/dein.vim"
if !isdirectory(s:dein_dir)
	echo "Please install dein.vim."
	function! s:install_dein()
		if input("Install dein.vim? [y/n] : ") =="y"
			if !isdirectory(s:vimplugin_dir)
				call mkdir(s:vimplugin_dir, "p")
			endif

			let cmd = "!git clone git://github.com/Shougo/dein.vim "
			\ . s:dein_dir
			echom cmd
			call execute(cmd)
			echom "dein.vim installed. Please restart vim."
		else
			echom "Canceled."
		endif
	endfunction
	augroup install-dein
		autocmd!
		autocmd VimEnter * call s:install_dein()
	augroup END
	finish
endif


"//////////////////////////////////////////////////////////
"
" プラグインのインストール・設定
"
"//////////////////////////////////////////////////////////

execute "set runtimepath+=" .s:dein_dir

if dein#load_state(s:vimplugin_dir)
	call dein#begin(s:vimplugin_dir)

	call dein#add('Shougo/dein.vim')
	call dein#add('Shougo/unite.vim')
	call dein#add('Shougo/unite-outline')
	call dein#add('Shougo/neocomplete.vim')
	call dein#add('Shougo/neomru.vim')
	call dein#add('Shougo/vimfiler.vim')
	call dein#add('Shougo/neosnippet')
	call dein#add('Shougo/neosnippet-snippets')
	call dein#add('thinca/vim-quickrun')
	call dein#add('osyo-manga/vim-watchdogs')
	call dein#add('osyo-manga/shabadou.vim')
	call dein#add('cohama/vim-hier')
	call dein#add('dannyob/quickfixstatus')

	call dein#end()
	call dein#save_state()

	if has('vim_starting') && dein#check_install()
		call dein#install()
	endif
endif

filetype plugin indent on
syntax enable


" neocomplete を有効にする
let g:neocomplete#enable_at_startup = 1

" スニペットを展開するキーマッピング
" <Tab> で選択されているスニペットの展開を行う
" 選択されている候補がスニペットであれば展開し、
" それ以外であれば次の候補を選択する
" また、既にスニペットが展開されている場合は次のマークへと移動する
imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)"
\: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)"
\: "\<TAB>"

" quickrun を使いやすくカスタマイズ
" job で非同期に実行
" 実行に成功すればバッファに出力
" 実行に失敗したらエラーリストに出力
" 実行結果を下部にウィンドウ分割して出力
" エラー箇所のハイライトを有効
" エラー箇所（行）にカーソルを移動させるとその行のエラー内容を出力
" 一時バッファの場合、正しくバッファ番号を指定するための設定
let g:quickrun_config = {
\	"_" : {
\		"runner" : "job",
\		"outputter" : "error",
\		"outputter/error/success" : "buffer",
\		"outputter/error/error"   : "quickfix",
\		"outputter/quickfix/open_cmd" : "copen",
\		"outputter/buffer/split" : ":botright 8sp",
\		"hook/hier_update/enable_exit" : 1,
\		"hook/quickfix_status_enable/enable_exit" : 1,
\		"hook/quickfix_replace_tempname_to_bufnr/enable" : 1,
\		"hook/quickfix_replace_tempname_to_bufnr/enable_exit" : 1,
\		"hook/quickfix_replace_tempname_to_bufnr/priority_exit" : -10,
\	},
\	"watchdogs_checker/_" : {
\		"runner" : "job"
\	}
\}


" エラー箇所のハイライトを波線にする
function! s:enable_hier_highlight()
" 	highlight hier_warning gui=undercurl guisp=Blue
" 	let g:hier_highlight_group_qfw = "hier_warning"
endfunction
MyAutoCmd VimEnter * call s:enable_hier_highlight()


" ファイル保存時にコードチェックする
let g:watchdogs_check_BufWritePost_enable = 1

" 一定時間入力がなかった場合にコードチェックする
let g:watchdogs_check_CursorHold_enable = 1
" チェックするタイミング(ms)
set updatetime=1000


"//////////////////////////////////////////////////////////
"
" Vim 本体設定
"
"//////////////////////////////////////////////////////////

" 検索時に大文字小文字を無視 (noignorecase:無視しない)
set ignorecase
" 大文字小文字の両方が含まれている場合は大文字小文字を区別
set smartcase
" 自動的にインデントする (noautoindent:インデントしない)
set autoindent
" バックスペースでインデントや改行を削除できるようにする
set backspace=indent,eol,start
" 検索時にファイルの最後まで行ったら最初に戻る (nowrapscan:戻らない)
set wrapscan
" 括弧入力時に対応する括弧を表示 (noshowmatch:表示しない)
set showmatch
" コマンドライン補完するときに強化されたものを使う(参照 :help wildmenu)
set wildmenu
" テキスト挿入中の自動折り返しを日本語に対応させる
set formatoptions+=mM
" 常にステータス行を表示 (詳細は:he laststatus)
set laststatus=2
" コマンドラインの高さ (Windows用gvim使用時はgvimrcを編集すること)
set cmdheight=2
" カーソルキーで行末／行頭の移動可能に設定。
set whichwrap=b,s,[,],<,>
nnoremap h <Left>
nnoremap l <Right>
" 括弧を入力した時にカーソルが移動しないように設定
set matchtime=0

" カーソルを表示行で移動する。物理行移動は<C-n>,<C-p>
nnoremap <silent> j gj
nnoremap <silent> k gk
vnoremap <silent> j gj
vnoremap <silent> k gk



"//////////////////////////////////////////////////////////
"
" 雑多なスクリプト
"
"//////////////////////////////////////////////////////////

" vimrc を編集するコマンド
command! EditVimrc execute ":tab drop " . expand(s:vimrc)

" vimrc を保存したら自動的に vimrc を再読込する
execute "MyAutoCmd BufWritePost " . s:vimrc . " :so %"


