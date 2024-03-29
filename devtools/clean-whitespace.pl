#!/usr/bin/perl
use strict;
use FindBin qw($Bin);
chdir "$Bin/.." or die;

my @exempted = qw(Makefile.am ChangeLog doc/Makefile.am README README.md md5.c md5.h);
push(@exempted, glob("doc/*.xml"));
push(@exempted, glob("doc/*.full"));
push(@exempted, glob("doc/xml2rfc/*.xsl"));
push(@exempted, glob("m4/*backport*m4"));
my %exempted_hash = map { $_ => 1 } @exempted;

my @stuff = split /\0/, `git ls-files -z -c -m -o --exclude-standard`;
my @files = grep { ! $exempted_hash{$_} && $_ !~ m/^vendor\// } @stuff;

unless (@files) {
    warn "ERROR: You don't seem to be running this from a git checkout\n";
    exit;
}

foreach my $f (@files) {
    open(my $fh, $f) or die;
    my $before = do { local $/; <$fh>; };
    close ($fh);
    my $after = $before;
    $after =~ s/\t/    /g;
    $after =~ s/ +$//mg;
    $after .= "\n" unless $after =~ /\n$/;
    next if $after eq $before;
    open(my $fh, ">$f") or die;
    print $fh $after;
    close($fh);
}
