# StatQuest Visual Companion (R & gganimate) Project Guidelines

このリポジトリは、YouTube の統計学習チャンネル「StatQuest with Josh Starmer」の解説を R と `gganimate` で可視化・教材化するプロジェクトです。

---

## 🎨 デザイン & スタイリング規約

1. **カラーパレット**:
   - 背景色: `#fdf6e3` (Solarized Light)
   - 文字・見出し色: `#002366` (Royal Blue)
   - カード背景: `#ffffff`
   - アクセント色: `#3498db` (青), `#e74c3c` (赤), `#2ecc71` / `#27ae60` (緑)
   - 共通 CSS: `CSS_RoyalBlue_Solarized.css`
2. **フォント**:
   - 日本語フォント: `Hiragino Sans` / `-apple-system, BlinkMacSystemFont, sans-serif`
3. **Quarto 設定**:
   - `_quarto.yml` で Web サイト全体の設定を管理。
   - 個別 QMD の YAML はシンプルに保つ（`_quarto.yml` に全体フォーマットを委ねる）。

---

## 📁 ディレクトリ構造規約

```text
topics/
  ├── 01_probability_vs_likelihood/
  ├── 02_continuous_probability_zero/
  ├── 03_poisson_distribution/
  └── 04_new_topic_name/              # 新規トピックは連番で追加
        ├── new_topic_guide.qmd       # Quarto 解説ドキュメント
        ├── new_topic_anim.R          # gganimate アニメーション生成スクリプト
        └── new_topic.gif             # 生成された GIF アニメーション
```

---

## ⚡ ビルド ＆ デプロイ ワークフロー（ローカル完結型）

**重要**: GitHub Actions 上での R/Python コンパイルは行わず、**ローカルでビルドした `_site/` を GitHub にプッシュして GitHub Pages に即座に公開する方式** を採用しています。

```bash
# 1. ローカルで Quarto Website を一括ビルド
quarto render

# 2. 変更・生成された _site を含めて Git コミット＆プッシュ
git add -A
git commit -m "Update or add topic"
git push origin main
```
