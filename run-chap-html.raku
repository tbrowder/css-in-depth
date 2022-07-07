#!/usr/bin/env raku

use lib <./lib>;
use Subs; 

my $host = %*ENV<HOST> // "unk";

my $is-run-host = $host eq 'juvat3' ?? True !! False;

if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <mode> <key> [debug]

    Modes
        show <chapter> - (where chapter is 1..16, shows the
                         listing numbers in the selected chapter)
               
        get <list-num> - (where list-num is the listing number from
                         one of the chapters)
                         runs the selected listing's html file with
                         Firefox

    On host 'juvat3' only, runs one of the 'CSS in Depth' listings in chapters 1-16.

    See example 6.9 as one of the most promosing for the GBUMC Online Directory.
    HERE
    exit;
}

if not $is-run-host {
    say "NOTE: This is not host 'juvat3', it's '$host'...exiting.";  exit;
}

my $debug = 0;
my $show  = 0;
my $chap; # show key
my $get  = 0;
my $list-num; # listing key

for @*ARGS {
    when /^ d [ebug]? / {
        ++$debug;
    }
    when /^ s [how]? / {
        ++$show;
    }
    when /^ g [et]? / {
        ++$get;
    }
    when /^ (\d+) $/ {
        $chap = +$0;
    }
    when /^ (\d+) '.' (\d+) $/ {
        my $c = +$0;
        my $n = +$1;
        $list-num = $c ~ '.' ~ $n;
        say "DEBUG: list-num: '$list-num'" if $debug;
    }
    default {
        die "Unknown arg '$_'";
    }
}

if not (($show and $chap.defined) or ($get and $list-num.defined)) {
    note q:to/HERE/;
        FATAL:
        You must enter either 'show' and a chapter number
        or 'get' and a listing number (m.n).
        HERE
    exit;
}

if $show and $chap.defined {
    my @list = show-listings :$chap, :$debug;
    say "Chapter $chap listings:";
    say "  $_" for @list;
    exit;
}

die "FATAL: Unexpected!!" if not ($get and $list-num.defined);

my $fil = get-listing :$list-num, :$debug;
say "DEBUG: \$fil = '$fil'" if $debug;

# make sure there is a DISPLAY env var defined
unless %*ENV<DISPLAY>:exists  {
    note "FATAL: No DISPLAY defined (you must be at juvat3's desktop)."; exit;
}

# execute
shell "/bin/firefox file://$fil";
