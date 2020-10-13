#176	186	11	ENSP00000259318	ENST00000259318	TRUE	ENSE00003656674	2	112899045	112899074	chr9	+
#chr9	112899161	112899190	+	ENST00000259318	215	225	11	AKAP2-001	191	221	221	251

open (FH,"bumps_30each.bed");

@file=<FH>;

my $pipeline = $ARGV[0];

foreach $line (@file)
{

$ENST="";
$start="";
$width=58;
$end="";
if ($line=~m/(.*)\t(.*)\t(.*)/)
{
$ENST=$1;
$start= $2;
$end=$3;
}

#$ENST2 = $ENST."\$";

$out= `grep -A 1 $ENST $pipeline/REF/bumpfinder/species/_translations.fa`;

@line_out=split ("\n",$out);

$aa_1 = substr( $line_out[1], $start, $width);

print $ENST."\t".$start."\t".$end."\t".$chr_strand."\t".$aa_1."\n"; 

}
