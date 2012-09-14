#!/usr/bin/perl
use warnings;
use Gtk2 qw( -init -threads-init );
use threads;
use FindBin '$Bin';
use utf8;

use constant TRUE  => 1;
use constant FALSE => 0;

$pi = 3.141592653589793;

$builder = Gtk2::Builder->new();
$builder->add_from_file("$Bin/bitui.ui");

$window     = $builder->get_object("window1");
$hdlabel    = $builder->get_object("hd-label");
$entlabel   = $builder->get_object("entlabel");
$meanlabel  = $builder->get_object("meanlabel");
$chi2label  = $builder->get_object("chi2label");
$magiclabel = $builder->get_object("magiclabel");
$corrlabel  = $builder->get_object("corrlabel");
$histoimage = $builder->get_object("histoimage");
$poincimage = $builder->get_object("poincimage");
$entimage   = $builder->get_object("entimage");
$meanimage  = $builder->get_object("meanimage");
$chi2image  = $builder->get_object("chi2image");
$corrimage  = $builder->get_object("corrimage");

$hexframe    = $builder->get_object("hexframe");
$magicframe  = $builder->get_object("magicframe");
$entframe    = $builder->get_object("entframe");
$histoframe  = $builder->get_object("histoframe");
$poincframe  = $builder->get_object("poincframe");

$statusbar  = $builder->get_object("statusbar");
$context_id = $statusbar->get_context_id("Statusbar example");

$window-> signal_connect (delete_event => sub {Gtk2->main_quit; FALSE});
$window->show_all();
$window->set_title($ARGV[0]);

# color gradient
for (0..127) {
  $rgb[$_] = chr(0xbb * ((127-$_)/127)) .
             chr(0xbb + 0x11*($_/127))  .
             chr(0xbb + 0x44*($_/127));
}
for (128..255) {
  $rgb[$_] = chr(0) .
             chr(0xcc - 0xcc*(($_-128)/127)).
             chr(0xff - 0xff*(($_-128)/127));
}
 
