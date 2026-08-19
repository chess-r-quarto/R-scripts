# ==============================================================================
# 連続確率分布（正規分布）における確率密度と尤度の対比アニメーション
#
# 観測データ: x = 12.0 (固定, 標準偏差 σ = 2.0 既知)
# 平均パラメータ μ を 6.0 から 18.0 までスイープ
# 左: 確率密度関数 f(X | μ) --- 曲線全体の面積は常に 1
# 右: 尤度関数 L(μ | X = 12.0) --- 観測値 x=12.0 における高さの軌跡
# ==============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(patchwork)
  library(gifski)
})

cat("🎬 正規分布（連続型）版 Probability vs Likelihood アニメーションの生成を開始...\n")

font_family <- "Hiragino Sans"
x_obs <- 12.0
sigma_known <- 2.0
mu_seq <- seq(6.0, 18.0, by = 0.25) # 49 frames

x_grid <- seq(0, 24, length.out = 300)

# 背景用の完全な尤度曲線
df_lik_bg <- data.frame(
  mu = seq(6, 18, length.out = 200)
) %>%
  mutate(
    lik = dnorm(x_obs, mean = mu, sd = sigma_known)
  )

max_dens_y <- 0.24
max_lik_y  <- 0.24

output_gif <- "probability_vs_likelihood_continuous.gif"
temp_dir <- file.path(tempdir(), "prob_lik_cont_frames")
if (!dir.exists(temp_dir)) dir.create(temp_dir, recursive = TRUE)

frame_files <- character(length(mu_seq))

cat(sprintf("⏳ 全 %d フレームを生成中...\n", length(mu_seq)))

