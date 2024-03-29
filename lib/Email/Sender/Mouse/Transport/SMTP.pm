package Email::Sender::Mouse::Transport::SMTP;
BEGIN {
  $Email::Sender::Mouse::Transport::SMTP::VERSION = '0.110001';
}
use Mouse 0.90;
# ABSTRACT: send email over SMTP

use Email::Sender::Mouse::Failure::Multi;
use Email::Sender::Mouse::Success::Partial;
use Email::Sender::Mouse::Util;


has host => (is => 'ro', isa => 'Str',  default => 'localhost');
has ssl  => (is => 'ro', isa => 'Bool', default => 0);
has port => (
  is  => 'ro',
  isa => 'Int',
  lazy    => 1,
  default => sub { return $_[0]->ssl ? 465 : 25; },
);

has timeout => (is => 'ro', isa => 'Int', default => 120);


has sasl_username => (is => 'ro', isa => 'Str');
has sasl_password => (is => 'ro', isa => 'Str');

has allow_partial_success => (is => 'ro', isa => 'Bool', default => 0);


has helo      => (is => 'ro', isa => 'Str');
has localaddr => (is => 'ro');
has localport => (is => 'ro', isa => 'Int');

# I am basically -sure- that this is wrong, but sending hundreds of millions of
# messages has shown that it is right enough.  I will try to make it textbook
# later. -- rjbs, 2008-12-05
sub _quoteaddr {
  my $addr       = shift;
  my @localparts = split /\@/, $addr;
  my $domain     = pop @localparts;
  my $localpart  = join q{@}, @localparts;

  # this is probably a little too paranoid
  return $addr unless $localpart =~ /[^\w.+-]/ or $localpart =~ /^\./;
  return join q{@}, qq("$localpart"), $domain;
}

sub _smtp_client {
  my ($self) = @_;

  my $class = "Net::SMTP";
  if ($self->ssl) {
    require Net::SMTP::SSL;
    $class = "Net::SMTP::SSL";
  } else {
    require Net::SMTP;
  }

  my $smtp = $class->new( $self->_net_smtp_args );

  $self->_throw("unable to establish SMTP connection") unless $smtp;

  if ($self->sasl_username) {
    $self->_throw("sasl_username but no sasl_password")
      unless defined $self->sasl_password;

    unless ($smtp->auth($self->sasl_username, $self->sasl_password)) {
      if ($smtp->message =~ /MIME::Base64|Authen::SASL/) {
        Carp::confess("SMTP auth requires MIME::Base64 and Authen::SASL");
      }

      $self->_throw('failed AUTH', $smtp);
    }
  }

  return $smtp;
}

sub _net_smtp_args {
  my ($self) = @_;

  return (
    $self->host,
    Port    => $self->port,
    Timeout => $self->timeout,
    defined $self->helo      ? (Hello     => $self->helo)      : (),
    defined $self->localaddr ? (LocalAddr => $self->localaddr) : (),
    defined $self->localport ? (LocalPort => $self->localport) : (),
  );
}

sub _throw {
  my ($self, @rest) = @_;
  Email::Sender::Mouse::Util->_failure(@rest)->throw;
}

