#! Strawberry/perl

use strict;
use warnings;
#use LWP::Simple;

### Purpose
### Go the output of the DynAlign batch script output and format it for network data

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

my @entries = split /\/\//,$temp;

my @edges = ("from,to,weight");
my %nodes = ();
my %type_type_hash = ();
my $type_inc = 1;
foreach my $results (@entries)
{
	next	if(!$results);
	$results =~ s/^\n+//;
	### get score for alignment and tags
	my @lines = split /\n/, $results;	
	my $tag1 = $lines[0];
	my $tag2 = $lines[2];
	my $score_value = $lines[4];
	next	if(!$score_value);
	
	#print STDERR "$tag1\t$tag2\t$score_value\n";
	
	### parse tags to get specific type
	my ($acc1,$start_end1,$type1) = split /\//, $tag1;
	my ($acc2,$start_end2,$type2) = split /\//, $tag2;
	
	### set type
	my $type_type1 = 1;	
	my $type_type2 = 1;	
	### check what type types are present and record what integer they are represented by in the nodes hash
	if(exists($type_type_hash{$type1})){
		$type_type1 = $type_type_hash{$type1};
	}else{
		$type_type_hash{$type1} = $type_inc++;
		$type_type1 = $type_type_hash{$type1};
	}
	if(exists($type_type_hash{$type2})){
		$type_type2 = $type_type_hash{$type2};
	}else{
		$type_type_hash{$type2} = $type_inc++;
		$type_type2 = $type_type_hash{$type2};
	}
	
	### generate IDs
	my $id1 = "$acc1/$start_end1/$type1";
	my $id2 = "$acc2/$start_end2/$type2";

	push @edges, "$id1,$id2,$score_value";
	if(!exists($nodes{$tag1}))
	{
		$nodes{$tag1} = "$id1,$type1,$type_type1";
	}
	if(!exists($nodes{$tag2}))
	{
		$nodes{$tag2} = "$id2,$type2,$type_type2";
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
