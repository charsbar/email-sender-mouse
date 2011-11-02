#!perl
use strict;
use warnings;
use Test::More tests => 4;

use Email::Sender::Mouse;
use Email::Sender::Mouse::Transport::Print;

{
  package CP;
  sub new    { bless { str => '' } => $_[0] }
  sub print  { shift->{str} .= join '', @_ }
  sub printf { shift->{str} .= sprintf shift, @_ }
  sub isa    { return 1 if $_[1] eq 'IO::Handle' }
}

my $xport = Email::Sender::Mouse::Transport::Print->new({ fh => CP->new });
ok($xport->does('Email::Sender::Mouse::Transport'));
isa_ok($xport, 'Email::Sender::Mouse::Transport::Print');

my $message = <<'END_MESSAGE';
From: from@test.example.com
To: to@nowhere.example.net
Subject: this message is going nowhere fast

Dear Recipient,

  You will never receive this.

-- 
sender
END_MESSAGE

my $want = <<"END_WANT";
ENVELOPE TO  : rcpt\@nowhere.example.net
ENVELOPE FROM: sender\@test.example.com
---------- begin message
$message---------- end message
END_WANT

my $result = $xport->send(
  $message,
  {
    to   => [ 'rcpt@nowhere.example.net' ],
    from => 'sender@test.example.com',
  },
);

use Data::Dumper;

isa_ok($result, 'Email::Sender::Mouse::Success');
is($xport->fh->{str}, $want, 'what we expected got printed');
