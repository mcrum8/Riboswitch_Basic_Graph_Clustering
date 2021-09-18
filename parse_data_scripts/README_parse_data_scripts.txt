parse_data_scripts README

The parse_data_scripts directory contains scripts for parsing the output from the batch_metric_scripts.

INPUT: accepts input files generate from corresponding batch_metic_script (ie: RNAmountAlign batch script output pairs with RNAmountAlign parse script)
OUTPUT: generated a Nodes.csv and Edges.csv file that can be used to generate networks for graph clustering

Format for all scripts: perl [parse_script].pl [batch_parse_script_output] [Nodes_file_output] [Edge_file_output]
	ex: perl parse_RNAmountAlign_output_for_network_data.pl datafile.out Nodes.csv Edges.csv

NOTE: Default parser parameters assume tag is formatted as "acc/start-stop/type". This can be easily modified by modifying the split and adding appropriate code add elements to IDs for nodes/edges files.
NOTE: The batch_metric_scripts and parse_data_scripts can be piped together to be run in one command-line command. However, they are provided as distinct scripts in case a user wants the raw batch_metric_script data for other purposes.