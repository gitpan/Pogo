# PogoLink.pm - bidirectional relationship class for Pogo
# 2000 Sey Nakajima <sey@jkc.co.jp>
use Pogo;

# Abstract base class 
package PogoLink;
use Carp;
use strict;
sub new {
	my($class, $object, $linkclass, $invattr, $keyattr) = @_;
	croak "Hash object required" unless (Pogo::type_of($object))[0] eq 'HASH';
	my $self = {
		OBJECT    => $object,
		LINK      => undef,
		LINKCLASS => $linkclass,
		INVATTR   => $invattr,
		KEYATTR   => $keyattr,
	};
	bless $self, $class;
}
sub clear {
	my $self = shift;
	my @objects = $self->getlist;
	return unless @objects;
	my $invattr = $self->{INVATTR};
	Pogo::tied_object($self)->begin_transaction;
	for my $object(@objects) {
		$self->_del($object);
		$object->{$invattr}->_del($self->{OBJECT});
	}
	Pogo::tied_object($self)->end_transaction;
}
sub del {
	my($self, $object) = @_;
	return unless $self->find($object);
	my $invattr = $self->{INVATTR};
	Pogo::tied_object($self)->begin_transaction;
	$self->_del($object);
	$object->{$invattr}->_del($self->{OBJECT});
	Pogo::tied_object($self)->end_transaction;
}
sub add {
	my($self, $object) = @_;
	my $linkclass = $self->{LINKCLASS};
	croak "Class mismatch" if $linkclass && !$object->isa($linkclass);
	return if $self->find($object);
	my $invattr = $self->{INVATTR};
	croak "Hash object required" unless (Pogo::type_of($object))[0] eq 'HASH';
	my $invclass = (Pogo::type_of($object->{$invattr}))[1];
	croak "Inverse attribute must be a PogoLink::* object" 
		unless $invclass =~ /^PogoLink::/;
	Pogo::tied_object($self)->begin_transaction;
	$self->_add($object);
	$object->{$invattr}->_add($self->{OBJECT});
	Pogo::tied_object($self)->end_transaction;
}

package PogoLink::Scalar;
use Carp;
use strict;
use vars qw(@ISA);
@ISA = qw(PogoLink);
sub get {
	my $self = shift;
	$self->{LINK};
}
sub getlist {
	my $self = shift;
	return () unless $self->{LINK};
	($self->{LINK});
}
sub find {
	my($self, $object) = @_;
	Pogo::equal($self->{LINK}, $object);
}
sub _del {
	my($self, $object) = @_;
	$self->{LINK} = undef if Pogo::equal($self->{LINK}, $object);
}
sub _add {
	my($self, $object) = @_;
	my $invattr = $self->{INVATTR};
	$self->{LINK}->{$invattr}->_del($self->{OBJECT}) if $self->{LINK};
	$self->{LINK} = $object;
}

package PogoLink::Array;
use Carp;
use strict;
use vars qw(@ISA);
@ISA = qw(PogoLink);
sub get {
	my($self, $idx) = @_;
	return undef unless $self->{LINK};
	$self->{LINK}->[$idx];
}
sub getlist {
	my $self = shift;
	return () unless $self->{LINK};
	@{$self->{LINK}};
}
sub find {
	my($self, $object) = @_;
	return 0 unless $self->{LINK};
	grep Pogo::equal($_, $object), @{$self->{LINK}};
}
sub _del {
	my($self, $object) = @_;
	return unless $self->{LINK};
	@{$self->{LINK}} = grep !Pogo::equal($_, $object), @{$self->{LINK}};
}
sub _add {
	my($self, $object) = @_;
	unless( $self->find($object) ) {
		$self->{LINK} = [] unless $self->{LINK};
		push @{$self->{LINK}}, $object;
	}
}

package PogoLink::Hash;
use Carp;
use strict;
use vars qw(@ISA);
@ISA = qw(PogoLink);
sub get {
	my($self, $key) = @_;
	return undef unless $self->{LINK};
	$self->{LINK}->{$key};
}
sub getlist {
	my $self = shift;
	return () unless $self->{LINK};
	values %{$self->{LINK}};
}
sub getkeylist {
	my $self = shift;
	return () unless $self->{LINK};
	keys %{$self->{LINK}};
}
sub find {
	my($self, $object) = @_;
	return 0 unless $self->{LINK};
	my $key = $object->{$self->{KEYATTR}};
	exists $self->{LINK}->{$key};
}
sub _del {
	my($self, $object) = @_;
	return unless $self->{LINK};
	my $key = $object->{$self->{KEYATTR}};
	delete $self->{LINK}->{$key};
}
sub _add {
	my($self, $object) = @_;
	unless( $self->find($object) ) {
		$self->{LINK} = new Pogo::Hash unless $self->{LINK};
		my $key = $object->{$self->{KEYATTR}};
		$self->{LINK}->{$key} = $object;
	}
}

package PogoLink::Htree;
use Carp;
use strict;
use vars qw(@ISA);
@ISA = qw(PogoLink::Hash);
sub _add {
	my($self, $object) = @_;
	unless( $self->find($object) ) {
		$self->{LINK} = new Pogo::Htree unless $self->{LINK};
		my $key = $object->{$self->{KEYATTR}};
		$self->{LINK}->{$key} = $object;
	}
}

package PogoLink::Btree;
use Carp;
use strict;
use vars qw(@ISA);
@ISA = qw(PogoLink::Hash);
sub _add {
	my($self, $object) = @_;
	unless( $self->find($object) ) {
		$self->{LINK} = new Pogo::Btree unless $self->{LINK};
		my $key = $object->{$self->{KEYATTR}};
		$self->{LINK}->{$key} = $object;
	}
}