@rgb = ("008cdb2a", "008bd82e", "008adb32", "0089d936", "008bd739", "008ad53d", "0487d842", "0485d645", 
        "0385d549", "0384d44d", "0384d351", "0384d555", "0684d459", "0682d35c", "0582d260", "0582d164", 
        "0580d068", "0780d06c", "077ed16f", "077dcf74", "097dce78", "087ccd7b", "087acd7f", "0a7bcc83", 
        "097bcc87", "0979cc8b", "0b77cb8f", "0a79cb92", "0a77ca96", "0c76c89a", "0b76c89e", "0d74c8a2", 
        "0c74c7a5", "0e74c8aa", "0f72c6ae", "0e72c5b1", "0f71c5b5", "0f70c4b9", "0f70c4bd", "106fc4c1", 
        "106ec2c5", "116ec2c8", "116dc1cd", "116cc0d0", "126bc0d4", "126bbfd8", "1369bfdc", "1369bee0", 
        "1469bee4", "1468bde7", "1467bceb", "1566bcf0", "1566bbf3", "1665bbf7", "1664bafb", "1764baff", 
        "1663baff", "1662baff", "1661baff", "1660bbff", "165fbbff", "165ebbff", "165dbbff", "165dbcff", 
        "165cbcff", "165bbcff", "165abdff", "1659bdff", "1658bdff", "1658bdff", "1657beff", "1656beff", 
        "1655beff", "1654beff", "1653bfff", "1553bfff", "1552bfff", "1551c0ff", "1550c0ff", "154fc0ff", 
        "154ec0ff", "154dc1ff", "154cc1ff", "154cc1ff", "154bc1ff", "154ac2ff", "1549c2ff", "1548c2ff", 
        "1547c3ff", "1547c3ff", "1546c3ff", "1545c3ff", "1544c4ff", "1543c4ff", "1542c4ff", "1442c4ff", 
        "1441c5ff", "1440c5ff", "143fc5ff", "143ec5ff", "143dc6ff", "143cc6ff", "143cc6ff", "143bc7ff", 
        "143ac7ff", "1439c7ff", "1438c7ff", "1437c8ff", "1437c8ff", "1436c8ff", "1435c8ff", "1434c9ff", 
        "1433c9ff", "1432c9ff", "1431c9ff", "1731c8ff", "1a30c6ff", "1c2fc5ff", "1f2fc3ff", "222ec2ff", 
        "252dc0ff", "272dbfff", "2a2cbeff", "2d2bbcff", "302abbff", "322abaff", "3529b8ff", "3729b7ff", 
        "3b28b5ff", "3d27b4ff", "4026b2ff", "4226b1ff", "4625afff", "4824aeff", "4b24acff", "4d23abff", 
        "5022aaff", "5322a8ff", "5621a7ff", "5820a5ff", "5b20a4ff", "5e1fa3ff", "611ea1ff", "631ea0ff", 
        "661d9eff", "691c9dff", "6c1b9bff", "6e1b9aff", "711a98ff", "741997ff", "771995ff", "791894ff", 
        "7c1793ff", "7f1791ff", "821690ff", "84158eff", "87158dff", "89148cff", "8d138aff", "8f1389ff", 
        "921287ff", "941186ff", "981084ff", "9a1083ff", "9d0f81ff", "9f0f80ff", "a20e7eff", "a50d7dff", 
        "a80c7cff", "ab0c7aff", "ad0b79ff", "b10a77ff", "b30a76ff", "b60974ff", "b80873ff", "bb0871ff", 
        "be0770ff", "c1066eff", "c3066dff", "c6056cff", "c9046aff", "cc0369ff", "ce0367ff", "d10266ff", 
        "d40165ff", "d70163ff", "d90062ff", "db0060ff", "d7005fff", "d5005dff", "d1005cff", "ce005aff", 
        "ca0059ff", "c70057ff", "c30056ff", "c10055ff", "bd0053ff", "ba0052ff", "b70050ff", "b3004fff", 
        "b0004dff", "ad004cff", "aa004bff", "a60049ff", "a30047ff", "9f0046ff", "9c0044ff", "980043ff", 
        "960042ff", "920040ff", "8f003fff", "8c003dff", "88003cff", "85003aff", "820039ff", "7f0038ff", 
        "7b0036ff", "780035ff", "740033ff", "710032ff", "6e0030ff", "6b002fff", "67002dff", "64002cff", 
        "61002aff", "5d0029ff", "5b0028ff", "570026ff", "540025ff", "500023ff", "4d0022ff", "490020ff", 
        "47001fff", "43001dff", "40001cff", "3d001aff", "390019ff", "360017ff", "320016ff", "300015ff", 
        "2c0013ff", "290012ff", "250010ff", "22000fff", "1e000dff", "1c000cff", "18000aff", "150009ff", 
        "120007ff", "0e0006ff", "0b0004ff", "080003ff", "050002ff", "010000ff", "000000ff", "000000ff");

$_ = pack("H*", $_) for (@rgb);

#printf("%02x%02x%02x\n",unpack("CCC",$rgb[$_])) for (0..255);

&mkhistogram;


threads->new(\&worksub);

Gtk2->main;

