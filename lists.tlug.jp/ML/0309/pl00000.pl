#!/usr/bin/perl

use strict;

#Each entry consists of a tab seperated list:
#
#   1. A Unique ID
#   2. An English lemma (obligatory)
#   3. One or more English parts of speech (obligatory)
#   4. Unparsed free elements in pre-position (optional)
#   5. Korean translation/explanation OR English Equivalent (obligatory)
#      Spell out of English abbreviations OR
#      pointer to other entry "=ENGLISH"
#   6. Korean word in Chinese Characters (optional)
#   7. Korean unparsed free elements in post-position (optional)
#   8. Meta information as a list of attribute value pairs (optional) 

my %dict;

while(<STDIN>) {

    chomp;
    my ($id, $lemma, $speech, $free1, $korean, $kanji, $free2, $attr) = split('\t');

    next if ($korean =~ /.* .*/); #gjiten compatibility

    my $out = '';

    $out .= $korean;
    $out .= " [$kanji]" if ($kanji ne '');
    $out .= " /";

    $out .= "($dspeech) " if ($speech ne '');
    $out .= $lemma;
    $out .= " ($free2)" if ($free2 ne '');
    $out .= " [$attr]" if ($attr ne '');
    $out .= "/";

    print "$out\n";
}
