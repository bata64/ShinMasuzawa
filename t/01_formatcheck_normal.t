use strict;
use Test::More 0.98;
use Test::Exception;

use Log::Handler;

use Data::Dumper;

use ShinMasuzawa::FormatCheck;

my $proc = "Process-0";
my $proc_org = $proc;
my $logdir = "./logs";

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

### 出場団体の定義
my $dantai_one    = ['A'];
my $dantai_two    = ['A','B'];
my $dantai_three  = ['A','B','C'];
my $dantai_four   = ['A','B','C','D'];
my $dantai_five   = ['A','B','C','D','E'];
my $dantai_six    = ['A','B','C','D','E','F'];
my $dantai_seven  = ['A','B','C','D','E','F','G'];
my $dantai_eight  = ['A','B','C','D','E','F','G','H'];
my $dantai_nine   = ['A','B','C','D','E','F','G','H','I'];
my $dantai_ten    = ['A','B','C','D','E','F','G','H','I','J'];
my $dantai_eleven = ['A','B','C','D','E','F','G','H','I','J','K'];
my $dantai_40th =   ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n'];

### 出場団体数の定義
my $dantainum_one = scalar @$dantai_one;
my $dantainum_two = scalar @$dantai_two;
my $dantainum_three = scalar @$dantai_three;
my $dantainum_four = scalar @$dantai_four;
my $dantainum_five = scalar @$dantai_five;
my $dantainum_six = scalar @$dantai_six;
my $dantainum_seven = scalar @$dantai_seven;
my $dantainum_eight = scalar @$dantai_eight;
my $dantainum_nine = scalar @$dantai_nine;
my $dantainum_ten = scalar @$dantai_ten;
my $dantainum_eleven = scalar @$dantai_eleven;
my $dantainum_40th = scalar @$dantai_40th;

### 順位表の定義
my $judge_three_two = {
    judge_01 => ['A','B'],
    judge_02 => ['B','A'],
    judge_03 => ['B','A'],
};

my $judge_five_five = {
    judge_01 => ['A','B','E','D','C'],
    judge_02 => ['C','E','B','D','A'],
    judge_03 => ['C','B','E','D','A'],
    judge_04 => ['E','B','C','D','A'],
    judge_05 => ['E','B','C','D','A'],
};

my $judge_five_six = {
    judge_01 => ['A','B','E','D','C','F'],
    judge_02 => ['C','E','B','D','F','A'],
    judge_03 => ['C','B','E','F','D','A'],
    judge_04 => ['E','B','F','C','D','A'],
    judge_05 => ['E','F','B','C','D','A'],
};

my $judge_five_seven = {
    judge_01 => ['A','B','E','D','C','F','G'],
    judge_02 => ['F','G','C','E','B','D','A'],
    judge_03 => ['C','B','F','G','E','D','A'],
    judge_04 => ['E','B','C','F','G','D','A'],
    judge_05 => ['E','B','C','D','F','G','A'],
};

my $judge_five_eight = {
    judge_01 => ['A','B','E','D','C','F','G','H'],
    judge_02 => ['F','G','C','E','B','H','D','A'],
    judge_03 => ['C','B','F','G','H','E','D','A'],
    judge_04 => ['E','B','C','H','F','G','D','A'],
    judge_05 => ['E','B','H','C','D','F','G','A'],
};

my $judge_eleven_40th = {
judge_01 =>  ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n'],
judge_02 =>  ['B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','A'],
judge_03 =>  ['C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','A','B'],
judge_04 =>  ['D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','A','B','C'],
judge_05 =>  ['E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','A','B','C','D'],
judge_06 =>  ['F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','A','B','C','D','E'],
judge_07 =>  ['G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','A','B','C','D','E','F'],
judge_08 =>  ['H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','A','B','C','D','E','F','G'],
judge_09 =>  ['I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','A','B','C','D','E','F','G','H'],
judge_10 => ['J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','A','B','C','D','E','F','G','H','I'],
judge_11 => ['K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','A','B','C','D','E','F','G','H','I','J'],
};

my @array_check_GroupNum = ();

### 審査員の数の取得
my $judgenum_three_two = keys(%$judge_three_two);
my $judgenum_five_five = keys(%$judge_five_five);
my $judgenum_five_six = keys(%$judge_five_six);
my $judgenum_five_seven = keys(%$judge_five_seven);
my $judgenum_five_eight = keys(%$judge_five_eight);
my $judgenum_eleven_40th = keys(%$judge_eleven_40th);

