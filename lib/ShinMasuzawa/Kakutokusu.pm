package ShinMasuzawa::Kakutokusu;
use 5.008001;
use strict;
use warnings;
use Data::Dumper;

use POSIX;
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

sub get {
    my ( $self, $proc, $log ) = @_;
    my $dantai = $self->{dantai};
    my $judge = $self->{judge};
    my $rank = $self->{rank};
    
    ### 獲得数格納用変数の初期化
    my $kakutokunum;

    ###各団体の獲得数の取得
    ###各配列の先頭の値を検索してカウント
    foreach my $dantaimei (@{ $dantai }){
        $kakutokunum->{$dantaimei} = 0;
        foreach my $hash_value (keys %{ $judge }){
            my $top_dantai = $judge->{$hash_value}[0];
            if ( $dantaimei eq $top_dantai ){
                $kakutokunum->{$dantaimei} += 1;
            }
        }
    }

    ### 各団体の獲得数を表示
    my %hash_kakutokunum = %$kakutokunum;
    foreach my $name ( sort keys %hash_kakutokunum ){
        $log->debug("$proc", encode_utf8 "団体名 $name の獲得数は $hash_kakutokunum{$name} です。");
    }
    return $kakutokunum;
}

1;
__END__

=encoding utf-8

=head1 NAME

ShinMasuzawa::FormatCheck - It's new $module

=head1 SYNOPSIS

    use ShinMasuzawa::Kakutokusu;
    my $kakutoku = ShinMasuzawa::Kakutokusu->new(
        dantai => $dantai,
        judge => $judge,
        rank => $rank,
    );
    
    my $kakutokusuu = $kakutoku->get($proc, $log);

=head1 DESCRIPTION

ShinMasuzawa::Kakutokusu は、新増沢式採点法（新増沢方式）にて獲得数を取得します。
各団体の獲得数を、ハッシュのリファレンスで返します。

=head1 LICENSE

Copyright (C) Keiji Kawabata.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Keiji Kawabata E<lt>bata64@gmail.comE<gt>

=cut

