#!/usr/bin/perl
#
# Having 'XML_PARSE_HUGE' enabled can make an application vulnerable to
# denial of service through entity expansion attacks.  This test script
# confirms that huge document mode is disabled by default and that this
# does not adversely affect expansion of sensible entity definitions.
#

use strict;
use warnings;

use Test::More;

use XML::LibXML;

if (XML::LibXML::LIBXML_VERSION() < 20700) {
    plan skip_all => "XML_PARSE_HUGE option not supported for libxml2 < 2.7.0";
}
else {
    plan tests => 5;
}

my $benign_xml = <<'EOF';
<?xml version="1.0"?>
<!DOCTYPE lolz [
  <!ENTITY lol "haha">
]>
<lolz>&lol;</lolz>
EOF

my $evil_xml = <<'EOF';
<!DOCTYPE root [
  <!ENTITY ha "Ha !">
  <!ENTITY ha2 "&ha; &ha;">
  <!ENTITY ha3 "&ha2; &ha2;">
  <!ENTITY ha4 "&ha3; &ha3;">
  <!ENTITY ha5 "&ha4; &ha4;">
  <!ENTITY ha6 "&ha5; &ha5;">
  <!ENTITY ha7 "&ha6; &ha6;">
  <!ENTITY ha8 "&ha7; &ha7;">
  <!ENTITY ha9 "&ha8; &ha8;">
  <!ENTITY ha10 "&ha9; &ha9;">
  <!ENTITY ha11 "&ha10; &ha10;">
  <!ENTITY ha12 "&ha11; &ha11;">
  <!ENTITY ha13 "&ha12; &ha12;">
  <!ENTITY ha14 "&ha13; &ha13;">
  <!ENTITY ha15 "&ha14; &ha14;">
  <!ENTITY ha16 "&ha15; &ha15;">
  <!ENTITY ha17 "&ha16; &ha16;">
  <!ENTITY ha18 "&ha17; &ha17;">
  <!ENTITY ha19 "&ha18; &ha18;">
  <!ENTITY ha20 "&ha19; &ha19;">
  <!ENTITY ha21 "&ha20; &ha20;">
  <!ENTITY ha22 "&ha21; &ha21;">
  <!ENTITY ha23 "&ha22; &ha22;">
  <!ENTITY ha24 "&ha23; &ha23;">
  <!ENTITY ha25 "&ha24; &ha24;">
  <!ENTITY ha26 "&ha25; &ha25;">
  <!ENTITY ha27 "&ha26; &ha26;">
  <!ENTITY ha28 "&ha27; &ha27;">
  <!ENTITY ha29 "&ha28; &ha28;">
  <!ENTITY ha30 "&ha29; &ha29;">
  <!ENTITY ha31 "&ha30; &ha30;">
  <!ENTITY ha32 "&ha31; &ha31;">
  <!ENTITY ha33 "&ha32; &ha32;">
  <!ENTITY ha34 "&ha33; &ha33;">
  <!ENTITY ha35 "&ha34; &ha34;">
  <!ENTITY ha36 "&ha35; &ha35;">
  <!ENTITY ha37 "&ha36; &ha36;">
  <!ENTITY ha38 "&ha37; &ha37;">
  <!ENTITY ha39 "&ha38; &ha38;">
  <!ENTITY ha40 "&ha39; &ha39;">
  <!ENTITY ha41 "&ha40; &ha40;">
  <!ENTITY ha42 "&ha41; &ha41;">
  <!ENTITY ha43 "&ha42; &ha42;">
  <!ENTITY ha44 "&ha43; &ha43;">
  <!ENTITY ha45 "&ha44; &ha44;">
  <!ENTITY ha46 "&ha45; &ha45;">
  <!ENTITY ha47 "&ha46; &ha46;">
  <!ENTITY ha48 "&ha47; &ha47;">
]>
<root>&ha48;</root>
EOF

my($parser, $doc);

$parser = XML::LibXML->new;
#$parser->set_option(huge => 0);
# TEST
ok(!$parser->get_option('huge'), "huge mode disabled by default");

$doc = eval { $parser->parse_string($evil_xml); };

# TEST
isnt("$@", "", "exception thrown during parse");
# TEST
like($@, qr/entity/si, "exception refers to entity maximum loop (libxml2 <= 2.10) or depth (>= 2.11)");


$parser = XML::LibXML->new;

$doc = eval { $parser->parse_string($benign_xml); };

# TEST
is("$@", "", "no exception thrown during parse");

my $body = $doc->findvalue( '/lolz' );
# TEST
is($body, 'haha', 'entity was parsed and expanded correctly');

exit;

