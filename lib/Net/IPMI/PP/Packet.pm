package Net::IPMI::PP::Packet;
use strict;
use warnings;
use Carp qw(croak confess);

my %len = (c => 1, C => 1, N => 4);

sub unpack {
  my ($class, $data) = @_;
  confess "Insufficient arguments" unless defined $data;

  my $self = bless {}, $class;
  my $fields = $self->fields;
  confess "Missing `fields' structure" unless defined $fields;

  my $pos = 0;
  for my $fieldspec (@$fields) {
    my $name = $fieldspec->{name};
    my ($format, $count) = ($fieldspec->{format} =~ /^(\D+)(\d+)?$/);
    $count = 1 unless defined $count;
    my $value = unpack $fieldspec->{format}, substr($data, $pos);
    croak "Invalid packet: could not decode $name"
      unless defined $value;
    $pos += ($len{$format} * $count);
    $self->{header}{$name} = $self->constant($name, $value);
  }
  $self->{payload} = substr($data, $pos);

  return $self;
}

1;
