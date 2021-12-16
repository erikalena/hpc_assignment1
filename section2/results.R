# read csv assignment 1, section 2
library(ggplot2)
library(RColorBrewer)
library(patchwork)
library(data.table)
library(ggpubr)

setwd("~/DSSC/hpc_assignment1/section2")
col_legend <- brewer.pal(n=8, name="Dark2")

##############
plot_times <- function(file) {
  df1 <- data.frame(read.csv(paste0("csv/",file)))
  if(startsWith(file, "intel"))
    file =  substring(file, 7)
  
  df <- df1[1:24,]
  
  model <-lm(t.usec.[1:26] ~ X.bytes[1:26], df)
  lambda <-  model$coef[1]
  B <- model$coef[2]
  
  print(file)
  print(coef(model))
  print(paste0("bandwith: ", 1/coef(model)[2]))
  
  times <- ggplot() +
    # core ucx
    geom_line(data = df, aes(x = as.factor(X.bytes), y = t.usec., color="empirical", group = 1)) +
    geom_point(data = df, aes(x = as.factor(X.bytes), y = t.usec., color="empirical", group = 1))  + 

    # theoretical 
    geom_line(data = df, aes(x = as.factor(X.bytes), y = min(t.usec.) + X.bytes/max(Mbytes.sec), color="comm. model", group=1)) +
    geom_point(data = df, aes(x = as.factor(X.bytes), y = min(t.usec.) + X.bytes/max(Mbytes.sec), color="comm. model", group=1)) +

    # fit 
   # geom_line(data = df, aes(x = as.factor(X.bytes), y = lambda + X.bytes*B, color="fit lm model", group=1)) +
   # geom_point(data = df, aes(x = as.factor(X.bytes), y = lambda + X.bytes*B, color="fit lm model", group=1)) +
    geom_point(aes(as.factor(df$X.bytes), loess(t.usec. ~ X.bytes, df)$fitted, color="fit model", group=1))+
    geom_line(aes(as.factor(df$X.bytes), loess(t.usec. ~ X.bytes, df)$fitted, color="fit model", group=1))+
    
    
    labs(x = "Message size (bytes)", y = "Time") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
    theme(legend.title = element_blank()) +
    scale_colour_manual(values = c("empirical" = "#2bacbd", "comm. model" = "#cf5e25", "fit model" = "#297504")) +
    labs(title = sub("\\_.*", "", file))
  

  if(!"t.usec.comp."  %in% colnames(df1)){
    df1$t.usec.comp.[1:24] <- round(loess(t.usec. ~ X.bytes, df)$fitted, 4)
    fwrite(df1, paste0("csv/",file))
  }
  return(times)
}


plot_bandwidth <- function(file) {
  df1 <- data.frame(read.csv(paste0("csv/",file)))
  if(startsWith(file, "intel"))
    file =  substring(file, 7)
  
  df <- df1[1:24,]
  #bandwidth
  bandwidth <- ggplot() +
    # core ucx
    geom_line(data = df, aes(x = as.factor(X.bytes), group = 2, y = Mbytes.sec, color="empirical")) +
    geom_point(data = df, aes(x = as.factor(X.bytes), group = 2, y = Mbytes.sec, color="empirical"))  +

    # theoretical
    geom_line(data = df, aes(x = as.factor(X.bytes), y = X.bytes/(min(t.usec.) + X.bytes/max(Mbytes.sec)), color="comm. model", group=1)) +
    geom_point(data = df, aes(x = as.factor(X.bytes), y = X.bytes/(min(t.usec.) + X.bytes/max(Mbytes.sec)), color="comm. model", group=1)) +

    # fit
    #geom_point(aes(as.factor(df$X.bytes), loess(Mbytes.sec ~ X.bytes, df,degree=1)$fitted, color="fit model", group=1))+
    #geom_line(aes(as.factor(df$X.bytes), loess(Mbytes.sec ~ X.bytes, df, degree=1)$fitted, color="fit model", group=1))+
    geom_line(data = df, aes(x = as.factor(X.bytes), y = X.bytes/(loess(t.usec. ~ X.bytes, df)$fitted), color="fit model", group=1)) +
    geom_point(data = df, aes(x = as.factor(X.bytes), y = X.bytes/(loess(t.usec. ~ X.bytes, df)$fitted), color="fit model", group=1)) +
    
   # geom_line(linetype = "dashed",data = df, aes(x = as.factor(X.bytes), y = 12000, color="th. bandwidth", group=1)) +
    
    labs(x = "Message size (bytes)", y = "Bandwidth") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
    theme(legend.title = element_blank()) +
    scale_colour_manual(values = c("empirical" = "#2bacbd", "comm. model" = "#cf5e25", "fit model" = "#297504")) +
    labs(title = sub("\\_.*", "", file))

  
   if(!"Mbytes.sec.comp."  %in% colnames(df1)){
    df1$Mbytes.sec.comp.[1:24] <- round(df$X.bytes/(loess(t.usec. ~ X.bytes, df)$fitted), 4)
    fwrite(df1, paste0("csv/",file))
   }

  return(bandwidth)
}

