# Read results obtained by ring.c
setwd("~/DSSC/hpc_assignment1/section1/ring")
times <- data.frame(read.table("results.csv"))

colnames(times) <- c("n_procs", "time_nonblocking", "time_blocking")

library("ggplot2")
#plot times for non blocking implementation
plot(times$n_procs, times$time_nonblocking, type='l', xlab="N procs", ylab="Time", col=5, lwd=2)
points(times$n_procs, times$time_nonblocking,pch=16,col=5)

#plot times for blocking implementation
lines(times$n_procs, times$time_blocking, type='l', xlab="N procs", ylab="Time", col=6, lwd=2, add=T)
points(times$n_procs, times$time_blocking,pch=16,col=6)

legend(5, 0.00012, legend=c("Non blocking implementation", "Blocking implementation"),
       col=c(5, 6), lty=1, lwd=2, cex=0.8)

