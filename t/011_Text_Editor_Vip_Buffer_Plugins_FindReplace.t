# -*- perl -*-

# t/002_load.t - check module loading and create testing directory

use strict ;

use Data::Hexdumper ;

use Test::More tests => 79 ;

BEGIN 
{
use_ok('Text::Editor::Vip::Buffer'); 
use_ok('Text::Editor::Vip::Buffer::Test'); 
}

#Find Forewards
#-------------------------------

my $buffer = Text::Editor::Vip::Buffer->new();
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Plugins::FindReplace') ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Test') ;

my $text = <<EOT ;
line 1 - 1
line 2 - 2 2
line 3 - 3 3 3
line 4 - 4 4 4 4
line 5 - 5 5 5 5 5
EOT

$buffer->Insert($text) ;

my ($match_line, $match_position, $match_word) ;
my $expected_text  ;

($match_line, $match_position, $match_word) = $buffer->FindOccurence(undef) ;
is($match_line, undef, 'Undef regex is ignored') ;

($match_line, $match_position, $match_word) = $buffer->FindOccurence('') ;
is($match_line, undef, 'empty regex is ignored') ;

($match_line, $match_position, $match_word) = $buffer->FindOccurence('cant_be_found') ;
is($match_line, undef, 'non matching regex is ignored') ;

($match_line, $match_position, $match_word) = $buffer->FindOccurence('line') ;
is($match_line, undef, 'At the end of buffer') ;

$buffer->SetModificationPosition(0, 0) ;
is_deeply([$buffer->FindOccurence('1')], [0, 5, '1'], 'Found occurence') ;

#directely passed arguments
is_deeply([$buffer->FindOccurence('1', 0, 0)], [0, 5, '1'], 'Found occurence 1') ;
is_deeply([$buffer->FindOccurence('2', 0, 0)], [1, 5, '2'], 'Found occurence 2') ;
is_deeply([$buffer->FindOccurence('5', 0, 0)], [4, 5, '5'], 'Found occurence 5') ;
is_deeply([$buffer->FindOccurence('6', 0, 0)], [undef, undef, undef], 'Search occurence 6') ;

#position outside line, buffer
is_deeply([$buffer->FindOccurence('1', 0, 50)], [undef, undef, undef], 'Search outside line') ;
is_deeply([$buffer->FindOccurence('1', 50, 0)], [undef, undef, undef], 'Search outside buffer') ;

#selection, position, text
$buffer->SetSelectionBoundaries(0, 5, 3, 4) ;
is_deeply([$buffer->FindOccurence('1', 0, 0)], [0, 5, '1'], 'Found occurence 1') ;

$buffer->SetSelectionBoundaries(10, 5, 13, 4) ;
is_deeply([$buffer->FindOccurence('1', 0, 0)], [0, 5, '1'], 'Found occurence 1') ;

$buffer->SetModificationPosition(5, 0) ;
is_deeply([$buffer->FindOccurence('1', 0, 0)], [0, 5, '1'], 'Found occurence 1') ;

$buffer->SetSelectionBoundaries(0, 0, 0, 0) ;
is_deeply([$buffer->FindOccurence('1', 0, 0)], [0, 5, '1'], 'Found occurence 1') ;
is($buffer->GetText(), $text, 'Text still the same') ;
is($buffer->GetSelectionText(), '', 'GetSelectionText empty') ;

#FindNextOccurence
$buffer->SetModificationPosition(0, 0) ;
is_deeply([$buffer->FindNextOccurence()], [0, 5, '1'], 'FindNextOccurence') ;

$buffer->SetModificationPosition(0, 5) ;
is_deeply([$buffer->FindNextOccurence()], [0, 9, '1'], 'FindNextOccurence') ;

# FindNextOccurenceForCurrentWord
$buffer->SetModificationPosition(0, 0) ;
is_deeply([$buffer->FindNextOccurenceForCurrentWord()], [1, 0, 'line'], 'FindNextOccurenceForCurrentWord') ;

