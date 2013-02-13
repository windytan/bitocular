#!/usr/bin/perl
use warnings;
use Gtk2 qw( -init -threads-init );
use threads;
use FindBin '$Bin';
use utf8;
use Image::Magick;

use constant TRUE  => 1;
use constant FALSE => 0;

$pi = 3.141592653589793;

$n = 0;

$builder = Gtk2::Builder->new();
$builder->add_from_file("$Bin/bitui.ui");

$gui{$_} = $builder->get_object($_) for (qw ( window1 hd-label entlabel meanlabel chi2label magiclabel corrlabel histoimage poincimage entimage meanimage chi2image corrimage ccorrimage hexframe magicframe entframe histoframe poincframe statusbar ));

$context_id = $gui{"statusbar"}->get_context_id("");

$gui{"window1"}->signal_connect (delete_event => sub {Gtk2->main_quit; FALSE});
$gui{"window1"}->show_all();
$gui{"window1"}->set_title($ARGV[0]);

$histo = Image::Magick->new(size=>'256x256');
$poinc = Image::Magick->new(size=>'256x256');

# color gradient
$rgb[0] = chr(0) x 3;
for (1..511) {
  $rgb[$_] = chr(0) .
             chr(0xbb * ($_/511)).
             chr(0x33);
}
for (512..1023) {
  $rgb[$_] = chr(0) .
             chr(0xbb + 0x44*(($_-512)/(1023-512))).
             chr(0x33 + 0xcc*(($_-512)/(1023-512)));
}
 
&mkhistogram;


threads->new(\&worksub);

Gtk2->main;

sub worksub {

  Gtk2::Gdk::Threads->enter;
  $gui{"statusbar"}->push($context_id, "hexdump...");
  Gtk2::Gdk::Threads->leave;

  open(S,"hexdump -C -n 384 -v '$ARGV[0]'|head -n 24|");
  ($hd = join("",<S>)) =~ s/\|/│/g;;
  close(S);
  Gtk2::Gdk::Threads->enter;
  $gui{"hexframe"}->set_sensitive(TRUE);
  $gui{"hd-label"}->set_text($hd);
  Gtk2::Gdk::Threads->leave;
  
  Gtk2::Gdk::Threads->enter;
  $gui{"statusbar"}->push($context_id, "magic...");
  Gtk2::Gdk::Threads->leave;

  open(S,"file -b '$ARGV[0]'|");
  $magic = join("",<S>);
  close(S);
  Gtk2::Gdk::Threads->enter;
  $gui{"magicframe"}->set_sensitive(TRUE);
  $gui{"magiclabel"}->set_text($magic);
  Gtk2::Gdk::Threads->leave;
  
  Gtk2::Gdk::Threads->enter;
  $gui{"statusbar"}->push($context_id, "ent...");
  Gtk2::Gdk::Threads->leave;

  open(SIS,"ent '$ARGV[0]'|");
  for (<SIS>) {
    chomp();
    if    (/Entropy = ([\d\.]+)/)     { $ent  = $1; }
    elsif (/exceed this value (\S+)/) { $chi2 = $1; }
    elsif (/mean value .* is (\S+)/)  { $mean = $1; }
    elsif (/coefficient is (\S+)/)    { $corr = $1; }
  }
  close(SIS);

  if    ($chi2 < 1  || $chi2 > 99) { $chirand = "non-random";     }
  elsif ($chi2 < 5  || $chi2 > 95) { $chirand = "suspect";        }
  elsif ($chi2 < 10 || $chi2 > 90) { $chirand = "almost suspect"; }
  else                             { $chirand = "very random";    }

  Gtk2::Gdk::Threads->enter;
  $gui{"entframe"}->set_sensitive(TRUE);
  $gui{"entlabel"}->set_text("$ent b/B");
  $gui{"meanlabel"}->set_text($mean);
  #$gui{"chi2label"}->set_text("$chi2 % ($chirand)");
  $gui{"chi2label"}->set_text("$chi2 %");
  $gui{"corrlabel"}->set_text("$corr");
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

  print "$corr\n";
  $corr = abs(0.01/$corr);
  $corr = 1 if ($corr > 1);
  print "$corr corr\n";
  $corrangle = -$corr * $pi + $pi/2;
  print "$corrangle corrangle\n";

  $entangle  = $entangle  * .778;# + 20/180*$pi;
  $meanangle = $meanangle * .778;# + 20/180*$pi;
  $chiangle  = $chiangle  * .778;# + 20/180*$pi;
  $corrangle = $corrangle * .778;## + 40/180*$pi;


  system("convert -size 75x46 xc:transparent -draw \'circle 38,38 42,38\' -stroke \'#cccccc\' -strokewidth 5 -fill transparent -draw \'arc 12,12 64,64 200,340\' -stroke black -strokewidth 2 -draw \'line 37,37 ".(38-26*sin($entangle)).",".(37-26*cos($entangle))."\' /tmp/entmeter.png"); 

  system("convert -size 75x46 xc:transparent -draw \'circle 38,38 42,38\' -stroke \'#cccccc\' -strokewidth 5 -fill transparent -draw \'arc 12,12 64,64 200,340\' -stroke black -strokewidth 2 -draw \'line 37,37 ".(38-26*sin($meanangle)).",".(37-26*cos($meanangle))."\' /tmp/meanmeter.png"); 

  system("convert -size 75x46 xc:transparent -draw \'circle 38,38 42,38\' -stroke \'#cccccc\' -strokewidth 5 -fill transparent -draw \'arc 12,12 64,64 200,340\' -stroke black -strokewidth 2 -draw \'line 37,37 ".(38-26*sin($chiangle)).",".(37-26*cos($chiangle))."\' /tmp/chi2meter.png"); 

  system("convert -size 75x46 xc:transparent -draw \'circle 38,38 42,38\' -stroke \'#cccccc\' -strokewidth 5 -fill transparent -draw \'arc 12,12 64,64 200,340\' ".($corr ne "undefined" && "-stroke black -strokewidth 2 -draw \'line 37,37 ".(38-26*sin($corrangle)).",".(37-26*cos($corrangle))."\'")." /tmp/corrmeter.png"); 

  Gtk2::Gdk::Threads->enter;
  $gui{"entimage"}->set_from_file("/tmp/entmeter.png");
  $gui{"chi2image"}->set_from_file("/tmp/chi2meter.png");
  $gui{"meanimage"}->set_from_file("/tmp/meanmeter.png");
  $gui{"corrimage"}->set_from_file("/tmp/corrmeter.png");
  Gtk2::Gdk::Threads->leave;
  
  Gtk2::Gdk::Threads->enter;
  $gui{"statusbar"}->push($context_id, "histogram...");
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

    push(@corrarr,$a);
    if (@corrarr > 256) {
      for $c (1..256) {
        for $b (0..7) {
          $corr[$b][$c-1] += (($corrarr[$c] >> (7-$b)) & 1) & (($corrarr[0] >> (7-$b)) & 1);
        }
      }
      shift(@corrarr);
    }

    if ($n % 5000 == 0) {
      &mkhistogram;
      Gtk2::Gdk::Threads->enter;
      $gui{"histoframe"}->set_sensitive(TRUE);
      $gui{"poincframe"}->set_sensitive(TRUE);
      $gui{"statusbar"}->push($context_id, sprintf("histogram... (%.0f %%)",$n/$s*100));
      Gtk2::Gdk::Threads->leave;
    }
  }
  close(SIS);
  &mkhistogram;
  
  Gtk2::Gdk::Threads->enter;
  $gui{"histoframe"}->set_sensitive(TRUE);
  $gui{"poincframe"}->set_sensitive(TRUE);
  $gui{"statusbar"}->push($context_id, "Done");
  Gtk2::Gdk::Threads->leave;

  use Data::Dumper;
  print Dumper @corr;

}

