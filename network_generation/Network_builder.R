library(igraph)
library(qgraph)

###
##### Network generation
###

### set working directory
setwd("/Users/name/Desktop/sample/path/")
### pull nodes file from working directory
nodes <- read.csv("Nodes.csv", header=T, as.is=T)
### pull edges file from working directory
links <- read.csv("Edges.csv", header=T, as.is=T)
### create framework for network
net <- graph.data.frame(links, nodes, directed=F)
### remove edges below a given weight from network
net.sp <- delete.edges(net, E(net)[weight<=5])
### get edge list
e <- get.edgelist(net.sp,names=FALSE)
### set colors for nodes
colrs <- c("blue", "green","red")
V(net.sp)$color <- colrs[V(net.sp)$type.num]
### define layout
l <- qgraph.layout.fruchtermanreingold(e,vcount=vcount(net.sp),
                                       area=8*(vcount(net.sp)^2),repulse.rad=(vcount(net.sp)^3.1))
### plot network
plot(net.sp, layout=l,edge.arrow.mode = 0,vertex.label=NA,vertex.size=7)
### add legend
legend(x=-1.5, y=-1.1, c("Type 1","Type 2"), pch=21,
       col="#777777", pt.bg=colrs, pt.cex=2, cex=.8, bty="n", ncol=1)
### add title
title(main = "Title")

###
##### de novo community detection algorithms (uncomment to use any/all)
###
# 
# wtc <- cluster_walktrap(net.sp)
# plot(wtc, net.sp,layout=l,edge.arrow.mode = 0,vertex.label=NA,vertex.size=7)
# 
# fc <- cluster_fast_greedy(net.sp)
# plot(fc, net.sp,layout=l,edge.arrow.mode = 0,vertex.label=NA,vertex.size=7)
# 
# lec <- cluster_leading_eigen(net.sp)
# plot(lec, net.sp,layout=l,edge.arrow.mode = 0,vertex.label=NA,vertex.size=7)
# 
# ceb <- cluster_edge_betweenness(as.undirected(net.sp))
# plot(ceb, net.sp,layout=l,edge.arrow.mode = 0,vertex.label=NA,vertex.size=7)

########################################################################
######################################################################## Clear
########################################################################
# clear plots
dev.off()
# close conections
closeAllConnections()
# remove variables/clear space
rm(list=ls())

