library(igraph)
library(qgraph)

########
#####
### parametric bootstrapping through perturbation, followed by jaccard similarity index calculation and averaging across all bootstrap reps
####
#######

###
### Network Building
###

### define network threshold 
net_thresh = 5;

### node to seed group identification
node_num = 1;

### set working directory
setwd("/Users/name/Desktop/sample/path/")
### pull nodes file from working directory
nodes <- read.csv("Nodes.csv", header=T, as.is=T)
### pull edges file from working directory
links <- read.csv("Edges.csv", header=T, as.is=T)
### create framework for network
net <- graph.data.frame(links, nodes, directed=F)
### remove edges below a given weight from network
net.sp <- delete.edges(net, E(net)[weight<=net_thresh])
### get edge list
e <- get.edgelist(net.sp,names=FALSE)
### define layout
l <- qgraph.layout.fruchtermanreingold(e,vcount=vcount(net.sp),
                                       area=8*(vcount(net.sp)^2),repulse.rad=(vcount(net.sp)^3.1))

### community detection on original network (ceb can take a while on large datasets, feel free to comment it out if it is not needed)
wtc <- cluster_walktrap(net.sp)
fc <- cluster_fast_greedy(net.sp)
lec <- cluster_leading_eigen(net.sp,options=list(maxiter=100000))
ceb <- cluster_edge_betweenness(as.undirected(net.sp))

### create matrix for holding memberships after community detection
wtc_mat <- wtc$membership
fc_mat <- fc$membership
lec_mat <- lec$membership
ceb_mat <- ceb$membership

### get values for bootstrapping (5% perturbation --> 2.5% added and 2.5% removed)
pert_perc = .05
total_edges = length(links$weight)
num_edges = length(E(net)[weight>net_thresh]) # <--- NEEDS TO BE MODIFIED FOR DIFFERENT METRICS (change ">" to "<" depending on increasing or decreasing metric)
num_perturbed = round(num_edges* (pert_perc/2))

### parametric bootstrapping through perturbation replicates
bootstraps = 100
for (rep in 1:bootstraps) {
  # reset links to original 
  links <- read.csv("Edges.csv", header=T, as.is=T)
  
  # add edges loop
  add_counter = 0
  while (add_counter < num_perturbed) {
    edge_element = sample(1:total_edges, 1)
    if (links$weight[edge_element] <= net_thresh) { # <--- NEEDS TO BE MODIFIED FOR DIFFERENT METRICS
      links$weight[edge_element] = 50
      add_counter = add_counter + 1
    }
  }
  #remove edges loop
  rem_counter = 0
  while (rem_counter < num_perturbed) {
    edge_element = sample(1:total_edges, 1)
    if (links$weight[edge_element] > net_thresh) { # <--- NEEDS TO BE MODIFIED FOR DIFFERENT METRICS
      links$weight[edge_element] = -50
      rem_counter = rem_counter + 1
    }
  }
  
  ### set network using newly modified links
  net <- graph.data.frame(links, nodes, directed=F)
  net.sp <- delete.edges(net, E(net)[weight<=net_thresh]) # <--- NEEDS TO BE MODIFIED FOR DIFFERENT METRICS
  
  ### perform community detection on new network
  ### community detection on original network
  wtc <- cluster_walktrap(net.sp)
  fc <- cluster_fast_greedy(net.sp)
  lec <- cluster_leading_eigen(net.sp,options=list(maxiter=1000000))
  ceb <- cluster_edge_betweenness(as.undirected(net.sp))
  
  ### store community detection data
  wtc_mat <- rbind(wtc_mat, wtc$membership)
  fc_mat <- rbind(fc_mat, fc$membership)
  lec_mat <- rbind(lec_mat, lec$membership)
  ceb_mat <- rbind(ceb_mat, ceb$membership)
}

###
## jaccard index calcutation for given set
###
### calculate average wtc jaccard similarity
wtc_vector <-vector()
group = wtc_mat[1,node_num]   #get group that node is a part of
### get all elements with value of group using which and make a vector of the element numbers
orig_cluster = which(wtc_mat[1,]==group, arr.ind=TRUE)
### loop through nodes in original cluster and get jaccard distance for group they are part of after bootstrap
for (element in orig_cluster) {
  wtc_jsim <- vector()
  ## loop through and get jaccard value between bootstrap groupings and initial grouping
  for (wtc_boot in 2:nrow(wtc_mat)) {
    boot_group = wtc_mat[wtc_boot,element]
    boot_cluster = which(wtc_mat[wtc_boot,]==boot_group, arr.ind=TRUE)
    jaccard_index = length(intersect(boot_cluster,orig_cluster))/length(union(boot_cluster,orig_cluster))
    wtc_jsim <- c(wtc_jsim, jaccard_index)
  }
  wtc_avg_jsim = mean(wtc_jsim)
  wtc_vector <- c(wtc_vector,wtc_avg_jsim)
}

