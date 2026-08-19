# ==============================================================================
# gganimate によるポアソン分布のアニメーション作成スクリプト
# λ (平均発生率) が 0.5 から 20 まで増加すると分布がどう変化するかを可視化
# ==============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(gganimate)
  library(dplyr)
  library(gifski)
})

cat("🎬 gganimate によるポアソン分布アニメーションの生成を開始します...\n")

# 1. データの作成
# λ を 0.5 から 20 まで 0.5 刻みで変化させる
lambda_vals <- seq(0.5, 20, by = 0.5)
max_k <- 35

df_anim <- expand.grid(k = 0:max_k, lambda = lambda_vals) %>%
  mutate(
    prob = dpois(k, lambda = lambda),
    # 正規分布による近似 (参考用)
    norm_prob = dnorm(k, mean = lambda, sd = sqrt(lambda))
  )

font_family <- "Hiragino Sans"

# 2. ggplot + gganimate のプロット定義
p <- ggplot(df_anim, aes(x = k, y = prob)) +
  # ポアソン分布の棒グラフ
  geom_col(fill = "#3498db", color = "#2980b9", width = 0.8, alpha = 0.7) +
  # ポアソン分布の折れ線・頂点
  geom_line(color = "#e74c3c", linewidth = 1.2) +
  geom_point(color = "#c0392b", size = 2.5) +
  # 正規分布による近似曲線（破線）
  geom_line(aes(y = norm_prob), color = "#2ecc71", linewidth = 1.0, linetype = "dashed") +
  # 軸と範囲の設定
  scale_x_continuous(breaks = seq(0, max_k, by = 5), limits = c(-0.5, max_k + 0.5)) +
  scale_y_continuous(limits = c(0, 0.65), expand = c(0, 0.01)) +
  # ラベル・タイトル（{frame_time} で現在の λ を動的表示）
  labs(
    title = "ポアソン分布の動的変化: λ = {sprintf('%.1f', frame_time)}",
    subtitle = "赤線: ポアソン分布 P(X=k) | 緑破線: 正規分布近似 N(λ, λ)",
    x = "事象の発生回数 k",
    y = "発生確率 P(X = k)",
    caption = "λ が大きくなるにつれて、左右非対称な形から正規分布（釣り鐘型）へと近づきます"
  ) +
  theme_minimal(base_family = font_family, base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 18, color = "#2c3e50"),
    plot.subtitle = element_text(size = 13, color = "#7f8c8d", margin = margin(b = 10)),
    plot.caption = element_text(size = 11, color = "#34495e", hjust = 0),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "#ecf0f1")
  ) +
  # gganimate のトランジション設定 (lambda に沿って滑らかに変化)
  transition_time(lambda) +
  ease_aes('linear')

# 3. アニメーションのレンダリングと保存
output_gif <- "poisson_animation.gif"
cat("⏳ レンダリング中 (フレーム数: 80, 15 fps)... 一時お待ちください\n")

anim <- animate(
  p,
  nframes = 80,
  fps = 15,
  width = 800,
  height = 500,
  renderer = gifski_renderer(output_gif)
)

cat(sprintf("🎉 アニメーション GIF を保存しました: %s\n", output_gif))
