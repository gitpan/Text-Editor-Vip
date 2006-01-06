
use strict ;
use warnings ;

use lib qw(lib) ;

use Data::TreeDumper ;
use Data::Hexdumper ;
use Text::Diff ;

use Test::More qw(no_plan);
use Test::Differences ;
use Test::Exception ;

use Text::Editor::Vip::Buffer ;
use Text::Editor::Vip::Buffer::Test ;

my $text = <<EOT ;
 line 0 - 0
  line 1 - 1
   line 2 - 2 2
    line 3 - 3 3 3
     line 4 - 4 4 4 4

something
EOT

for
	(
	[$text, undef, undef, 'l...', [3, 4, 'line'], 'undefined start position'] ,
	[$text, -1   , -1   , 'l...', [3, 4, 'line'], 'invalid start position 1'] ,
	[$text, 50   , 50   , 'l...', [3, 4, 'line'], 'invalid start position 2'] ,
	[$text, 3    , -5   , 'l...', [3, 4, 'line'], 'invalid start position 3'] ,
	[$text, 3    , 5000 , 'l...', [4, 5, 'line'], 'invalid start position 4'] ,
	[$text, 3    , undef, 'l...', [3, 4, 'line'], 'invalid start position 5'] ,
	[$text, undef, 5000 , 'l...', [3, 4, 'line'], 'invalid start position 6'] ,
	[$text, 3    , undef, 'l...', [3, 4, 'line'], 'invalid start position 7'] ,
	[$text, 1    , 1    , 'l...', [3, 4, 'line'], 'start position before boundaries'] ,
	[$text, 5    , 7    , 'l...', [3, 4, 'line'], 'start position after boundaries'] ,
	[$text, 3    , 5    , 'l...', [4, 5, 'line'], 'second match'] ,
	)
	{
	TestFindOccurenceWithinBoundaries(@$_) ;
	}

sub TestFindOccurenceWithinBoundaries
{
my ($text, $start_line, $start_character, $regex, $result, $message) = @_ ;

my @boundaries = (2, 4, 5, 6) ;
my ($match_line, $match_character, $match_word, $replacement) ;

my $buffer = new Text::Editor::Vip::Buffer() ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Plugins::FindReplace') ;
$buffer->Insert($text) ;
$buffer->SetSelectionBoundaries(0, 0, 3, 3) ;
$buffer->SetModificationPosition(0, 0) ;

eq_or_diff([$buffer->FindOccurenceWithinBoundaries($regex, @boundaries, $start_line, $start_character )], $result, $message) ;
eq_or_diff([$buffer->GetModificationPosition()], [0, 0], 'stay at the same position') ;
is_deeply([$buffer->GetSelectionBoundaries()], [0, 0, 3, 3], 'unchanged selection boundaries') ;
}

