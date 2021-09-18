#! Strawberry/perl

use strict;
use warnings;

### Purpose
### Go the output of the RNApdist_batch.pl script and format it for network data

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
foreach my $entry (@entries)
{
	next	if(!$entry);
	my $data = $entry;
	$data =~ s/^\n//;
	my ($tag1,$seq1,$tag2,$seq2,$pdist) = split /\n/, $data;
	next	if(!$pdist);

	my ($acc1,$start_end1,$type1) = split /\//, $tag1;
	my ($acc2,$start_end2,$type2) = split /\//, $tag2;

	
	### set type
	my $type_type1 = 1;
	my $type_type2 = 1;
	
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
		
	### set IDs
	my $id1 = "$acc1/$start_end1/$type1";
	my $id2 = "$acc2/$start_end2/$type2";

	push @edges, "$id1,$id2,$pdist";
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

