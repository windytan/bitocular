#!/usr/bin/perl
use warnings;
use Gtk2 qw( -init -threads-init );
use threads;
use FindBin '$Bin';

$builder = Gtk2::Builder->new();
$builder->add_from_file("$Bin/bitui.ui");

$window     = $builder->get_object("window1");
$hdlabel    = $builder->get_object("hd-label");
$entlabel   = $builder->get_object("entlabel");
$meanlabel  = $builder->get_object("meanlabel");
$chi2label  = $builder->get_object("chi2label");
$magiclabel = $builder->get_object("magiclabel");
$histoimage = $builder->get_object("histoimage");
$poincimage = $builder->get_object("poincimage");
$entimage   = $builder->get_object("entimage");
$meanimage  = $builder->get_object("meanimage");
$chi2image  = $builder->get_object("chi2image");

$window-> signal_connect (delete_event => sub {Gtk2->main_quit; FALSE});
$window->show_all();
$window->set_title($ARGV[0]);

&mkhistogram;


threads->new(\&worksub);

Gtk2->main;

sub worksub {

  $hd = qx!hexdump -C -n 384 -v '$ARGV[0]'|head -n 24!;
Gtk2::Gdk::Threads->enter;
$hdlabel->set_text($hd);
Gtk2::Gdk::Threads->leave;

$magic = qx!file -b '$ARGV[0]'!;
Gtk2::Gdk::Threads->enter;
$magiclabel->set_text($magic);
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
  }
}
close(SIS);

if ($chi2 < 1 || $chi2 > 99) {
  $chirand = "non-random";
} elsif ($chi2 < 5 || $chi > 95) {
  $chirand = "suspect";
} elsif ($chi2 < 10 || $chi > 90) {
  $chirand = "almost suspect";
} else {
  $chirand = "very random";
}

Gtk2::Gdk::Threads->enter;
$entlabel->set_text("$ent b/B");
$meanlabel->set_text($mean);
#$chi2label->set_text("$chi2 % ($chirand)");
$chi2label->set_text("$chi2 %");
Gtk2::Gdk::Threads->leave;

system("convert $Bin/chi2meter.png $Bin/needle.png -geometry +".int((50-abs($chi2-50))/50*255+2)."+1 -composite /tmp/chi2meter.png");
system("convert $Bin/entmeter.png $Bin/needle.png -geometry +".int($ent/8*255+2)."+1 -composite /tmp/entmeter.png");
system("convert $Bin/meanmeter.png $Bin/needle.png -geometry +".int(255-abs(127.5-$mean)/127.5*255+2)."+1 -composite /tmp/meanmeter.png");

Gtk2::Gdk::Threads->enter;
$entimage->set_from_file("/tmp/entmeter.png");
$chi2image->set_from_file("/tmp/chi2meter.png");
$meanimage->set_from_file("/tmp/meanmeter.png");
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
  }
}
close(SIS);
&mkhistogram;

}

sub mkhistogram {
open(IM, "|convert -depth 8 -size 256x256 gray:- /tmp/histo.png");
for $y (0..255) {
  for $x (0..255) {
    if (($maxhisto // 0) > 0 && ($histo[$x] // 0) / $maxhisto * 255 >= 256 - $y) {
      print IM chr(0);
    } else {
      print IM chr(240);
    }
  }
}
close(IM);

Gtk2::Gdk::Threads->enter;
$histoimage->set_from_file ("/tmp/histo.png");
Gtk2::Gdk::Threads->leave;

open(IM, "|convert -depth 8 -size 256x256 gray:- /tmp/poinc.png");
for $y (0..255) {
  for $x (0..255) {
    if (($maxpoinc // 0) > 0 && ($poinc[$x][$y] // 0)/$maxpoinc > 0) {
      print IM chr(0);
    } else {
      print IM chr(240);
    }
  }
}
close(IM);

Gtk2::Gdk::Threads->enter;
$poincimage->set_from_file ("/tmp/poinc.png");
Gtk2::Gdk::Threads->leave;
}
