# Read results obtained for section 1, part 1
library("ggplot2")

# read data
setwd("~/DSSC/hpc_assignment1/section1/ring")
times <- data.frame(read.csv("results.csv"))
colnames(times) <- c("n_procs", "time_nonblocking", "time_blocking")

x <- as.numeric(times$n_procs)
y <- as.numeric(times$time_nonblocking)

png("ring_results.png", width=1200, height = 800)

#plot times for non blocking implementation
plot(x, times$time_nonblocking, type='l', xlab="N procs", ylab="Time", col=5, lwd=2, ylim=c(0,1.5*10^(-4)))
points(x, times$time_nonblocking,pch=16,col=5)

#plot times for blocking implementation
lines(x, times$time_blocking, type='l', xlab="N procs", ylab="Time", col=6, lwd=2)
points(x, times$time_blocking,pch=16,col=6)


abline(v = 24, lty = 2, lwd=1.5)
text(24, 0.0, "n_procs=24", pos = 4, srt=90)

#plot theoretical model for non blocking implementation
#estimated results for bandwidth and latency from section 2 have been used
#since messages are really small, use the results obtained when the cache is used
band_socket <- 12000
band_node <- 12000
lat_socket <- 0.69
lat_node <- 1.23
  
y1 <- x[1:24]*(2*2*(10^(-6))/band_socket + lat_socket*(10^(-6)))
y2 <- x[25:47]*(2*2*(10^(-6))/band_node + lat_node*(10^(-6)))
lines(x, c(y1,y2), type='l', col="#0f95a6", lty = 2,lwd=2)

#plot theoretical model for blocking implementation
y1 <- 2*y1 
y2 <- 2*y2 
lines(x, c(y1,y2), type='l', col="#a30f94", lty = 2,lwd=2)

legend(1, 0.00012, legend=c("Non blocking implementation", "nb. model", "Blocking implementation", "b. model"),
       col=c(5,5,6,6), lty=c(1,2,1,2), lwd=2, cex=1.1, pt.cex = 0.8)

#close the png file
dev.off()

