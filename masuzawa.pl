#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/extlib/lib/perl5";
use lib "$FindBin::Bin/lib";

use Data::Dumper;

# CPAN Module
use Log::Handler;
use POSIX;
use Math::Combinatorics;

# Bata Module
use ShinMasuzawa::FormatCheck;

# 各種設定
my $proc = "Process-0";
my $proc_org;
my $logdir = "./logs";
my $name_1st;
my $name_2st;
my $name_3st;
my $rank  = 1;


### 出場団体の定義
my $dantai = ['A','B','C','D','E'];

### 出場団体数の定義
my $dantainum = scalar @$dantai;

### 順位表の定義
my $judge = {
    judge_1 => ['A','B','E','D','C'],
    judge_2 => ['C','E','B','D','A'],
    judge_3 => ['C','B','E','D','A'],
    judge_4 => ['E','B','C','D','A'],
    judge_5 => ['E','B','C','D','A'],
    judge_6 => ['B','E','C','D','A'],
    judge_7 => ['B','E','C','D','A'],
};

### 獲得数格納用変数の定義
my $kakutokunum;

### 仮の一位団体の情報格納用変数の定義
my $kari1st;

### 仮の二位団体の情報格納用変数の定義
my $kari2st;

### 仮の三位団体の情報格納用変数の定義
my $kari3st;

### 総合順位格納用配列の定義
my @array_total_rank = ();

### 審査員の数の取得
my $judgenum = keys(%$judge);

# set for Log::Handler
my $log = Log::Handler->new();
$log->add(
    file => {
        filename => "$logdir/masuzawa.log",
        timeformat => "%Y%m%d %H:%M:%S %z",
        maxlevel => 7,
        minlevel => 0,
        message_layout => "%T %L %m",
    }
);
$log->add(
    file => {
        filename => "$logdir/masuzawa.log_error",
        timeformat => "%Y-%m-%d %H:%M:%S",
        maxlevel => 4,
        minlevel => 0,
        message_layout => "%T %L %m (%C)",
    }
);

# set for ShinMasuzawa::FormatCheck
my $chk = ShinMasuzawa::FormatCheck->new(
        proc => $proc,
        proc_org => $proc_org,
        dantai => $dantai,
        dantainum => $dantainum,  #出場団体数
        judge => $judge,            #順位表
        judgenum => $judgenum,      #審査員の数
        log => $log,
);

################################################################################
# Process0 フォーマットチェック
################################################################################
$proc = "Process-0";
$proc_org = $proc;
$log->info("$proc","フォーマットチェック 開始");

### 審査員の数の確認(奇数ならOK)
$proc = "${proc}-1";
$log->info("$proc","審査員数の確認 開始");

$chk->check_JudgeAndDantai;
exit 1;

$chk->{proc} = $proc;
my $kahansu = $chk->check_JudgeNum;

$log->info("$proc","審査員数の確認 終了");
$proc = $proc_org;

### 順位表に記載されている団体数が一致するか確認
$proc = "${proc}-2";
$log->info("$proc","順位表記載の団体数が正しいか確認 開始");

$chk->{proc} = $proc;
$chk->check_GroupNum;

$log->info("$proc","順位表記載の団体数が正しいか確認 終了");

$proc = $proc_org;
$log->info("$proc","フォーマットチェック 終了");

################################################################################
# Process1 獲得数の取得
################################################################################

