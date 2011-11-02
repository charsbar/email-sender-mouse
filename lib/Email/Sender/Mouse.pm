package Email::Sender::Mouse;
BEGIN {
  $Email::Sender::Mouse::VERSION = '0.110001';
}
use Mouse::Role;
# ABSTRACT: a library for sending email

requires 'send';


no Mouse::Role;
1;

__END__
=pod

=head1 NAME

Email::Sender::Mouse - a library for sending email

=head1 VERSION

version 0.110001

=head1 SYNOPSIS

  my $message = Email::MIME->create( ... );
  # produce an Email::Abstract compatible message object,
  # e.g. produced by Email::Simple, Email::MIME, Email::Stuff

  use Email::Sender::Mouse::Simple qw(sendmail);
  use Email::Sender::Mouse::Transport::SMTP qw();
  use Try::Tiny;

  try {
    sendmail(
      $message,
      {
        from => $SMTP_ENVELOPE_FROM_ADDRESS,
        transport => Email::Sender::Mouse::Transport::SMTP->new({
            host => $SMTP_HOSTNAME,
            port => $SMTP_PORT,
        })
      }
    );
  } catch {
      warn "sending failed: $_";
  };

=head1 OVERVIEW

Email::Sender::Mouse replaces the old and sometimes problematic Email::Send library,
which did a decent job at handling very simple email sending tasks, but was not
suitable for serious use, for a variety of reasons.

Most users will be able to use L<Email::Sender::Mouse::Simple> to send mail.  Users
with more specific needs should look at the available Email::Sender::Mouse::Transport
classes.

Documentation may be found in L<Email::Sender::Mouse::Manual>, and new users should
start with L<Email::Sender::Mouse::Manual::QuickStart>.

=head1 IMPLEMENTING

Email::Sender::Mouse itelf is a Mouse role.  Any class that implements Email::Sender::Mouse
is required to provide a method called C<send>.  This method should accept any
input that can be understood by L<Email::Abstract>, followed by a hashref
containing C<to> and C<from> arguments to be used as the envelope.  The method
should return an L<Email::Sender::Mouse::Success> object on success or throw an
L<Email::Sender::Mouse::Failure> on failure.

=head1 AUTHOR

Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Ricardo Signes.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

