#! Strawberry/perl

###
### Run a RNAmountAlign in batch using an input fasta file
##### run on the server (unless local machine has RNAmountAlign installed)
##### takes two files on the command line: and input and an output file	
######## usage: perl RNAmountAlign_batch.pl infile outfile

use strict;
use warnings;


my $file = $ARGV[0];

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
my $tmp_file = "RNAmountAlign_tmp.txt";
my $counter = 0;
foreach my $entry (@seq_entries)
{
	next	if(!$entry);
	$counter++;
	print "$counter\n"	if($counter % 10 == 0);
	my ($tag,$seq) = split /\n/, $entry;	
	$done{$tag} = 1;
	foreach my $c_entry (@seq_entries)
	{
		next	if(!$c_entry);
		my ($c_tag,$c_seq) = split /\n/, $c_entry;	
		next	if(exists($done{$c_tag}));
		
		open(my $TMP,">", $tmp_file) or die $!;
		print $TMP ">$tag\n$seq\n>$c_tag\n$c_seq\n";
		close $TMP;	
		my $RNAmountAlign_val = qx{RNAmountAlign -format fasta -f $tmp_file};
		#RNAmountAlign -format fasta -f test.fa
		push @output, "$tag\n$seq\n$c_tag\n$c_seq\n$RNAmountAlign_val";	
	}
}
qx{rm $tmp_file};

my $file1 = $ARGV[1];
open(my $OUT,">", $file1) or die $!;
foreach my $out (@output){
	my $output = $out;
	$output =~ s/^.*#PARAMETERS/\n#PARAMETERS/s;
	print $OUT "$output\n//\n";
	#my ($tmp,$params,$scale,$score,$align) = $out;
	#print $OUT "#$params\n$scale\n#$score\n#$align\n//\n";
}
close $OUT;

print "DONE!\n";




