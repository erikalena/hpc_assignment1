# read csv assignment 1 
library(ggplot2)
library(RColorBrewer)
library(patchwork)

setwd("~/DSSC/hpc_assignment1/section2")
col_legend <-brewer.pal(n=8, name="Dark2")



##############
plot_times <- function(file) {
  df <- data.frame(read.csv(file))
  df<-df[1:24,]
  
  model <-lm(t.usec.[1:24] ~ X.bytes[1:24], df)
  lambda <- model$coef[1]
  B <- model$coef[2]
  
  print(file)
  print(coef(model))
  print(paste0("bandwith: ", 1/coef(model)[2], "\n"))
  
  times <- ggplot() +
    # core ucx
    geom_line(data = df, aes(x = as.factor(X.bytes), y = t.usec., color="empirical", group = 1)) +
    geom_point(data = df, aes(x = as.factor(X.bytes), y = t.usec., color="empirical", group = 1))  + 

    # theoretical 
    geom_line(data = df, aes(x = as.factor(X.bytes), y = min(t.usec.) + X.bytes/max(Mbytes.sec), color="comm. model", group=1)) +
    geom_point(data = df, aes(x = as.factor(X.bytes), y = min(t.usec.) + X.bytes/max(Mbytes.sec), color="comm. model", group=1)) +

    # fit 
    geom_line(data = df, aes(x = as.factor(X.bytes), y = lambda + X.bytes*B, color="fit model", group=1)) +
    geom_point(data = df, aes(x = as.factor(X.bytes), y = lambda + X.bytes*B, color="fit model", group=1)) +

    
    labs(x = "Message size (bytes)", y = "Time") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
    theme(legend.title = element_blank()) +
    scale_colour_manual(values = c("empirical" = "#2bacbd", "comm. model" = "#cf5e25", "fit model" = "#297504")) +
    labs(title = gsub('_', ' ', gsub('.{4}$', '', file)))
  
  return(times)
}


plot_bandwidth <- function(file) {
  df <- data.frame(read.csv(file))

  #bandwidth
  bandwidth <- ggplot() +
    # core ucx
    geom_line(data = df, aes(x = as.factor(X.bytes), group = 2, y = Mbytes.sec, color="empirical")) +
    geom_point(data = df, aes(x = as.factor(X.bytes), group = 2, y = Mbytes.sec, color="empirical"))  +

    # theoretical
    geom_line(data = df, aes(x = as.factor(X.bytes), y = X.bytes/(min(t.usec.) + X.bytes/max(Mbytes.sec)), color="comm. model", group=1)) +
    geom_point(data = df, aes(x = as.factor(X.bytes), y = X.bytes/(min(t.usec.) + X.bytes/max(Mbytes.sec)), color="comm. model", group=1)) +

    # fit
    #geom_line(data = df, aes(x = as.factor(X.bytes), y = 1/bandwidth[file] , color="fit model", group=1)) +

    labs(x = "Message size (bytes)", y = "Bandwidth") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
    theme(legend.title = element_blank()) +
    scale_colour_manual(values = c("empirical" = "#2bacbd", "comm. model" = "#cf5e25", "fit model" = "#297504")) +
    labs(title = gsub('_', ' ', gsub('.{4}$', '', file)))

  return(bandwidth)
}

plot_openmpi_times <- function(core, socket, node) {
  core_times <- plot_times(core)
  socket_times <- plot_times(socket)
  node_times <- plot_times(node)
  core_times + socket_times + node_times
}

plot_openmpi_bandwidth <- function(core, socket, node) {
  core_bandwidth <- plot_bandwidth(core)
  socket_bandwidth <- plot_bandwidth(socket)
  node_badnwidth <- plot_bandwidth(node)
  core_bandwidth + socket_bandwidth + node_badnwidth
}

#openmpi - cpu
##############
#ucx
plot_openmpi_times("core_ucx.csv", "socket_ucx.csv", "node_ucx.csv")
plot_openmpi_bandwidth("core_ucx.csv", "socket_ucx.csv", "node_ucx.csv")
#tcp
plot_openmpi_times("core_ucx.csv", "socket_tcp.csv", "node_tcp.csv")
plot_openmpi_bandwidth("core_tcp.csv", "socket_tcp.csv", "node_tcp.csv")
