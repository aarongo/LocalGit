#!/usr/bin/perl
use File::Path 'rmtree';
my $expire_day = 20;
my $delete_log = "delete_log.log";
my $date = &getDateTime();
my $pattern = ".+[0-9]{4}\-[0-9]{2}+\-[0-9]{2}.+"; #修改成自己的正则表达式
#my @will_delete_file_root = ("C:\\QMDownload\\SoftMgr");
my @will_delete_file_root = ("/data/log1","/data/log2");
open DELETELOG,">>","$delete_log" or warn "Can't open $delete_log: $!";
print DELETELOG "############# $date #################\n";
foreach (@will_delete_file_root){
&deleteExpireFile($_);
}
print DELETELOG "\n";
close DELETELOG;
sub deleteExpireFile(){
my $will_delete_filedir = shift @_;
chdir "$will_delete_filedir" or die "Can't chdir to $will_delete_filedir: $!";
opendir FILEDIR,"$will_delete_filedir" or die "Can't open $will_delete_filedir: $!";
foreach (readdir FILEDIR){
next if ($_ eq '.');
next if ($_ eq '..');
if ($_ =~ /$pattern/ and -M $_ > $expire_day) {
print DELETELOG "$_\n";
rmtree($_);
}
}
close FILEDIR;
}
sub getDateTime() {
      my ($sec, $min, $hour, $mday, $mon, $year) = (localtime)[0..5];
      $date = sprintf "%4d-%02d-%02d %2d:%02d:%02d" ,$year + 1900,$mon + 1 ,$mday ,$hour ,$min ,$sec;
}