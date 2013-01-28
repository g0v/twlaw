twlaw
=====

Organize Taiwan laws

## HTML -> JSON

For single law

    % npm run prepublish && ./node_modules/.bin/lsc law2json.ls --outdir output/json/law data/law/憲法/中華民國憲法

..or all

    % npm run prepublish && find data/law -type d -depth 2 -exec ./node_modules/.bin/lsc law2json.ls --outdir output/json/law {} +

## JSON -> Markdown -> git
    % (mkdir output/law && cd output/law && git init)
    % for dir in `find output/json/law -type d -depth 2`; do
          ./json2git.py $dir/law_history.json output/law
      done

## Crawl the source

The source pages are committed so that we can check for updates.  But if you
need to fetch the source yourself, here is the instruction

### 0. Update the first link in ./prepare_categories.sh manually
1. http://lis.ly.gov.tw/lgcgi/lglaw -> 分類瀏覽 -> 任意一筆
2. Copy the link in address bar to $PARTAL in prepare_categories.sh

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

