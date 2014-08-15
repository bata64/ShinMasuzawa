package ShinMasuzawa::DetarmineTop;
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

sub get {
    my ( $self, $prerank, $proc, $log ) = @_;
    my $judge = $self->{judge};
    my $rank = $self->{rank};
    my $judgenum= keys(%{ $judge });

    ### 過半数を取得（2で割って切り上げ）
    my $kahansu = ceil(${judgenum}/2);

    my $kari1st = $prerank->{kari1st};
    my $kari2nd = $prerank->{kari2nd};
    my $kari3rd = $prerank->{kari3rd};

    my $TOP;
    my $SECOUND;
    ### 各「仮の○位」の団体数を変数に代入
    my $num_1st = keys(%{ $kari1st });
    my $num_2nd = keys(%{ $kari2nd });
    my $num_3rd = keys(%{ $kari3rd });
    ### 各「仮の○位」の獲得数を変数に代入
    my $kakutoku_1st = 0;
    my $kakutoku_2st = 0;
    my $kakutoku_3st = 0;
    if ( defined($kari1st) ) {
        foreach my $hash_value (keys %{ $kari1st }){
            $kakutoku_1st += $kari1st->{$hash_value};
        }
    }
    if ( defined($kari2nd) ) {
        foreach my $hash_value (keys %{ $kari2nd }){
            $kakutoku_2st += $kari2nd->{$hash_value};
        }
    }
    if ( defined($kari3rd) ) {
        foreach my $hash_value (keys %{ $kari3rd }){
            $kakutoku_3st += $kari3rd->{$hash_value};
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
        $log->info("$proc", encode_utf8 "ルール1「「仮の第1位」が1団体だけで、かつ、その獲得数が審査員の半数を超えた場合は、その団体が総合第1位となる。」が適用されます。");
        $log->info("$proc", encode_utf8 "総合第 $rank 位は、$TOP です。");
    ###ルール2：「仮の第1位」が2団体存在し、かつ、両者の獲得数の合計が半数を超える場合には、その2団体で決選投票を行い、総合第1位を決定する。
    } elsif ( $num_1st == 2 && $kakutoku_1st > $kahansu ){
        $log->info("$proc", encode_utf8 "ルール2「「仮の第1位」が2団体存在し、かつ、両者の獲得数の合計が半数を超える場合には、その2団体で決選投票を行い、総合第1位を決定する。」が適用されます。");
        my @array_for_kessen = ();
        foreach my $hash_value (keys %{ $kari1st }){
            push @array_for_kessen, $hash_value;
        }
        ### 決選投票の実行
        $TOP = &kessen($self, \@array_for_kessen, $proc, $log);
        $log->info("$proc", encode_utf8 "総合第 $rank 位は、$TOP です。");
    ###ルール3：「仮の第1位」が3団体以上存在し、かつ、「仮の第1位」全員の獲得数の合計が半数を超える場合には、それらの団体で勝ちポイント選抜を行い、総合第1位を決定する。
    } elsif ( $num_1st >= 2 && $kakutoku_1st > $kahansu ){
        $log->info("$proc", encode_utf8 "ルール3「「仮の第1位」が3団体以上存在し、かつ、「仮の第1位」全員の獲得数の合計が半数を超える場合には、それらの団体で勝ちポイント選抜を行い、総合第1位を決定する。」が適用されます。");
        ### 勝ちポイント選抜の実行
        $TOP = &kachipoint($self, $kari1st, $proc, $log);
    ###ルール4：「仮の第1位」の獲得数が半数を超えず、「仮の第1位」と「仮の第2位」の獲得数の合計が半数を超えた場合
    } elsif ( $kakutoku_1st <= $kahansu && $kakutoku_1_2 > $kahansu ){
        $log->info("$proc", encode_utf8 "ルール4「「仮の第1位」の獲得数が半数を超えず、「仮の第1位」と「仮の第2位」の獲得数の合計が半数を超えた場合」が適用されます。");
        ###「仮の第2位」が一団体の場合、「仮の第1位」と「仮の第2位」によって決選投票を行い、総合第1位を決定する。
        if ( $num_2nd == 1 ){
            $log->info("$proc", encode_utf8 "「仮の第2位」が1団体なので、「仮の第1位」と「仮の第2位」によって決選投票を行い、総合第1位を決定します。");
            my @array_for_kessen = ();
            foreach my $hash_value (keys %{ $kari1st }){
                push @array_for_kessen, $hash_value;
            }
            foreach my $hash_value (keys %{ $kari2nd }){
                push @array_for_kessen, $hash_value;
            }
            ### 決選投票の実行
            $TOP = &kessen($self, \@array_for_kessen, $proc, $log);
            $log->info("$proc", encode_utf8 "総合第 $rank 位は、$TOP です。");
        ###「仮の第2位」が複数存在する場合には、最初に「仮の第2位」の団体において決選投票又は勝ちポイント選抜を行い、「第1位候補」を1団体だけ選抜する。次に、「仮の第1位」と「第1位候補」とで決選投票を行い、総合第1位を決定する。
        } else {
            ###「仮の第2位」が2団体の場合は決選投票を行い、「第1位候補」を選抜する。
            if ( $num_2nd == 2 ){
                $log->info("$proc", encode_utf8 "「仮の第2位」が2団体なので、「仮の第2位」同士で決選投票を行い、「第1位候補」を選抜します。");
                my @array_for_kessen = ();
                foreach my $hash_value (keys %{ $kari2nd }){
                    push @array_for_kessen, $hash_value;
                }
                ### 決選投票の実行
                $SECOUND = &kessen($self, \@array_for_kessen, $proc, $log);
            ###「仮の第2位」が3団体以上の場合は勝ちポイント選抜を行い、「第1位候補」を選抜する。
            } elsif ( $num_2nd >= 3) {
                $log->info("$proc", encode_utf8 "「仮の第2位」が3団体以上なので、「仮の第2位」同士で勝ちポイント選抜を行い、「第1位候補」を選抜します。");
                ### 勝ちポイント選抜の実行
                $SECOUND = &kachipoint($self, $kari2nd, $proc, $log);
            }
            ###「仮の第1位」と「第1位候補」とで決選投票を行う
            my @array_for_kessen = ();
            foreach my $hash_value (keys %{ $kari1st }){
                $log->info("$proc", encode_utf8 "「仮の第1位」は、$hash_value です。");
                push @array_for_kessen, $hash_value;
            }
            $log->info("$proc", encode_utf8 "「第1位候補」は、$SECOUND です。");
            push @array_for_kessen, $SECOUND;
            ### 決選投票の実行
            $TOP = &kessen($self, \@array_for_kessen, $proc, $log);
            $log->info("$proc", encode_utf8 "総合第 $rank 位は、$TOP です。");
        }
    }
    return $TOP;
}

sub kessen{
    my ( $self, $array_for_kessen, $proc, $log ) = @_;
    my $judge = $self->{judge};
    my $name_1 = $array_for_kessen->[0];
    my $name_2 = $array_for_kessen->[1];
    my $kessen_result;
    my $counter_1 = 0;
    my $counter_2 = 0;
    
    $log->info("$proc", encode_utf8 "$name_1 と $name_2 の決選投票 開始");
    foreach my $judgeseat (sort keys %{ $judge }){
        $kessen_result = undef;
        my $counter = 1;
        my $result_per_judge = $judge->{$judgeseat};
        foreach my $jyuni (@{ $result_per_judge }){
            if ( $name_1 eq $jyuni ){
                $log->info("$proc", encode_utf8 "審査員 $judgeseat の、$name_1 の順位は 第 $counter 位です。");
                $kessen_result->{$name_1} = $counter;
            } elsif ( $name_2 eq $jyuni ){
                $log->info("$proc", encode_utf8 "審査員 $judgeseat の、$name_2 の順位は 第 $counter 位です。");
                $kessen_result->{$name_2} = $counter;
            }
            $counter++;
        }
        if ( $kessen_result->{$name_1} < $kessen_result->{$name_2} ){
            $counter_1++;
            $log->info("$proc", encode_utf8 "審査員 $judgeseat の順位表では、$name_1 の方が上位です。");
        } else {
            $counter_2++;
            $log->info("$proc", encode_utf8 "審査員 $judgeseat の順位表では、$name_2 の方が上位です。");
        }
        $log->info("$proc", encode_utf8 "$name_1 が $counter_1 ポイント、$name_2 が $counter_2 ポイントになりました。");
    }
    if ( $counter_1 > $counter_2 ){
        $log->info("$proc", encode_utf8 "よって、$counter_1 対 $counter_2 で、$name_1 が決選投票の勝者となります。");
        return $name_1;
    } else {
        $log->info("$proc", encode_utf8 "よって、$counter_2 対 $counter_1 で、$name_2 が決選投票の勝者となります。");
        return $name_2;
    }
    $log->info("$proc", encode_utf8 "$name_1 と $name_2 の決選投票 終了");
}

sub kachipoint{
    my ( $self, $kari_dantai, $proc, $log ) = @_;
    my @dantai_mei = ();
    my $kekka_kachipoint;
    my $top_kachipoint;
    my $counter = 1;
    my $proc_org = $proc;
    ### 勝ちポイント選抜を行う団体名の抽出
    foreach my $hash_value (keys %{ $kari_dantai }){
        push @dantai_mei, $hash_value;
    }
    $log->info("$proc", encode_utf8 "@dantai_mei の勝ちポイント選抜 開始");
    ### 勝ちポイント選抜実施団体の、2団体の組み合わせ(nC2)計算実施
    my @array_combine = combine(2,@dantai_mei);	#C(3,2)
    ### 各2団体の組み合わせについて、決選投票を実施
    foreach my $combine (sort { $b cmp $a } @array_combine){
        $proc = $proc_org;
        $proc = "${proc}\-${counter}";
        $log->info("$proc", encode_utf8 "第 $counter 回戦");
        ### 決選投票実行
        my $dantai = &kessen($self, $combine, $proc, $log);
        $log->info("$proc", encode_utf8 "@{ $combine } の 対決の勝者は、$dantai です。");
        foreach my $hash_value (keys %{ $kari_dantai }){
            if ( !defined( $kekka_kachipoint->{$hash_value} ) ){
                $kekka_kachipoint->{$hash_value} = 0;
            }
            if ( $dantai eq $hash_value){
                $kekka_kachipoint->{$hash_value} += 1;
            }
        }
        $counter++;
    }
    $proc = $proc_org;
    $log->info("$proc", encode_utf8 "@dantai_mei の勝ちポイント選抜の結果は、以下の通りです。");
    my %hash_kekka = %{ $kekka_kachipoint };
    $counter = 0;
    foreach my $name ( sort { $hash_kekka{$b} <=> $hash_kekka{$a} } keys %hash_kekka ){
        $log->info("$proc", encode_utf8 "団体： $name 勝ちポイント： $hash_kekka{$name}");
        if ( $counter == 0 ){
            $top_kachipoint = $name;
        }
        $counter++;
    }
    $log->info("$proc", encode_utf8 "よって勝ちポイント選抜の勝者は、$top_kachipoint です。");
    return $top_kachipoint;
}

1;
__END__

=encoding utf-8

=head1 NAME

ShinMasuzawa::DetarmineTop - It's new $module

=head1 SYNOPSIS

    use ShinMasuzawa::DetarmineTop;
    my $pre = ShinMasuzawa::DetarmineTop->new(
        dantai => $dantai,
        judge => $judge,
    );
    my $prerank = $pre->get($kakutokusuu, $proc, $log);

=head1 DESCRIPTION

ShinMasuzawa::DetarmineTop は、新増沢式採点法（新増沢方式）にて最上位団体を決めます。

=head1 LICENSE

Copyright (C) Keiji Kawabata.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Keiji Kawabata E<lt>bata64@gmail.comE<gt>

=cut