###while ($judge->{'judge_1'}->[0]){
while (@$dantai){

    ### 獲得数格納用変数の初期化
    $kakutokunum = undef;
    ### 仮の第一位団体の情報格納用変数の初期化
    $kari1st = undef;
    ### 仮の第二位団体の情報格納用変数の初期化
    $kari2st = undef;
    ### 仮の第三位団体の情報格納用変数の初期化
    $kari3st = undef;

    $proc = "Process-$rank-1";
    $log->info("$proc","$rank 回目の順位表評価");
    $log->info("$proc","獲得数の取得 開始");
    ###各団体の獲得数の取得
    ###各配列の先頭の値を検索してカウント
    foreach my $dantaimei (@$dantai){
        $kakutokunum->{$dantaimei} = 0;
        foreach my $hash_value (keys %$judge){
            my $top_dantai = $judge->{$hash_value}[0];
            if ( $dantaimei eq $top_dantai ){
                $kakutokunum->{$dantaimei} += 1;
            }
        }
    }

    ### 各団体の獲得数を表示
    my %hash_kakutokunum = %$kakutokunum;
    foreach my $name ( sort keys %hash_kakutokunum ){
        
        $log->info("$proc","団体名 $name の獲得数は $hash_kakutokunum{$name} です。");
    }
    $log->info("$proc","獲得数の取得 終了");

################################################################################
# 仮の順位の決定(仮の第一位から第三位)
################################################################################
    $proc = "Process-$rank-2";
    $log->info("$proc","仮の第一位から第三位の決定 開始");
    ### 「仮の第一位」、「仮の第二位」、「仮の第三位」およびそれぞれの獲得数を取得する
    ($kari1st, $kari2st, $kari3st) = &determinePreRank(%hash_kakutokunum);
    ### 「仮の第一位」、「仮の第二位」、「仮の第三位」の出力
    &print_1_2_3($kari1st, $kari2st, $kari3st);
    
    $log->info("$proc","仮の第一位から第三位の決定 終了");

################################################################################
# 最上位団体の決定
################################################################################
    $proc = "Process-$rank-3";
    $log->info("$proc","総合第 $rank 位の決定 開始");
##    my $top_dantai = &detarmineTop($kari1st, $kari2st, $kari3st, $rank);
    my $top_dantai = &detarmineTop($kari1st, $kari2st, $kari3st, $rank);
    push @array_total_rank, $top_dantai;

################################################################################
# 確定した最上位団体を除いた順位表を作成
################################################################################
    $proc = "Process-$rank-4";
    $log->info("$proc","$top_dantai を除いた順位表の作成 開始");
    &makeNewRanking($top_dantai);
    $log->info("$proc","$top_dantai を除いた順位表の作成 終了");
    $log->info("$proc","総合第 $rank 位の決定 終了");
    $rank++;
}

$log->info("$proc","総合順位は以下の通りです。");
my $counter = 1;
foreach my $dantai ( @array_total_rank ){
    $log->info("$proc","第 $counter 位： $dantai ");
    $counter++;
}

