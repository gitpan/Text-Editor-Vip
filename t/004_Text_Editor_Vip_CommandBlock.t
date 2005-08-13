# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Text::Editor::Vip' ); }

my $object = Text::Editor::Vip->new ();
isa_ok ($object, 'Text::Editor::Vip');


