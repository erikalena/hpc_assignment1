# read csv assignment 1,section 1, part 2
library(ggplot2)
library(gridExtra)
library(grid)


setwd("~/DSSC/hpc_assignment1/section1/matrix")

#set table theme
color_df <- data.frame(color = c("#ffffff", "#bfdedd"), stringsAsFactors = FALSE)
my_table_theme <- ttheme_default(core=list(bg_params = list(fill = color_df$color[1:2], col=NA)), colhead =list(bg_params=list(fill ="#8bb0af")))

#build table
times <- data.frame(read.csv("3D_matrix.csv"))
colnames(times) <- c("Matrix dims", "Topology", "Time taken", "Comp time")

#save table as png
png("3D_matrix_results.png")
grid.table(times, rows=NULL,theme = my_table_theme)
dev.off()

#####
# compute theoretical times and compare them with empirical ones
B <- 7000 # ~ estimated latency without the use of the cache
lambda <- 0.60*(10^(-6))
# size of matrix (2 matrices) multiplied by 8 (size of double)
size <- (2400*100*100)*8*(10^(-6))
T <- 3*(size/B + lambda) # ~ 0.08228

comm_time <- times$`Time taken` - times$`Comp time`
