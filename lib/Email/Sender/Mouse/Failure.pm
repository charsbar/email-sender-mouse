package Email::Sender::Mouse::Failure;
BEGIN {
  $Email::Sender::Mouse::Failure::VERSION = '0.110001';
}
use Mouse;
extends 'Throwable::Mouse::Error';
# ABSTRACT: a report of failure from an email sending transport


has code => (
  is => 'ro',
);


has _recipients => (
  is         => 'rw',
  isa        => 'ArrayRef',
  auto_deref => 1,
  init_arg   => 'recipients',
);

sub recipients { shift->_recipients }


sub BUILD {
  my ($self) = @_;
  confess("message must contain non-space characters")
    unless $self->message =~ /\S/;
}


__PACKAGE__->meta->make_immutable(inline_constructor => 0);
no Mouse;
1;

__END__
=pod

=head1 NAME

Email::Sender::Mouse::Failure - a report of failure from an email sending transport

=head1 VERSION

version 0.110001

=head1 ATTRIBUTES

=head2 message

This method returns the failure message, which should describe the failure.
Failures stringify to this message.

=head2 code

This returns the numeric code of the failure, if any.  This is mostly useful
for network protocol transports like SMTP.  This may be undefined.

=head2 recipients

This returns a list (or, in scalar context, an arrayref) of addresses to which
the email could not be sent.

=head1 METHODS

=head2 throw

This method can be used to instantiate and throw an Email::Sender::Mouse::Failure
object at once.

  Email::Sender::Mouse::Failure->throw(\%arg);

Instead of a hashref of args, you can pass a single string argument which will
be used as the C<message> of the new failure.

=head1 SEE ALSO

=over

=item * L<Email::Sender::Mouse::Permanent>

=item * L<Email::Sender::Mouse::Temporary>

=item * L<Email::Sender::Mouse::Multi>

=back

=head1 AUTHOR

Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Ricardo Signes.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

