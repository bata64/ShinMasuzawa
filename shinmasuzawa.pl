use strict;
use warnings;
use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin/extlib/lib/perl5";
use lib "$FindBin::Bin/extlib";
use lib "$FindBin::Bin/lib";
use utf8;
use Encode;
use Carp ();

### CPAN Module
use Log::Handler;
use POSIX;
use Math::Combinatorics;
use Text::CSV;

use ShinMasuzawa::GetData;
use ShinMasuzawa::FormatCheck;
use ShinMasuzawa::Kakutokusu;
use ShinMasuzawa::PreRank;
use ShinMasuzawa::DetarmineTop;
use ShinMasuzawa::MakeNewRanking;
use ShinMasuzawa::CreateOutputRanking;

### 設定ファイル読み込み
my $configfile = 'config/config.pl';
my $config = do $configfile;
Carp::croak("$configfile: $@") if $@;
Carp::croak("$configfile: $!") unless defined $config;
unless ( ref($config) eq 'HASH' ) {
    Carp::croak("$configfile does not return HashRef.");
}

### 入力CSVファイル
my $input_csv = $ARGV[0] || '新増沢方式審査用紙.csv';

### 出力CSVファイル
my $output_csv = $ARGV[1] || '総合順位表.csv';


### CSVファイルからデータを取得
my $get = ShinMasuzawa::GetData->new(
    csv_file => $input_csv,
);
my $data = $get->csv;

### 出場団体の定義
my $dantai = $data->{array_dantai};
my @dantai_org = @{ $dantai };

### 順位表の定義
my $judge = $data->{judge};

### 未定義の順位表を削除
foreach my $key(keys(%{ $judge })){
    if (!$judge->{$key}){
        delete($judge->{$key}); 
    }
}

### set for Log::Handler
my $log = Log::Handler->new();
$log->add(
    file => {
        filename => "$config->{logdir}/masuzawa.log",
        timeformat => "%Y%m%d %H:%M:%S %z",
        maxlevel => 7,
        minlevel => 0,
        message_layout => "%T %L %m",
    }
);
$log->add(
    file => {
        filename => "$config->{logdir}/masuzawa.log_error",
        timeformat => "%Y-%m-%d %H:%M:%S",
        maxlevel => 4,
        minlevel => 0,
        message_layout => "%T %L %m (%C)",
    }
);

my $proc = "Process-1";
my $proc_org = $proc;

my @array_total_rank = ();

# フォーマットチェック
my $chk = ShinMasuzawa::FormatCheck->new(
        dantai => $dantai,
        judge => $judge,
        judge_max => $config->{judge_max},
        judge_min => $config->{judge_min},
);

$log->info("$proc", encode_utf8 "審査表チェック開始");

if ( $chk->check_JudgeNum($proc, $log) != 0 ){
    exit;
}

if ( $chk->check_GroupNum($proc, $log) != 0 ){
    exit;
}

if ( $chk->check_JudgeAndDantai($proc, $log) != 0 ){
    exit;
}

$log->info("$proc", encode_utf8 "審査表チェック終了");

$proc = "Process-2";
$proc_org = $proc;
my $rank = 1;
###以降、順位表確定まで繰り返す
while (@{ $dantai }){
    $proc = "${proc_org}-1-$rank";
    $log->info("$proc", encode_utf8 "総合 $rank 位の決定");
    # 獲得数の取得
    $log->info("$proc", encode_utf8 "獲得数の取得 開始");
    my $kakutoku = ShinMasuzawa::Kakutokusu->new(
        dantai => $dantai,
        judge => $judge,
        rank => $rank,
    );
    my $kakutokusuu = $kakutoku->get($proc, $log);
    $log->info("$proc", encode_utf8 "獲得数の取得 終了");
    
    $proc = "${proc_org}-2-$rank";
    # 仮の順位の決定(仮の第一位から第三位)
    $log->info("$proc", encode_utf8 "仮の第一位から第三位の取得 開始");
    my $pre = ShinMasuzawa::PreRank->new(
        judge => $judge,
        rank => $rank,
    );
    my $prerank = $pre->get($kakutokusuu, $proc, $log);
    $log->info("$proc", encode_utf8 "仮の第一位から第三位の取得 終了");
    
    $proc = "${proc_org}-3-$rank";
    # 最上位団体の決定
    $log->info("$proc", encode_utf8 "最上位団体の決定 開始");
    my $top = ShinMasuzawa::DetarmineTop->new(
        judge => $judge,
        rank => $rank,
    );
    my $top_dantai = $top->get($prerank, $proc, $log);
    $log->info("$proc", encode_utf8 "総合第 $rank 位は、$top_dantai です。");
    $log->info("$proc", encode_utf8 "最上位団体の決定 終了");
if (!$top_dantai){
    die;
}    
    push @array_total_rank, $top_dantai;
    
    # 確定した最上位団体を除いた順位表を作成
    my $newrank = ShinMasuzawa::MakeNewRanking->new(
        judge => $judge,
        dantai => $dantai,
    );
    $newrank->make($top_dantai);    
    $rank++;
    $top_dantai = undef;
    
}

$log->info("$proc", encode_utf8 "総合順位は以下の通りです。");
$rank = 1;
foreach my $ranking (@array_total_rank){
    $log->info("$proc", encode_utf8 "総合第 $rank 位 $ranking ");
    $rank++;
}

# 総合順位表CSVファイルを作成
##CSVファイルからデータを取得
$get = ShinMasuzawa::GetData->new(
    csv_file => $input_csv,
);
$data = $get->csv;
$judge = $data->{judge};
### 未定義の順位表を削除
foreach my $key(keys(%{ $judge })){
    if (!$judge->{$key}){
        delete($judge->{$key}); 
    }
}

my $output = ShinMasuzawa::CreateOutputRanking->new(
    dantai => $data->{dantai},
    judge => $data->{judge},
    judge_name => $data->{array_judge},
    total_rank => \@array_total_rank,
    csv_file => $output_csv,
);
$output->make;

$log->info("$proc", encode_utf8 "全処理終了");