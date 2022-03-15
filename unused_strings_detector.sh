#!/bin/bash

#######
# 
# Localizable.stringsファイルから未使用の文字列を出力する
#
#######

rootFolder=.
if [[ $1 ]]; then
  rootFolder=$1
fi

allLocalisableFiles=$(find $rootFolder -type f -name "Localizable.strings");
for localisableFile in $allLocalisableFiles; do
  echo -e "\n🔎  Inspecting:" $localisableFile

  while read p; do
    IFS=" = ";
    # $p： 読み込んだ行
    string=($p);
    # ${string[0]}： L_~~~ の部分
    key=${string[0]//L_/l_}
    # double quotes(")を消す（"があると検索にヒットしない）
    keyNoQuotes=`sed -e 's/^"//' -e 's/"$//' <<<"$key"`

    # ${#string[@]}： 要素数
    # ${#string[@]} -gt 1： 要素数 > 1 か
    if [[ ${#string[@]} -gt 1 ]] && [[ $key == \"* ]]; then 
      # rootFolder以下の.swiftに一致するファイルの中から、$keyNoQuotesの文字列が一件も一致しなかったら出力する
      # grep オプション -r:サブディレクトリまで再帰的に検索  -q:ログを出力しない -i:文字大小を区別しない
      if ! grep -rqi --include='*.swift' "$keyNoQuotes" $rootFolder; then
        echo "⚠️ " $key "is not used"
      fi
    fi

    unset IFS;
  done < $localisableFile
done
