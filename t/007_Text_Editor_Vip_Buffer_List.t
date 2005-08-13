# -*- perl -*-

# t/002_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Text::Editor::Vip::Buffer::List' ); }

my $object = Text::Editor::Vip::Buffer::List->new ();
isa_ok ($object, 'Text::Editor::Vip::Buffer::List');


