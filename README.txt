README.txt

NOTE: Default script parameters assume a faster file with tags formatted as "acc/start-end/type"
NOTE: To run batch_metric_scripts, the tools must be installed for your use in the command-line

This script repository is broken into a few directories:
1) batch_metric_scripts --> used for generating pairwise distance data for various metrics
2) network_generation   --> used for generating networks based on pairwise distance metrics
3) parse_data_scripts   --> used for parsing batch_metric_scripts output

TUTORIAL: This will take you from using the supplied fasta.fa to get pairwise distances based on the RNAmountAlign metric and generated networks and graphs with the preset parameters wittin the script.
1) Running RNAmountAlign to get pairwise distance for all entries in fasta.fa
	Run --> perl RNAmountAlign_batch.pl tutorial.fa tutorial.RNAmountAlign.out
		- Takes in fasta file (tutorial.fa) and export output file (tutorial.RNAmountAlign.out)
2) Parsing output file from RNAmountAlign runs to get the Nodes.csv and Edges.csv for use in network generation
	Run --> perl parse_RNAmountAlign_output_for_network_data.pl tutorial.RNAmountAlign.out Nodes.csv Edges.csv
		- Takes in output from batch script (tutorial.RNAmountAlign.out) and exports Nodes.csv and Edges.csv files
3) Generate network using Nodes.csv and Edges.csv files
	Run --> Network_builder.R
		- Takes in Nodes.csv and Edges.csv (set the working directory path to them for easy access) and generates network
		- Saved network as PDF (tutorial.network.pdf)
	Optional: At the end of the script are some lines of code to visualize the different community detection methods, uncomment them for use
		- Saved community detection output as PDF (tutorial.network.cluster_fast_greedy.pdf)
			- This is an interesting example, as two sub communities can seen within the Type1 group.
4) Perform Jaccard Sim Index bootstrapping analysis on desired group in network
	Run --> Jaccard_sim_index.R
		- Takes in Nodes.csv and Edges.csv (set the working directory path to them for easy access) and generates network
			- Use same thresholding parameters as used in the network that you want to analyze
		- Saved Jaccard Similarity Index values (tutorial.network.JSI.txt)
5) Create network density graph representing subgroups within your network
	Run --> perl network_data_between_group_density_parser.pl Nodes.csv Edges.csv > [outputfile]
		- Need to run 3 times, with different "target_type1" and "target_type2" values corresponding to type.num in the Nodes.csv file
			1: Saved file as --> tutorial.networkDensity.type1.csv
				target_type1 = "1"
				target_type2 = "1"
			2: Saved file as --> tutorial.networkDensity.type2.csv
				target_type1 = "2"
				target_type2 = "2"
			3: Saved file as --> tutorial.networkDensity.type1_vs_2.csv
				target_type1 = "1"
				target_type2 = "2"
	Run --> Network_density_line_graph_generator.R
		- Takes output files from network_data_between_group_density_parser.pl (set the working directory path to them for easy access) and generates density graph
			- The output from network_data_between_group_density_parser.pl is just a csv, you cna generate your own if desired
		- Saved as PDF (tutorial.densityGraph.pdf)