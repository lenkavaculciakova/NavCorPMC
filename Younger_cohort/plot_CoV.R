# This is a code creating Figure 5
# function written by Martin Petr (contact@bodkan.net) adapted by L. Vaculciakova (contact@lenkav.net)
library(tidyverse)
library(cowplot)
library(furrr)
library(gapminder)
plan(multiprocess)


plot_CoV <- function(df, cont, indiv = FALSE, outlier = FALSE) {
    units <- case_when(cont == "PD" ~ "Inhomogeneity CoV [%]",
                       cont == "R1" ~ "", #[1 / sec]
                       cont == "R2*" ~ "") #[1 / sec]

    x <- df %>% filter(contrast == cont) %>%
        mutate(brain_area = ifelse(brain_area == "GM", "gray matter", "white matter")) %>%
        mutate(nav = ifelse(nav == "navOFF", "NAV off", "NAV on")) %>%
        mutate(pmc = ifelse(pmc == "pmcOFF", "PMC off", "PMC on"))

    mean_df <- group_by(x, brain_area, contrast,pmc, nav) %>%
        summarise(mean_cov = mean(cov), .groups = "keep")

    p <- ggplot() + ylim(c(min(x$cov), max(x$cov)))

    if (indiv)
        p <- p +
            geom_boxplot(data = x, aes(x = nav, y = cov, color = brain_area, group = interaction(nav, brain_area)), size = 1) +
            geom_boxplot(data = x, aes(x = nav, y = cov, color = brain_area, group =  interaction(nav, brain_area)), size = 1)

    p <- p +
        facet_wrap(~ pmc, scales = "free_x") +
        theme_bw() +
#        theme(text = element_text(size = 15), legend.position = "bottom", plot.title = element_text(hjust = 0.5),
#              strip.background=element_rect(fill = "gray93"),
#              panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
#              panel.background = element_blank()) +
        labs(x = "", y = units, title = cont) + #y = units
        scale_x_discrete(expand=c(0, 0.5)) +

#        geom_point(data = mean_df, aes(x = nav, y = mean_cov, color = brain_area, group = nav), size = 2.5) +
#        geom_point(data = mean_df, aes(x = nav, y = mean_cov, color = brain_area, group = nav), size = 2.5) +

#        geom_line(data = mean_df, aes(x = nav, y = mean_cov, color = brain_area, group = brain_area), size = 0.9) +
#        geom_line(data = mean_df, aes(x = nav, y = mean_cov, color = brain_area, group = brain_area), size = 0.9) +
        scale_color_manual(values = c("darkgoldenrod3", "aquamarine4"))

    if (cont == "R1")
        p <- p +  guides(color = guide_legend(nrow = 1)) +
        theme(axis.title.x = element_blank(),
              legend.position = "bottom",
              legend.text = element_text(size = 20),
              legend.spacing.x = unit(0.2, "cm"),
              text = element_text(size = 20),
              plot.title = element_text(hjust = 0.5),
              # strip.background = element_blank(),
              # strip.text.x = element_blank(),
              panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
              panel.background = element_blank(),
              legend.title=element_blank())
    else
        p <- p + guides(colour = guide_legend(override.aes = list(size=0, alpha = 0))) +
        theme(axis.title.x = element_blank(),
              legend.position = "bottom",
              legend.text = element_blank(),
              text = element_text(size = 20),
              plot.title = element_text(hjust = 0.5),
              # strip.background = element_blank(),
              # strip.text.x = element_blank(),
              panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
              panel.background = element_blank(),
              legend.title=element_blank())


    p
}


# Load text file and convert it to a properly formatted data frame.
# Load text file and convert it to a properly formatted data frame.
load_txt <- function(path) {
    # load the numbers
    values <- scan(path)

    # extract fields based on the TXT file name
    fields <- strsplit(path, "_|.txt")[[1]]
    #fields <- gsub("pmc|nav|WM", "", fields)

    data <- as.list(fields)
    names(data) <- c("participant", "brain_area", "contrast", "pmc", "nav")
    data$cov <- values

    data.frame(data, stringsAsFactors = F)
}

#
#  plotting
#

# set path to txt files
txt_dir <- "Inhomogeneity_CoV/"

# presun nas do directory s input TXT daty
setwd(txt_dir)

# get a list of all text files
txt_files <- list.files(".", pattern = "txt$")

# load all text files and calculate STDEV of values
# convert everything to a nice data frame
df <- map_dfr(txt_files, load_txt)

# rename R2s to R2*
indices_to_change <- which(df$contrast== 'R2s')
df$contrast[indices_to_change] <- 'R2*'

# multiply CoV by 100 to change units to %
df$cov <- df$cov*100


p1 <- plot_CoV(df, "PD", indiv = TRUE) + theme(plot.margin = unit(c(0.5, 0, 0, 0.1), "cm"))
p2 <- plot_CoV(df, "R1", indiv = TRUE) + theme(plot.margin = unit(c(0.5, 0, 0, -0.45), "cm"))
p3 <- plot_CoV(df, "R2*", indiv = TRUE) + theme(plot.margin = unit(c(0.5, 0.2, 0, -0.45), "cm"))


plot_grid(p1,p2,p3,
          nrow = 1, hjust = "left", rel_widths = c(1, 1, 1))

ggsave("CoV_plot.eps", width=14, height=5)