sub worksub {

  Gtk2::Gdk::Threads->enter;
  $statusbar->push($context_id, "hexdump...");
  Gtk2::Gdk::Threads->leave;

  $hd = qx!hexdump -C -n 384 -v '$ARGV[0]'|head -n 24!;
  Gtk2::Gdk::Threads->enter;
  $hexframe->set_sensitive(TRUE);
  $hdlabel->set_text($hd);
  Gtk2::Gdk::Threads->leave;
  
  Gtk2::Gdk::Threads->enter;
  $statusbar->push($context_id, "magic...");
  Gtk2::Gdk::Threads->leave;

  $magic = qx!file -b '$ARGV[0]'!;
  Gtk2::Gdk::Threads->enter;
  $magicframe->set_sensitive(TRUE);
  $magiclabel->set_text($magic);
  Gtk2::Gdk::Threads->leave;
  
  Gtk2::Gdk::Threads->enter;
  $statusbar->push($context_id, "ent...");
  Gtk2::Gdk::Threads->leave;

  open(SIS,"ent '$ARGV[0]'|");
  for (<SIS>) {
    chomp();
    if (/Entropy = ([\d\.]+)/) {
      $ent = $1;
    } elsif (/exceed this value (\S+)/) {
      $chi2 = $1;
    } elsif (/mean value .* is (\S+)/) {
      $mean = $1;
    } elsif (/coefficient is (\S+)/) {
      $corr = $1;
    }
  }
  close(SIS);

  if    ($chi2 < 1  || $chi2 > 99) { $chirand = "non-random";     }
  elsif ($chi2 < 5  || $chi2 > 95) { $chirand = "suspect";        }
  elsif ($chi2 < 10 || $chi2 > 90) { $chirand = "almost suspect"; }
  else                             { $chirand = "very random";    }

  Gtk2::Gdk::Threads->enter;
  $entframe->set_sensitive(TRUE);
  $entlabel->set_text("$ent b/B");
  $meanlabel->set_text($mean);
  #$chi2label->set_text("$chi2 % ($chirand)");
  $chi2label->set_text("$chi2 %");
  $corrlabel->set_text("$corr");
  Gtk2::Gdk::Threads->leave;

#  system("convert $Bin/chi2meter.png $Bin/needle.png -geometry +".
#         int((50-abs($chi2-50))/50*255+2)."+1 -composite /tmp/chi2meter.png");
#  system("convert $Bin/entmeter.png $Bin/needle.png -geometry +".int($ent/8*255+2).
#         "+1 -composite /tmp/entmeter.png");
#  system("convert $Bin/meanmeter.png $Bin/needle.png -geometry +".
#         int(255-abs(127.5-$mean)/127.5*255+2)."+1 -composite /tmp/meanmeter.png");

  $entangle  = -$ent/8 * $pi + $pi/2;
  $meanangle = -(255-abs(127.5-$mean)/127.5) * $pi;# + $pi/2;
  
  $chi2 = 100-$chi2 if ($chi2 > 50);
  if ($chi2 >= 25) {
    $chiangle = -$pi + $pi/2;
  } else {
    $chiangle = $chi2/25 * $pi + $pi/2;
  }

  if ($corr > .75) {
    $corr = 1;
  } else {
    $corr /= .75;
  }
  $corrangle = abs($corr) * $pi - $pi/2;


  $entangle  = $entangle  * .778;# + 20/180*$pi;
  $meanangle = $meanangle * .778;# + 20/180*$pi;
  $chiangle  = $chiangle  * .778;# + 20/180*$pi;
  $corrangle = $corrangle * .778;## + 40/180*$pi;



  system("convert -size 75x46 xc:transparent -draw \'circle 38,38 42,38\' -stroke \'#cccccc\' -strokewidth 5 -fill transparent -draw \'arc 12,12 64,64 200,340\' -stroke black -strokewidth 2 -draw \'line 37,37 ".(38-26*sin($entangle)).",".(37-26*cos($entangle))."\' /tmp/entmeter.png"); 

  system("convert -size 75x46 xc:transparent -draw \'circle 38,38 42,38\' -stroke \'#cccccc\' -strokewidth 5 -fill transparent -draw \'arc 12,12 64,64 200,340\' -stroke black -strokewidth 2 -draw \'line 37,37 ".(38-26*sin($meanangle)).",".(37-26*cos($meanangle))."\' /tmp/meanmeter.png"); 

  system("convert -size 75x46 xc:transparent -draw \'circle 38,38 42,38\' -stroke \'#cccccc\' -strokewidth 5 -fill transparent -draw \'arc 12,12 64,64 200,340\' -stroke black -strokewidth 2 -draw \'line 37,37 ".(38-26*sin($chiangle)).",".(37-26*cos($chiangle))."\' /tmp/chi2meter.png"); 

  system("convert -size 75x46 xc:transparent -draw \'circle 38,38 42,38\' -stroke \'#cccccc\' -strokewidth 5 -fill transparent -draw \'arc 12,12 64,64 200,340\' ".($corr ne "undefined" && "-stroke black -strokewidth 2 -draw \'line 37,37 ".(38-26*sin($corrangle)).",".(37-26*cos($corrangle))."\'")." /tmp/corrmeter.png"); 

  Gtk2::Gdk::Threads->enter;
  $entimage->set_from_file("/tmp/entmeter.png");
  $chi2image->set_from_file("/tmp/chi2meter.png");
  $meanimage->set_from_file("/tmp/meanmeter.png");
  $corrimage->set_from_file("/tmp/corrmeter.png");
  Gtk2::Gdk::Threads->leave;
  
  Gtk2::Gdk::Threads->enter;
  $statusbar->push($context_id, "histogram...");
  Gtk2::Gdk::Threads->leave;

  open(SIS,$ARGV[0]) or die($!);
  $s = -s $ARGV[0];
  while ($n++ < $s) {
    read(SIS,$a,1);
    $a = ord($a);
    $histo[$a]++;
    $maxhisto = $histo[$a] if ($histo[$a] > ($maxhisto // 0));
    if (defined $prev) {
      $poinc[$prev][$a]++;
      $maxpoinc = $poinc[$prev][$a] if ($poinc[$prev][$a] > ($maxpoinc // 0));
    }
    $prev = $a;
    if ($n % 500000 == 0) {
      &mkhistogram;
      Gtk2::Gdk::Threads->enter;
      $histoframe->set_sensitive(TRUE);
      $poincframe->set_sensitive(TRUE);
      $statusbar->push($context_id, sprintf("histogram... (%.0f %%)",$n/$s*100));
      Gtk2::Gdk::Threads->leave;
    }
  }
  close(SIS);
  &mkhistogram;
  
  Gtk2::Gdk::Threads->enter;
  $histoframe->set_sensitive(TRUE);
  $poincframe->set_sensitive(TRUE);
  $statusbar->push($context_id, "Done");
  Gtk2::Gdk::Threads->leave;

}

sub mkhistogram {
  open(IM, "|convert -depth 8 -size 256x256 gray:- /tmp/histo.png");
  for $y (0..255) {
    for $x (0..255) {
      if (($maxhisto // 0) > 0 && ($histo[$x] // 0) / $maxhisto * 255 >= 256 - $y) {
        print IM chr(0x00);
      } else {
        print IM chr(0xdd);
      }
    }
  }
  close(IM);

  Gtk2::Gdk::Threads->enter;
  $histoimage->set_from_file ("/tmp/histo.png");
  Gtk2::Gdk::Threads->leave;

  open(IM, "|convert -depth 8 -size 256x256 rgba:- /tmp/poinc.png");
  for $y (0..255) {
    for $x (0..255) {
      if (($maxpoinc // 0) > 0 && ($poinc[$x][$y] // 0)/$maxpoinc > 0) {

        if ($poinc[$x][$y] > $maxpoinc*.6) {
          print IM chr(0x00) . chr(0x00) . chr(0x00) . chr(0xff);
        } else  {
          print IM $rgb[log($poinc[$x][$y]) / log($maxpoinc*.6)*255];
        }
      } else {
        print IM chr(0xff) . chr(0xff) . chr(0xff) . chr(0x00);
      }
    }
  }
  close(IM);

  Gtk2::Gdk::Threads->enter;
  $poincimage->set_from_file ("/tmp/poinc.png");
  Gtk2::Gdk::Threads->leave;
}
