# StatQuest Visual Companion (R & gganimate)

R言語と `gganimate` を用いた統計モデリング、確率分布のシミュレーション、および動的可視化教材のリポジトリです。
YouTube の人気統計チャンネル **「StatQuest with Josh Starmer」** の名講義を直感的に深く理解するための補足教材（インタラクティブな Quarto Web サイト）として構成されています。

---

## 🌐 オンライン教材ポータル & 各教材ダイレクトリンク (GitHub Pages)

👉 🏠 **[StatQuest Visual Companion ポータルサイト トップ](https://chess-r-quarto.github.io/R-scripts/)**

### 📚 各教材のレンダリング済み HTML ページ
- 📖 **Topic 01**: **[「確率（Probability）」vs「尤度（Likelihood）」解説ガイド](https://chess-r-quarto.github.io/R-scripts/topics/01_probability_vs_likelihood/probability_vs_likelihood_guide.html)**
  - *gganimate による左右対比アニメーション、数学的定義、最尤法（MLE）、ベイズ統計との関係*
- 📖 **Topic 02**: **[「身長がピッタリ170cmである確率」はなぜ 0 なのか？ 解説ガイド](https://chess-r-quarto.github.io/R-scripts/topics/02_continuous_probability_zero/continuous_probability_zero_guide.html)**
  - *連続変数の確率ゼロパラドックス、確率密度と極限、区間幅 Δx→0 の gganimate アニメーション、測度論*
- 📖 **Topic 03**: **[ポアソン分布と到着間隔（指数分布）の基礎と実践 ガイド](https://chess-r-quarto.github.io/R-scripts/topics/03_poisson_distribution/poisson_guide.html)**
  - *ポアソン過程、時間経過とイベント発生アニメーション、理論計算とシミュレーション*
- 📖 **Topic 04**: **[「P値（p-value）」の本質を直感的に理解する ガイド](https://chess-r-quarto.github.io/R-scripts/topics/04_p_value/p_value_guide.html)**
  - *帰無仮説、有意水準α=0.05の動的突破アニメーション、t検定、モンテカルロシミュレーション、ASA声明*

---

## 📁 リポジトリ構成

```text
R-scripts/
├── _quarto.yml                          # Quarto Website 設定（トップバー、検索、共通デザイン）
├── index.qmd                            # 🏠 教材ポータルトップページ
├── CSS_RoyalBlue_Solarized.css           # 共通 Solarized Light × Royal Blue テーマ
│
├── topics/                              # 📚 StatQuest 各トピック別フォルダ（自己完結型）
│   ├── 01_probability_vs_likelihood/    # 確率 vs 尤度
│   │   ├── probability_vs_likelihood_guide.qmd
│   │   ├── probability_vs_likelihood_anim.R
│   │   ├── probability_vs_likelihood.gif
│   │   ├── probability_vs_likelihood_continuous_anim.R
│   │   └── probability_vs_likelihood_continuous.gif
│   │
│   ├── 02_continuous_probability_zero/  # 連続変数の確率ゼロ
│   │   ├── continuous_probability_zero_guide.qmd
│   │   ├── continuous_probability_zero_anim.R
│   │   └── continuous_probability_zero.gif
│   │
│   ├── 03_poisson_distribution/         # ポアソン分布 & 指数分布
│   │   ├── poisson_guide.qmd
│   │   ├── poisson_animation.R
│   │   ├── poisson_animation.gif
│   │   ├── poisson_animation.mp4
│   │   └── poisson_distribution.R
│   │
│   └── 04_p_value/                      # P値（p-value）の本質と仮説検定
│       ├── p_value_guide.qmd
│       ├── p_value_anim.R
│       └── p_value.gif
│
├── finance/                             # 📈 金融・市場データ分析スクリプト等
│   └── sp500_gold.R
│
└── .github/workflows/deploy-pages.yml   # GitHub Pages 自動ビルド＆デプロイ設定
```

---

## 🛠️ 使い方

### 1. 必要なパッケージのインストール (R)

```r
install.packages(c("tidyverse", "gganimate", "gifski", "patchwork", "scales", "reticulate", "tidyquant"))
```

### 2. サイト全体のビルド

```bash
# Quarto Website を一括ビルド (_site ディレクトリに出力)
quarto render

# プレビューサーバーの起動 (ローカルで確認)
quarto preview
```

### 3. アニメーションの生成

各トピックのフォルダで R スクリプトを実行することで、GIF アニメーションを生成できます。

```bash
Rscript topics/01_probability_vs_likelihood/probability_vs_likelihood_anim.R
Rscript topics/02_continuous_probability_zero/continuous_probability_zero_anim.R
Rscript topics/03_poisson_distribution/poisson_animation.R
Rscript topics/04_p_value/p_value_anim.R
```

---

## 🎨 デザインテーマ

本教材サイトは、長時間の学習でも目に優しく上品な **Solarized Light (`#fdf6e3`)** 背景と **Royal Blue (`#002366`)** をベースに構築されています。
