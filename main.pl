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
		@lineParts = $line =~ /("[^"]*"|\S+)/g; 
		{	
		if ($lineParts[0] eq "PROGRAM") {
				if ($lineParts[2] eq "START") {
					die "Program already started"if $progStarted;
					$progStarted = 1;
					$currentProg = $lineParts[1];
					print $fh2 "PROGRAM $currentProg\n";
					print $fh2 "USE :: raylib\n";
					print $fh2 "USE, INTRINSIC :: iso_c_binding \n";
					print $fh2 "IMPLICIT NONE\n"; }
					
					
				if ($lineParts[2] eq "END") {
					die "No program started!" unless $progStarted;
					unless ($lineParts[1] eq $currentProg) {
							die "Program $lineParts[1] not found.\n"; }
					$progStarted = 0;
					print $fh2 "END PROGRAM $currentProg\n";
				}
		}
		elsif ($lineParts[0] eq "DEF") {
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
		elsif ($lineParts[0] eq "ARR") {
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
		elsif($lineParts[0] eq "SET") {
			print $fh2 "$lineParts[1] = $lineParts[2]\n";
			}
		elsif($lineParts[0] eq "PRINT") {
			if(substr($lineParts[1], 0, 1) eq "\"") {
				print $fh2 "WRITE(*,'(A)', ADVANCE='NO') $lineParts[1]\n";
				}
			else {
				print $fh2 "WRITE(*,'($lineParts[2])', ADVANCE='NO') $lineParts[1]\n";
				}
			}
		elsif($lineParts[0] eq "INPUT") {
				print $fh2 "READ(*,*) $lineParts[1]\n"
			}	
		elsif($lineParts[0] eq "NEWLINE") {
			print $fh2 "WRITE(*,*) \"\"\n";
			}
		elsif($lineParts[0] eq "AS"){
			print $fh2 "IF ($lineParts[1] $lineParts[2] $lineParts[3]) THEN\n";
			}
		elsif($lineParts[0] eq "AS}"){
			print $fh2 "END IF\n";
			}
		elsif($lineParts[0] eq "LOOP"){
			print $fh2 "DO\n";
			}
		elsif($lineParts[0] eq "LOOPEND"){
			print $fh2 "END DO\n";
			}
		elsif($lineParts[0] eq "DIE") {
			print $fh2 "CALL EXIT($lineParts[1]) \n";
			}
		elsif($lineParts[0] eq "DEFINE"){
			print $fh2 "CONTAINS\n";
			}
		elsif($lineParts[0] eq "SUBROUTE"){
			if($lineParts[1] eq "DEFINE") {
				print $fh2 "SUBROUTINE $lineParts[2]($lineParts[3])\n";
				}
			elsif($lineParts[1] eq "END") {
					print $fh2 "END SUBROUTINE $lineParts[2]\n";
			}		
			}
		elsif($lineParts[0] eq "ROUTE"){
			if($lineParts[1] eq "DEFINE") {
				print $fh2 "FUNCTION $lineParts[2]($lineParts[3])\n";
				}
			elsif($lineParts[1] eq "END") {
					print $fh2 "END FUNCTION $lineParts[2]\n";
			}		
			}
		elsif($lineParts[0] eq "INTO"){
			print $fh2 "CALL $lineParts[1]($lineParts[2])\n";
			}
		elsif($lineParts[0] eq "WINDOW"){
			if ($lineParts[1] eq "INIT") {
				print $fh2 "call init_window($lineParts[2], $lineParts[3], $lineParts[4] // c_null_char)\n";
				}
			elsif($lineParts[1] eq "DRAW") {
				print $fh2 "call begin_drawing()\n"
				}
			elsif($lineParts[1] eq "CLOSE") {
				print $fh2 "call close_window()\n";
				}
			}
		elsif($lineParts[0] eq "DRAWTEXT"){
			print $fh2 "call draw_text($lineParts[1] // c_null_char, $lineParts[2], $lineParts[3], $lineParts[4], $lineParts[5])\n";
			}
		elsif($lineParts[0] eq "BGCLEAR"){
			print $fh2 "call clear_background($lineParts[1])\n";
			}
		elsif($lineParts[0] eq "INITDRAW") {
			print $fh2 "call begin_drawing()\n";
			}
		elsif($lineParts[0] eq "ENDDRAW") {
			print $fh2 "call end_drawing()\n";
			}
		elsif($lineParts[0] eq "GAMELOOP") {
			print $fh2 "do while (.not. window_should_close())\n";
			}
		elsif($lineParts[0] eq "ALS"){
			if($lineParts[1] eq "KEY") {
				print $fh2 "IF (is_key_down(KEY_$lineParts[2])) then\n";
				}
			elsif($lineParts[1] eq "MOUSE") {
				print $fh2 "if (is_mouse_button_down(MOUSE_BUTTON_$lineParts[2])) then\n";
				}
			
			}
		else {
			die "Unknown command $lineParts[0]\n";
			}
		
		}
	}
	close($fh);
	
	my $modDir = "/home/erdinc/Downloads/fortran-raylib-0.2.0/build/gfortran_F713BEBFB294EE41";


	my $libDir = "/usr/local/lib"; 

	print "Compiling $outputFilename with gfortran..\n";
	my $exeName = $tempOFileGen[0];


	my $exitCode = system("gfortran", 
		$outputFilename, 
		"-I", $modDir, 
		"-L", $libDir, 
		"-lraylib", 
		"-o", $exeName
	);
	if ($exitCode == 0) {
		print "Compilation successful! Executable created: $exeName\n";
	} else {
		die "Compilation failed with exit code: $exitCode\n";
	}

