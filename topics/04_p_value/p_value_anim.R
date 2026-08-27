# ==============================================================================
# gganimate による「P値（p-value）」の動的可視化スクリプト
#
# 観測された統計量 z が 0.0 から 3.0 まで変化するとき：
# 左: 帰無仮説の確率分布における両側の裾野面積（P値）の変化
# 右: 統計量 z に対する P値 の急減曲線と 有意水準 alpha = 0.05 の突破
# ==============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(gganimate)
  library(dplyr)
  library(tidyr)
  library(gifski)
  library(patchwork)
})

cat("🎬 P-value アニメーションの生成を開始します...\n")

font_family <- "Hiragino Sans"
out_dir <- "topics/04_p_value"
out_gif <- file.path(out_dir, "p_value.gif")

# 1. パラメータ設定
z_frames <- seq(0.2, 2.8, by = 0.05) # 約 53 フレーム
n_frames <- length(z_frames)

x_grid <- seq(-3.5, 3.5, length.out = 300)
norm_density <- dnorm(x_grid)

# 2. 各フレームのデータを生成
# (A) 左パネル用: 帰無仮説分布と両側の裾野
df_left_list <- lapply(seq_along(z_frames), function(i) {
  z_cur <- z_frames[i]
  p_val <- 2 * (1 - pnorm(z_cur))
  
  data.frame(
    frame = i,
    z_cur = z_cur,
    x = x_grid,
    density = norm_density,
    is_extreme = abs(x_grid) >= z_cur,
    p_val = p_val
  )
})
df_left <- bind_rows(df_left_list)

# (B) 右パネル用: 曲線と現在点
# 曲線背景データ
z_curve <- seq(0.0, 3.2, length.out = 150)
df_curve <- data.frame(
  z = z_curve,
  p_val = 2 * (1 - pnorm(z_curve))
)

df_right_list <- lapply(seq_along(z_frames), function(i) {
  z_cur <- z_frames[i]
  p_val <- 2 * (1 - pnorm(z_cur))
  
  # 現在の点
  data.frame(
    frame = i,
    z_cur = z_cur,
    p_val = p_val,
    is_sig = (p_val < 0.05)
  )
})
df_right <- bind_rows(df_right_list)

# 3. 各フレームのプロットを生成して gifski で結合（レイアウトと文字を完全制御）
tmp_dir <- file.path(out_dir, "frames_tmp")
dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

theme_anim <- function() {
  theme_minimal(base_family = font_family) +
    theme(
      plot.background = element_rect(fill = "#fdf6e3", color = NA),
      panel.background = element_rect(fill = "#ffffff", color = "#e2d9c2"),
      panel.grid.major = element_line(color = "#f0ebd8"),
      panel.grid.minor = element_blank(),
      plot.title = element_text(color = "#002366", face = "bold", size = 13, hjust = 0),
      plot.subtitle = element_text(color = "#2c3e50", size = 10, hjust = 0),
      axis.title = element_text(color = "#002366", face = "bold", size = 10),
      axis.text = element_text(color = "#2c3e50", size = 9)
    )
}

cat("Rendering frames...\n")

for (i in seq_along(z_frames)) {
  cur_left <- df_left %>% filter(frame == i)
  cur_right <- df_right %>% filter(frame == i)
  
  z_val <- cur_right$z_cur
  p_val <- cur_right$p_val
  is_sig <- cur_right$is_sig
  
  status_text <- if (is_sig) "統計的有意 (p < 0.05) Bam!" else "有意差なし (p >= 0.05)"
  status_color <- if (is_sig) "#e74c3c" else "#3498db"
  
  # 左プロット: 帰無仮説の分布と極端領域
  p_left <- ggplot(cur_left, aes(x = x, y = density)) +
    geom_area(aes(fill = is_extreme), alpha = 0.75) +
    geom_line(color = "#002366", linewidth = 1) +
    geom_vline(xintercept = c(-z_val, z_val), color = "#e74c3c", linetype = "dashed", linewidth = 0.8) +
    scale_fill_manual(
      values = c("FALSE" = "#d0e1fd", "TRUE" = "#e74c3c"),
      guide = "none"
    ) +
    scale_x_continuous(breaks = seq(-3, 3, 1)) +
    coord_cartesian(ylim = c(0, 0.45), xlim = c(-3.5, 3.5)) +
    theme_anim() +
    labs(
      title = "【帰無仮説の分布】偶然データが出る確率",
      subtitle = sprintf("観測統計量 z = ±%.2f | 赤色面積 (P値) = %.4f", z_val, p_val),
      x = "検定統計量 (z 値)",
      y = "確率密度"
    ) +
    annotate(
      "label", x = 0, y = 0.40,
      label = sprintf("P値 = %.4f (%s)", p_val, status_text),
      color = status_color, fill = "#ffffff", fontface = "bold", size = 3.5, family = font_family
    )
  
  # 右プロット: P値の減少曲線
  p_right <- ggplot() +
    geom_line(data = df_curve, aes(x = z, y = p_val), color = "#002366", linewidth = 1) +
    geom_hline(yintercept = 0.05, linetype = "dashed", color = "#e74c3c", linewidth = 0.8) +
    annotate("text", x = 2.7, y = 0.09, label = "有意水準 α = 0.05", color = "#e74c3c", fontface = "bold", size = 3, family = font_family) +
    geom_point(data = cur_right, aes(x = z_cur, y = p_val), color = status_color, size = 4) +
    geom_segment(
      data = cur_right,
      aes(x = z_cur, xend = z_cur, y = 0, yend = p_val),
      linetype = "dotted", color = status_color, linewidth = 0.7
    ) +
    scale_x_continuous(limits = c(0, 3.2), breaks = seq(0, 3, 0.5)) +
    scale_y_continuous(limits = c(0, 1.05), breaks = seq(0, 1, 0.2)) +
    theme_anim() +
    labs(
      title = "【P値の推移】統計量が離れるほど急減",
      subtitle = sprintf("z = %.2f で P値は %.1f%% に低下", z_val, p_val * 100),
      x = "観測された統計量 |z|",
      y = "P値 (両側確率)"
    )
  
  # 2つのプロットを統合
  p_combined <- (p_left | p_right) +
    plot_annotation(
      title = "StatQuest Visual Companion: P値（p-value）の直感的メカニズム",
      theme = theme(
        plot.background = element_rect(fill = "#fdf6e3", color = NA),
        plot.title = element_text(color = "#002366", face = "bold", size = 15, family = font_family, hjust = 0.5, margin = margin(t = 8, b = 4))
      )
    )
  
  frame_file <- file.path(tmp_dir, sprintf("frame_%03d.png", i))
  ggsave(frame_file, plot = p_combined, width = 10, height = 4.5, dpi = 110, device = "png")
}

cat("Compiling GIF with gifski...\n")
frame_files <- list.files(tmp_dir, pattern = "^frame_.*\\.png$", full.names = TRUE)
frame_files <- sort(frame_files)

# 前後を少しポーズさせるため、先頭と末尾のフレームを数枚複製
all_frames <- c(
  rep(frame_files[1], 10),
  frame_files,
  rep(frame_files[length(frame_files)], 18)
)

gifski(
  png_files = all_frames,
  gif_file = out_gif,
  width = 1100,
  height = 495,
  delay = 0.08, # 秒/フレーム
  loop = TRUE
)

# 一時ファイルの削除
unlink(tmp_dir, recursive = TRUE)

cat("🎉 アニメーション生成完了:", out_gif, "\n")
