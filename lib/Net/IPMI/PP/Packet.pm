package Net::IPMI::PP::Packet;
use strict;
use warnings;
use Carp qw(croak confess);

my %len = (c => 1, C => 1, N => 4, a => 1);

sub unpack {
  my ($obj, $data) = @_;
  confess "Insufficient arguments" unless defined $data;

  my $self = (ref $obj eq '' ? bless {}, $obj : $obj);
  my $fields = $self->fields;
  confess "Missing `fields' structure" unless defined $fields;

  my $pos = 0;
  for my $fieldspec (@$fields) {
    my $name = $fieldspec->{name};
    my ($format, $count) = ($fieldspec->{format} =~ /^(\D+)(\d+)?$/);
    confess "Illegal format code: $format" unless defined $format;
    confess "Illegal format code: $format" unless defined $len{$format};
    $count = 1 unless defined $count;
    my $value = unpack $fieldspec->{format}, substr($data, $pos);
    croak "Invalid packet: could not decode $name"
      unless defined $value;
    $pos += ($len{$format} * $count);
    if (ref $name eq "HASH") {
      while(my ($subname, $subspec) = each %$name) {
        my ($mask, $shift) = ($subspec->{mask}, $subspec->{shift});
        confess "Illegal name spec (mask missing) in $subname" unless defined $mask;
        confess "Illegal name spec (shift missing) in $subname" unless defined $shift;
        my $value = (($value & $mask) >> $shift);
        $self->{$subname} = $self->constant($subname, $value);
      }
    } else {
      $self->{$name} = $self->constant($name, $value);
    }
  }

  return ($self, substr($data, $pos));
}

sub pack {
  my $self = shift;
  my $fields = $self->fields;
  my $packed = "";
  for my $fieldspec (@$fields) {
    my $name = $fieldspec->{name};
    my ($format, $count) = ($fieldspec->{format} =~ /^(\D+)(\d+)?$/);
    confess "Illegal format code: $format" unless defined $format;
    confess "Illegal format code: $format" unless defined $len{$format};
    $count = 1 unless defined $count;

    my $value = 0;
    if (ref $name eq "HASH") {
      while(my ($subname, $subspec) = each %$name) {
        my ($mask, $shift) = ($subspec->{mask}, $subspec->{shift});
        confess "Illegal name spec (mask missing) in $subname" unless defined $mask;
        confess "Illegal name spec (shift missing) in $subname" unless defined $shift;
        $value |= (($value & $mask) << $shift);
      }
    } else {
      $value = defined $self->{$name} ? $self->{$name} : "";
    }
    $packed .= pack $fieldspec->{format}, $value;
  }
  return $packed;
}

1;
