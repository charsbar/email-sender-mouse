package Email::Sender::Mouse::Transport::Wrapper;
BEGIN {
  $Email::Sender::Mouse::Transport::Wrapper::VERSION = '0.110001';
}
use Mouse;
with 'Email::Sender::Mouse::Transport';
# ABSTRACT: a mailer to wrap a mailer for mailing mail


has transport => (
  is   => 'ro',
  does => 'Email::Sender::Mouse::Transport',
  required => 1,
);

sub send_email {
  my $self = shift;

  $self->transport->send_email(@_);
}

__PACKAGE__->meta->make_immutable;
no Mouse;
1;

__END__
=pod

=head1 NAME

Email::Sender::Mouse::Transport::Wrapper - a mailer to wrap a mailer for mailing mail

=head1 VERSION

version 0.110001

=head1 DESCRIPTION

Email::Sender::Mouse::Transport::Wrapper wraps a transport, provided as the
C<transport> argument to the constructor.  It is provided as a simple way to
use method modifiers to create wrapping classes.

=head1 AUTHOR

Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Ricardo Signes.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

