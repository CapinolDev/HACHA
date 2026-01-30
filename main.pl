#!/usr/bin/perl
use strict;
use warnings;

my $filename = shift;

my $outputFilename = "a"; 
my $progStarted = 0;
my $currentProg = "";
my @lineParts;
my @tempOFileGen;
open(my $fh, '<',$filename) or die "no file $filename found!\n";
@tempOFileGen = split(/\./,$filename);
$outputFilename = $tempOFileGen[0] . ".f95";
print("Output: $outputFilename\n");
open(my $fh2, '>',$outputFilename) or die "couldnt create file $outputFilename/n";


while (my $line = <$fh>) {
	chomp($line);
    if ($line eq "") {
		next
		}
	
	$line =~ s/^\s+//;
	$line =~ s/\s+$//;
	next if $line eq "";
	$line =~ tr/a-z/A-Z/;
	@lineParts = split(' ', $line);
	{	
	if ($lineParts[0] eq "PROGRAM") {
			if ($lineParts[2] eq "START") {
				die "Program already started"if $progStarted;
				$progStarted = 1;
				$currentProg = $lineParts[1];
				print $fh2 "PROGRAM $currentProg\n";
				print $fh2 "IMPLICIT NONE\n"; }
				
			if ($lineParts[2] eq "END") {
				die "No program started!" unless $progStarted;
				unless ($lineParts[1] eq $currentProg) {
						die "Program $lineParts[1] not found.\n"; }
				$progStarted = 0;
				print $fh2 "END PROGRAM $currentProg\n";
			}
	}
	if ($lineParts[0] eq "DEF") {
		if ($lineParts[1] eq "INT") {
			print $fh2 "INTEGER :: $lineParts[2]\n";
			}
		elsif ($lineParts[1] eq "STR") {
			print $fh2 "CHARACTER(LEN=$lineParts[3]) :: $lineParts[2]\n";
			}
		elsif ($lineParts[1] eq "BOOL") {
			print $fh2 "LOGICAL :: $lineParts[2]\n";
			}
		elsif ($lineParts[1] eq "REAL") {
			print $fh2 "REAL :: $lineParts[2]\n";
			}
		else{
			die "ERR: Invalid type $lineParts[1]\n";
			}
		}
	if ($lineParts[0] eq "ARR") {
		if ($lineParts[1] eq "INT") {
			print $fh2 "INTEGER, DIMENSION($lineParts[3]) :: $lineParts[2]\n";
			}
		elsif ($lineParts[1] eq "REAL") {
			print $fh2 "REAL, DIMENSION($lineParts[3]) :: $lineParts[2]\n";
			}
		elsif ($lineParts[1] eq "CHAR") {
			print $fh2 "CHARACTER, DIMENSION($lineParts[3]) :: $lineParts[2]\n";
			}
		elsif ($lineParts[1] eq "BOOL") {
			print $fh2 "LOGICAL, DIMENSION($lineParts[3]) :: $lineParts[2]\n";
			}
		else {
			die "ERR: invalid type $lineParts[1]\n";
			}
		}
		
	
	}
	
}
close($fh)
