network_generation README

The network_generation directory contains scripts for taking pariwise distance data and generating networks for graph clustering.

There are 4 scripts in this directory:
1) Network_builder.R --> general builder that takes in Nodes.csv and Edges.csv files and creates a network

2) Jaccard_sim_index.R --> analysis script for getting Jaccard Similarity Index for a given cluster in a given network

3) network_data_between_group_density_parser.pl --> takes in Nodes.csv and Edges.csv and spits out file for network density graph generation

4) Network_density_line_graph_generator.R --> generates network density graphs based on edges density (can use network_data_between_group_density_parser.pl or generate own values)
	- You need to assign thresholding parameters at the top of the script that fit your analysis