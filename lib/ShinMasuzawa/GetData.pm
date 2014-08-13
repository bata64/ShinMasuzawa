package ShinMasuzawa::GetData;

use 5.008005;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin/extlib/lib/perl5";
use lib "$FindBin::Bin/extlib";
use utf8;
use Encode;

use Text::CSV;

sub new {
    my($class,%opt) = @_;
    my $self = bless {
        csv_file => undef,
        %opt,
    },$class;
    if ($self->{csv_file}){
        open my $csvf, '<:encoding(cp932)', $self->{csv_file} or die("error :$!");
        $self->{FH} = $csvf;
    }
    $self;
}

sub csv {
    my ( $self ) = @_ ;
    my $csv = Text::CSV->new({
        binary=>1,
        auto_diag=>1,
    });
    
    my $row_num = 1; ##横
    my $col_num = 1; ##縦
    my $ret_check = 0;
    my $judge_num;
    my @array_judge = ();
    my @array_dantai = ();
    my $push;
    my $getjudge;
    
    $ret_check = &_csvcheck($csv, $self->{FH});
    if ( $ret_check != 0 ){
        die;
    }

    while(my $line_ref = $csv->getline($self->{FH})){
        my @array =  @{ $line_ref };
        my @grep = grep(!/^$/, @array);
        if ( $col_num == 1 ){
            @array_judge = @grep;
            shift @array_judge;
            $judge_num = scalar(@array_judge);
        } else {
            push @array_dantai, $grep[0];
            for (my $for_num = 1; $for_num <= $judge_num; $for_num++ ){
                my $prefix = "judge\_$for_num";
                push @{ $push->{$prefix} }, $grep[$for_num];
            }
        }
        $row_num = scalar(@grep);
        $col_num++;
        shift @{ $line_ref };

    }
    
    for (my $for_num = 1; $for_num <= $judge_num; $for_num++ ){
        my $prefix = "judge\_$for_num";
        $getjudge->{$prefix} = my $judge_1 = &_getjudge( \@array_dantai, $push->{$prefix} );
    }

    return {
        row_num => $row_num,
        col_num => $col_num,
        array_judge => \@array_judge,
        array_dantai => \@array_dantai,
        judge => {
            judge_1 => $getjudge->{judge_1}||undef,
            judge_2 => $getjudge->{judge_2}||undef,
            judge_3 => $getjudge->{judge_3}||undef,
            judge_4 => $getjudge->{judge_4}||undef,
            judge_5 => $getjudge->{judge_5}||undef,
            judge_6 => $getjudge->{judge_6}||undef,
            judge_7 => $getjudge->{judge_7}||undef,
            judge_8 => $getjudge->{judge_8}||undef,
            judge_9 => $getjudge->{judge_9}||undef,
            judge_10 => $getjudge->{judge_10}||undef,
            judge_11 => $getjudge->{judge_11}||undef,
        },
    }
}

sub _getjudge {
    my ( $array_judge, $array_ranking ) = @_ ;
    my $judge;
    my $dantai;
    my $i = 0;

    my @array = @{ $array_ranking };

    foreach my $hoge (@{ $array_judge }){
        $dantai->{$hoge} = $array[$i];
        $i++;
    };
    
    ##ハッシュの値でソートし、キー（団体名）だけ取得
    foreach my $key (sort { %{$dantai}{$a} <=> %{$dantai}{$b} } keys %{ $dantai} ) {
        push @{ $judge }, $key;
    }
    return $judge;
}

sub _csvcheck {
    my ( $self, $csv, $fh ) = @_ ;
    #CSVファイルの行あたりのカラム数をチェック
    ### カラム数が指定値未満の場合にエラー
    ### カラム数が一致しない場合にエラー
    ### 読み込んだファイルがCSVファイルのフォーマットで無い場合、エラー
    return 0;
}

1;
__END__

=encoding utf-8

=head1 NAME

ShinMasuzawa::GetData- It's new $module

=head1 SYNOPSIS

    use ShinMasuzawa::GetData;
    my $get = ShinMasuzawa::GetData->new(
        csv_file => '/tmp/hoge.csv',
    );
    my $data = $get->csv;

=head1 DESCRIPTION

ShinMasuzawa::GetDataaは、新増沢式採点法（新増沢方式）の審査表データを読み込むモジュールです。
現在はCSVファイル（文字コードはShift-JIS）からデータを読み込む機能だけです。

=head1 LICENSE

Copyright (C) Keiji Kawabata.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Keiji Kawabata E<lt>bata64@gmail.comE<gt>

=cut