################################################################################
# sub detarmineTop 最上位団体の決定
################################################################################
sub detarmineTop{
    my ($kari1st, $kari2st, $kari3st, $rank) = @_;
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

################################################################################
# sub determinePreRank 仮の順位の決定(仮の第一位から第三位)
################################################################################
sub determinePreRank{
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

################################################################################
# sub makeNewRanking 順位決定団体を除いた順位表を作成
################################################################################
sub makeNewRanking{
    my ( $top_dantai ) = @_;
    foreach my $hash_value (keys %$judge){
        my $counter = 0;
        foreach my $name (@{$judge->{$hash_value}}){
            if ( $name eq $top_dantai){
                splice (@{$judge->{$hash_value}},$counter,1);
            }
            $counter++;
        }
    }
    $counter = 0;
    foreach my $name (@$dantai){
        if ( $name eq $top_dantai ){
            splice (@$dantai,$counter,1);
        }
        $counter++;
    }
}

################################################################################
# sub print_1_2_3 仮の一位、二位、三位の団体名と獲得数をログに出力
################################################################################
sub print_1_2_3{
    my ( $kari1, $kari2, $kari3 ) = @_;
    ### 仮の第一位の団体名と獲得数をログ出力
    $log->info("$proc","仮の第一位とその獲得数は以下の通りです。");
    foreach my $name ( sort keys %$kari1 ){
        $log->info("$proc","団体名: $name 獲得数: $kari1->{$name}");
    }
    ### 仮の第二位が存在する場合、団体名と獲得数をログ出力
    if ( defined $kari2 ){
        $log->info("$proc","仮の第二位とその獲得数は以下の通りです。");
        foreach my $name ( sort keys %$kari2 ){
            $log->info("$proc","団体名: $name 獲得数: $kari2->{$name}");
        }
    } else{
        $log->info("$proc","仮の第二位の団体は存在しません。");
    }
    ### 仮の第三位が存在する場合、団体名と獲得数をログ出力
    if ( defined $kari3 ){
        $log->info("$proc","仮の第三位とその獲得数は以下の通りです。");
        foreach my $name ( sort keys %$kari3 ){
            $log->info("$proc","団体名: $name 獲得数: $kari3->{$name}");
        }
    } else{
        $log->info("$proc","仮の第三位の団体は存在しません。");
    }
}

################################################################################
# sub kessen 決選投票の実施
################################################################################
sub kessen{
    my ( @array_for_kessen ) = @_;
    my $name_1 = $array_for_kessen[0];
    my $name_2 = $array_for_kessen[1];
    my $kessen_result;
    my $counter_1 = 0;
    my $counter_2 = 0;
    $log->info("$proc","$name_1 と $name_2 の決選投票 開始");
    foreach my $judgeseat (sort keys %$judge){
        my $kessen_result = undef;
        my $counter = 1;
        my $array_ref = $judge->{$judgeseat};
        foreach my $jyuni (@$array_ref){
            if ( $name_1 eq $jyuni ){
                $log->info("$proc","審査員 $judgeseat の、$name_1 の順位は 第 $counter 位です。");
                $kessen_result->{$name_1} = $counter;
            } elsif ( $name_2 eq $jyuni ){
                $log->info("$proc","審査員 $judgeseat の、$name_2 の順位は 第 $counter 位です。");
                $kessen_result->{$name_2} = $counter;
            }
            $counter++;
        }
        if ( $kessen_result->{$name_1} < $kessen_result->{$name_2} ){
            $counter_1++;
            $log->info("$proc","審査員 $judgeseat の順位表では、$name_1 の方が上位です。");
        } else {
            $counter_2++;
            $log->info("$proc","審査員 $judgeseat の順位表では、$name_2 の方が上位です。");
        }
        $log->info("$proc","$name_1 が $counter_1 ポイント、$name_2 が $counter_2 ポイントになりました。");
    }
    if ( $counter_1 > $counter_2 ){
        $log->info("$proc","よって、$counter_1 対 $counter_2 で、$name_1 が決選投票の勝者となります。");
        return $name_1;
    } else {
        $log->info("$proc","よって、$counter_2 対 $counter_1 で、$name_2 が決選投票の勝者となります。");
        return $name_1;
    }
    $log->info("$proc","$name_1 と $name_2 の決選投票 終了");
}

################################################################################
# sub kachipoint 勝ちポイント選抜の実施
################################################################################
sub kachipoint{
    my ( $kari1st ) = @_;
    my @dantai_mei = ();
    my $kekka_kachipoint;
    my $top_kachipoint;
    my $counter = 1;
    $proc_org = $proc;
    ### 勝ちポイント選抜を行う団体名の抽出
    foreach my $hash_value (keys %$kari1st){
        push @dantai_mei, $hash_value;
    }
    $log->info("$proc","@dantai_mei の勝ちポイント選抜 開始");
    ### 勝ちポイント選抜実施団体の、2団体の組み合わせ(nC2)計算実施
    my @array_combine = combine(2,@dantai_mei);	#C(3,2)
    ### 各2団体の組み合わせについて、決選投票を実施
    foreach my $combine (sort { $b cmp $a } @array_combine){
        $proc = $proc_org;
        $proc = "${proc}-${counter}";
        $log->info("$proc","第 $counter 回戦");
        ### 決選投票実行
        my $dantai = &kessen(@$combine);
        $log->info("$proc","@$combine の 対決の勝者は、$dantai です。");
        foreach my $hash_value (keys %$kari1st){
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
    $log->info("$proc","@dantai_mei の勝ちポイント選抜の結果は、以下の通りです。");
    my %hash_kekka = %$kekka_kachipoint;
    $counter = 0;
    foreach my $name ( sort { $hash_kekka{$b} <=> $hash_kekka{$a} } keys %hash_kekka ){
        $log->info("$proc","団体： $name 勝ちポイント： $hash_kekka{$name}");
        if ( $counter == 0 ){
            $top_kachipoint = $name;
        }
        $counter++;
    }
    $log->info("$proc","よって勝ちポイント選抜の勝者は、$top_kachipoint です。");
    return $top_kachipoint;
}
