# ==============================================================================
# 連続確率変数における「1点の確率がゼロになる」メカニズムの可視化
#
# 身長モデル: X ~ Normal(mu = 170 cm, sigma = 6 cm)
# ターゲット: x = 170 cm (平均値)
# 区間幅 Δx を 30 cm から 0 cm (ピッタリ170.000...cm) へ狭めたときの
# 面積（確率）の変化を可視化
# ==============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(patchwork)
  library(gifski)
})

cat("🎬 連続変数の確率ゼロ可視化アニメーションの生成を開始...\n")

font_family <- "Hiragino Sans"
mu <- 170
sigma <- 6
f_at_mu <- dnorm(mu, mean = mu, sd = sigma) # ≈ 0.06649

# 区間半幅 h のシーケンス (スムーズに縮小、最後は 0 で停止)
# 指数的に減少させることで、微小区間の変化をじっくり見せる
h_seq <- c(
  seq(15, 5, length.out = 12),
  seq(4.8, 1.5, length.out = 12),
  seq(1.4, 0.2, length.out = 12),
  seq(0.18, 0.0, length.out = 10)
)

x_grid <- seq(145, 195, length.out = 400)
df_norm_base <- data.frame(
  x = x_grid,
  density = dnorm(x_grid, mean = mu, sd = sigma)
)

output_gif <- "continuous_probability_zero.gif"
temp_dir <- file.path(tempdir(), "prob_zero_frames")
if (!dir.exists(temp_dir)) dir.create(temp_dir, recursive = TRUE)

frame_files <- character(length(h_seq))

# 全体の履歴データ用
df_history <- data.frame(
  frame = seq_along(h_seq),
  width = 2 * h_seq,
  prob = pnorm(mu + h_seq, mean = mu, sd = sigma) - pnorm(mu - h_seq, mean = mu, sd = sigma)
)

cat(sprintf("⏳ 全 %d フレームを生成中...\n", length(h_seq)))

