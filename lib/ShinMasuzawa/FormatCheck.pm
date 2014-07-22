package ShinMasuzawa::FormatCheck;
use 5.008001;
use strict;
use warnings;
use Data::Dumper;

use POSIX;

our $VERSION = "0.01";

sub new {
    my ($class,%opt) = @_;
    my $self = bless {
        %opt,
    },$class;
    $self;
}

sub check_JudgeNum {
    my ( $self ) = @_;
    
    my $proc = $self->{proc};
    my $proc_org = $self->{proc_org};
    my $judgenum = $self->{judgenum};
    my $log = $self->{log};

    my $kahansu = ceil(${judgenum}/2);

    $log->info("$proc","審査員の数は $judgenum 人、過半数は $kahansu です。");
    if ( $judgenum % 2 == 0 ){
        $log->error("$proc","審査員の数が偶数です。審査員の数は奇数でなければいけません。");
        $log->info("$proc","審査員数の確認 終了");
        die;
    }
    return( $kahansu );
}

sub check_GroupNum {
    my ( $self ) = @_;
    
    my $proc = $self->{proc};
    my $proc_org = $self->{proc_org};
    my $dantainum_org = $self->{dantainum};
    my $judge = $self->{judge};
    my $log = $self->{log};

    my $error_counter = 0;
    my $dantai_num = 0;
    foreach my $judge_name ( sort keys %$judge ){
        my $ranking = $judge->{$judge_name};
        $dantai_num = scalar @$ranking;
        $log->info("$proc","$judge_nameの順位表の団体数は$dantai_numです。");
        if ( $dantai_num != $dantainum_org ){
            $log->warn("$proc","$judge_nameの順位表は、団体数が違います。正しい団体数は $dantainum_org です。");
            $error_counter++;
        }
    }
    if ( $error_counter >= 1 ){
        $log->error("$proc","団体数が違う順位表があるため処理を中断します。");
        $log->info("$proc","順位表記載の団体数が正しいか確認 終了");
        die;
    }
    return ( 1, $dantai_num );
}

sub check_JudgeAndDantai {
    my ( $self ) = @_;
    
    my $proc = $self->{proc};
    my $proc_org = $self->{proc_org};
    my $dantai = $self->{dantai};
    my $judge = $self->{judge};
    my $log = $self->{log};

    my $error_counter = 0;

    foreach my $judge_name ( sort keys %$judge ){
        foreach my $group_name (@$dantai){
            my $eva_result = grep { /$group_name/ } @{ $judge->{$judge_name} };
            $log->info("$proc","$judge_nameの順位表について、団体 $group_name の評価中...");
            if ( $eva_result == 0  ){
                $log->warn("$proc","$judge_nameの順位表に、団体 $group_name が書かれていません。");
                $error_counter++;
            } elsif ( $eva_result >= 2  ){
                $log->warn("$proc","$judge_nameの順位表に、団体 $group_name が $eva_result 個書かれています。");
                $error_counter++;
            }
        }
    }
    
    if ( $error_counter >= 1 ){
        $log->error("$proc","団体数が違う順位表があるため処理を中断します。");
        $log->info("$proc","順位表記載の団体数が正しいか確認 終了");
        die;
    }
    return 1;

}

1;
__END__

=encoding utf-8

=head1 NAME

ShinMasuzawa::FormatCheck - It's new $module

=head1 SYNOPSIS

    use ShinMasuzawa::FormatCheck;

=head1 DESCRIPTION

ShinMasuzawa::FormatCheck is ...

=head1 LICENSE

Copyright (C) Keiji Kawabata.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Keiji Kawabata E<lt>kawabata.keiji@toshiba-sol.co.jpE<gt>

=cut

