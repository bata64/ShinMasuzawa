package ShinMasuzawa::PreRank;
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
    my ( $self, $kakutokusuu, $proc, $log ) = @_;
    my $dantai = $self->{dantai};
    my $judge = $self->{judge};
    my $rank = $self->{rank};
    my %hash_kakutokunum = %{ $kakutokusuu };
    my $kari1st;
    my $kari2nd;
    my $kari3rd;
    my $kari1st_name;
    my $kari2nd_name;
    my $kari3rd_name;
    
    my $counter = 0;
    ### 獲得数が多い順に団体を整列
    foreach my $name ( sort { $hash_kakutokunum{$b} <=> $hash_kakutokunum{$a} } keys %hash_kakutokunum ){
        ### 一番獲得数が多い団体を「仮の第一位」に設定
        ### 先頭にある団体は無条件で「仮の第一位」とする
        if ( $counter == 0 ){
            $kari1st->{$name} = $hash_kakutokunum{$name};
            ### 最初に「仮の第一位」となった団体名を変数に格納
            $kari1st_name = $name;
        ### 獲得数順で整列時の二番目以降の団体についての処理(獲得数が0の場合は処理対象としない)
        } elsif ( $hash_kakutokunum{$name} != 0 ) {
            ### 「仮の第一位」と同じ獲得数の場合は、「仮の第一位」に追加
            if ( $kari1st->{$kari1st_name} == $hash_kakutokunum{$name} ){
                $kari1st->{$name} = $hash_kakutokunum{$name};
            ### 「仮の第一位」より獲得数が少なく、かつ「仮の第二位」が未決定の場合は「仮の第二位」に設定
            } elsif ( ( $kari1st->{$kari1st_name} > $hash_kakutokunum{$name} ) && ( !defined($kari2nd) ) ){
                $kari2nd->{$name} = $hash_kakutokunum{$name};
                ### 最初に「仮の第二位」となった団体名を変数に格納
                $kari2nd_name = $name;
            ### 「仮の第二位」が一つでも決定している場合の処理
            } elsif ( defined($kari2nd) ){
                ### 「仮の第一位」より獲得数が少なく、かつ「仮の第二位」と獲得数が等しい場合は「仮の第二位」に追加
                if ( ( $kari1st->{$kari1st_name} > $hash_kakutokunum{$name} ) &&  ( $kari2nd->{$kari2nd_name} == $hash_kakutokunum{$name} ) ){
                    $kari2nd->{$name} = $hash_kakutokunum{$name};
                ### 「仮の第二位」より獲得数が少なく、かつ「仮の第三位」が未決定の場合は「仮の第三位」に設定
                } elsif ( ( $kari2nd->{$kari2nd_name} > $hash_kakutokunum{$name} ) && ( !defined($kari3rd) ) ){
                    $kari3rd->{$name} = $hash_kakutokunum{$name};
                    ### 最初に「仮の第三位」となった団体名を変数に格納
                    $kari3rd_name = $name;
                ### 「仮の第三位」が一つでも決定している場合の処理
                } elsif ( defined($kari3rd) ){
                    ### 「仮の第二位」より獲得数が少なく、かつ「仮の第三位」と獲得数が等しい場合は「仮の第三位」に追加
                    if ( ( $kari2nd->{$kari2nd_name} > $hash_kakutokunum{$name} ) &&  ( $kari3rd->{$kari3rd_name} == $hash_kakutokunum{$name} ) ){
                        $kari3rd->{$name} = $hash_kakutokunum{$name};
                    }
                }
            }
        }
        $counter++;
    }
    return {
        kari1st => $kari1st,
        kari2nd => $kari2nd,
        kari3rd => $kari3rd,
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

ShinMasuzawa::PreRank - It's new $module

=head1 SYNOPSIS

    use ShinMasuzawa::PreRank;
    my $pre = ShinMasuzawa::PreRank->new(
        dantai => $dantai,
        judge => $judge,
    );
    my $prerank = $pre->get($kakutokusuu, $proc, $log);

=head1 DESCRIPTION

ShinMasuzawa::PreRank は、新増沢式採点法（新増沢方式）にて仮の順位を決めます。
仮の第一位から第三位までを、ハッシュのリファレンスで返します。

=head1 LICENSE

Copyright (C) Keiji Kawabata.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Keiji Kawabata E<lt>bata64@gmail.comE<gt>

=cut

