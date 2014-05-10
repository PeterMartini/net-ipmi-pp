package Net::IPMI::PP::Packet;
use strict;
use warnings;
use Carp;

my %len = (c => 1, C => 1, V => 4);

sub new {
  my ($self, $data) = @_;

  my $size;
  my $fields = $self->{fields};
  croak "Missing `fields' structure" unless defined $fields;
  croak "Cannot use `new' on an existing Packet"
    if defined $self->{header} || defined $self->{payload};

  # Count how much of the data we're absorbing
  for my $field (@$fields){ 
    my ($format, $count) = ($field->{format} =~ /^(\w)(\d+)?$/);
    $count = 1 unless defined $count;
    croak "Invalid format: $format" unless defined $len{$format};
    $size += $len{$format} * $count;
  }

  # Separate out our header and payload
  my $format = join " ", map { $_->{format} } @$fields;
  my @unpacked = unpack $format, $data;
  $self->{header} = { map { $fields->[$_]{name} => $unpacked[$_]} (0..$#unpacked) };
  $self->{payload} = substr $data, $size;

  return $self;
}

1;