sub send_email {
  my ($self, $email, $env) = @_;

  Email::Sender::Mouse::Failure->throw("no valid addresses in recipient list")
    unless my @to = grep { defined and length } @{ $env->{to} };

  my $smtp = $self->_smtp_client;

  my $FAULT = sub { $self->_throw($_[0], $smtp); };

  $smtp->mail(_quoteaddr($env->{from}))
    or $FAULT->("$env->{from} failed after MAIL FROM:");

  my @failures;
  my @ok_rcpts;

  for my $addr (@to) {
    if ($smtp->to(_quoteaddr($addr))) {
      push @ok_rcpts, $addr;
    } else {
      # my ($self, $error, $smtp, $error_class, @rest) = @_;
      push @failures, Email::Sender::Mouse::Util->_failure(
        undef,
        $smtp,
        recipients => [ $addr ],
      );
    }
  }

  # This logic used to include: or (@ok_rcpts == 1 and $ok_rcpts[0] eq '0')
  # because if called without SkipBad, $smtp->to can return 1 or 0.  This
  # should not happen because we now always pass SkipBad and do the counting
  # ourselves.  Still, I've put this comment here (a) in memory of the
  # suffering it caused to have to find that problem and (b) in case the
  # original problem is more insidious than I thought! -- rjbs, 2008-12-05

  if (
    @failures
    and ((@ok_rcpts == 0) or (! $self->allow_partial_success))
  ) {
    $failures[0]->throw if @failures == 1;

    my $message = sprintf '%s recipients were rejected during RCPT',
      @ok_rcpts ? 'some' : 'all';

    Email::Sender::Mouse::Failure::Multi->throw(
      message  => $message,
      failures => \@failures,
    );
  }

  # restore Pobox's support for streaming, code-based messages, and arrays here
  # -- rjbs, 2008-12-04

  $smtp->data                        or $FAULT->("error at DATA start");
  $smtp->datasend($email->as_string) or $FAULT->("error at during DATA");
  $smtp->dataend                     or $FAULT->("error at after DATA");

  my $message = $smtp->message;

  $self->_message_complete($smtp);

  # We must report partial success (failures) if applicable.
  return $self->success({ message => $message }) unless @failures;
  return $self->partial_success({
    message => $message,
    failure => Email::Sender::Mouse::Failure::Multi->new({
      message  => 'some recipients were rejected during RCPT',
      failures => \@failures
    }),
  });
}

my %SUCCESS_CLASS;
BEGIN {
  $SUCCESS_CLASS{FULL} = Mouse::Meta::Class->create_anon_class(
    superclasses => [ 'Email::Sender::Mouse::Success' ],
    roles        => [ 'Email::Sender::Mouse::Role::HasMessage' ],
    cache        => 1,
  );
  $SUCCESS_CLASS{PARTIAL} = Mouse::Meta::Class->create_anon_class(
    superclasses => [ 'Email::Sender::Mouse::Success::Partial' ],
    roles        => [ 'Email::Sender::Mouse::Role::HasMessage' ],
    cache        => 1,
  );
}

sub success {
  my $self = shift;
  my $success = $SUCCESS_CLASS{FULL}->name->new(@_);
}

sub partial_success {
  my ($self, @args) = @_;
  my $obj = $SUCCESS_CLASS{PARTIAL}->name->new(@args);
  return $obj;
}

sub _message_complete { $_[1]->quit; }


with 'Email::Sender::Mouse::Transport';
__PACKAGE__->meta->make_immutable;
no Mouse;
1;

__END__
=pod

=head1 NAME

Email::Sender::Mouse::Transport::SMTP - send email over SMTP

=head1 VERSION

version 0.110001

=head1 DESCRIPTION

This transport is used to send email over SMTP, either with or without secure
sockets (SSL).  It is one of the most complex transports available, capable of
partial success.

For a potentially more efficient version of this transport, see
L<Email::Sender::Mouse::Transport::SMTP::Persistent>.

=head1 ATTRIBUTES

The following attributes may be passed to the constructor:

=over 4

=item C<host>: the name of the host to connect to; defaults to C<localhost>

=item C<ssl>: if true, connect via SSL; defaults to false

=item C<port>: port to connect to; defaults to 25 for non-SSL, 465 for SSL

=item C<timeout>: maximum time in secs to wait for server; default is 120

=item C<sasl_username>: the username to use for auth; optional

=item C<sasl_password>: the password to use for auth; required if C<username> is provided

=item C<allow_partial_success>: if true, will send data even if some recipients were rejected; defaults to false

=item C<helo>: what to say when saying HELO; no default

=item C<localaddr>: local address from which to connect

=item C<localport>: local port from which to connect

=back

=head1 PARTIAL SUCCESS

If C<allow_partial_success> was set when creating the transport, the transport
may return L<Email::Sender::Mouse::Success::Partial> objects.  Consult that module's
documentation.

=head1 AUTHOR

Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Ricardo Signes.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