# 審査員3名、団体数2でのフォーマットチェック用設定
my $chk = ShinMasuzawa::FormatCheck->new(
    proc => $proc,
    proc_org => $proc_org,
    judgenum => $judgenum_three_two,
    dantainum => $dantainum_two,
    judge => $judge_three_two,
    dantai => $dantai_two,
    log => $log,
);

is( $chk->check_JudgeNum, '2', "3-2 kahansu is 2." );
@array_check_GroupNum = $chk->check_GroupNum;
is( $array_check_GroupNum[1], '2', "3-2 GroupNum is all 2."  );
is( $chk->check_JudgeAndDantai, '1', "3-2 Judge And Dantai Check is OK." );
# 審査員5名、団体数5でのフォーマットチェック用設定
my $chk = ShinMasuzawa::FormatCheck->new(
    proc => $proc,
    proc_org => $proc_org,
    judgenum => $judgenum_five_five,
    dantainum => $dantainum_five,
    judge => $judge_five_five,
    dantai => $dantai_five,
    log => $log,
);

is( $chk->check_JudgeNum, '3', "5-5 kahansu is 3." );
@array_check_GroupNum = $chk->check_GroupNum;
is( $array_check_GroupNum[1], '5', "5-5 GroupNum is all 5."  );
is( $chk->check_JudgeAndDantai, '1', "5-5 Judge And Dantai Check is OK." );

# 審査員5名、団体数6でのフォーマットチェック用設定
my $chk = ShinMasuzawa::FormatCheck->new(
    proc => $proc,
    proc_org => $proc_org,
    judgenum => $judgenum_five_six,
    dantainum => $dantainum_six,
    judge => $judge_five_six,
    dantai => $dantai_six,
    log => $log,
);
is( $chk->check_JudgeNum, '3', "5-6 kahansu is 3." );
@array_check_GroupNum = $chk->check_GroupNum;
is( $array_check_GroupNum[1], '6', "5-6 GroupNum is all 6."  );
is( $chk->check_JudgeAndDantai, '1', "5-6 Judge And Dantai Check is OK." );

# 審査員5名、団体数7でのフォーマットチェック用設定
$chk = ShinMasuzawa::FormatCheck->new(
    proc => $proc,
    judgenum => $judgenum_five_seven,
    dantainum => $dantainum_seven,
    judge => $judge_five_seven,
    dantai => $dantai_seven,
    log => $log,
);

is( $chk->check_JudgeNum, '3', "5-7 kahansu is 3." );
@array_check_GroupNum = $chk->check_GroupNum;
is( $array_check_GroupNum[1], '7', "5-7 GroupNum is all 7."  );
is( $chk->check_JudgeAndDantai, '1', "5-7 JudgeAnd Dantai Check is OK." );

# 審査員5名、団体数8でのフォーマットチェック用設定
$chk = ShinMasuzawa::FormatCheck->new(
    proc => $proc,
    judgenum => $judgenum_five_eight,
    dantainum => $dantainum_eight,
    judge => $judge_five_eight,
    dantai => $dantai_eight,
    log => $log,
);

is( $chk->check_JudgeNum, '3', "5-8 kahansu is 3." );
@array_check_GroupNum = $chk->check_GroupNum;
is( $array_check_GroupNum[1], '8', "5-8 GroupNum is all 8."  );
is( $chk->check_JudgeAndDantai, '1', "5-8 Judge And Dantai Check is OK." );

# 審査員11名、団体数40でのフォーマットチェック用設定
$chk = ShinMasuzawa::FormatCheck->new(
    proc => $proc,
    judgenum => $judgenum_eleven_40th,
    dantainum => $dantainum_40th,
    judge => $judge_eleven_40th,
    dantai => $dantai_40th,
    log => $log,
);

is( $chk->check_JudgeNum, '6', "11-40 kahansu is 6." );
@array_check_GroupNum = $chk->check_GroupNum;
is( $array_check_GroupNum[1], '40', "11-40 GroupNum is all 40."  );
is( $chk->check_JudgeAndDantai, '1', "11-40 Judge And Dantai Check is OK." );
done_testing;
