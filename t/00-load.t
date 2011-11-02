use Test::More 'no_plan';

   use_ok('Email::Sender::Mouse')
&& use_ok('Email::Sender::Mouse::Simple')
&& use_ok('Email::Sender::Mouse::Transport::DevNull')
&& use_ok('Email::Sender::Mouse::Transport::Failable')
&& use_ok('Email::Sender::Mouse::Transport::Maildir')
&& use_ok('Email::Sender::Mouse::Transport::Mbox')
&& use_ok('Email::Sender::Mouse::Transport::Print')
&& use_ok('Email::Sender::Mouse::Transport::SMTP')
&& use_ok('Email::Sender::Mouse::Transport::SMTP::Persistent')
&& use_ok('Email::Sender::Mouse::Transport::Sendmail')
&& use_ok('Email::Sender::Mouse::Transport::Test')
&& use_ok('Email::Sender::Mouse::Transport::Wrapper')
|| BAIL_OUT("can't even compile all relevant modules");

