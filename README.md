# R Scripts & Statistical Visualizations

R を用いた統計モデリング、確率分布のシミュレーション・可視化、および市場データ分析のスクリプト集です。

---

## 🌐 オンラインドキュメント (GitHub Pages)

Quarto で作成したインタラクティブな解説ドキュメントを GitHub Pages で公開しています：

- 📖 **[「確率」と「尤度」の決定的な違い ガイド](./probability_vs_likelihood_guide.html)**
  - *gganimate による左右対比アニメーション、数学的定義、最尤法（MLE）、ベイズ統計との関係*
- 📖 **[「身長がピッタリ170cmである確率」はなぜ 0 なのか？ ガイド](./continuous_probability_zero_guide.html)**
  - *連続変数の確率ゼロパラドックス、確率密度と極限、区間幅 Δx→0 の gganimate アニメーション、測度論*
- 📖 **[ポアソン分布と到着間隔（指数分布）の基礎と実践 ガイド](https://chess-r-quarto.github.io/R-scripts/)**
  - *Solarized Light + Royal Blue カスタムテーマ適用*
  - 直感的解説、Python/R コード、理論計算、シミュレーション可視化

---

## 📁 リポジトリ構成

| ファイル / ディレクトリ | 概要 |
| :--- | :--- |
| [**`continuous_probability_zero_guide.qmd`**](./continuous_probability_zero_guide.qmd) | 連続変数の確率ゼロ（P(X=170)=0）を解説する Quarto ソースファイル |
| [**`continuous_probability_zero_guide.html`**](./continuous_probability_zero_guide.html) | 上記 qmd からレンダリングされたスタンドアロン HTML レポート |
| [**`continuous_probability_zero_anim.R`**](./continuous_probability_zero_anim.R) | 区間幅 Δx→0 で面積がゼロになる過程を可視化する gganimate スクリプト |
| [**`continuous_probability_zero.gif`**](./continuous_probability_zero.gif) | 連続型変数の確率ゼロ可視化アニメーション GIF |
| [**`probability_vs_likelihood_guide.qmd`**](./probability_vs_likelihood_guide.qmd) | 確率と尤度の違いを解説する Quarto ソースファイル |
| [**`probability_vs_likelihood_guide.html`**](./probability_vs_likelihood_guide.html) | 上記 qmd からレンダリングされたスタンドアロン HTML レポート |
| [**`probability_vs_likelihood_anim.R`**](./probability_vs_likelihood_anim.R) | コイン投げ二項分布モデルで確率と尤度の対応を可視化する gganimate スクリプト |
| [**`probability_vs_likelihood.gif`**](./probability_vs_likelihood.gif) | 離散型（二項分布）の確率 vs 尤度 動的アニメーション GIF |
| [**`probability_vs_likelihood_continuous_anim.R`**](./probability_vs_likelihood_continuous_anim.R) | 正規分布モデルで確率密度と尤度の対応を可視化する gganimate スクリプト |
| [**`probability_vs_likelihood_continuous.gif`**](./probability_vs_likelihood_continuous.gif) | 連続型（正規分布）の確率密度 vs 尤度 動的アニメーション GIF |
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
