# read csv assignment 1 
library(ggplot2)
setwd("~/DSSC/hpc_assignment1/section2")

##############
#core_ucx
core_ucx <- data.frame(read.csv("core_ucx.csv"))

attach(core_ucx)

#latency
a <- core_ucx[1:15,]
p<- ggplot(data = a, aes(x = as.factor(X.bytes), y = t.usec., color = 2,group = 1))  + geom_line() + geom_point()
p + geom_line(data = a, aes(x = as.factor(X.bytes), y = 0.20 + X.bytes/12500, color=3)) + geom_line() + geom_point()
                     
#bandwidth
p <- ggplot(data = core_ucx, aes(x = as.factor(X.bytes), y = Mbytes.sec, color = 2,group = 1)) 
p + geom_line() + geom_point() + labs(x = "Message size (bytes)") + theme(legend.position="none") 

p <- ggplot(data = core_ucx, aes(x = as.factor(X.bytes), y = 0.20 + X.bytes/12500, color = 2,group = 1)) 
p + geom_line(data = core_ucx, aes(x = as.factor(X.bytes), y = 0.20 + X.bytes/12500)) + geom_point() + labs(x = "Message size (bytes)", y="Time (s)") + theme(legend.position="none") 

p <- geom_line(0.20 + X.bytes/12500)


ggplot() + 
  geom_line(data = core_ucx, aes(x = X.bytes, y = 0.20 + X.bytes/12500), color = "red")

detach(core_ucx)

#############
#socket_ucx
socket_ucx <- data.frame(read.csv("socket_ucx.csv"))

############
#node_ucx
node_ucx <- data.frame(read.csv("node_ucx.csv"))

##############
#core_vader
core_vader <- data.frame(read.csv("core_vader.csv"))

attach(core_vader)

#latency
a <- core_vader[1:15,]
ggplot(data = a, aes(x = as.factor(a$X.bytes), y = a$t.usec., color = 2,group = 1))  + geom_line() + geom_point()

#bandwidth
p <- ggplot(data = core_vader, aes(x = as.factor(trunc(X.bytes)), y = Mbytes.sec, color = 2,group = 1)) 
p + geom_line() + geom_point() + labs(x = "Message size (bytes)") + theme(legend.position="none") 

detach(core_vader)

#################
#