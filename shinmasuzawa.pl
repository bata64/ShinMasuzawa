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

### 設定ファイル読み込み
my $configfile = 'config/config.pl';
my $config = do $configfile;
Carp::croak("$configfile: $@") if $@;
Carp::croak("$configfile: $!") unless defined $config;
unless ( ref($config) eq 'HASH' ) {
    Carp::croak("$configfile does not return HashRef.");
}

##CSVファイルからデータを取得
my $get = ShinMasuzawa::GetData->new(
    csv_file => '新増沢方式審査用紙.csv',
);
my $data = $get->csv;

### 出場団体の定義
my $dantai = $data->{array_dantai};

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

my $rank = 1;
###以降、順位表確定まで繰り返す
#while (@{ $dantai }){
    # 獲得数の取得
    my $kakutoku = ShinMasuzawa::Kakutokusu->new(
        dantai => $dantai,
        judge => $judge,
        rank => $rank,
    );
    
    my $kakutokusuu = $kakutoku->get($proc, $log);

    # 仮の順位の決定(仮の第一位から第三位)

    # 最上位団体の決定

    # 確定した最上位団体を除いた順位表を作成
    $rank++;
#}



