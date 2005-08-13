# -*- perl -*-

# t/002_load.t - check module loading and create testing directory

use Test::More tests => 5 ;

BEGIN { use_ok('Text::Editor::Vip::Buffer' ); }

my $buffer = Text::Editor::Vip::Buffer->new();
isa_ok($buffer, 'Text::Editor::Vip::Buffer');

$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Plugins::Display') ;
$buffer->SetTabSize(3) ;
is($buffer->GetTabSize(), 3, 'tab size is as set') ;

#~ use Data::TreeDumper ;
#~ diag("\n" . DumpTree($buffer, 'Buffer:')) ;

$buffer->Insert("\t\ttext") ;
is($buffer->GetCharacterDisplayPosition(0, 2), 6, 'text to display convertion') ;
is($buffer->GetCharacterPositionInText(0, 6), 2, 'display to text convertion') ;


