use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request::Common;
use JSON;
use URI;
use URI::Escape;
use Data::Dumper;
use Encode;


sub rest_get {
my ($path,$params) = @_;
my $uri = _create_uri($path);
$uri->query_form($params);
return _process_request( GET $uri->as_string, Content_Type => 'application/json' );
}

sub rest_put {
my ($path,$params) = @_;
my $uri = _create_uri($path);
return _process_request( POST $uri->as_string, 
			'X-HTTP-Method' => 'PUT',
			Content_Type => 'application/json',
			Content => $params );
}

sub rest_update {
my ($path,$params) = @_;
my $uri = _create_uri($path);
return _process_request( POST $uri->as_string, 
			'X-HTTP-Method' => 'PATCH',
			Content_Type => 'application/json',
			Content => $params );
}

sub _create_uri {
    my $path = shift;
    return URI->new('http://<yourwebsite>.azurewebsites.net/'.$path);
}

sub _process_request {
    my $ua = LWP::UserAgent->new;
	print Dumper(@_);
#    $ua->default_header('X-ZUMO-APPLICATION','pbAAVyvTUedWjSZMhVLVEBYiryavIN85');
    my $response = $ua->request( @_ );
#    my $decoded_response = decode ("iso-8859-1",$response->decoded_content);
    my $decoded_response=$response->decoded_content;
    print $decoded_response,"\n";
    my $result = from_json($decoded_response); 
    if ($response->is_success) {
	return $result;
    }
    else {
        print "error processing request \n",@_ ;
    }
}

#my $sensorname = uri_escape($ARGV[0],"\x00-\x2f\x3a-\x40\x5b-\x61\x7b-\xff");
my $sensorname = $ARGV[0];

print "Creating ",$sensorname,"\n";

my %query =
	(
	 p => $sensorname,
	 t => "<yourtoken>",
	 mw => "ROW",
         cr => "NFOR",
         ca => "CRO",
	 j => "1"
	 );

my $getresponse = rest_get( "open.php",\%query);

print "getresponse:",Dumper($getresponse),"\n";

print "Master is ",@$getresponse{"info"},"\n";

