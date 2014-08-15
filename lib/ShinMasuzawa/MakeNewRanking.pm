package ShinMasuzawa::MakeNewRanking;
use 5.008001;
use strict;
use warnings;
use Data::Dumper;

use POSIX;
use Math::Combinatorics;
use utf8;
use Encode;

our $VERSION = "0.01";

sub new {
    my ($class,%opt) = @_;
    my $self = bless {
        %opt,
    },$class;
    $self;
}

sub make {
    my ( $self, $top_dantai ) = @_;
    my $judge = $self->{judge};
    my $dantai = $self->{dantai};
    foreach my $judge_name (keys %{ $judge }){
        my $counter = 0;
        foreach my $name (@{ $judge->{$judge_name} }){
            if ( $name eq $top_dantai){
                splice (@{ $judge->{$judge_name} },$counter,1);
            }
            $counter++;
        }
    }
    my $counter = 0;
    foreach my $name (@{ $dantai }){
        if ( $name eq $top_dantai ){
            splice (@{ $dantai },$counter,1);
        }
        $counter++;
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

ShinMasuzawa::MakeNewRanking - It's new $module

=head1 SYNOPSIS

    use ShinMasuzawa::MakeNewRanking;
    my $top = ShinMasuzawa::MakeNewRanking->new(
        judge => $judge,
        rank => $rank,
    );
    my $top_dantai = $top->get($prerank, $proc, $log);

=head1 DESCRIPTION

ShinMasuzawa::MakeNewRanking は、新増沢式採点法（新増沢方式）にて最上位団体を決めます。
審査表（ハッシュのリファレンス）をもとに計算し、最上位団体の名前を返します。

=head1 LICENSE

Copyright (C) Keiji Kawabata.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Keiji Kawabata E<lt>bata64@gmail.comE<gt>

=cut

