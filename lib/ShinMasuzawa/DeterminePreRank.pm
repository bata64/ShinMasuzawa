package ShinMasuzawa::DeterminePreRank;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

sub new {
    my ($class,%opt) = @_;
    my $self = bless {
        %opt,
    },$class;
    $self;
}

sub detarmine {
    my %hash_kakutokunum = @_;
    $counter = 0;
    ### 獲得数が多い順に団体を整列
    $log->info("$proc","総合 $rank 位の決定");
    foreach my $name ( sort { $hash_kakutokunum{$b} <=> $hash_kakutokunum{$a} } keys %hash_kakutokunum ){
        ### 一番獲得数が多い団体を「仮の第一位」に設定
        ### 先頭にある団体は無条件で「仮の第一位」とする
        if ( $counter == 0 ){
            $kari1st->{$name} = $hash_kakutokunum{$name};
            ### 最初に「仮の第一位」となった団体名を変数に格納
            $name_1st = $name;
        ### 獲得数順で整列時の二番目以降の団体についての処理
        } else{
            ### 「仮の第一位」と同じ獲得数の場合は、「仮の第一位」に追加
            if ( $kari1st->{$name_1st} == $hash_kakutokunum{$name} ){
                $kari1st->{$name} = $hash_kakutokunum{$name};
            ### 「仮の第一位」より獲得数が少なく、かつ「仮の第二位」が未決定の場合は「仮の第二位」に設定
            } elsif ( ( $kari1st->{$name_1st} > $hash_kakutokunum{$name} ) && ( !defined($kari2st) ) ){
                $kari2st->{$name} = $hash_kakutokunum{$name};
                ### 最初に「仮の第二位」となった団体名を変数に格納
                $name_2st = $name;
            ### 「仮の第二位」が一つでも決定している場合の処理
            } elsif ( defined($kari2st) ){
                ### 「仮の第一位」より獲得数が少なく、かつ「仮の第二位」と獲得数が等しい場合は「仮の第二位」に追加
                if ( ( $kari1st->{$name_1st} > $hash_kakutokunum{$name} ) &&  ( $kari2st->{$name_2st} == $hash_kakutokunum{$name} ) ){
                    $kari2st->{$name} = $hash_kakutokunum{$name};
                ### 「仮の第二位」より獲得数が少なく、かつ「仮の第三位」が未決定の場合は「仮の第三位」に設定
                } elsif ( ( $kari2st->{$name_2st} > $hash_kakutokunum{$name} ) && ( !defined($kari3st) ) ){
                    $kari3st->{$name} = $hash_kakutokunum{$name};
                    ### 最初に「仮の第三位」となった団体名を変数に格納
                    $name_3st = $name;
                ### 「仮の第三位」が一つでも決定している場合の処理
                } elsif ( defined($kari3st) ){
                    ### 「仮の第二位」より獲得数が少なく、かつ「仮の第三位」と獲得数が等しい場合は「仮の第三位」に追加
                    if ( ( $kari2st->{$name_2st} > $hash_kakutokunum{$name} ) &&  ( $kari3st->{$name_3st} == $hash_kakutokunum{$name} ) ){
                        $kari3st->{$name} = $hash_kakutokunum{$name};
                    }
                }
            }
        }
        $counter++;
    }
    return ($kari1st, $kari2st, $kari3st);
}

1;
__END__

=encoding utf-8

=head1 NAME

ShinMasuzawa::DeterminePreRank - It's new $module

=head1 SYNOPSIS

    use ShinMasuzawa::DeterminePreRank;

=head1 DESCRIPTION

ShinMasuzawa::DeterminePreRank is ...

=head1 LICENSE

Copyright (C) Keiji Kawabata.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Keiji Kawabata E<lt>kawabata.keiji@toshiba-sol.co.jpE<gt>

=cut

