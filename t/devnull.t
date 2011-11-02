#!perl
use strict;
use warnings;
use Test::More 'no_plan';

use Email::Sender::Mouse;
use Email::Sender::Mouse::Transport::DevNull;

my $xport = Email::Sender::Mouse::Transport::DevNull->new;
ok($xport->does('Email::Sender::Mouse::Transport'));
isa_ok($xport, 'Email::Sender::Mouse::Transport::DevNull');

my $message = <<'END_MESSAGE';
From: sender@test.example.com
To: recipient@nowhere.example.net
Subject: this message is going nowhere fast

Dear Recipient,

  You will never receive this.

-- 
sender
END_MESSAGE

my $result = $xport->send($message);
isa_ok($result, 'Email::Sender::Mouse::Success');