$buffer->SetModificationPosition(1, 0) ;
is_deeply([$buffer->FindNextOccurenceForCurrentWord()], [2, 0, 'line'], 'FindNextOccurenceForCurrentWord') ;

$buffer->SetModificationPosition(4, 0) ;

is_deeply([$buffer->FindNextOccurenceForCurrentWord()], [undef, undef, undef], 'FindNextOccurenceForCurrentWord') ;

# Regex search
is_deeply([$buffer->FindOccurence(qr/..n[a-z]/, 0, 0)], [0, 0, 'line'], 'Found occurence with regex') ;

#Find Backwards
#-------------------------------

$buffer = new Text::Editor::Vip::Buffer() ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Plugins::FindReplace') ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Test') ;

$buffer->Insert($text) ;

($match_line, $match_position, $match_word) = $buffer->FindOccurenceBackwards(undef) ;
is($match_line, undef, 'Undef regex is ignored') ;

($match_line, $match_position, $match_word) = $buffer->FindOccurenceBackwards('') ;
is($match_line, undef, 'empty regex is ignored') ;

($match_line, $match_position, $match_word) = $buffer->FindOccurenceBackwards('cant_be_found') ;
is($match_line, undef, 'non matching regex is ignored') ;

($match_line, $match_position, $match_word) = $buffer->FindOccurenceBackwards('line') ;
#~ is_deeply([$buffer->FindOccurenceBackwards('1')], [undef, undef, undef], 'Found occurence') ;
is_deeply([$buffer->FindOccurenceBackwards('2')], [1, 11, '2'], 'Found occurence') ;

$buffer->SetModificationPosition(1, 10) ;
is_deeply([$buffer->FindOccurenceBackwards('2')], [1, 9, '2'], 'Found occurence') ;

#directely passed arguments
is_deeply([$buffer->FindOccurenceBackwards('1', 0, 0)], [undef, undef, undef], 'Search occurence 1') ;

is_deeply([$buffer->FindOccurenceBackwards('1', 0, 10)], [0, 9, '1'], 'Found occurence 1') ;
is_deeply([$buffer->FindOccurenceBackwards('2', 1, 9)], [1, 5, '2'], 'Found occurence 2') ;
is_deeply([$buffer->FindOccurenceBackwards('5', 4, 7)], [4, 5, '5'], 'Found occurence 5') ;
is_deeply([$buffer->FindOccurenceBackwards('6', 0, 0)], [undef, undef, undef], 'Search occurence 6') ;

#position outside line, buffer
is_deeply([$buffer->FindOccurenceBackwards('1', 0, 50)], [0, 9, '1'], 'Search outside line') ;
is_deeply([$buffer->FindOccurenceBackwards('1', 50, 0)], [0, 9, '1'], 'Search outside buffer') ;

#selection, position, text
$buffer->SetSelectionBoundaries(0, 5, 3, 4) ;
is_deeply([$buffer->FindOccurenceBackwards('1', 0, 10)], [0, 9, '1'], 'Found occurence 1') ;

$buffer->SetSelectionBoundaries(10, 5, 13, 4) ;
is_deeply([$buffer->FindOccurenceBackwards('1', 1, 0)], [0, 9, '1'], 'Found occurence 1') ;

$buffer->SetModificationPosition(0, 10) ;
is_deeply([$buffer->FindOccurenceBackwards('2', 1, 10)], [1, 9, '2'], 'Found occurence') ;

$buffer->SetSelectionBoundaries(0, 0, 0, 0) ;
is_deeply([$buffer->FindOccurenceBackwards('2', 1, 10)], [1, 9, '2'], 'Found occurence 1') ;
is($buffer->GetText(), $text, 'Text still the same') ;
is($buffer->GetSelectionText(), '', 'GetSelectionText empty') ;
is_deeply([0, 0, 0, 0], [$buffer->GetSelectionBoundaries()], 'GetSelectionText unchanged selection') ;