package PogoLink::Ntree;
use Carp;
use strict;
use vars qw(@ISA);
@ISA = qw(PogoLink::Hash);
sub _add {
	my($self, $object) = @_;
	unless( $self->find($object) ) {
		$self->{LINK} = new Pogo::Ntree unless $self->{LINK};
		my $key = $object->{$self->{KEYATTR}};
		$self->{LINK}->{$key} = $object;
	}
}

1;
__END__

=head1 NAME

PogoLink - Bidirectional relationship class for objects in a Pogo database

=head1 SYNOPSIS

  use PogoLink;
  # Define relationships
  package Person;
  sub new {
      my($class, $pogo, $name) = @_;
      # Make a hash ref persistent by $pogo and blessed by $class
      my $self = new_tie Pogo::Hash 8, $pogo, $class;
      %$self = (
          NAME     => $name,
          FATHER   => new PogoLink::Scalar($self, 'Man',    'CHILDREN'),
          MOTHER   => new PogoLink::Scalar($self, 'Woman',  'CHILDREN'),
          FRIENDS  => new PogoLink::Btree ($self, 'Person', 'FRIENDS', 'NAME'),
      );
      $self;
  }
  package Man;
  @ISA = qw(Person);
  sub new {
      my($class, $pogo, $name) = @_;
      my $self = $class->SUPER::new($pogo, $name);
      $self->{CHILDREN} = new PogoLink::Array ($self, 'Person', 'FATHER');
      $self->{WIFE}     = new PogoLink::Scalar($self, 'Woman',  'HUS');
      $self;
  }
  package Woman;
  @ISA = qw(Person);
  sub new {
      my($class, $pogo, $name) = @_;
      my $self = $class->SUPER::new($pogo, $name);
      $self->{CHILDREN} = new PogoLink::Array ($self, 'Person', 'MOTHER');
      $self->{HUS}      = new PogoLink::Scalar($self, 'Man',    'WIFE');
      $self;
  }

  # Use relationships
  $Pogo = new Pogo 'sample.cfg';
  $Dad = new Man   $Pogo, 'Dad';
  $Mom = new Woman $Pogo, 'Mom';
  $Jr  = new Man   $Pogo, 'Jr';
  $Gal = new Woman $Pogo, 'Gal';
  # Marriage 
  $Dad->{WIFE}->add($Mom);     # $Mom->{HUS} links to $Dad automatically
  # Birth
  $Dad->{CHILDREN}->add($Jr);  # $Jr->{FATHER} links to $Dad automatically
  $Mom->{CHILDREN}->add($Jr);  # $Jr->{MOTHER} links to $Mom automatically
  # Jr gets friend
  $Jr->{FRIENDS}->add($Gal);   # $Gal->{FRIENDS} links to $Jr automatically
  # Oops! Gal gets Dad
  $Gal->{HUS}->add($Dad);      # $Dad->{WIFE} links to $Gal automatically
                               # $Mom->{HUS} unlinks to $Dad automatically

=head1 DESCRIPTION

PogoLink makes single-single or single-multi or multi-multi bidirectional 
relationships between objects in a Pogo database. The relationships are 
automatically maintained to link each other correctly. You can choose one 
of Pogo::Array, Pogo::Hash, Pogo::Htree, Pogo::Btree and Pogo::Ntree to make 
a multi end of link.

=over 4

=head2 Classes

=item PogoLink::Scalar

This class makes a single end of link.

=item PogoLink::Array

This class makes a multi end of link as an array. It uses Pogo::Array to 
have links.

=item PogoLink::Hash, PogoLink::Htree, PogoLink::Btree, PogoLink::Ntree

These classes make a multi end of link as a hash. Each uses corresponding 
Pogo::* to have links.

=head2 Methods

=item new PogoLink::* $selfobject, $linkclass, $invattr, $keyattr

Constructor. Class method. $selfobject is a object in the database which 
possesses this link. It must be a object as a hash reference. 
$linkclass is a class name of linked object. If $linkclass defaults, 
any class object is allowed. $invattr is an attribute (i.e. hash key) name 
of the linked object which links inversely. $keyattr is only necessary for 
PogoLink::Hash, PogoLink::Htree, PogoLink::Btree, PogoLink::Ntree. 
It specifies an attribute name of the linked object thats value is used as 
the key of this link hash.

NOTE: You cannot use PogoLink::* constructors as follows in a class constructor.

  sub new {
      my($class) = @_;
      my $self = {};
      bless $self, $class;
      $self->{FOO} = new PogoLink::Scalar $self, 'Foo', 'BAR';
      $self;
  }

Because the self-object which is passed to PogoLink::* constructors must 
be a object in the database. In the above sample, $self is on the memory yet.
The right way is as follows.

  sub new {
      my($class, $pogo) = @_;
      my $self = new_tie Pogo::Hash 8, $pogo, $class;
      $self->{FOO} = new PogoLink::Scalar $self, 'Foo', 'BAR';
      $self;
  }

You can make a database-stored and blessed reference by using new_tie which 
takes a Pogo object and a class name as arguments.

=item get $idx_or_key

Get the linked object. For PogoLink::Scalar, $idx_or_key is not necessary. For 
PogoLink::Array, $idx_or_key is an array index number. For other, $idx_or_key
is a hash key string.

=item getlist

Get the linked object list.

=item getkeylist

Get the hash key list of linked objects. Only available for PogoLink::Hash, 
PogoLink::Htree, PogoLink::Btree, PogoLink::Ntree. 

=item find $object

Test the link if it links to $object.

=item clear

Unlink to all objects in the link.

=item del $object

Unlink to $object.

=item add $object

Link to $object.

=back

=head1 AUTHOR

Sey Nakajima <sey@jkc.co.jp>

=head1 SEE ALSO

Pogo(3). 
sample/person.pl.
