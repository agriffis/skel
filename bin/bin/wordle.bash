#!/bin/bash

main() {
  cd ~/Sync
  update
  if [[ $1 == used ]]; then
    search used-wordle-words.txt
  else
    search wordle-words.txt
  fi
  exit
}

update() {
  curl https://www.rockpapershotgun.com/wordle-past-answers | \
    awk -F'[<>]' '/^<li>[A-Z]{5}</{print $3}' | \
    tr '[[:upper:]]' '[[:lower:]]' | \
    sort > used-wordle-words.txt
  cat used-wordle-words.txt all-wordle-words.txt | \
    sort -R | uniq -u > wordle-words.txt
}

search() {
  local reload="reload:rg -NP {q} $1"
  fzf --disabled --bind "start:$reload" --bind "change:$reload"
}

main "$@"
