# StatQuest Visual Companion (R & gganimate)

R言語と `gganimate` を用いた統計モデリング、確率分布のシミュレーション、および動的可視化教材のリポジトリです。
YouTube の人気統計チャンネル **「StatQuest with Josh Starmer」** の名講義を直感的に深く理解するための補足教材（インタラクティブな Quarto Web サイト）として構成されています。

---

## 🌐 オンライン教材ポータル (GitHub Pages)

Quarto Website としてビルドされた教材ポータルを GitHub Pages で公開しています：

👉 **[StatQuest Visual Companion ポータルサイト](https://chess-r-quarto.github.io/R-scripts/)**

---

## 📚 カリキュラム & 収録トピック

| # | トピック / ディレクトリ | 概要・キーワード |
| :---: | :--- | :--- |
| **01** | [**`topics/01_probability_vs_likelihood/`**](./topics/01_probability_vs_likelihood/) | **確率（Probability）vs 尤度（Likelihood）**<br>・前提からデータを語る（確率）vs データから前提を推定する（尤度）<br>・最尤推定（MLE）、対数尤度、ベイズの定理との関係 |
| **02** | [**`topics/02_continuous_probability_zero/`**](./topics/02_continuous_probability_zero/) | **連続変数の確率ゼロ（$P(X=170)=0$）**<br>・日常の有効数字（区間）vs 数学の無限精度（点）<br>・確率密度（高さ）と確率（面積）、区間幅 $\Delta x \to 0$ の極限 |
| **03** | [**`topics/03_poisson_distribution/`**](./topics/03_poisson_distribution/) | **ポアソン分布と到着間隔（指数分布）**<br>・単位時間あたりの発生回数（ポアソン）と待ち時間（指数）の表裏一体関係<br>・ポアソン過程、期待値と分散の一致 |
| **--** | [**`finance/`**](./finance/) | **金融・市場データ分析**<br>・S&P 500、Gold、暗号資産ETF等の時系列可視化スクリプト |

---

## 📁 リポジトリ構成

```text
R-scripts/
├── _quarto.yml                          # Quarto Website 設定（トップバー、検索、共通設定）
├── index.qmd                            # 🏠 教材ポータル トップページ
├── CSS_RoyalBlue_Solarized.css           # 共通 Solarized Light × Royal Blue テーマ
│
├── topics/                              # 📚 各トピック別フォルダ
│   ├── 01_probability_vs_likelihood/    # 確率 vs 尤度
│   │   ├── probability_vs_likelihood_guide.qmd
│   │   ├── probability_vs_likelihood_anim.R
│   │   └── *.gif
│   │
│   ├── 02_continuous_probability_zero/  # 連続変数の確率ゼロ
│   │   ├── continuous_probability_zero_guide.qmd
│   │   ├── continuous_probability_zero_anim.R
│   │   └── *.gif
│   │
│   └── 03_poisson_distribution/         # ポアソン分布 & 指数分布
│       ├── poisson_guide.qmd
│       ├── poisson_animation.R
│       └── *.gif / *.mp4 / *.R
│
├── finance/                             # 金融・市場データ分析スクリプト等
│   └── sp500_gold.R
│
└── .github/workflows/deploy-pages.yml   # GitHub Pages 自動ビルド＆デプロイ
```

---

## 🛠️ 開発と使い方

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

各トピックのフォルダに移動して R スクリプトを実行することで、高解像度 GIF アニメーションを再生成できます。

```bash
Rscript topics/01_probability_vs_likelihood/probability_vs_likelihood_anim.R
Rscript topics/02_continuous_probability_zero/continuous_probability_zero_anim.R
Rscript topics/03_poisson_distribution/poisson_animation.R
```

---

## 🎨 デザインテーマ

本教材サイトは、長時間の学習でも目に優しく上品な **Solarized Light (`#fdf6e3`)** 背景と **Royal Blue (`#002366`)** をベースに構築されています。
