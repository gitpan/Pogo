#!/usr/local/bin/perl
# Sample script for PogoLink
# 2000 Sey Nakajima <sey@jkc.co.jp>
use Pogo;
use PogoLink;
use strict vars;
use vars qw(@Cmds0 @Cmds1 @Cmds2 $AUTOLOAD);

@Cmds0 = qw(add_man add_woman list help);
@Cmds1 = qw(show);
@Cmds2 = qw(
    add_child del_child add_father del_father add_mother del_mother
    add_friend del_friend add_hus del_hus add_wife del_wife
);

main(@ARGV);

sub main {
	my($arg) = @_;

	my $pogo = new Pogo 'sample.cfg';
	my $root = $pogo->root_tie;
	if( $arg eq 'new' ) {
		$root->{PERSONS} = new Pogo::Btree;
	} else {
		$root->{PERSONS} = new Pogo::Btree unless exists $root->{PERSONS};
	}
	my $persons = $root->{PERSONS};

	print "type 'help' for help, 'exit' for exit\n";
	while(1) {
		print ">";
		my $line = <STDIN>;
		my($func, @args) = split(/\s+/,$line);
		last if $func eq 'exit';
		if( grep($func eq $_, @Cmds0) ) {
			unshift @args, $pogo, $persons;
		} else {
			@args = map $persons->{$_}, @args;
			print("no such name\n"),next if grep !$_, @args;
		}
		eval { &$func(@args); };
		print $@ if $@;
	}
}

sub help {
	print <<END;
command as follows:
  exit           : exit this script
  list           : show all persons name list
  show NAME      : show attributes of NAME person
  add_man NAME   : add a man who has NAME
  add_woman NAME : add a woman who has NAME
  
  add_child NAME1 NAME2 : NAME2 person becomes NAME1 person's child
  
  below commands are same as add_child
    add_child del_child add_father del_father add_mother del_mother
    add_friend del_friend add_hus del_hus add_wife del_wife
END
}

sub list {
	my($pogo, $persons) = @_;
	my @name = keys %{$persons};
	print "@name\n" if @name;
}
sub add_man {
	my($pogo, $persons, $name) = @_;
	return if exists $persons->{$name};
	$persons->{$name} = new Man $pogo, $name;
}
sub add_woman {
	my($pogo, $persons, $name) = @_;
	return if exists $persons->{$name};
	$persons->{$name} = new Woman $pogo, $name;
}
sub AUTOLOAD {
	my($person1, $person2) = @_;
	my $func = $AUTOLOAD;
	$func =~ s/.*:://;
	if( grep($func eq $_, @Cmds1) && $person1 ) {
		$person1->$func();
	} elsif( grep($func eq $_, @Cmds2) && $person1 && $person2 ) {
		$person1->$func($person2);
	} else {
		print "no such command\n";
	}
}

package Person;
sub new {
	my($class, $pogo, $name) = @_;
	my $self = new_tie Pogo::Hash 8, $pogo, $class;
	%$self = (
		NAME     => $name,
		FATHER   => new PogoLink::Scalar($self, 'Man',    'CHILDREN'),
		MOTHER   => new PogoLink::Scalar($self, 'Woman',  'CHILDREN'),
		FRIENDS  => new PogoLink::Btree ($self, 'Person', 'FRIENDS', 'NAME'),
	);
	$self;
}
sub name {
	my $self = shift;
	$self->{NAME};
}
sub add_child {
	my($self, $person) = @_;
	$self->{CHILDREN}->add($person);
}
sub del_child {
	my($self, $person) = @_;
	$self->{CHILDREN}->del($person);
}
sub children {
	my $self = shift;
	$self->{CHILDREN}->getlist;
}
sub father {
	my $self = shift;
	$self->{FATHER}->get;
}
sub add_father {
	my($self, $person) = @_;
	$self->{FATHER}->add($person);
}
sub del_father {
	my($self, $person) = @_;
	$self->{FATHER}->del($person);
}
sub mother {
	my $self = shift;
	$self->{MOTHER}->get;
}
sub add_mother {
	my($self, $person) = @_;
	$self->{MOTHER}->add($person);
}
sub del_mother {
	my($self, $person) = @_;
	$self->{MOTHER}->del($person);
}
sub add_friend {
	my($self, $person) = @_;
	$self->{FRIENDS}->add($person);
}
sub del_friend {
	my($self, $person) = @_;
	$self->{FRIENDS}->del($person);
}
sub friends {
	my $self = shift;
	$self->{FRIENDS}->getlist;
}

package Man;
BEGIN { @Man::ISA = qw(Person); }
sub new {
	my($class, $pogo, $name) = @_;
	my $self = $class->SUPER::new($pogo, $name);
	$self->{CHILDREN} = new PogoLink::Array ($self, 'Person', 'FATHER');
	$self->{WIFE}     = new PogoLink::Scalar($self, 'Woman', 'HUS');
	$self;
}
sub show {
	my $self = shift;
	print "Father : ",$self->father->name,"\n" if $self->father;
	print "Mother : ",$self->mother->name,"\n" if $self->mother;
	print "Wife   : ",$self->wife->name,"\n" if $self->wife;
	print "Children : ",join(",",map($_->name,$self->children)),"\n" 
		if $self->children;
	print "Friends  : ",join(",",map($_->name,$self->friends)),"\n"
		if $self->friends;
}
sub wife {
	my $self = shift;
	$self->{WIFE}->get;
}
sub add_wife {
	my($self, $person) = @_;
	$self->{WIFE}->add($person);
}
sub del_wife {
	my($self, $person) = @_;
	$self->{WIFE}->del($person);
}

package Woman;
BEGIN { @Woman::ISA = qw(Person); }
sub new {
	my($class, $pogo, $name) = @_;
	my $self = $class->SUPER::new($pogo, $name);
	$self->{CHILDREN} = new PogoLink::Array ($self, 'Person', 'MOTHER');
	$self->{HUS}      = new PogoLink::Scalar($self, 'Man', 'WIFE');
	$self;
}
sub show {
	my $self = shift;
	print "Father : ",$self->father->name,"\n" if $self->father;
	print "Mother : ",$self->mother->name,"\n" if $self->mother;
	print "Hus    : ",$self->hus->name,"\n" if $self->hus;
	print "Children : ",join(",",map($_->name,$self->children)),"\n" 
		if $self->children;
	print "Friends  : ",join(",",map($_->name,$self->friends)),"\n"
		if $self->friends;
}
sub hus {
	my $self = shift;
	$self->{HUS}->get;
}
sub add_hus {
	my($self, $person) = @_;
	$self->{HUS}->add($person);
}
sub del_hus {
	my($self, $person) = @_;
	$self->{HUS}->del($person);
}

