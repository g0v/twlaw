Organize Taiwan laws
====================

This repo aims to make Taiwan laws easy to process by computer geeks.  The output includes:

1. Law article in JSON
2. Law change history in JSON
3. Script to create Git repo of laws
4. Progress of law motion in JSON

# Law to JSON (and git repo)

## Extract law content and change history (修正沿革/立法紀錄.html -> JSON)

For single law

    % npm run prepublish && ./node_modules/.bin/lsc law2json.ls --outdir output/law/json data/law/憲法/中華民國憲法

..or all

    % npm run prepublish && find data/law -type d -depth 2 -exec ./node_modules/.bin/lsc law2json.ls --outdir output/law/json {} +

## Build git commits (JSON -> Markdown -> git)
    % (cd output/law && git init)
    % for dir in `find output/law/json -type d -depth 2`; do
          ./json2git.py $dir/law_history.json output/law
      done

    % git remote add github git@github.com:victorhsieh/tw-law-corpus.git
    % git push -f github master
    % git push github refs/notes/*

## Crawl the source

The source pages are committed so that we can check for updates.  But if you
need to fetch the source yourself, here is the instruction

### 0. Update the first link in ./prepare_categories.sh manually
1. [http://lis.ly.gov.tw/lgcgi/lglaw](http://lis.ly.gov.tw/lgcgi/lglaw) -> 分類瀏覽 -> 任意一筆
2. set $PORTAL env variable to the url

### 1. Crawls the portal to prepare category links.
    % ./prepare_categories.sh  # probably need to update the link manually
    % ./fetcher.sh data/file-link.txt

### 2. Fetch law pages

Fetch a single category

    % npm run prepublish && ./node_modules/.bin/lsc prepare_law.ls --cat 憲法 --dir data/law
    % ./fetcher.sh data/law/憲法/file-link.tsv

..or fetch every categories

    % npm run prepublish
    % for cat in data/law/*; do
          ./node_modules/.bin/lsc prepare_law.ls --cat `basename $cat` --dir data/law
          ./fetcher.sh $cat/file-link.tsv
      done

### 3. Fetch law pages (all revision)

Generate file-link-all-revision.tsv for single category

    % npm run prepublish && ./node_modules/.bin/lsc prepare_law_all_revision.ls --cat 憲法 --dir data/law
    % ./fetcher.sh -r data/law/憲法/file-link-all-revision.tsv

..or for all categories

    % npm run prepublish
    % for cat in data/law/*; do
          ./node_modules/.bin/lsc prepare_law_all_revision.ls --cat `basename $cat` --dir data/law
          ./fetcher.sh -r $cat/file-link-all-revision.tsv
      done

# Progress of law proposals

## Crawling

Currently it's done manually.

0. Open http://lis.ly.gov.tw/lgcgi/ttsweb?@0:0:1:lgmempropg08@@0
1. 選第一個會期、到最後一個, then search
2. click 詳目顯示、依提案日期「遞增」
3. open javascript console
    1. localStorage['page'] = 1
    2. document.querySelector('select[name="_TTS.DISPLAYPAGE"]').options[0].value = 200; document.querySelector('input[name="_TTS.PGTOP"]').value = 200*(localStorage['page']-1)+1; localStorage['page']++; document.querySelector('input[name="_IMG_顯示結果"]').click();
    3. document.querySelector('input[name="_IMG_本頁全部"]').click();
    4. repeat 2 until you got every pages.
    5. rename downloads to data/progress/8/ad-8-$N.txt

## Parsing (to JSON)

    % ./node_modules/.bin/lsc parse_progress.ls --ad 8 > progress.json

    # one record per line for mongodbimport
    % ./node_modules/.bin/lsc parse_progress.ls --ad 8 --newline > progress.json

# Gulp Workflow

### 0. Update the first link in ./prepare_categories.sh manually
0.  `% npm install`
1. [http://lis.ly.gov.tw/lgcgi/lglaw](http://lis.ly.gov.tw/lgcgi/lglaw) -> 分類瀏覽 -> 任意一筆
2. set $PORTAL env variable to the url

### 1. Prepare categories
you can use $PORTAL or default value in `tasks/prepare_categories.ls` L12.

    % gulp
default is `gulp prepare_categories`

### 2. Fetch law pages
Fetch single categories

    % gulp fetch:single --cat 主計-會計

Fetcg all categories

    % gulp fetch:all

### 3. Fetch law pages (all revision)
Fetch single categories

    % gulp fetch:single_revision --cat 主計-會計

Fetcg all categories

    % gulp fetch:all_revision

### 4. Convert law to json
Convert single law

    % gulp json:single --name 會計師法

COnvert all laws

    % gulp json:all