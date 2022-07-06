unit module Subs;

use Vars;

sub show-listings(Int :$chap! where { 0 < $_ < 17 }, :$debug) is export {
    # Chapter 10 is special, it has listings under a "docs" subdir
    # that have no numbers.
    my @list;
    for @fils {
        # ./ch07/listing-7.12.html
        when / ch (\d \d) / {
            my $c = ~$0;
            $c ~~ s/^0//;
            note "DEBUG: found chapter $c" if $debug;
            next if $c != $chap;
            @list.push: $_;
            # '/listing-' (\d+) '.' (\d+) '.html' / 
        }
    }
    @list.sort({.Str});
}

sub get-listing(:$list-num!, :$debug) is export {
    # ./ch07/listing-7.12.html
    my $fil; 
    if $list-num ~~ / (\d+) '.' (\d+) / {
        my $chap = +$0;
        if $chap == 10 {
            note "Unable to handle chap 10 yet"; exit;
        }

        my $list = +$1;
        my $ch   = $chap.chars == 1 ?? "0$chap" !! $chap;
        $fil = "./ch{$ch}/listing-{$chap}.{$list}.html";
    }
    else {
        die "FATAL: Unexpected listing number '$list-num'";
    }

    # least 1.
}