### calculate average fc jaccard similarity
fc_vector <-vector()
group = fc_mat[1,node_num]   #get group that node is a part of
### get all elements with value of group using which and make a vector of the element numbers
orig_cluster = which(fc_mat[1,]==group, arr.ind=TRUE)
### loop through nodes in original cluster and get jiccard distance for group they are part of after bootstrap
for (element in orig_cluster) {
  fc_jsim <- vector()
  ## loop through and get jaccard value between bootstrap groupings and initial grouping
  for (fc_boot in 2:nrow(fc_mat)) {
    boot_group = fc_mat[fc_boot,element]
    boot_cluster = which(fc_mat[fc_boot,]==boot_group, arr.ind=TRUE)
    jaccard_index = length(intersect(boot_cluster,orig_cluster))/length(union(boot_cluster,orig_cluster))
    fc_jsim <- c(fc_jsim, jaccard_index)
  }
  fc_avg_jsim = mean(fc_jsim)
  fc_vector <- c(fc_vector,fc_avg_jsim)
}

### calculate average lec jaccard similarity
lec_vector <-vector()
group = lec_mat[1,node_num]   #get group that node is a part of
### get all elements with value of group using which and make a vector of the element numbers
orig_cluster = which(lec_mat[1,]==group, arr.ind=TRUE)
### loop through nodes in original cluster and get jiccard distance for group they are part of after bootstrap
for (element in orig_cluster) {
  lec_jsim <- vector()
  ## loop through and get jaccard value between bootstrap groupings and initial grouping
  for (lec_boot in 2:nrow(lec_mat)) {
    boot_group = lec_mat[lec_boot,element]
    boot_cluster = which(lec_mat[lec_boot,]==boot_group, arr.ind=TRUE)
    jaccard_index = length(intersect(boot_cluster,orig_cluster))/length(union(boot_cluster,orig_cluster))
    lec_jsim <- c(lec_jsim, jaccard_index)
  }
  lec_avg_jsim = mean(lec_jsim)
  lec_vector <- c(lec_vector,lec_avg_jsim)
}

### calculate average ceb jaccard similarity
ceb_vector <-vector()
group = ceb_mat[1,node_num]   #get group that node is a part of
### get all elements with value of group using which and make a vector of the element numbers
orig_cluster = which(ceb_mat[1,]==group, arr.ind=TRUE)
### loop through nodes in original cluster and get jaccard distance for group they are part of after bootstrap
for (element in orig_cluster) {
  ceb_jsim <- vector()
  ## loop through and get jaccard value between bootstrap groupings and initial grouping
  for (ceb_boot in 2:nrow(ceb_mat)) {
    boot_group = ceb_mat[ceb_boot,element]
    boot_cluster = which(ceb_mat[ceb_boot,]==boot_group, arr.ind=TRUE)
    jaccard_index = length(intersect(boot_cluster,orig_cluster))/length(union(boot_cluster,orig_cluster))
    ceb_jsim <- c(ceb_jsim, jaccard_index)
  }
  ceb_avg_jsim = mean(ceb_jsim)
  ceb_vector <- c(ceb_vector,ceb_avg_jsim)
}

### maximum of every node in groups average jaccard sim index across 100 bootstraps
#### Returns to average Jaccard Sim Index for the node in the group which had the highest average after bootstrapping
###### This ensures the best grouping is chosen to represent the Jaccard Sim Index, not one based on a more periphery node
max(wtc_vector)
max(fc_vector)
max(lec_vector)
max(ceb_vector)

### mean of every node in groups average jaccard sim index across 100 bootstraps
#### Returns to average Jaccard Sim Index across all nodes in the group after the bootstrapping
##### This could be distorted by periphery nodes that have lower sim to core group
#mean(wtc_vector)
#mean(fc_vector)
#mean(lec_vector)
#mean(ceb_vector)