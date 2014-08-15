package ShinMasuzawa::CreateOutputRanking;

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
    open my $csvf, '>:encoding(cp932)', $self->{csv_file} or die("error :$!");
    $self->{FH} = $csvf;
    $self;
}

sub make {
    my ( $self, $filename ) = @_ ;
    my @first_array = @{ $self->{judge_name} };
    my @total_rank = @{ $self->{total_rank} };
    my $judge = $self->{judge};
    my $csv = Text::CSV->new({
        binary => 1,
        auto_diag => 1,
        eol => "\r\n",
    });
    
    my @num_col = ();
    my @rank_col = ();
    my $counter = 1;
    foreach my $col_data (@{ $self->{total_rank} }){
        push @num_col, $counter;
        $counter++;
    }
    my %hash_judge = %{ $judge }; 
    ### 一行目
    unshift @first_array, '順位';
    push @first_array, '総合順位';
    $csv->print($self->{FH}, \@first_array);
    
    ### 二行目以降
    $counter = 0;
    foreach my $num_counter (@num_col){
        @rank_col = ();
        push @rank_col, $num_counter; 
        foreach my $judgeseat ( sort {$a cmp $b} keys %hash_judge ){
            my $result_per_judge = $judge->{$judgeseat};
            push @rank_col, $result_per_judge->[$counter];
            foreach my $jyuni (@{ $result_per_judge }){
            }
        }
        push @rank_col, $total_rank[$counter]; 
        $csv->print($self->{FH}, \@rank_col);
        $counter++;
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

ShinMasuzawa::CreateOutputRanking- It's new $module

=head1 SYNOPSIS

    use ShinMasuzawa::CreateOutputRanking;
    my $get = ShinMasuzawa::CreateOutputRanking->new(
        csv_file => '/tmp/hoge.csv',
    );
    my $data = $get->csv;

=head1 DESCRIPTION

ShinMasuzawa::CreateOutputRankingaは、新増沢式採点法（新増沢方式）の審査表データを読み込むモジュールです。
現在はCSVファイル（文字コードはShift-JIS）からデータを読み込む機能だけです。

=head1 LICENSE

Copyright (C) Keiji Kawabata.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Keiji Kawabata E<lt>bata64@gmail.comE<gt>

=cut
