library(igraph)
library(qgraph)

###
### Density Graph Generation
###

### set working directory
setwd("/Users/name/Desktop/sample/path/")
### input csv files can come from network_data_between_group_density_parser.pl or be geneated yourself in another way
type1 <- read.csv(file = 'tutorial.networkDensity.type1.out', header = FALSE)
type2 <- read.csv(file = 'tutorial.networkDensity.type2.out', header = FALSE)
type1_type2 <- read.csv(file = 'tutorial.networkDensity.type1_vs_2.out', header = FALSE)

# make matrix with each lines data as a row
type_matrix <- rbind(type1,type2,type1_type2)
# get number of rows in matrix
num_lines <- nrow(type_matrix)

# set the range for the axes
xrange <- c(seq(-50, 50, 5))
yrange <- c(seq(0, 1, .1))

# set up the plot 
plot(1, type="n", xlim=c(-50, 50), ylim=c(0, 1), xlab="Threshold",
     ylab="Edge Density" ) 
colors <- c("blue","green","red") 
linetype <- rep(1:1,12)
plotchar <-  c(rep(1:6,2))

# add lines 
for (i in c(1:num_lines)) { 
  lines(xrange, type_matrix[i,], type="b", lwd=1.5,
        lty=linetype[i], col=colors[i], pch=plotchar[i]) 
}

# add a title 
title("Title")
# add a legend 
legend(54, 1.04, xjust =1, rownames(type_matrix), cex=.75, col=colors, 
       pch=plotchar, lty=linetype, title="Groups")
