# ==============================================================================
# gganimate による「確率（Probability）」と「尤度（Likelihood）」の対比可視化
#
# コイン投げモデル（10回投げて表が7回出た場合: n=10, k_obs=7）
# 左: 確率分布 P(X=k | p) --- パラメータ p を固定したときの各データの確率
# 右: 尤度関数 L(p | X=7) --- 観測データ X=7 を固定したときのパラメータ p の尤もらしさ
# ==============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(gganimate)
  library(dplyr)
  library(tidyr)
  library(gifski)
})

cat("🎬 Probability vs Likelihood アニメーションの生成を開始します...\n")

font_family <- "Hiragino Sans"
n_trials <- 10
k_obs <- 7
p_seq <- seq(0.02, 0.98, by = 0.02) # 49 frames

# ------------------------------------------------------------------------------
# 1. データの作成
# ------------------------------------------------------------------------------

# (A) 確率パネル用のデータ: 各フレーム(p)ごとに k = 0..10 の二項確率
df_prob <- expand.grid(k = 0:n_trials, p = p_seq) %>%
  mutate(
    panel = "【確率の視点】P(X = k | p)",
    x_val = k,
    y_val = dbinom(k, size = n_trials, prob = p),
    is_obs = (k == k_obs),
    mle_line = NA_real_
  )

# (B) 尤度パネル用のデータ: 現在のフレーム(p)における尤度点と軌跡
# 各フレーム p_current において、p_val <= p_current の軌跡を描く
df_lik_list <- lapply(p_seq, function(cur_p) {
  # 尤度曲線全体の背景用
  full_curve <- data.frame(
    p_frame = cur_p,
    p_val = seq(0, 1, length.out = 100),
    panel = "【尤度の視点】L(p | X = 7)",
    lik_bg = dbinom(k_obs, size = n_trials, prob = seq(0, 1, length.out = 100))
  )
  
  # 現在の点
  cur_point <- data.frame(
    p_frame = cur_p,
    x_val = cur_p,
    y_val = dbinom(k_obs, size = n_trials, prob = cur_p),
    panel = "【尤度の視点】L(p | X = 7)",
    is_current = TRUE
  )
  
  # 現在までの軌跡
  trail <- data.frame(
    p_frame = cur_p,
    x_val = p_seq[p_seq <= cur_p],
    y_val = dbinom(k_obs, size = n_trials, prob = p_seq[p_seq <= cur_p]),
    panel = "【尤度の視点】L(p | X = 7)",
    is_current = FALSE
  )
  
  list(cur_point = cur_point, trail = trail)
})

df_lik_points <- bind_rows(lapply(df_lik_list, `[[`, "cur_point"))
df_lik_trails <- bind_rows(lapply(df_lik_list, `[[`, "trail"))

# 全体の背景となる完全な尤度曲線
df_lik_bg <- data.frame(
  p = seq(0, 1, length.out = 200)
) %>%
  mutate(
    lik = dbinom(k_obs, size = n_trials, prob = p),
    panel = "【尤度の視点】L(p | X = 7)"
  )

# ------------------------------------------------------------------------------
# 2. カスタムレンダリング（左右並列でよりリッチなレイアウトを確実にするため
#    patchwork をフレームごとに合成して高品質なGIFを出力）
# ------------------------------------------------------------------------------

max_prob_y <- 0.42
max_lik_y  <- 0.32

output_gif <- "probability_vs_likelihood.gif"
temp_dir <- file.path(tempdir(), "prob_lik_frames")
if (!dir.exists(temp_dir)) dir.create(temp_dir, recursive = TRUE)

library(patchwork)

frame_files <- character(length(p_seq))

cat(sprintf("⏳ 全 %d フレームを生成中...\n", length(p_seq)))

