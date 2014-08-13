package ShinMasuzawa::FormatCheck;
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
        judge => undef,
        dantai => undef,
        judge_max => 11,
        judge_min => 3,
        %opt,
    },$class;
    $self;
}

sub check_JudgeNum {
    my ( $self, $proc, $log ) = @_;
    my $judge = $self->{judge};
    my $judgenum= keys(%$judge);

    if ( $judgenum < $self->{judge_min} || $judgenum > $self->{judge_max} || $judgenum % 2 == 0 ){
        $log->error("$proc",encode_utf8 "審査員の数は$self->{judge_min} 人以上$self->{judge_max}未満の奇数でなければいけません。");
        return 1;
    }
    $log->debug("$proc", encode_utf8 "審査員の数 $judgenum 。チェックOK");
    return 0;
}

sub check_GroupNum {
    my ( $self, $proc, $log ) = @_;
    my $judge = $self->{judge};
    my $judgenum= keys(%{ $judge });
    my $dantainum_org = scalar @{ $self->{dantai} };

    my $error_counter = 0;
    my $dantai_num;

    foreach my $judge_name ( sort keys %{ $judge } ){
        my $ranking = $judge->{$judge_name};
        $dantai_num = scalar @{ $ranking };
        $log->debug("$proc", encode_utf8 "$judge_name の順位表の団体数は$dantai_num です。");
        if ( $dantai_num != $dantainum_org ){
            $log->error("$proc", encode_utf8 "$judge_name の順位表は、団体数が違います。正しい団体数は $dantainum_org です。");
            $error_counter++;
        }
    }
    if ( $error_counter >= 1 ){
        return 1;
    }
    $log->debug("$proc", encode_utf8 "各順位表の団体の数が$dantainum_org 。チェックOK");
    return 0;
}

sub check_JudgeAndDantai {
    my ( $self, $proc, $log ) = @_;

    my $dantai = $self->{dantai};
    my $judge = $self->{judge};

    my $error_counter = 0;

    foreach my $judge_name ( sort keys %{ $judge } ){
        foreach my $group_name (@{ $dantai }){
            my $eva_result = grep { /$group_name/ } @{ $judge->{$judge_name} };
            if ( $eva_result == 0  ){
                $log->error("$proc", encode_utf8 "$judge_name の順位表に、団体 $group_name が書かれていません。");
                $error_counter++;
            } elsif ( $eva_result >= 2  ){
                $log->error("$proc", encode_utf8 "$judge_name の順位表に、団体 $group_name が $eva_result 個書かれています。");
                $error_counter++;
            }
        }
    }
    
    if ( $error_counter >= 1 ){
        return 1;
    }
    $log->debug("$proc", encode_utf8 "各順位表の団体が登録団体と一致しているかチェックOK");
    return 0;
}

1;
__END__

=encoding utf-8

=head1 NAME

ShinMasuzawa::FormatCheck - It's new $module

=head1 SYNOPSIS

    use ShinMasuzawa::FormatCheck;
    my $chk = ShinMasuzawa::FormatCheck->new(
        dantai => $dantai, #配列のリファレンス
        judge => $judge,   #ハッシュのリファレンス
        judge_max => 11,   #最大審査員数
        judge_min => 3,    #最小審査員数
    );

    if ( $chk->check_JudgeNum($proc, $log) != 0 ){
        exit;
    }

    if ( $chk->check_GroupNum($proc, $log) != 0 ){
        exit;
    }

=head1 DESCRIPTION

ShinMasuzawa::FormatCheck は、新増沢式採点法（新増沢方式）の審査表データのフォーマットチェックをします。
check_JudgeNumは審査員数のチェック（奇数であること、最大値、最小値以内であること）
check_GroupNumは団体数のチェック（登録団体数と順位表記載の団体数が一致すること）

=head1 LICENSE

Copyright (C) Keiji Kawabata.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Keiji Kawabata E<lt>bata64@gmail.comE<gt>

=cut