sub mkhistogram {
  open(IM, "|convert -depth 8 -size 256x256 rgb:- /tmp/histo.png");
  for $y (0..255) {
    for $x (0..255) {
      if (($maxhisto // 0) > 0 && ($histo[$x] // 0) / $maxhisto * 255 >= 256 - $y) {
        print IM $rgb[768];
      } else {
        print IM chr(0) x 3;
      }
    }
  }
  close(IM);

  Gtk2::Gdk::Threads->enter;
  $gui{"histoimage"}->set_from_file ("/tmp/histo.png");
  Gtk2::Gdk::Threads->leave;

  open(IM, "|convert -depth 8 -size 256x256 rgb:- /tmp/poinc.png");
  for $y (0..255) {
    for $x (0..255) {
      if (($maxpoinc // 0) > 0 && ($poinc[$x][$y] // 0)/$maxpoinc > 0) {
        if (log($poinc[$x][$y]) / log($maxpoinc*.6) > 1) {
          print IM $rgb[1023];
        } else {
          print IM $rgb[log($poinc[$x][$y]) / log($maxpoinc*.6)*1023];
        }
      } else {
        print IM chr(0) x 3;
      }
    }
  }
  close(IM);

  Gtk2::Gdk::Threads->enter;
  $gui{"poincimage"}->set_from_file ("/tmp/poinc.png");
  Gtk2::Gdk::Threads->leave;

  open(IM, "|convert -depth 8 -size 256x256 rgb:- /tmp/ccorr.png");
  for $y (0..255) {
    for $x (0..255) {
      if ($x % 32 == 0) {
        print IM chr(127) x 3;
      } else {
        print IM $rgb[($corr[int($x/32)][$y] // 0)/($n+1)*1023];
      }
    }
  }
  close(IM);
  
  Gtk2::Gdk::Threads->enter;
  $gui{"ccorrimage"}->set_from_file ("/tmp/ccorr.png");
  Gtk2::Gdk::Threads->leave;
}