plot_nshm <- function(core, socket, node, type) {
  core_times <- plot_times(core)
  socket_times <- plot_times(socket)
  node_times <- plot_times(node)
  core_times + socket_times + node_times +
  plot_annotation(title =  gsub('_', ' ', type)) &  theme(plot.title = element_text(hjust = 0.5))
  
  ggsave(paste0( "images/times_", type, ".png"), width = 20, height = 8, dpi = 150)
  
  core_bandwidth <- plot_bandwidth(core)
  socket_bandwidth <- plot_bandwidth(socket)
  node_bandwidth <- plot_bandwidth(node)
  core_bandwidth + socket_bandwidth + node_bandwidth +
  plot_annotation(title =  gsub('_', ' ', type)) &  theme(plot.title = element_text(hjust = 0.5))
  
  ggsave(paste0( "images/bandwidth_", type, ".png"), width = 20, height = 8, dpi = 150)
  
}


plot_shm <- function(core, socket,type) {
  core_times <- plot_times(core)
  socket_times <- plot_times(socket)
  core_times + socket_times +
  plot_annotation(title =  gsub('_', ' ', type)) &  theme(plot.title = element_text(hjust = 0.5))
  
  ggsave(paste0( "images/times_", type, ".png"), width = 20, height = 8, dpi = 150)
  
  core_bandwidth <- plot_bandwidth(core)
  socket_bandwidth <- plot_bandwidth(socket)
  
  core_bandwidth + socket_bandwidth +
  plot_annotation(title =  gsub('_', ' ', type)) &  theme(plot.title = element_text(hjust = 0.5))
  
  ggsave(paste0( "images/bandwidth_", type, ".png"), width = 20, height = 8, dpi = 150)
}


#openmpi - cpu
##############
#ucx
plot_nshm("core_ucx.csv", "socket_ucx.csv", "node_ucx.csv", "ucx_openmpi_cpu")
#tcp
plot_nshm("core_tcp.csv", "socket_tcp.csv", "node_tcp.csv", "tcp_openmpi_cpu")
#vader
plot_shm("core_vader.csv", "socket_vader.csv", "vader_openmpi_cpu")

#openmpi - gpu
##############
#ucx
plot_nshm("core_ucx_gpu.csv", "socket_ucx_gpu.csv", "node_ucx_gpu.csv", "ucx_openmpi_gpu")
#tcp
plot_nshm("core_tcp_gpu.csv", "socket_tcp_gpu.csv", "node_tcp_gpu.csv", "tcp_openmpi_gpu")
#vader
plot_shm("core_vader_gpu.csv", "socket_vader_gpu.csv", "vader_openmpi_gpu")

#intel - cpu
##############
#ucx
plot_nshm("intel_core_ucx.csv", "intel_socket_ucx.csv", "intel_node_ucx.csv", "ucx_intel_cpu")
#tcp
plot_nshm("intel_core_tcp.csv", "intel_socket_tcp.csv", "intel_node_tcp.csv", "tcp_intel_cpu")
#vader
plot_shm("intel_core_shm.csv", "intel_socket_shm.csv","shm_intel_cpu")

#intel - gpu
##############
#ucx
plot_nshm("intel_core_ucx_gpu.csv", "intel_socket_ucx_gpu.csv", "intel_node_ucx_gpu.csv", "ucx_intel_gpu")
#tcp
plot_nshm("intel_core_tcp_gpu.csv", "intel_socket_tcp_gpu.csv", "intel_node_tcp_gpu.csv", "tcp_intel_gpu")
#vader
plot_shm("intel_core_shm_gpu.csv", "intel_socket_shm_gpu.csv", "shm_intel_gpu")


