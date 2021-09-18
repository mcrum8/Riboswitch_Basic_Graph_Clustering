#! Strawberry/perl

###
### Run a FoldAlign in batch using an input fasta file
##### run on the server (unless local machine has FoldAlign installed)
##### takes two files on the command line: and input and an output file	
######## usage: perl RNApdist_batch.pl infile outfile

use strict;
use warnings;


my $file = $ARGV[0];
my $file1 = $ARGV[1];

if(!$file1){
	print STDERR "Please enter an output file title\n";
	exit;
}

open(my $IN,"<", $file) or die $!;

my $temp = "";
{
	$/ = undef;
	$temp = <$IN>;
}

close $IN;

my @seq_entries = split />/,$temp;
my %done = ();
my @output = ();
my $counter = 0;
my $counter1 = 0;
print STDERR localtime(time) . "\n";
#my $FoldAlign_val = qx{/home/crumm/foldalign/bin/foldalign -global -output_format stockholm $file $file};

foreach my $entry (@seq_entries)
{
	next	if(!$entry);
	$counter++;
	#print STDERR "$counter\n";
	print "$counter\n"	if($counter % 10 == 0);
	my ($tag,$seq) = split /\n/, $entry;	
	$done{$tag} = 1;
	my $counter_in = 1;
	#print STDERR "\t";
	foreach my $c_entry (@seq_entries)
	{
		next	if(!$c_entry);
		my ($c_tag,$c_seq) = split /\n/, $c_entry;	
		next	if(exists($done{$c_tag}));

		#my $FoldAlign_val = qx{/home/crumm/foldalign/bin/foldalign -format commandline -global -output_format stockholm $seq $c_seq};
		### use -np_pruning for the global alignments (suggested when error for no global alignments were thrown when not using it)
		#my $FoldAlign_val = qx{/home/crumm/foldalign/bin/foldalign -no_pruning -format commandline -global -output_format stockholm $seq $c_seq};
		my $FoldAlign_val = qx{/home/crumm/foldalign/bin/foldalign -number_of_processors 8 -no_pruning -format commandline -global -output_format stockholm $seq $c_seq};


		#my $FoldAlign_val = qx{/home/crumm/foldalign/bin/foldalign -format commandline -output_format stockholm $seq $c_seq};

		#print STDERR "$counter1 ";
		$counter1++;
		#my $FoldAlign_val = `foldalign -format commandline -global -output_format stockholm $seq $c_seq`;
		push @output, "$tag\n$seq\n$c_tag\n$c_seq\n$FoldAlign_val";	
		#print STDERR "$counter_in ";
		$counter_in++;
	}
	#print STDERR "\n";
}

print STDERR localtime(time) . "\n";

open(my $OUT,">", $file1) or die $!;
foreach my $out (@output){
	print $OUT "$out\n";
}
#print $OUT $FoldAlign_val;
close $OUT;






