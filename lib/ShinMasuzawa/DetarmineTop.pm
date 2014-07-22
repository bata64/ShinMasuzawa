package ShinMasuzawa::DetarmineTop;
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
    my ($self, $kari1st, $kari2st, $kari3st, $rank) = @_;

    my $TOP;
    my $SECOUND;
    ### 各「仮の○位」の団体数を変数に代入
    my $num_1st = keys(%$kari1st);
    my $num_2st = keys(%$kari2st);
    my $num_3st = keys(%$kari3st);
    ### 各「仮の○位」の獲得数を変数に代入
    my $kakutoku_1st = 0;
    my $kakutoku_2st = 0;
    my $kakutoku_3st = 0;
    if ( defined($kari1st) ) {
        foreach my $hash_value (keys %$kari1st){
            $kakutoku_1st += $kari1st->{$hash_value};
        }
    }
    if ( defined($kari2st) ) {
        foreach my $hash_value (keys %$kari2st){
            $kakutoku_2st += $kari2st->{$hash_value};
        }
    }
    if ( defined($kari3st) ) {
        foreach my $hash_value (keys %$kari3st){
            $kakutoku_3st += $kari3st->{$hash_value};
            last;
        }
    }
    
    ### 「仮の第1位」と「仮の第2位」の獲得数の合計を変数に代入
    my $kakutoku_1_2 = $kakutoku_1st + $kakutoku_2st;
    
    ###ルール1：「仮の第1位」が1団体だけで、かつ、その獲得数が審査員の半数を超えた場合は、その団体が総合第1位となる。
    if ( $num_1st == 1 && $kakutoku_1st > $kahansu ){
        foreach my $hash_value (keys %$kari1st){
            $TOP = $hash_value;
        }
        $log->info("$proc","ルール1「「仮の第1位」が1団体だけで、かつ、その獲得数が審査員の半数を超えた場合は、その団体が総合第1位となる。」が適用されます。");
        $log->info("$proc","総合第 $rank 位は、$TOP です。");
    ###ルール2：「仮の第1位」が2団体存在し、かつ、両者の獲得数の合計が半数を超える場合には、その2団体で決選投票を行い、総合第1位を決定する。
    } elsif ( $num_1st == 2 && $kakutoku_1st > $kahansu ){
        $log->info("$proc","ルール2「「仮の第1位」が2団体存在し、かつ、両者の獲得数の合計が半数を超える場合には、その2団体で決選投票を行い、総合第1位を決定する。」が適用されます。");
        my @array_for_kessen = ();
        foreach my $hash_value (keys %$kari1st){
            push @array_for_kessen, $hash_value;
        }
        ### 決選投票の実行
        $TOP = &kessen(@array_for_kessen);
        $log->info("$proc","総合第 $rank 位は、$TOP です。");
    ###ルール3：「仮の第1位」が3団体以上存在し、かつ、「仮の第1位」全員の獲得数の合計が半数を超える場合には、それらの団体で勝ちポイント選抜を行い、総合第1位を決定する。
    } elsif ( $num_1st >= 2 && $kakutoku_1st > $kahansu ){
        $log->info("$proc","ルール3「「仮の第1位」が3団体以上存在し、かつ、「仮の第1位」全員の獲得数の合計が半数を超える場合には、それらの団体で勝ちポイント選抜を行い、総合第1位を決定する。」が適用されます。");
        ### 勝ちポイント選抜の実行
        $TOP = &kachipoint($kari1st);
    ###ルール4：「仮の第1位」の獲得数が半数を超えず、「仮の第1位」と「仮の第2位」の獲得数の合計が半数を超えた場合
    } elsif ( $num_1st == 1 && $kakutoku_1st <= $kahansu && $kakutoku_1_2 > $kahansu ){
        $log->info("$proc","ルール4「「仮の第1位」の獲得数が半数を超えず、「仮の第1位」と「仮の第2位」の獲得数の合計が半数を超えた場合」が適用されます。");
        ###「仮の第2位」が一団体の場合、「仮の第1位」と「仮の第2位」によって決選投票を行い、総合第1位を決定する。
        if ( $num_2st == 1 ){
            $log->info("$proc","「仮の第2位」が1団体なので、「仮の第1位」と「仮の第2位」によって決選投票を行い、総合第1位を決定します。");
            my @array_for_kessen = ();
            foreach my $hash_value (keys %$kari1st){
                push @array_for_kessen, $hash_value;
            }
            foreach my $hash_value (keys %$kari2st){
                push @array_for_kessen, $hash_value;
            }
            ### 決選投票の実行
            $TOP = &kessen(@array_for_kessen);
            $log->info("$proc","総合第 $rank 位は、$TOP です。");
        ###「仮の第2位」が複数存在する場合には、最初に「仮の第2位」の団体において決選投票又は勝ちポイント選抜を行い、「第1位候補」を1団体だけ選抜する。次に、「仮の第1位」と「第1位候補」とで決選投票を行い、総合第1位を決定する。
        } else {
            ###「仮の第2位」が2団体の場合は決選投票を行い、「第1位候補」を選抜する。
            if ( $num_2st == 2 ){
                $log->info("$proc","「仮の第2位」が2団体なので、「仮の第2位」同士で決選投票を行い、「第1位候補」を選抜します。");
                my @array_for_kessen = ();
                foreach my $hash_value (keys %$kari2st){
                    push @array_for_kessen, $hash_value;
                }
                ### 決選投票の実行
                $SECOUND = &kessen(@array_for_kessen);
            ###「仮の第2位」が3団体以上の場合は勝ちポイント選抜を行い、「第1位候補」を選抜する。
            } elsif ( $num_2st <= 3) {
                $log->info("$proc","「仮の第2位」が3団体以上なので、「仮の第2位」同士で勝ちポイント選抜を行い、「第1位候補」を選抜します。");
                ### 勝ちポイント選抜の実行
                $SECOUND = &kachipoint($kari2st);
            }
            ###「仮の第1位」と「第1位候補」とで決選投票を行う
            my @array_for_kessen = ();
            foreach my $hash_value (keys %$kari1st){
                $log->info("$proc","「仮の第1位」は、$hash_value です。");
                push @array_for_kessen, $hash_value;
            }
            $log->info("$proc","「第1位候補」は、$SECOUND です。");
            push @array_for_kessen, $SECOUND;
            ### 決選投票の実行
            $TOP = &kessen(@array_for_kessen);
            $log->info("$proc","総合第 $rank 位は、$TOP です。");
        }
    }
    
    return $TOP;
}

1;
__END__

=encoding utf-8

=head1 NAME

ShinMasuzawa::DetarmineTop - It's new $module

=head1 SYNOPSIS

    use ShinMasuzawa::DetarmineTop;

=head1 DESCRIPTION

ShinMasuzawa::DetarmineTop is ...

=head1 LICENSE

Copyright (C) Keiji Kawabata.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Keiji Kawabata E<lt>kawabata.keiji@toshiba-sol.co.jpE<gt>

=cut

