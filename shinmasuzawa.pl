use strict;
use warnings;
use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin/extlib/lib/perl5";
use lib "$FindBin::Bin/extlib";
use lib "$FindBin::Bin/lib";
use utf8;
use Encode;

use Text::CSV;

use ShinMasuzawa::GetData;

##CSVファイルからデータを取得
my $get = ShinMasuzawa::GetData->new(
    csv_file => '新増沢方式審査用紙.csv',
);
my $data = $get->csv;

### 出場団体の定義
my $dantai = $data->{array_dantai};

### 出場団体数の定義
my $dantainum = scalar @$dantai;

### 順位表の定義
my $judge = $data->{judge};

### 未定義の順位表を削除
foreach my $key(keys(%{ $judge })){
    if (!$judge->{$key}){
        delete($judge->{$key}); 
    }
}

