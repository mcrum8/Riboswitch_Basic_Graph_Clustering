#! Strawberry/perl

###
### Run Dynalign in batch using an input fasta file
##### run on the server (unless local machine has Dynalign installed)
##### takes two files on the command line: and input and an output file	
######## usage: perl Dynalign_batch.pl infile outfile

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
my $fa1_file = "fasta1.fa";
my $fa2_file = "fasta2.fa";
my $out1_file = "out1.tab";
my $out2_file = "out2.tab";
my $out_ali_file = "out.ali.tab";
my $config_file = "dynalign_config.tmp";

### create config file
open(my $TMP,">", $config_file) or die $!;
print $TMP "inseq1 = $fa1_file
inseq2 = $fa2_file
outct = $out1_file
outct2 = $out2_file
aout = $out_ali_file
num_processors = 8";
close $TMP;	

my $counter = 0;
print STDERR localtime(time) . "\n";
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
		
		### print sequences into fasta files
		#qx{$entry > $fa1_file} or die $!;
		#qx{$c_entry > $fa2_file} or die $!;
		open(my $TMP,">", $fa1_file) or die $!;
		print $TMP "$seq\n";
		close $TMP;	
		open($TMP,">", $fa2_file) or die $!;
		print $TMP "$c_seq\n";
		close $TMP;
		
		qx{/home/crumm/RNAstructure/exe/dynalign_ii-smp $config_file} or die $!;
		
		open(my $IN,"<", $out_ali_file) or die $!;
		my $out_data = "";
		{
			$/ = undef;
			$out_data = <$IN>;
		}
		close $IN;
		
		my $ali_score = $1	if($out_data =~ m/Alignment #1 Score=\s+(.*?)\s+/si);
		push @output, "$tag\n$seq\n$c_tag\n$c_seq\n$ali_score";	
	}
}
print STDERR localtime(time) . "\n";

qx{rm $fa1_file} ;
qx{rm $fa2_file} ;
qx{rm $out1_file} ;
qx{rm $out2_file} ;
qx{rm $out_ali_file} ;
qx{rm $config_file} ;


open(my $OUT,">", $file1) or die $!;
foreach my $out (@output){
	print $OUT "$out\n//\n";
}
close $OUT;






