# This script generates figure showing the proportion of navigators identified
# for adaptive combine due to low point SNR.

library(tidyverse)
library(R.matlab)

younger <- readMat("Younger_cohort/Young_perc.mat") %>% .$young.perc
elderly <- readMat("Elderly_cohort/Elderly_perc.mat") %>% .$elderly.perc

to_df <- function(mat) {
  df <- map_dfr(seq_len(dim(mat)[1]), function(i) {
    t(mat[i, ,]) %>%
      as.data.frame() %>%
      setNames(paste0("m", 1:4)) %>%
      as_tibble() %>%
      mutate(part = paste0("p", i), channel = 1:n())
  }) %>%
    pivot_longer(
      cols = c("m1", "m2", "m3", "m4"),
      names_to = "measurement",
      values_to = "percent"
    ) %>%
    mutate(channel = as.factor(channel),
           part = factor(part, levels = paste0("p", 1:dim(mat)[1])),
           measurement = str_replace(measurement, "m", ""))
  df
}

younger_df <- to_df(younger) %>% mutate(cohort = "Younger cohort")
elderly_df <- to_df(elderly) %>% mutate(cohort = "Elderly cohort")
df <- bind_rows(younger_df, elderly_df)

summary_df <- df %>%
  group_by(part, measurement, cohort) %>%
  summarise(
    mean = mean(percent),
    median = median(percent),
    sd = sd(percent),
    q75 = quantile(percent, 0.75)
  )

p <- ggplot() +
  geom_point(data = df, aes(part, percent, color = measurement),
             position = position_dodge(width = 0.75), size = 0.65, alpha = 0.35) +
  geom_point(data = summary_df, aes(part, mean, group = measurement), shape = 1,
             position = position_dodge(width = 0.75), size = 1.5) +
  labs(x = "Participant",
       y = "Proportion of navigator with low SNR [%]") +
  guides(color = guide_legend("Measurement",
                              override.aes = list(size = 2.5, alpha = 1))) +
  theme_minimal() +
  theme(legend.position = "bottom",
        panel.grid.major.x = element_blank(),
        strip.text = element_text(face = "bold", size = 10)) +
  coord_cartesian(ylim = c(0, 100)) +
  facet_wrap(~cohort, nrow = 2, scales = "free_x")

ggsave("navigator_stats.png", bg = "white", width = 7, height = 5)
ggsave("navigator_stats.tiff", bg = "white", width = 7, height = 5)
