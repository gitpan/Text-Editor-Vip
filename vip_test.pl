
use strict ;
use warnings ;

use lib qw(lib) ;

use Data::TreeDumper ;
use Data::Hexdumper ;
use Text::Diff ;

use Test::More qw(no_plan);

use Text::Editor::Vip::Buffer ;
use Text::Editor::Vip::Buffer::Test ;

my ($text, $expected_text) ;

my $buffer = new Text::Editor::Vip::Buffer() ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Test') ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Plugins::InsertDelete') ;
$buffer->ExpandedWithOrLoad('SelectAll', 'Text::Editor::Vip::Buffer::Plugins::Selection') ;

# SetText
$text = <<EOT ;
line 1 - 1
line 2 - 2 2
line 3 - 3 3 3
line 4 - 4 4 4 4
line 5 - 5 5 5 5 5
EOT

$expected_text = <<EOT ;
use Data::TreeDumper ;
use Data::Hexdumper ;
use Text::Diff ;
EOT


$buffer->Reset() ;
$buffer->Insert($text) ;
$buffer->SetText($expected_text) ;
is($buffer->CompareText($expected_text), '', 'SetText') ;

$expected_text = "no new line" ;
$buffer->Reset() ;
$buffer->Insert($text) ;
$buffer->SetText($expected_text) ;
is($buffer->CompareText($expected_text), '', 'SetText') ;

$expected_text = "\nnew line and text" ;
$buffer->Reset() ;
$buffer->Insert($text) ;
$buffer->SetText($expected_text) ;
is($buffer->CompareText($expected_text), '', 'SetText') ;

$expected_text = "text\nnew line and text" ;
$buffer->Reset() ;
$buffer->Insert($text) ;
$buffer->SetText($expected_text) ;
is($buffer->CompareText($expected_text), '', 'SetText') ;

my $setup = <<'EOS' ;
my $text = "original text" ;
$buffer->Reset() ;
$buffer->Insert($text) ;
EOS

my $command = <<'EOC' ;
my $expected_text = "\nnew line and text\nother text\nstill another text" ;

$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Plugins::InsertDelete') ;
$buffer->SetText($expected_text) ;
EOC

is(TestDoUndo($command, $setup), 1, 'test undo after SetText') ;