for (i in seq_along(p_seq)) {
  cur_p <- p_seq[i]
  cur_lik <- dbinom(k_obs, size = n_trials, prob = cur_p)
  
  # 現在の確率分布
  df_p_now <- data.frame(
    k = 0:n_trials,
    prob = dbinom(0:n_trials, size = n_trials, prob = cur_p),
    is_obs = (0:n_trials == k_obs)
  )
  
  # 過去〜現在の尤度軌跡
  df_trail_now <- data.frame(
    p = p_seq[1:i],
    lik = dbinom(k_obs, size = n_trials, prob = p_seq[1:i])
  )
  
  # --- 左グラフ: 確率分布 P(X = k | p) ---
  p_left <- ggplot(df_p_now, aes(x = factor(k), y = prob)) +
    geom_col(aes(fill = is_obs), width = 0.75, show.legend = FALSE) +
    # 観測データ位置の数値ラベル
    geom_text(
      data = filter(df_p_now, is_obs),
      aes(label = sprintf("P(X=7) = %.3f\n(= 尤度)", prob)),
      vjust = -0.6, fontface = "bold", color = "#c0392b", size = 4.2, family = font_family
    ) +
    # 他の棒の数値ラベル
    geom_text(
      data = filter(df_p_now, !is_obs, prob > 0.03),
      aes(label = sprintf("%.2f", prob)),
      vjust = -0.4, color = "#7f8c8d", size = 3.2, family = font_family
    ) +
    scale_fill_manual(values = c("FALSE" = "#3498db", "TRUE" = "#e74c3c")) +
    scale_y_continuous(limits = c(0, max_prob_y), expand = expansion(mult = c(0, 0.05))) +
    labs(
      title = sprintf("① 確率（Probability）: P(X = k | p = %.2f)", cur_p),
      subtitle = "【パラメータ p を固定】し、データ k がどう分布するかを見る（合計 = 1.0）",
      x = "表が出た回数 k（観測データ）",
      y = "確率 P(X = k | p)"
    ) +
    theme_minimal(base_family = font_family, base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 14, color = "#2c3e50"),
      plot.subtitle = element_text(size = 10.5, color = "#555555", margin = margin(b = 8)),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(color = "#ecf0f1")
    )
  
  # --- 右グラフ: 尤度関数 L(p | X = 7) ---
  p_right <- ggplot() +
    # 尤度関数全体の背景ガイド線（薄いグレー点線）
    geom_line(data = df_lik_bg, aes(x = p, y = lik), color = "#bdc3c7", linewidth = 0.9, linetype = "dashed") +
    # これまでに描かれた尤度曲線の軌跡（赤い実線）
    { if (nrow(df_trail_now) > 1) geom_line(data = df_trail_now, aes(x = p, y = lik), color = "#e74c3c", linewidth = 1.6) } +
    # 現在のパラメータ位置（大きな赤丸）
    geom_point(aes(x = cur_p, y = cur_lik), color = "#c0392b", size = 4.5) +
    # 最尤推定量 (MLE: p=0.7) の垂直ガイド線
    geom_vline(xintercept = 0.7, color = "#27ae60", linetype = "dotted", linewidth = 0.9) +
    annotate(
      "text", x = 0.71, y = max_lik_y * 0.92,
      label = "最尤推定量 MLE (p̂ = 0.70)",
      color = "#27ae60", hjust = 0, fontface = "bold", size = 3.6, family = font_family
    ) +
    # 現在値のアノテーション
    annotate(
      "label", x = cur_p, y = cur_lik,
      label = sprintf("p = %.2f\nL = %.3f", cur_p, cur_lik),
      vjust = if(cur_p > 0.4 && cur_p < 0.8) -0.5 else 1.3,
      hjust = if(cur_p > 0.75) 1.1 else if(cur_p < 0.25) -0.1 else 0.5,
      fill = "white", color = "#c0392b", fontface = "bold", size = 3.8, family = font_family,
      label.padding = unit(0.2, "lines")
    ) +
    scale_x_continuous(breaks = seq(0, 1, by = 0.2), limits = c(0, 1)) +
    scale_y_continuous(limits = c(0, max_lik_y), expand = expansion(mult = c(0, 0.05))) +
    labs(
      title = "② 尤度（Likelihood）: L(p | X = 7)",
      subtitle = "【観測データ X = 7 を固定】し、パラメータ p の尤もらしさを測る（積分 ≠ 1）",
      x = "成功確率パラメータ p",
      y = "尤度 L(p | X = 7) = P(X = 7 | p)"
    ) +
    theme_minimal(base_family = font_family, base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 14, color = "#2c3e50"),
      plot.subtitle = element_text(size = 10.5, color = "#555555", margin = margin(b = 8)),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#ecf0f1")
    )
  
  # --- 左右を統合 ---
  p_combined <- (p_left | p_right) +
    plot_annotation(
      title = "【徹底比較】確率（Probability）vs 尤度（Likelihood）",
      subtitle = "左側の「赤い棒の高さ（P(X=7))」が、右側の「尤度曲線（L(p|X=7))」をリアルタイムに描く様子",
      caption = "コインを10回投げて表が7回出たケース (n=10, k=7) | パラメータ p をスキャン中",
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

# 3. gifski による GIF エンコード
cat("🎞️ GIF アニメーションをレンダリング中...\n")
# 最後のフレームで少し一時停止させるため、最後のフレームを数回複製
extended_frames <- c(frame_files, rep(frame_files[length(frame_files)], 12))

gifski(
  png_files = extended_frames,
  gif_file = output_gif,
  width = 1430,
  height = 754,
  delay = 1 / 10 # 10 fps
)

cat(sprintf("🎉 アニメーション GIF を保存しました: %s\n", output_gif))

# 一時ファイルの削除
unlink(temp_dir, recursive = TRUE)
