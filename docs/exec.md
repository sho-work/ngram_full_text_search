# 実⾏説明資料
## USAGE
1. このリポジトリを`git clone`してください。
2. このリポジトリのrootをカレントディレクトリにしてください。
3. 以下のコマンドを実行して、転置インデックスを構築します。
```bash
$ ruby lib/address_searcher.rb < [入力として与えたいCSVのファイルパス] [--build | -b]
```
4. 以下のコマンドで実行します。
```bash
$ ruby lib/address_searcher.rb [検索テキスト] [--search | -s]
```

## 実行例
### 転置インデックスの構築
```bash
$ ruby lib/address_searcher.rb < lib/address_list.csv --build
```
### 住所の検索
```bash
$ ruby lib/address_searcher.rb 東京都 --search
```
