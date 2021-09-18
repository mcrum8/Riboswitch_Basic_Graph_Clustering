parse_data_scripts README

The batch_metic_scripts directory contains scripts for taking in fasta files and getting pariwise distance scores based on a range of metrics.

INPUT: fasta file (the default parse scripts assume the tage is in "acc/start-stop/type" format, but that can be modified in the parse scripts).
OUTPUT: output file containing raw pairwise output from given distance metric tool

Format for all scripts: perl [batch_parse_script].pl [fasta_input] [raw_output]
	ex: perl RNAmountAlign_batch.pl infile.fa outfile.out

NOTE: The default parse scripts assume the tage is in "acc/start-stop/type" format, but that can be modified in the parse scripts.
NOTE: The batch_metric_scripts and parse_data_scripts can be piped together to be run in one command-line command. However, they are provided as distinct scripts in case a user wants the raw batch_metric_script data for other purposes.