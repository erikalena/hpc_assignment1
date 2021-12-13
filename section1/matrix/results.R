# read csv assignment 1,section 1, part 2
library(ggplot2)
library(gridExtra)
library(grid)


setwd("~/DSSC/hpc_assignment1/section1/matrix")

#set table theme
color_df <- data.frame(color = c("#ffffff", "#bfdedd"), stringsAsFactors = FALSE)
my_table_theme <- ttheme_default(core=list(bg_params = list(fill = color_df$color[1:2], col=NA)), colhead =list(bg_params=list(fill ="#8bb0af")))

#times to sum matrices
times <- data.frame(read.csv("3D_matrix.csv"))
grid.table(times, rows=NULL, theme = my_table_theme)

#save table as png
png("3D_matrix_results.png")
grid.table(times, rows=NULL)
dev.off()
