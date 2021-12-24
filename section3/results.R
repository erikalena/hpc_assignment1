# read csv assignment 1, section 3
library(ggplot2)
library(gridExtra)
library(grid)


setwd("~/DSSC/hpc_assignment1/section3")

color_df <- data.frame(color = c("#ffffff", "#bfdedd"), stringsAsFactors = FALSE)
my_table_theme <- ttheme_default(core=list(bg_params = list(fill = color_df$color[1:2], col=NA)), colhead =list(bg_params=list(fill ="#8bb0af")))

#read csv about results obtained on cpu nodes
jacobi <- data.frame(read.csv("results_cpu.csv"))
jacobi$min_commtime <- jacobi$mintime - jacobi$jacobimin
jacobi$max_commtime <- jacobi$maxtime - jacobi$jacobimax

grid.table(jacobi, rows=NULL, theme = my_table_theme)
grid.newpage()

#simple plot for scalability wtr to the number of processor
par(mfrow=c(1,2))
plot( jacobi$n_procs[c(1:4,9,10,11)], jacobi$mlups[c(1:4,9,10,11)], xlab="number of processes", ylab="Performance [MLUPs/sec]", type='l',lwd=2)
points(jacobi$n_procs[c(1:4,9,10,11)], jacobi$mlups[c(1:4,9,10,11)],pch=16)
slope = (jacobi$mlups[2] - jacobi$mlups[1])/(jacobi$n_procs[2] - jacobi$n_procs[1])
curve(slope*x, add=T)
legend(1, 5000, legend=c("linear", expression(~ 120^3~ " Infiniband")), lty=c(1,2), lwd=c(1,2))

par(mfrow=c(1,2))
plot( jacobi$n_procs[c(1:4,9,10,11)], jacobi$maxtime[c(1:4,9,10,11)], xlab="number of processes", ylab="Time taken [sec]", type='l',lwd=2)
points(jacobi$n_procs[c(1:4,9,10,11)], jacobi$maxtime[c(1:4,9,10,11)],pch=16)
slope = (jacobi$mlups[2] - jacobi$mlups[1])/(jacobi$n_procs[2] - jacobi$n_procs[1])
curve(slope*x, add=T)
legend(1, 5000, legend=c("linear", expression(~ 120^3~ " Infiniband")), lty=c(1,2), lwd=c(1,2))

#read csv about results obtained on gpu nodes
jacobi_gpu <- data.frame(read.csv("results_gpu.csv"))
jacobi_gpu$min_commtime <- jacobi_gpu$mintime - jacobi_gpu$jacobimin
jacobi_gpu$max_commtime <- jacobi_gpu$maxtime - jacobi_gpu$jacobimax

grid.table(jacobi_gpu, rows=NULL)
grid.newpage()

#build table for cpu nodes
jacobi_res <- jacobi[,1:2]
jacobi_res$mean_time <- (jacobi$mintime +jacobi$maxtime)/2
jacobi_res$mean_jacobi <- (jacobi$jacobimin +jacobi$jacobimax)/2
jacobi_res$comm_time <- (jacobi_res$mean_time - jacobi_res$mean_jacobi)
jacobi_res$k <- c(0,4,6,6,4,6,6,6,6,6,6)
jacobi_res$MLUP <- jacobi[,7]
jacobi_res$t.usec <- c(0,0.24,0.24,0.24,0.68,0.68,0.68,1.24,1.24,1.24,1.24)
jacobi_res$'B [MB/s]' <- c(0,6527.72,6527.72,6527.72,7398.77,7398.77,7398.77,11899.06,11899.06,11899.06,11899.06)

subdomain <- 1200/jacobi_res$n_procs^(1/3)
jacobi_res$'C(L,N) [Mb]' <- c(0,subdomain[-1]^2*jacobi_res$k[-1]*16*10^(-6))
jacobi_res$'Tc(L,N) [s]' <- c(0,jacobi_res$'C(L,N) [Mb]'[-1]/(jacobi_res$'B [MB/s]'[-1] * 8) + jacobi_res$k[-1]*jacobi_res$t.usec[-1]*10^(-6))
jacobi_res$'P(L,N) [MLUP/sec]' <- 1200^3/((jacobi_res$mean_jacobi + jacobi_res$comm_time)*1000000)

png("jacobi_res.png", width=1000,height=480,bg = "white")
grid.table(jacobi_res, rows=NULL, theme = my_table_theme)
dev.off()

plot(jacobi_res$n_procs, jacobi_res$MLUP, xlab="number of processes", ylab="Performance [MLUPs/sec]", type='l')
lines(jacobi_res$n_procs, jacobi_res$'P(L,N) [MLUP/sec]', xlab="number of processes", ylab="Performance [MLUPs/sec]", type='l', col=3)


#gpu
jacobi_gpu <- data.frame(read.csv("results_gpu.csv"))
jacobi_gpu$min_commtime <- jacobi_gpu$mintime - jacobi_gpu$jacobimin
jacobi_gpu$max_commtime <- jacobi_gpu$maxtime - jacobi_gpu$jacobimax

grid.table(jacobi_gpu, rows=NULL)

#build table for gpu nodes
jacobi_gpu_res <- jacobi_gpu[,1:2]
jacobi_gpu_res$mean_time <- (jacobi_gpu$mintime +jacobi_gpu$maxtime)/2
jacobi_gpu_res$mean_jacobi <- (jacobi_gpu$jacobimin +jacobi_gpu$jacobimax)/2
jacobi_gpu_res$comm_time <- (jacobi_gpu_res$mean_time - jacobi_gpu_res$mean_jacobi)
jacobi_gpu_res$k <- c(0,4,6,6,4,6,6,6,6,6)
jacobi_gpu_res$MLUP <- jacobi_gpu[,7]
jacobi_gpu_res$t.usec <- c(0,0.24,0.24,0.24,0.68,0.68,0.68,1.24,1.24,1.24)
jacobi_gpu_res$'B [MB/s]' <- c(0,6527.72,6527.72,6527.72,7398.77,7398.77,7398.77,7398.77,7398.77,7398.77)

subdomain <- 1200/jacobi_gpu_res$n_procs^(1/3)
jacobi_gpu_res$'C(L,N) [Mb]' <- c(0,subdomain[-1]^2*jacobi_gpu_res$k[-1]*16/1000000)
jacobi_gpu_res$'Tc(L,N) [s]' <- c(0,jacobi_res$'C(L,N) [Mb]'[-1]/(jacobi_res$'B [MB/s]'[-1] * 8) + jacobi_gpu_res$k[-1]*jacobi_gpu_res$t.usec[-1]*10^(-6))
jacobi_gpu_res$'P(L,N) [MLUP/sec]' <- 1200^3/((jacobi_gpu_res$mean_jacobi + jacobi_gpu_res$comm_time)*1000000)

png("jacobi_gpu_res.png", width=1000,height=480,bg = "white")
grid.table(jacobi_gpu_res, rows=NULL, theme = my_table_theme)
dev.off()