for (i in seq_along(h_seq)) {
  cur_h <- h_seq[i]
  cur_width <- 2 * cur_h
  cur_lower <- mu - cur_h
  cur_upper <- mu + cur_h
  cur_prob <- pnorm(cur_upper, mean = mu, sd = sigma) - pnorm(cur_lower, mean = mu, sd = sigma)
  
  # 塗りつぶし領域データ
  df_fill <- filter(df_norm_base, x >= cur_lower & x <= cur_upper)
  if (nrow(df_fill) < 2) {
    df_fill <- data.frame(x = c(cur_lower, cur_upper), density = c(f_at_mu, f_at_mu))
  }
  
  # 履歴データ（現在まで）
  df_hist_cur <- df_history[1:i, ]
  
  # --- 左グラフ: 正規分布と区間面積（確率） ---
  p_left <- ggplot(df_norm_base, aes(x = x, y = density)) +
    # 全体分布（薄いグレー）
    geom_area(fill = "#ecf0f1", color = "#bdc3c7", linewidth = 0.6) +
    # 現在の区間の塗りつぶし（青〜赤）
    geom_area(
      data = df_fill,
      aes(x = x, y = density),
      fill = if(cur_width == 0) "#e74c3c" else "#3498db",
      alpha = 0.7
    ) +
    geom_line(color = "#2c3e50", linewidth = 1.0) +
    # 区間の左右境界線
    geom_vline(xintercept = c(cur_lower, cur_upper), color = "#2980b9", linetype = "dashed", linewidth = 0.7) +
    # ターゲット x = 170 cm の垂線
    geom_segment(
      aes(x = mu, xend = mu, y = 0, yend = f_at_mu),
      color = "#e74c3c", linewidth = 1.2
    ) +
    geom_point(aes(x = mu, y = f_at_mu), color = "#c0392b", size = 3.5) +
    # 説明ラベル
    annotate(
      "label",
      x = 150, y = 0.058,
      label = sprintf(
        "【現在の区間】\n%.2f cm 〜 %.2f cm\n区間幅 Δx = %.2f cm\n\n【確率（面積）】\nP(%.2f ≤ X ≤ %.2f)\n= %.4f (%.2f%%)",
        cur_lower, cur_upper, cur_width,
        cur_lower, cur_upper, cur_prob, cur_prob * 100
      ),
      hjust = 0, fill = "white", color = "#2c3e50", fontface = "bold", size = 3.8, family = font_family,
      label.padding = unit(0.3, "lines")
    ) +
    # ピーク高さのアノテーション
    annotate(
      "text", x = 171.5, y = f_at_mu * 0.95,
      label = sprintf("確率密度の高さ\nf(170) = %.4f /cm\n(※高さは一定！)", f_at_mu),
      hjust = 0, color = "#c0392b", fontface = "bold", size = 3.3, family = font_family
    ) +
    scale_x_continuous(breaks = seq(145, 195, by = 5), limits = c(145, 195)) +
    scale_y_continuous(limits = c(0, 0.075), expand = expansion(mult = c(0, 0.05))) +
    labs(
      title = "① 身長の確率分布（正規分布）と区間の「面積」",
      subtitle = if(cur_width == 0) "【極限】幅 Δx = 0 cm (ピッタリ170.000...cm) ➔ 面積はゼロ！" else sprintf("幅 Δx = %.2f cm の青い領域の「面積」がその身長範囲に入る確率", cur_width),
      x = "身長 X (cm)",
      y = "確率密度 f(x)"
    ) +
    theme_minimal(base_family = font_family, base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 13.5, color = "#2c3e50"),
      plot.subtitle = element_text(size = 10, color = if(cur_width == 0) "#c0392b" else "#555555", face = if(cur_width == 0) "bold" else "plain", margin = margin(b = 6)),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#ecf0f1")
    )
  
  # --- 右グラフ: 区間幅 Δx vs 確率 P ---
  p_right <- ggplot() +
    # 全体の理論直線（幅と確率の関係）
    geom_line(data = df_history, aes(x = width, y = prob), color = "#bdc3c7", linewidth = 0.9, linetype = "dashed") +
    # 現在までの軌跡
    { if (nrow(df_hist_cur) > 1) geom_line(data = df_hist_cur, aes(x = width, y = prob), color = "#3498db", linewidth = 1.4) } +
    # 現在の点
    geom_point(aes(x = cur_width, y = cur_prob), color = if(cur_width == 0) "#e74c3c" else "#2980b9", size = 4) +
    # 点 (0, 0) の強調
    geom_point(aes(x = 0, y = 0), color = "#e74c3c", size = 4.5, shape = 1) +
    annotate(
      "label",
      x = if(cur_width < 10) cur_width + 1.5 else cur_width - 1.5,
      y = cur_prob,
      hjust = if(cur_width < 10) 0 else 1,
      label = sprintf("幅 Δx = %.2f cm\n確率 P = %.4f (%.1f%%)", cur_width, cur_prob, cur_prob * 100),
      fill = "white", color = if(cur_width == 0) "#c0392b" else "#2980b9", fontface = "bold", size = 3.6, family = font_family,
      label.padding = unit(0.2, "lines")
    ) +
    # (0, 0) の解説アノテーション
    annotate(
      "text", x = 0.5, y = 0.05,
      label = "幅 Δx → 0 のとき\n確率 P(X = 170) → 0",
      hjust = 0, color = "#c0392b", fontface = "bold", size = 3.6, family = font_family
    ) +
    scale_x_continuous(breaks = seq(0, 30, by = 5), limits = c(0, 30)) +
    scale_y_continuous(breaks = seq(0, 1, by = 0.2), limits = c(0, 1), labels = scales::percent) +
    labs(
      title = "② 区間幅 Δx と 確率 P の関係",
      subtitle = "確率 ＝ 確率密度 × 幅 (P ≈ f(170) × Δx) ➔ 幅が0なら確率は0",
      x = "区間幅 Δx (cm)",
      y = "区間に含まれる確率 P"
    ) +
    theme_minimal(base_family = font_family, base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 13.5, color = "#2c3e50"),
      plot.subtitle = element_text(size = 10, color = "#555555", margin = margin(b = 6)),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#ecf0f1")
    )
  
  # --- 統合 ---
  p_combined <- (p_left | p_right) +
    plot_annotation(
      title = "【なぜ連続変数の1点の確率はゼロなのか？】P(X = 170.000...cm) = 0 の直感理解",
      subtitle = "確率は「領域の面積」として定義されるため、幅がゼロ（1点）になると面積＝0 になる",
      caption = "成人男性の身長モデル N(μ=170, σ=6) | 区間幅 Δx を 30cm から 0cm へ連続縮小中",
      theme = theme(
        plot.title = element_text(face = "bold", size = 16, color = "#2c3e50", family = font_family),
        plot.subtitle = element_text(size = 11.5, color = "#7f8c8d", family = font_family, margin = margin(b = 5)),
        plot.caption = element_text(size = 10, color = "#34495e", family = font_family, hjust = 0.5, margin = margin(t = 8))
      )
    )
  
  frame_path <- file.path(temp_dir, sprintf("frame_%03d.png", i))
  ggsave(frame_path, plot = p_combined, width = 11.5, height = 6.0, dpi = 130)
  frame_files[i] <- frame_path
}

cat("🎞️ GIF アニメーションをレンダリング中...\n")
# 最後のフレーム（幅0）を長めにホールド
extended_frames <- c(frame_files, rep(frame_files[length(frame_files)], 16))

gifski(
  png_files = extended_frames,
  gif_file = output_gif,
  width = 1495,
  height = 780,
  delay = 1 / 8
)

cat(sprintf("🎉 確率ゼロ可視化アニメーション GIF を保存しました: %s\n", output_gif))
unlink(temp_dir, recursive = TRUE)
