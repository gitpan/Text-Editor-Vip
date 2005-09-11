
use strict ;
use warnings ;

use Pod::Simple::HTMLBatch;

my $batchconv = Pod::Simple::HTMLBatch->new;
$batchconv->css_flurry(0) ;
$batchconv->add_css('perl_style.css') ;
$batchconv->verbose(1);
$batchconv->batch_convert( [ './lib' ], './html_doc' );
`cp ./perl_style.css html_doc` ;


 
