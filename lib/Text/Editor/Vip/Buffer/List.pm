
package Text::Editor::Vip::Buffer::List;

use strict;
use warnings ;
use Carp qw(cluck) ;

BEGIN 
{
use Exporter ();
use vars qw ($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION     = 0.01;
@ISA         = qw (Exporter);
@EXPORT      = qw ();
@EXPORT_OK   = qw ();
%EXPORT_TAGS = ();
}

#-------------------------------------------------------------------------------

sub new
{
my $invocant = shift ;
my $class = ref($invocant) || $invocant ;

return( bless [], $class );
}

#-------------------------------------------------------------------------------

sub GetNumberOfNodes
{
return(scalar(@{$_[0]})) ;
}

#-------------------------------------------------------------------------------

sub Push
{
push @{$_[0]}, $_[1] ;
}

#-------------------------------------------------------------------------------

sub GetNodeData
{
my $this         = shift ;
my $a_node_index = shift ;

if(0 <= $a_node_index && $a_node_index < $this->GetNumberOfNodes())
	{
	return($this->[$a_node_index]) ;
	}
else
	{
	cluck("$a_node_index is an invalide node index") ;
	return(undef) ;
	}
}

#-------------------------------------------------------------------------------

sub SetNodeData
{
my $this         = shift ;
my $a_node_index = shift ;
my $a_node_data  = shift ;

if(0 <= $a_node_index && $a_node_index < $this->GetNumberOfNodes())
	{
	$this->[$a_node_index] = $a_node_data ;
	}
else
	{
	cluck("$a_node_index is an invalide node index") ;
	return(undef) ;
	}

}

#-------------------------------------------------------------------------------

sub DeleteNode
{
my $this         = shift ;
my $a_node_index = shift ;

if(0 != $this->GetNumberOfNodes())
	{
	if(0 <= $a_node_index && $a_node_index < $this->GetNumberOfNodes())
		{
		splice 
			(
			@{$this}
			, $a_node_index
			, 1
			) ;
		}
	else
		{
		cluck("$a_node_index is an invalide node index") ;
		}
	}
else
	{
	cluck('List is empty, nothing to delete !!') ;
	}
}

#-------------------------------------------------------------------------------

sub InsertAfter
{
my $this         = shift ;
my $a_node_index = shift ;
my $a_node_data  = shift ;

if(0 != $this->GetNumberOfNodes())
	{
	if(0 <= $a_node_index && $a_node_index < $this->GetNumberOfNodes())
		{
		splice 
			(
			@{$this}
			, $a_node_index + 1
			, 0
			, $a_node_data
			) ;
		}
	else
		{
		cluck("$a_node_index is an invalide node index") ;
		}
	}
else
	{
	cluck('List is empty !!') ;
	}
}

#-------------------------------------------------------------------------------

sub InsertBefore
{
my ($this, $a_node_index, $a_node_data) = @_ ;

if(0 != $this->GetNumberOfNodes())
	{
	if(0 <= $a_node_index && $a_node_index < $this->GetNumberOfNodes())
		{
		if(0 == $a_node_index)
			{
			unshift @{$this}, $a_node_data ;
			}
		else
			{
			splice 
				(
				@{$this}
				, $a_node_index
				, 0
				, $a_node_data
				) ;
			}
		}
	else
		{
		cluck("$a_node_index is an invalide node index") ;
		}
	}
else
	{
	cluck('List is empty !!') ;
	}
}

#-------------------------------------------------------------------------------

1;

=head1 NAME

Text::Editor::Vip::Buffer::List - lines container

=head1 SYNOPSIS

  use Text::Editor::Vip::Buffer::List
  

=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.


=head1 USAGE


=head1 BUGS


=head1 SUPPORT


=head1 AUTHOR

	Khemir Nadim ibn Hamouda
	CPAN ID: NKH
	mailto:nadim@khemir.net
	http:// no web site

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