#FindPreviousOccurence
$buffer->SetModificationPosition(1, 11) ;
is_deeply([$buffer->FindPreviousOccurence()], [1, 9 , '2'], 'FindPreviousOccurence') ;

$buffer->SetModificationPosition(1, 8) ;
is_deeply([$buffer->FindPreviousOccurence()], [1, 5, '2'], 'FindPreviousOccurence') ;

$buffer->SetModificationPosition(1, 5) ;
is_deeply([$buffer->FindPreviousOccurence()], [undef, undef, undef], 'FindPreviousOccurence') ;

# FindPreviousOccurenceForCurrentWord
$buffer->SetModificationPosition(1, 0) ;
is_deeply([$buffer->FindPreviousOccurenceForCurrentWord()], [0, 0, 'line'], 'FindNextOccurenceForCurrentWord') ;

$buffer->SetModificationPosition(3, 0) ;
is_deeply([$buffer->FindPreviousOccurenceForCurrentWord()], [2, 0, 'line'], 'FindNextOccurenceForCurrentWord') ;

$buffer->SetModificationPosition(0, 0) ;
is_deeply([$buffer->FindPreviousOccurenceForCurrentWord()], [undef, undef, undef], 'FindNextOccurenceForCurrentWord') ;

TODO:
{
local $TODO = "Regex search backwards" ;
fail($TODO) ;
}

# Find and replace
#-------------------------------

$buffer = new Text::Editor::Vip::Buffer() ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Plugins::FindReplace') ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Test') ;

$buffer->Insert($text) ;
$buffer->SetModificationPosition(0, 0) ;

is_deeply([$buffer->ReplaceOccurence('not_found', 'yasmin')], [undef, undef, undef, undef], 'ReplaceOccurence non existing') ;
is_deeply([$buffer->ReplaceOccurence(undef, 'yasmin')], [undef, undef, undef, undef], 'Found occurence') ;
is_deeply([$buffer->ReplaceOccurence(undef, '')], [undef, undef, undef, undef], 'Found occurence') ;
is_deeply([$buffer->ReplaceOccurence(undef, undef)], [undef, undef, undef, undef], 'Found occurence') ;

($expected_text = $buffer->GetText()) =~ s/1/yasmin/ ;
is_deeply([$buffer->ReplaceOccurence('1', 'yasmin')], [0, 5, '1', 'yasmin'], 'Found occurence') ;
is($buffer->CompareText($expected_text), '', 'Modification OK') ;

($expected_text = $buffer->GetText()) =~ s/1/yasmin/ ;
is_deeply([$buffer->ReplaceOccurence('1', 'yasmin')], [0, 14, '1', 'yasmin'], 'Found occurence') ;
is($buffer->CompareText($expected_text), '', 'Modification OK') ;

$buffer->SetModificationPosition(0, 0) ;
($expected_text = $buffer->GetText()) =~ s/2/yasmin/ ;
is_deeply([$buffer->ReplaceOccurence('2', 'yasmin')], [1, 5, '2', 'yasmin'], 'Found occurence 2') ;
is($buffer->CompareText($expected_text), '', 'Modification OK') ;

is_deeply([$buffer->ReplaceOccurence('6', 'yasmin')], [undef, undef, undef, undef], 'Search occurence 6') ;

#position outside line
$buffer->SetModificationPosition(3, 50) ;
is_deeply([$buffer->ReplaceOccurence('1', 'yasmin')], [undef, undef, undef, undef], 'Search outside line') ;

# Replacement has \\n"
$buffer->SetModificationPosition(0, 0) ;
($expected_text = $buffer->GetText()) =~ s/2/yasmin\n/ ;
is_deeply([$buffer->ReplaceOccurence('2', "yasmin\n")], [1, 14, '2', "yasmin\n"], 'Found occurence 2') ;
is($buffer->CompareText($expected_text), '', 'Modification OK') ;

