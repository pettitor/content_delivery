#!/usr/bin/perl

open (FILE, $ARGV[0]);
while (<FILE>) {
    my $line = $_;
    chomp;
    if ($line =~ m/^(\d+)\|(\d+)\|(-?\d+)$/) {
#    print "$name $1\n";
    $asn1 = $1;
    $asn2 = $2; 
    print "$asn1,$asn2,$3\n";
    } else {
        print STDERR $line;
    }
}
close (FILE);
exit;
