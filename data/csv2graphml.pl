#!/usr/bin/perl

use List::MoreUtils qw(uniq);

print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print "<graphml xmlns=\"http://graphml.graphdrawing.org/xmlns\"\nxmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\nxsi:schemaLocation=\"http://graphml.graphdrawing.org/xmlns\nhttp://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd\">\n";
print "<graph id=\"G\" edgedefault=\"directed\">\n";
print "<key id=\"d0\" for=\"edge\" attr.name=\"weight\" attr.type=\"double\"/>\n";
print "<key id=\"d1\" for=\"node\" attr.name=\"AS\" attr.type=\"double\"/>\n";

my @aslist;

open (FILE, $ARGV[0]);

while (<FILE>) {
    my $line = $_;
    chomp;
#    if ($line =~ m/^(\d+)\|(\d+)\|(-?\d+)$/) {
    if ($line =~ m/^(\d+),(\d+),(-?\d+)$/) {
#    print "$name $1\n";
    $asn1 = $1;
    $asn2 = $2; 
    print "$asn1,$asn2,$3\n";

    print "\t<edge directed=\"true\" source=\"n$asn1\" target=\"n$asn2\">\n";
    print "\t\t<data key=\"d0\">$3</data>\n";
    print "\t</edge>\n";

    push @aslist,$asn1;
    push @aslist,$asn2;

    } else {
        print STDERR $line;
    }  
}

my @unique_aslist = uniq @aslist;

foreach $asn(@unique_aslist) {
print "\t<node id=\"n$asn\">\n";
print "\t\t<data key=\"d1\">$asn</data>\n";
print "\t</node>\n";
}
print "</graph>\n";
print "</graphml>";
close (FILE);
exit;