#Replacement is ''" 
$buffer->SetModificationPosition(0, 0) ;
($expected_text = $buffer->GetText()) =~ s/2// ;
is_deeply([$buffer->ReplaceOccurence('2', '')], [2, 1, '2', ''], 'Found occurence 2') ;
is($buffer->CompareText($expected_text), '', 'Modification OK') ;

# Regex find
$buffer->SetModificationPosition(0, 0) ;
($expected_text = $buffer->GetText()) =~ s/..n[a-z]/regex/ ;
is_deeply([$buffer->ReplaceOccurence(qr/..n[a-z]/, 'regex')], [0, 0, 'line', 'regex'], 'Found and replaced with regex search') ;
is($buffer->CompareText($expected_text), '', 'Modification OK') ;

# Regex find and replace
$buffer->SetModificationPosition(0, 0) ;
($expected_text = $buffer->GetText()) =~ s/..(n[a-z])/xx$1/ ;
is_deeply([$buffer->ReplaceOccurence(qr/..(n[a-z])/, 'xx$1')], [1, 0, 'line', 'xxne'], 'Found and replaced with regex search') ;
is($buffer->CompareText($expected_text), '', 'Modification OK') ;

# find and replace again
# the cursor is moved the length of the replcaement
$buffer = new Text::Editor::Vip::Buffer() ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Plugins::FindReplace') ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Test') ;

$buffer->Insert($text) ;

$buffer->SetModificationPosition(0, 0) ;
($expected_text = $buffer->GetText()) =~ s/l/l/ ;
is_deeply([$buffer->ReplaceOccurence(qr/l/, 'l')], [0, 0, 'l', 'l'], 'Found and replaced with regex search') ;
is($buffer->CompareText($expected_text), '', 'Modification OK') ;
$buffer->SetModificationPosition(0, 1) ;

($expected_text = $buffer->GetText()) =~ s/l/l/ ;
is_deeply([$buffer->ReplaceOccurence(qr/l/, 'l')], [1, 0, 'l', 'l'], 'Found and replaced with regex search') ;
is($buffer->CompareText($expected_text), '', 'Modification OK') ;
$buffer->SetModificationPosition(1, 1) ;

($expected_text = $buffer->GetText()) =~ s/l/l/ ;
is_deeply([$buffer->ReplaceOccurence(qr/l/, 'l')], [2, 0, 'l', 'l'], 'Found and replaced with regex search') ;
is($buffer->CompareText($expected_text), '', 'Modification OK') ;
$buffer->SetModificationPosition(2, 1) ;

TODO:
{
local $TODO = "search in selection" ;
fail($TODO) ;

local $TODO = "search and replace in selection" ;
fail($TODO) ;

#~ #selection, position, text
#~ $buffer->SetSelectionBoundaries(0, 5, 3, 4) ;
#~ is_deeply([$buffer->ReplaceOccurence('1', 'yasmin')], [0, 5, '1'], 'Found occurence 1') ;

#~ $buffer->SetSelectionBoundaries(10, 5, 13, 4) ;
#~ is_deeply([$buffer->ReplaceOccurence('1', 'yasmin')], [0, 5, '1'], 'Found occurence 1') ;

#~ $buffer->SetModificationPosition(5, 0) ;
#~ is_deeply([$buffer->ReplaceOccurence('1', 'yasmin')], [0, 5, '1'], 'Found occurence 1') ;

#~ $buffer->SetSelectionBoundaries(0, 0, 0, 0) ;
#~ is_deeply([$buffer->ReplaceOccurence('1', 'yasmin')], [0, 5, '1'], 'Found occurence 1') ;
#~ is($buffer->GetText(), $text, 'Text still the same') ;
#~ is($buffer->GetSelectionText(), '', 'GetSelectionText empty') ;

}
