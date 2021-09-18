#! Strawberry/perl

###
### Purpose: parse pairwise percent identity matrix data from RNA/protein msa output (ex: muscle, clustal omega, etc.)
###		

use strict;
use warnings;

### enter files on command line
my $file = $ARGV[0];
my $nodes = $ARGV[1];
my $edges = $ARGV[2];

if(!$edges){
	print "Need file names for Nodes and Edges files\nExample:\tperl script.pl datafile.out Nodes.csv Edges.csv\n";
	exit;
}

open(my $IN,"<", $file) or die $!;

my $temp = "";
{
	$/ = undef;
	$temp = <$IN>;
}

close $IN;

my @data = split /\n/,$temp;

### variable for the number of seqs in matrix file that you want the pairwise data for
my $query_num = 0;
my $query_tag = "";

my @entries = ();
foreach my $line (@data){
	# skip if line begins with "#"
	next	if(!$line || $line =~ m/^#/);
	# split line and pull information using regex
	if($line =~ m/\s+(\d+):\s+(.*?)\s+(.*?)$/si){
		my $num = $1;
		my $tag = $2;
		my $values = $3;
		$num =~ s/\s+//g;
		$tag =~ s/\s+//g;
		push @entries, "$num\t$tag\t$values";
		$query_num++;
	}
}

# iterate through entries and generate node and entry data
my @edges = ();
my @nodes = ();
my %type_type_hash = ();
my $type_inc = 1;
foreach my $entry (@entries)
{
	my ($num,$tag,@values) = split /\s+/, $entry;

	$num =~ s/://g;

	### get tag info for this tag
	my ($acc,$start_end,$type) = split /\//, $tag;
	
	### check what type types are present and record what integer they are represented by in the nodes hash
	if(exists($type_type_hash{$type})){
		$type_type = $type_type_hash{$type};
	}else{
		$type_type_hash{$type} = $type_inc++;
		$type_type = $type_type_hash{$type};
	}
	
	my $id = "$acc/$start_end/$type";	
	
	push @nodes, "$id,$type,$type_type";
	for (my $i = $num+1; $i <= $query_num ; $i++){
  		push @edges, "$id,$ids{$i},$values[$i-1]";
	}
}

open(NODES,">", $nodes) or die $!;
print NODES "acc,type,type.num\n";
foreach my $key (sort keys %nodes)
{
	print NODES "$nodes{$key}\n";
}
close NODES;

open(EDGES,">", $edges) or die $!;
foreach my $key (sort keys %type_type_hash)
{
	#print EDGES "$key:\t$type_type_hash{$key}\n";
}
foreach my $edge (@edges)
{
	print EDGES "$edge\n";
}
close EDGES;
