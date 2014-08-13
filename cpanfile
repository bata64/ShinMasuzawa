requires 'perl', '5.008001';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Log::Handler', '0.82';
};

requires 'Log::Handler';
requires 'POSIX';
requires 'Math::Combinatorics';
requires 'Text::CSV';