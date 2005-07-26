
package Text::Editor::Vip;

use strict;

BEGIN 
{
use Exporter ();
use vars qw ($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 0.01_1;
@ISA         = qw (Exporter);
@EXPORT      = qw ();
@EXPORT_OK   = qw ();
%EXPORT_TAGS = ();
}



=head1 NAME

Text::Editor::Vip - Text editor for Perl and other languages

=head1 SYNOPSIS

  use Text::Editor::Vip
  

=head1 DESCRIPTION

See the README file.

=head1 USAGE

=head1 BUGS

=head1 SUPPORT

=head1 AUTHOR

  Nadim iibn Hamouda El Khemir
  <nadim@khemir.net>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

perl(1).

=cut

sub new
{
my ($class, %parameters) = @_;

my $self = bless ({}, ref ($class) || $class);

return ($self);
}


1 ; 

__END__

