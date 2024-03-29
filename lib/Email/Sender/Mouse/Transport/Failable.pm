package Email::Sender::Mouse::Transport::Failable;
BEGIN {
  $Email::Sender::Mouse::Transport::Failable::VERSION = '0.110001';
}
use Mouse;
extends 'Email::Sender::Mouse::Transport::Wrapper';
# ABSTRACT: a wrapper to makes things fail predictably


has 'failure_conditions' => (
  is  => 'ro',
  isa => 'ArrayRef',
  clearer    => 'clear_failure_conditions',
  auto_deref => 1,
  default    => sub { [] },
);

sub fail_if {
  my ($self, $cond) = @_;
  push @{ scalar $self->failure_conditions }, $cond;
}

around send_email => sub {
  my ($orig, $self, $email, $env, @rest) = @_;

  for my $cond ($self->failure_conditions) {
    my $reason = $cond->($self, $email, $env, \@rest);
    next unless $reason;
    die (ref $reason ? $reason : Email::Sender::Mouse::Failure->new($reason));
  }

  return $self->$orig($email, $env, @rest);
};

__PACKAGE__->meta->make_immutable;
no Mouse;
1;

__END__
=pod

=head1 NAME

Email::Sender::Mouse::Transport::Failable - a wrapper to makes things fail predictably

=head1 VERSION

version 0.110001

=head1 DESCRIPTION

This transport extends L<Email::Sender::Mouse::Transport::Wrapper>, meaning that it
must be created with a C<transport> attribute of another
Email::Sender::Mouse::Transport.  It will proxy all email sending to that transport,
but only after first deciding if it should fail.

It does this by calling each coderef in its C<failure_conditions> attribute,
which must be an arrayref of code references.  Each coderef will be called and
will be passed the Failable transport, the Email::Abstract object, the
envelope, and a reference to an array containing the rest of the arguments to
C<send>.

If any coderef returns a true value, the value will be used to signal failure.

=head1 AUTHOR

Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Ricardo Signes.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

