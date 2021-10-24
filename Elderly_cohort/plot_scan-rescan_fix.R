# This is a code creating Figure 8
# function written by Martin Petr (contact@bodkan.net) adapted by L. Vaculciakova (contact@lenkav.net)
library(tidyverse)
library(cowplot)
library(furrr)
plan(multiprocess)


plot_scanrescan <- function(df) {

    x <- df %>%
        mutate(brain_area = ifelse(brain_area == "GM", "gray matter", "white matter")) %>%
        mutate(nav = ifelse(nav == "navOFF", "NAV off", "NAV on"))

    mean_df <- group_by(x, brain_area, contrast, nav) %>%
            summarise(mean_sq = mean(cv), .groups = "keep")

    ggplot() +
            geom_point(data = x, aes(x = nav, y = cv*100, color = brain_area, group = nav),
                       alpha = 0.25, size = 1.5) +
            geom_line(data = x, aes(x = nav, y = cv*100, color = brain_area,
                                    group = interaction(brain_area, participant)),
                      alpha = 0.25, size = 0.5) +
      
        geom_point(data = mean_df, aes(x = nav, y = mean_sq*100, color = brain_area,
                                       group = nav),
                   size = 3) +
        geom_line(data = mean_df, aes(x = nav, y = mean_sq*100, color = brain_area,
                                group = brain_area),
                  size = 1.5) +
      
      theme_bw() + guides(color = guide_legend(nrow = 1)) +
            theme(axis.title.x = element_blank(),
                  legend.position = "bottom",
                  text = element_text(size = 15),
                  plot.title = element_text(hjust = 0.5),
                  strip.background = element_blank(),
                  strip.text.x = element_text(size = 18),
                  panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                  panel.background = element_blank(),
                  legend.title=element_blank()) +
            #labs(y = expression(sqrt("Sum of Squared Difference")/"mean")) +
            labs(y = "Scan-rescan CoV [%]") +
            scale_x_discrete(expand=c(0, 0.4)) +
            scale_color_manual(values = c("darkgoldenrod3", "aquamarine4")) +
      facet_wrap(~ contrast, scales = "free_y") #+ expand_limits(y = 0)

}


# Load text file and convert it to a properly formatted data frame.
load_txt <- function(path) {
    # load the numbers
    values <- scan(path)
    
    # extract fields based on the TXT file name
    fields <- strsplit(path, "_|.txt")[[1]]
    #fields <- gsub("pmc|nav|WM", "", fields)
    
    data <- as.list(fields)
    names(data) <- c("participant", "brain_area", "contrast", "nav")
    data$cv <- values
    
    data.frame(data, stringsAsFactors = F)
}


#
#  plotting
#


# set path to txt files
txt_dir <- "scan-rescan_CoV/"
setwd(txt_dir)

# get a list of all text files
txt_files <- list.files(txt_dir, pattern = "txt$")

# load all text files and calculate STDEV of values
# convert everything to a nice data frame
df <- map_dfr(txt_files, load_txt)
# rename R2s to R2* 
indices_to_change <- which(df$contrast== 'R2s')
df$contrast[indices_to_change] <- 'R2*'


plot_scanrescan(df)

ggsave("scan-rescan.eps", width = 6, height = 4)

