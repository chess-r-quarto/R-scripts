# R Scripts & Statistical Visualizations

R を用いた統計モデリング、確率分布のシミュレーション・可視化、および市場データ分析のスクリプト集です。

---

## 🌐 オンラインドキュメント (GitHub Pages)

Quarto で作成したインタラクティブな解説ドキュメントを GitHub Pages で公開しています：

- 📖 **[ポアソン分布と到着間隔（指数分布）の基礎と実践 ガイド](https://chess-r-quarto.github.io/R-scripts/)**
  - *Solarized Light + Royal Blue カスタムテーマ適用*
  - 直感的解説、Python/R コード、理論計算、シミュレーション可視化

---

## 📁 リポジトリ構成

| ファイル / ディレクトリ | 概要 |
| :--- | :--- |
| [**`poisson_guide.qmd`**](./poisson_guide.qmd) | ポアソン分布と指数分布を解説する Quarto ソースファイル |
| [**`poisson_guide.html`**](https://chess-r-quarto.github.io/R-scripts/poisson_guide.html) | 上記 qmd からレンダリングされたスタンドアロン HTML レポート |
| [**`poisson_animation.R`**](./poisson_animation.R) | 時間経過に伴うイベント発生（ポアソン過程）の動的アニメーション生成スクリプト |
| [**`poisson_animation.gif`**](./poisson_animation.gif) / [**`.mp4`**](./poisson_animation.mp4) | ポアソン過程の可視化アニメーション動画・GIF |
| [**`poisson_distribution.R`**](./poisson_distribution.R) | ポアソン確率質量関数・累積分布関数のプロットおよび比較シミュレーション |
| [**`sp500_gold.R`**](./sp500_gold.R) | S&P 500、Gold、暗号資産ETF等の金融時系列データ取得・可視化スクリプト |
| [**`CSS_RoyalBlue_Solarized.css`**](./CSS_RoyalBlue_Solarized.css) | Solarized Light 背景（`#fdf6e3`）× Royal Blue 文字（`#002366`）のカスタム CSS |
| [**`.github/workflows/deploy-pages.yml`**](./.github/workflows/deploy-pages.yml) | GitHub Pages への自動ビルド・デプロイを行う GitHub Actions ワークフロー |

---

## 🛠️ 使い方

### 1. 必要なパッケージのインストール (R)

```r
install.packages(c("tidyverse", "tidyquant", "gganimate", "gifski", "av", "reticulate"))
```

### 2. Quarto レポートのレンダリング

```bash
# HTMLのビルド
quarto render poisson_guide.qmd
```

### 3. アニメーションの生成

```bash
Rscript poisson_animation.R
```

---

## 🎨 デザインテーマ

本リポジトリのドキュメントには、長時間の閲覧でも疲れにくく気品のある配色テーマ [`CSS_RoyalBlue_Solarized.css`](./CSS_RoyalBlue_Solarized.css) を採用しています。

- **Background**: `#fdf6e3` (Solarized Light)
- **Text & Headings**: `#002366` (Royal Blue)
