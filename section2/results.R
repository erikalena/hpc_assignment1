# read csv assignment 1 
setwd("~/Documents/hpc_assignment1/section2")
core_ucx <- data.frame(read.csv("core_ucx.csv"))
core_vader <- data.frame(read.csv("core_vader.csv"))

socket_ucx <- data.frame(read.csv("socket_ucx.csv"))
core_vader <- data.frame(read.csv("core_vader.csv"))

attach(core_ucx)
plot(X.bytes, t.usec., type='l')
