# ==============================================================================
# ポアソン分布 (Poisson Distribution) & 到着間隔 (指数分布) の R 実践スクリプト
# ==============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(dplyr)
})

cat("==============================================================\n")
cat(" 📊 Rによるポアソン分布 (Poisson Distribution) の解説・シミュレーション\n")
cat("==============================================================\n\n")

cat("【具体例: コンビニのトイレ利用客】\n")
cat("平日の特定時間帯において、1時間に平均 3 人 (lambda = 3) がトイレを利用するとします。\n\n")

# 1. 確率計算 (dpois)
lam <- 3.0
k_vals <- 0:10
probs <- dpois(k_vals, lambda = lam)

cat(sprintf("--- 1時間あたりの利用客数 k と発生確率 (lambda = %.1f) ---\n", lam))
cat(sprintf("%-10s | %-16s | %s\n", "利用人数(k)", "確率 P(X = k)", "バー表示"))
cat(paste(rep("-", 55), collapse = ""), "\n")

for (i in seq_along(k_vals)) {
  k <- k_vals[i]
  p <- probs[i]
  bar_len <- round(p * 40)
  bar_str <- paste(rep("■", bar_len), collapse = "")
  cat(sprintf("%2d 人      | %8.4f (%5.1f%%) | %s\n", k, p, p * 100, bar_str))
}
cat(paste(rep("-", 55), collapse = ""), "\n\n")

# 2. 乱数シミュレーション (rpois)
set.seed(42)
n_samples <- 10000
samples <- rpois(n_samples, lambda = lam)

sim_mean <- mean(samples)
sim_var <- var(samples)

cat(sprintf("🎲 乱数シミュレーション (10,000 時間分):\n"))
cat(sprintf("  ・標本平均 : %.4f (理論値 lambda = %.1f)\n", sim_mean, lam))
cat(sprintf("  ・標本分散 : %.4f (理論値 lambda = %.1f)\n", sim_var, lam))
cat("  ※ Rの rpois() でも「平均 ≒ 分散 ≒ lambda」が綺麗に再現されます。\n\n")

# ==============================================================================
# 3. ggplot2 による可視化 (ポアソン分布 + 指数分布)
# ==============================================================================
font_family <- "Hiragino Sans"


# [Plot 1] lambdaの違いによる分布の形の変化
df_lambda <- expand.grid(k = 0:25, lambda = c(1, 3, 7, 15)) %>%
  mutate(
    prob = dpois(k, lambda = lambda),
    lambda_label = factor(paste0("λ = ", lambda), levels = paste0("λ = ", c(1, 3, 7, 15)))
  )

p1 <- ggplot(df_lambda, aes(x = k, y = prob, color = lambda_label, fill = lambda_label)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_area(alpha = 0.15, position = "identity") +
  scale_color_brewer(palette = "Set1", name = "平均発生率") +
  scale_fill_brewer(palette = "Set1", name = "平均発生率") +
  labs(
    title = "① 平均発生率 λ による形状変化",
    subtitle = "λが大きくなるにつれて正規分布に近づく",
    x = "1時間の発生回数 k (人)",
    y = "発生確率 P(X = k)"
  ) +
  theme_minimal(base_family = font_family) +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    legend.position = "right"
  )

# [Plot 2] 理論値 vs シミュレーション (ヒストグラム)
df_sim <- data.frame(k = samples)
df_theory <- data.frame(k = 0:max(samples), prob = dpois(0:max(samples), lambda = lam))

p2 <- ggplot() +
  geom_histogram(data = df_sim, aes(x = k, y = after_stat(density)),
                 binwidth = 1, center = 0, fill = "#3498db", color = "white", alpha = 0.6) +
  geom_line(data = df_theory, aes(x = k, y = prob), color = "#e74c3c", linewidth = 1.1) +
  geom_point(data = df_theory, aes(x = k, y = prob), color = "#e74c3c", size = 2.5) +
  labs(
    title = paste0("② 理論値 vs シミュレーション (λ = ", lam, ")"),
    subtitle = "10,000回のサンプリング結果と理論式の一致",
    x = "1時間の発生回数 k (人)",
    y = "相対度数 / 確率"
  ) +
  theme_minimal(base_family = font_family) +
  theme(plot.title = element_text(face = "bold", size = 12))

# [Plot 3] 累積確率分布 (CDF: ppois)
df_cdf <- data.frame(k = 0:15, cdf = ppois(0:15, lambda = lam))

p3 <- ggplot(df_cdf, aes(x = k, y = cdf)) +
  geom_step(color = "#e67e22", linewidth = 1.2, direction = "hv") +
  geom_point(color = "#d35400", size = 2) +
  geom_hline(yintercept = 0.5, linetype = "dotted", color = "gray40") +
  geom_hline(yintercept = 0.95, linetype = "dashed", color = "red") +
  annotate("text", x = 12, y = 0.92, label = "95% 信頼ライン", color = "red", family = font_family, size = 3.5) +
  labs(
    title = paste0("③ 累積確率分布 CDF (λ = ", lam, ")"),
    subtitle = "k 人以下で収まる確率 P(X ≤ k)",
    x = "利用人数 k (人)",
    y = "累積確率 P(X ≤ k)"
  ) +
  theme_minimal(base_family = font_family) +
  theme(plot.title = element_text(face = "bold", size = 12))

# [Plot 4] 表裏一体: 到着間隔 (指数分布 dexp / rexp)
# 1時間に平均3人来る場合、平均間隔は 60分 / 3 = 20分 (rate = 3/60 = 0.05 人/分)
rate_per_min <- lam / 60
interval_sim <- rexp(n_samples, rate = rate_per_min)
df_intervals <- data.frame(interval = interval_sim)
df_exp_theory <- data.frame(t = seq(0, 80, length.out = 200)) %>%
  mutate(density = dexp(t, rate = rate_per_min))

p4 <- ggplot() +
  geom_histogram(data = df_intervals, aes(x = interval, y = after_stat(density)),
                 binwidth = 3, boundary = 0, fill = "#1abc9c", color = "white", alpha = 0.6) +
  geom_line(data = df_exp_theory, aes(x = t, y = density), color = "#16a085", linewidth = 1.2) +
  coord_cartesian(xlim = c(0, 80)) +
  labs(
    title = "④ 表裏一体: 到着間隔 (指数分布)",
    subtitle = "平均間隔: 20分 (即座に来る確率が最も高い)",
    x = "次の客が来るまでの待ち時間 (分)",
    y = "確率密度"
  ) +
  theme_minimal(base_family = font_family) +
  theme(plot.title = element_text(face = "bold", size = 12))

# 4つのプロットを2x2で配置
combined_plot <- (p1 + p2) / (p3 + p4) +
  plot_annotation(
    title = "ポアソン分布と指数分布の全体像 (R / ggplot2)",
    theme = theme(
      plot.title = element_text(family = font_family, size = 16, face = "bold", hjust = 0.5)
    )
  )

output_img <- "poisson_distribution_r.png"
ggsave(output_img, combined_plot, width = 12, height = 9, dpi = 300, type = "cairo")
cat(sprintf("📊 グラフ画像を保存しました: %s\n", output_img))

