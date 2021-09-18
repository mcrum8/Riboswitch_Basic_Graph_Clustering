#! Strawberry/perl

###
### Purpose: parse Nodes.csv and Edges.csv files to get edge density within a group or between 2 groups across a thresholding range

use strict;
use warnings;

###
##### THRESHOLDING PARAMAETER DECLARATION (example for percent identity metric: 0% to 100% seq similarity in 5% increments)
######## NOTE: If lower values for your metric correspond to more similar pairs, 
###

### set threshold range minimum
my $min = -50; # RNAmountAlign
#my $min = 0; # Prot Ident
#my $min = 100; # RNApdist

### set threshold range maximum
my $max = 50; # RNAmountAlign
#my $max = 100; # Prot Ident
#my $max = 0; # RNApdist

### set threshold incrementation value
my $increment = 5; # RNAmountAlign
#my $increment = 1; # Fine-scale

### set threshold similarity direction (do higher or lower values correspond to more similar pairs)
my $direction = "Increasing";
#my $direction = "Decreasing"

### print parameters so user gets a visual check to verify parameters
print STDERR "Threshold Range:\t$min - $max\nIncrement Interval\t$increment\n";


###
##### THRESHOLDING PARAMAETER DECLARATION END
###

### Get nodes and edges .csv file
my $nodes = $ARGV[0];
my $edges = $ARGV[1];

###
##### extract data from files
###
open(my $IN,"<", $nodes) or die $!;
my $temp = "";
{
	$/ = undef;
	$temp = <$IN>;
}
close $IN;
my $network_nodes = $temp;

open($IN,"<", $edges) or die $!;
$temp = "";
{
	$/ = undef;
	$temp = <$IN>;
}
close $IN;
my $network_edges = $temp;

### split data from files
my @all_nodes = split /\n/,$network_nodes;
my @all_edges = split /\n/,$network_edges;

### set hash for nodes which fit parameters
my %nodes = ();
### set array for edges between nodes which fit parameters
my @edges = (); # holds all edge data
my @edge_weights = (); # holds just edge weights

### set parameters for clusters you are looking for (based on columns in Nodes.csv)
##### To get density between groups, set the target_type for each group
##### To get density within a group, set both target_types tp that group
my $target_type1 = "1";
my $target_type2 = "1";

### print visual confirmation of what groups are being compared
print STDERR "Edge density between group $target_type1 and $target_type2\n";

### get set of nodes and edges corresponding to desired parameters
foreach my $node (@all_nodes){
	### split nodes file based on column
	#### default format: acc,type,type_num
	#### Variable from this split can be used for matching to target_types declared above (default set to $type_num)
	my ($tag,$type,$type_num) = split /,/, $node;
	next	if($tag eq "acc");
	if($target_type1 ne $target_type2){
		$nodes{$tag} = 1	if($type_num eq $target_type1); # checks if chosen node element matche target_type1
		$nodes{$tag} = 2	if($type_num eq $target_type2); # checks if chosen node element matche target_type2
	}else{
		$nodes{$tag} = 1	if($type_num eq $target_type1);
	}
	
	### Uncomment this to get density of entire network 
	#$nodes{$tag} = 1; ### for accepting all nodes in network
}

foreach my $edge (@all_edges){
	my ($from,$to,$weight) = split /,/, $edge;
	next	if(!$to);
	next if(!exists($nodes{$from}) || !exists($nodes{$to}));
	
	if($target_type1 ne $target_type2){
		### used for getting edges between two groups
		push @edges,$edge if(($nodes{$from} == 1 && $nodes{$to} == 2) || $nodes{$from} == 2 && $nodes{$to} == 1);
		push @edge_weights,$weight if(($nodes{$from} == 1 && $nodes{$to} == 2) || $nodes{$from} == 2 && $nodes{$to} == 1);
	}else{
		### used for getting within edges for one group
		push @edges,$edge if($nodes{$from} == 1 && $nodes{$to} == 1);
		push @edge_weights,$weight	if($nodes{$from} == 1 && $nodes{$to} == 1);
	}
	### Uncomment for getting all edges in network
	#push @edges,$edge;
	#push @edge_weights,$weight;
}

### get number of edges (for reporting if desired
my $num_edges = @edges;
#print STDERR "$num_edges\n";

### get avg edge weight
my $avg = get_avg($num_edges,@edge_weights);

###
##### get network/cluster density for sliding set metric threshold
##### 	make sure to use appropriate sliding threshold for given metric in network_data.csv file (ex: seq sim, RNApdist. etc.)
###

### set density value holding arra
my @density_values = ();
my @density_csv = ();

### set threshold slider starting value
my $slider = $min;

### for increasing thresholds
#=pod
if($direction eq "Increasing"){
	while($slider <= $max){	# for increasing thresholds
		my $pass = 0;
		foreach my $edge (@edges){
			my ($from,$to,$weight) = split /,/, $edge;
			$pass++ if($slider <= $weight);	# for increasing thresholds
		}
		my $density = get_density($pass,$num_edges);

		push @density_values, "$slider\t$density";
		push @density_csv, $density;
		$slider += $increment;	# for increasing thresholds
	}
}elsif($direction eq "Decreasing"){
	while($slider >= $max){	# for decreasing thresholds
		my $pass = 0;
		foreach my $edge (@edges){
			my ($from,$to,$weight) = split /,/, $edge;
			$pass++ if($slider >= $weight);	# for decreasing thresholds
		}
		my $density = get_density($pass,$num_edges);

		push @density_values, "$slider\t$density";
		push @density_csv, $density;
		$slider -= $increment;	# for decreasing thresholds
	}
}else{
	print STDERR "Threshold direction is not set to Increasing or Decreasing. Unable to determine which direction to threshold.\n";
	exit;
}

## print density as comma separated line
print join( ',', @density_csv);
print "\n";


###
### Optional print statements for reporting data to command-line
###

### print targets
#print STDERR "$target_type1 vs $target_type2:\n";

### print average edge weight
#print "Avg\t$avg\n";

### print density values across threshold range
#foreach my $output (@density_values){
#	print "$output\n";
#}

### print edge weights as comma separated line
#print join( ',', @edge_weights);
#print "\n";

#######
### SUBROUTINES
#######

sub get_density
{
	my ($num,$total) = @_;
	my $density = $num/$total;
	return $density;
}

sub get_avg
{
	my ($num_edges,@values) = @_;
	my $total = 0;
	foreach my $value (@values)
	{
		$total += $value;
	}
	my $avg = $total/$num_edges;
	return $avg;
}
















