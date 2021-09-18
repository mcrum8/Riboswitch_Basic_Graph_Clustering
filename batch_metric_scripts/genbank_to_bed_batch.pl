#! perl

use warnings;
use strict;
use Bio::SeqIO;

### Go through all genbank files loop
#my $dir = "/GBKs/RefSeq77bacteria";
my $dir = "../temp_stuff";
my $count = 0;
foreach my $gbk_path (glob("$dir/*.gbk")) {
    #my $acc = $1 if($gbk_path =~ m/\/([^\/]*?)\.gbk/si);
    my $seqio_object = Bio::SeqIO->new(-file => "$gbk_path",
                                       -format => "genbank" );
    #my $test = $seqio_object->next_seq;
    while (my $seq_object = $seqio_object->next_seq) {
	my $acc = $seq_object->accession;
	for my $feat_object ($seq_object->get_SeqFeatures) {
	    next if($feat_object->primary_tag ne "CDS");
	    my $start = $feat_object->location->start;
	    my $end = $feat_object->location->end;
	    my $strand = $feat_object->location->strand;
	    $strand = "-" if($strand eq "-1");
	    $strand = "+" if($strand eq "1");
	    next if(!$feat_object->has_tag("product"));
	    my @prod_array = $feat_object->get_tag_values("product");
	    my $product = shift @prod_array;
	    print "$acc\t$start\t$end\t$product\t0\t$strand\n";
	}
    }
    $count ++;
    print STDERR "$count\t" if($count % 100 eq 0);
}