for (i in seq_along(mu_seq)) {
  cur_mu <- mu_seq[i]
  cur_dens_at_obs <- dnorm(x_obs, mean = cur_mu, sd = sigma_known)
  
  # 現在の確率密度曲線
  df_norm_now <- data.frame(
    x = x_grid,
    density = dnorm(x_grid, mean = cur_mu, sd = sigma_known)
  )
  
  # 過去〜現在の尤度軌跡
  df_trail_now <- data.frame(
    mu = mu_seq[1:i],
    lik = dnorm(x_obs, mean = mu_seq[1:i], sd = sigma_known)
  )
  
  # --- 左グラフ: 確率密度関数 f(X | μ) ---
  p_left <- ggplot(df_norm_now, aes(x = x, y = density)) +
    geom_area(fill = "#3498db", alpha = 0.25) +
    geom_line(color = "#2980b9", linewidth = 1.2) +
    # 観測データ x_obs の位置に垂線
    geom_segment(
      aes(x = x_obs, xend = x_obs, y = 0, yend = cur_dens_at_obs),
      color = "#e74c3c", linewidth = 1.4, linetype = "solid"
    ) +
    geom_point(aes(x = x_obs, y = cur_dens_at_obs), color = "#c0392b", size = 4) +
    # 平均値 μ の位置マーカー
    geom_vline(xintercept = cur_mu, color = "#2c3e50", linetype = "dashed", linewidth = 0.8) +
    annotate(
      "text", x = cur_mu, y = max_dens_y * 0.95,
      label = sprintf("平均 μ = %.2f", cur_mu),
      color = "#2c3e50", fontface = "bold", size = 3.8, family = font_family
    ) +
    # 観測値 x=12 のラベル
    annotate(
      "label", x = x_obs, y = cur_dens_at_obs,
      label = sprintf("観測値 x = %.1f\n密度 = %.3f\n(= 尤度)", x_obs, cur_dens_at_obs),
      vjust = -0.3, fill = "white", color = "#c0392b", fontface = "bold", size = 3.6, family = font_family,
      label.padding = unit(0.2, "lines")
    ) +
    scale_x_continuous(breaks = seq(0, 24, by = 4), limits = c(0, 24)) +
    scale_y_continuous(limits = c(0, max_dens_y), expand = expansion(mult = c(0, 0.05))) +
    labs(
      title = sprintf("① 確率密度（Probability Density）: f(x | μ = %.2f, σ = 2)", cur_mu),
      subtitle = "【パラメータ μ を固定】し、データ x の分布を見る（曲線下の全面積 = 1.0）",
      x = "データ測定値 x",
      y = "確率密度 f(x | μ, σ)"
    ) +
    theme_minimal(base_family = font_family, base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 14, color = "#2c3e50"),
      plot.subtitle = element_text(size = 10.5, color = "#555555", margin = margin(b = 8)),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#ecf0f1")
    )
  
  # --- 右グラフ: 尤度関数 L(μ | X = 12.0) ---
  p_right <- ggplot() +
    geom_line(data = df_lik_bg, aes(x = mu, y = lik), color = "#bdc3c7", linewidth = 0.9, linetype = "dashed") +
    { if (nrow(df_trail_now) > 1) geom_line(data = df_trail_now, aes(x = mu, y = lik), color = "#e74c3c", linewidth = 1.6) } +
    geom_point(aes(x = cur_mu, y = cur_dens_at_obs), color = "#c0392b", size = 4.5) +
    # 最尤推定量 (μ = 12.0) のガイド
    geom_vline(xintercept = x_obs, color = "#27ae60", linetype = "dotted", linewidth = 0.9) +
    annotate(
      "text", x = x_obs + 0.3, y = max_lik_y * 0.95,
      label = "最尤推定量 MLE (μ̂ = 12.0)",
      color = "#27ae60", hjust = 0, fontface = "bold", size = 3.6, family = font_family
    ) +
    annotate(
      "label", x = cur_mu, y = cur_dens_at_obs,
      label = sprintf("μ = %.2f\nL = %.3f", cur_mu, cur_dens_at_obs),
      vjust = if(cur_mu > 9.5 && cur_mu < 14.5) -0.5 else 1.3,
      hjust = if(cur_mu > 15) 1.1 else if(cur_mu < 9) -0.1 else 0.5,
      fill = "white", color = "#c0392b", fontface = "bold", size = 3.8, family = font_family,
      label.padding = unit(0.2, "lines")
    ) +
    scale_x_continuous(breaks = seq(6, 18, by = 2), limits = c(6, 18)) +
    scale_y_continuous(limits = c(0, max_lik_y), expand = expansion(mult = c(0, 0.05))) +
    labs(
      title = sprintf("② 尤度関数（Likelihood）: L(μ | x = %.1f, σ = 2)", x_obs),
      subtitle = "【観測データ x = 12.0 を固定】し、平均パラメータ μ の尤もらしさを測る",
      x = "平均パラメータ μ",
      y = "尤度 L(μ | x = 12.0) = f(12.0 | μ, σ)"
    ) +
    theme_minimal(base_family = font_family, base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 14, color = "#2c3e50"),
      plot.subtitle = element_text(size = 10.5, color = "#555555", margin = margin(b = 8)),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#ecf0f1")
    )
  
  # --- 統合 ---
  p_combined <- (p_left | p_right) +
    plot_annotation(
      title = "【連続分布版】確率密度（Probability Density）vs 尤度（Likelihood）",
      subtitle = "左側の「観測点 x=12.0 における確率密度の高さ」が、右側の「尤度曲線」を描いていくメカニズム",
      caption = "データ x = 12.0 が1つ得られたとき (σ=2.0 既知) | パラメータ μ をスキャン中",
      theme = theme(
        plot.title = element_text(face = "bold", size = 18, color = "#2c3e50", family = font_family),
        plot.subtitle = element_text(size = 12.5, color = "#7f8c8d", family = font_family, margin = margin(b = 5)),
        plot.caption = element_text(size = 10.5, color = "#34495e", family = font_family, hjust = 0.5, margin = margin(t = 8))
      )
    )
  
  frame_path <- file.path(temp_dir, sprintf("frame_%03d.png", i))
  ggsave(frame_path, plot = p_combined, width = 11, height = 5.8, dpi = 130)
  frame_files[i] <- frame_path
}

cat("🎞️ GIF アニメーションをレンダリング中...\n")
extended_frames <- c(frame_files, rep(frame_files[length(frame_files)], 12))

gifski(
  png_files = extended_frames,
  gif_file = output_gif,
  width = 1430,
  height = 754,
  delay = 1 / 10
)

cat(sprintf("🎉 連続型アニメーション GIF を保存しました: %s\n", output_gif))
unlink(temp_dir, recursive = TRUE)
