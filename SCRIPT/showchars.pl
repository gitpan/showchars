#! /usr/local/bin/perl


#################################################################################
#										#
#  										#
#   Showchars v.0.1							       	#
#   Copyright (C) 2004 - Steven Schubiger <steven@accognoscere.org>		#
#   Last changes: 14th November 2004						#
#										#
#   This program is free software; you can redistribute it and/or modify	#
#   it under the terms of the GNU General Public License as published by	#
#   the Free Software Foundation; either version 2 of the License, or		#
#   (at your option) any later version.						#
#										#
#   This program is distributed in the hope that it will be useful,		#
#   but WITHOUT ANY WARRANTY; without even the implied warranty of		#
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the		#
#   GNU General Public License for more details.				#
#										#
#   You should have received a copy of the GNU General Public License		#
#   along with this program; if not, write to the Free Software			#
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA	#
#										#
#										#
#################################################################################




use strict;
use vars qw($VERSION $NAME);

our ($file,
     $item,
     %Options,
     %table);

use Getopt::Long;

$VERSION = '0.1';
$NAME = 'Showchars';

$item = '#';


&parse_arguments();
&read_file;
&output_header;
&output_bargraph;


sub parse_arguments {
    $Getopt::Long::autoabbrev = 0; # disable arguments abbreviations
    $Getopt::Long::ignorecase = 0; # case-sensitive evaluation of arguments
    # parse arguments
    &GetOptions (\%Options, 'h', 'v', 'V', 'infile=s') or $Options{'h'} = 1;
    $Options{h} = 1 if $#ARGV > 0; # reluctant arguments detected, set help mode


    HELP:
    if ($Options{h} or $Options{V}) {
        if ($Options{h}) {
            print << "HELP"; # usage and options output
Usage: $0 [options] --infile=<name>
 -h                this help screen
 -V                display version info
 --infile=<name>   input file
HELP
        } 
        else {
            print << "VERSION";
 $main::NAME $main::VERSION
VERSION
        }
    
    exit (0);

    }

    if (length $Options{infile} == 0) { # file in argument missing, output notice message
        print qq~Option infile required\n~;
        $Options{h} = 1;
        goto HELP;
    }
}


sub read_file {
    open FILE, "<$Options{infile}" or die "Could not open $Options{infile}: $!\n";
    while (<FILE>){
        chomp;
        my @chars = split (//);

        foreach (@chars) {
            next if $_ !~ /\w+/;
            $table{$_}++;
        }
    }
    close FILE or die "Could not close <$Options{infile}: $!\n";
}


sub output_header {
    foreach (sort keys %table) {
        print "$_ ";
    }
    print "\n";

    my $u_line = keys %table;
    while ($u_line--) { print '= ' }
    print "\n";
}


sub output_bargraph {
    my ($count, $lastrun);

    while ($count || !$lastrun) {
        foreach (sort keys %table) {
            if ($table{$_}) {
                print "$item ";
                $table{$_}--;
            } 
            else { print '  ' }
        }
        print "\n";

        $lastrun = 1 if $count == 0;

        $count = 0;
        my @values = values %table;
        foreach (@values) { $count += $_ }
    }
}

