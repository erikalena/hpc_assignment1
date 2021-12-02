# Read results obtained by ring.c
setwd("~/DSSC/hpc_assignment1/section1")
times <- data.frame(read.table("results.csv"))

times <- times[-c(1,2,3),]
colnames(times) <- c("n_procs", "time_nonblocking", "time_blocking")

library("ggplot2")
plot(times$n_procs, times$time_nonblocking, type='l', xlab="N procs", ylab="Time", col=5, lwd=2)
points(times$n_procs, times$time_nonblocking,pch=16,col=5)
