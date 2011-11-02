package Email::Sender::Mouse::Failure::Multi;
BEGIN {
  $Email::Sender::Mouse::Failure::Multi::VERSION = '0.110001';
}
use Mouse;
extends 'Email::Sender::Mouse::Failure';
# ABSTRACT: an aggregate of multiple failures


has failures => (
  is  => 'ro',
  isa => 'ArrayRef',
  auto_deref => 1,
);

sub recipients {
  my ($self) = @_;
  my @rcpts = map { $_->recipients } $self->failures;
  return wantarray ? @rcpts : \@rcpts;
}


sub isa {
  my ($self, $class) = @_;

  if (
    $class eq 'Email::Sender::Mouse::Failure::Permanent'
    or
    $class eq 'Email::Sender::Mouse::Failure::Temporary'
  ) {
    my @failures = $self->failures;
    return 1 if @failures == grep { $_->isa($class) } @failures;
  }

  return $self->SUPER::isa($class);
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
no Mouse;
1;

__END__
=pod

=head1 NAME

Email::Sender::Mouse::Failure::Multi - an aggregate of multiple failures

=head1 VERSION

version 0.110001

=head1 DESCRIPTION

A multiple failure report is raised when more than one failure is encountered
when sending a single message, or when mixed states were encountered.

=head1 ATTRIBUTES

=head2 failures

This method returns a list (or arrayref, in scalar context) of other
Email::Sender::Mouse::Failure objects represented by this multi.

=head1 METHODS

=head2 isa

A multiple failure will report that it is a Permanent or Temporary if all of
its contained failures are failures of that type.

=head1 AUTHOR

Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Ricardo Signes.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

