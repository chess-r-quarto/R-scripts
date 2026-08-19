---
name: statquest-companion
description: >-
  StatQuest 補助教材（Visual Companion）の新しい講義トピック（R & gganimate アニメーション + Quarto ドキュメント）を作成・追加・デプロイするための標準ワークフロー。
---

# StatQuest Visual Companion 作成ワークフロー

このスキルは、StatQuest の講義内容に基づいた新しい動的可視化教材を作成し、教材ポータルサイトへ統合・デプロイする際の手順書です。

---

## 🛠️ 教材追加の 6 ステップ

### ステップ 1: トピックディレクトリの作成
トピック番号とトピック名でディレクトリを作成します。

```bash
mkdir -p topics/04_topic_name
```

### ステップ 2: gganimate アニメーションスクリプトの作成 & 実行
- スクリプト名: `topics/04_topic_name/topic_name_anim.R`
- 要件:
  - `ggplot2`, `gganimate` (または `patchwork` + `gifski`) を使用
  - 日本語フォント `family = "Hiragino Sans"`
  - テーマカラー（Solarized `#fdf6e3` や `#002366`, `#3498db`, `#e74c3c` 等）に調和
  - 出力 GIF: `topics/04_topic_name/topic_name.gif`
- 実行:
  ```bash
  Rscript topics/04_topic_name/topic_name_anim.R
  ```

### ステップ 3: Quarto ドキュメントの作成
- ファイル名: `topics/04_topic_name/topic_name_guide.qmd`
- ドキュメント構成の標準:
  1. **はじめに**: 直感的な問い・日常の例え
  2. **決定的なポイントの比較表**: 一目でわかる対比
  3. **動的ビジュアライゼーション**: 作成した GIF の埋め込みとステップバイステップ解説
  4. **数式と理論計算**: R コードブロック付きの実践
  5. **応用・実務での活用**: 機械学習や統計モデルでの位置づけ
  6. **理解度チェッククイズ**: `::: {.callout-caution collapse="true"}` による 3 問
  7. **まとめ**: 箇条書き

### ステップ 4: `_quarto.yml` のナビゲーションバー更新
`_quarto.yml` の `website.navbar.left` に新しい教材へのリンクを追加します。

### ステップ 5: ポータルページ `index.qmd` と `README.md` の更新
- `index.qmd`:
  - `::: {.portal-card}` を使った教材カードを追加（GIF サムネイル、StatQuest 動画名、概要、ボタン）
  - クイックアクセスリンク表に新しい行を追加
- `README.md`:
  - カリキュラム表に新しいトピックを追加

### ステップ 6: サイト全体のビルド ＆ GitHub へのデプロイ
```bash
# 1. Quarto Website を一括ビルド
quarto render

# 2. 生成された _site を含めて Git コミット＆プッシュ
git add -A
git commit -m "Add Topic 04: [Topic Name] guide and animation"
git push origin main
```
