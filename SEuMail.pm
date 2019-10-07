#!/usrbin/perl -w

package SEuMail;

use strict;
use warnings;
no warnings 'experimental::smartmatch';
use feature	qw( switch );

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION		=	0.01;
@ISA			=	qw( Exporter );
@EXPORT			=	();
@EXPORT_OK		=	qw( send_scan_notice );
%EXPORT_TAGS	=	(	DEFAULT	=>	[qw( send_scan_notice send_scan_complete send_new_host_found )],
						Both	=>	[qw( send_scan_notice send_scan_complete send_new_host_hound )]);

use Term::ANSIColor;
use Data::Dumper;
use MIME::Lite;

sub send_scan_notice {
	my $to		= shift(@_);
	my $from 	= shift(@_);
	my $target	= shift(@_);
	my $source	= shift(@_);
	my $engine	= shift(@_);
	my $start	= shift(@_);

	my $subject = "P13: Scanning $target beginning $start\n\n";

	my $scan_type = '';
	given ($engine) {
		when (/masscan/)	{ $scan_type = "Network discovery scan."; }
		when (/nmap/)		{ $scan_type = "Network discovery or host enumeration scan."; }
		default 			{ die "Scan engine unrecognized or undefined."; }
	}

	my $body = <<EoS;

	<h3>TO WHOM IT MAY CONCERN:</h3>
	<p>I will be performing automated server testing of $target beginning $start.</p>

	<h3>OUTAGE:</h3>
	<p>No outand is intended for these scans.</p>

	<h3>POTENTIAL IMPACT:</h3>
	<p>No anticipated impact.</p>

	<h3>BACKOUT PLAN:</h3>
	<p>If anyone notices any application, system, or network issues that requires scanning to stop please call the Sempra Energy Security Operations Center \@858-613-3278.</p>

	<table style="border: 2px solid #000; padding: 0px; margin: 0px;">
	<tr style="margin: 0px;">
		<td style="text-align: center; background-color: #99CCFF; font-weight: bold; border: 1px solid #000;">Server/Network Name</td>
		<td style="text-align: center; background-color: #99CCFF; font-weight: bold; border: 1px solid #000;">Component Engine(s)</td>
		<td style="text-align: center; background-color: #99CCFF; font-weight: bold; border: 1px solid #000;">Originating Host(s)</td>
		<td style="text-align: center; background-color: #99CCFF; font-weight: bold; border: 1px solid #000;">Scan/Test Type</td>
	</tr>
	<tr style="margin: 0px;">
		<td style="text-align: center; padding 0px; margin 0px; border: 1px solid #000;">$target</td>
		<td style="text-align: center; padding 0px; margin 0px; border: 1px solid #000;">$engine</td>
		<td style="text-align: center; padding 0px; margin 0px; border: 1px solid #000;">$source</td>
		<td style="text-align: center; padding 0px; margin 0px; border: 1px solid #000;">$scan_type</td>
	</tr>
	</table>

	<p>Thank you for your time.</p>

EoS

	my $message = MIME::Lite->new(
		From		=>	$from,
		To			=>	$to,
		Subject		=>	$subject,
		Data		=>	$body,
		Type		=>	'text/html',
	);

	#$message->send( 'smtp', 'ms-smtp-t01a.sempra.com', Debug=>1 );
	$message->send('smtp');

}

sub send_scan_complete {
	my $to			= shift(@_);
	my $from		= shift(@_);
	my $target		= shift(@_);
	my $source		= shift(@_);
	my $engine		= shift(@_);
	my $end_time	= shift(@_);

	my $subject = "P13: Scanning $target complete: $end_time\n\n";

	my $scan_type = '';
	given ($engine) {
		when (/masscan/)	{ $scan_type = "Network discovery scan."; }
		when (/nmap/)		{ $scan_type = "Network discovery or host enumeration scan."; }
		default 			{ die "Scan engine unrecognized or undefined."; }
	}

	my $body = <<EoS;

	<h3>SCANNING COMPLETE</h3>
	<p>Scanning for this session has been completed.</p>

	<table style="border: 2px solid #000; padding: 0px; margin: 0px;">
	<tr style="margin: 0px;">
		<td style="text-align: center; background-color: #99CCFF; font-weight: bold; border: 1px solid #000;">Server/Network Name</td>
		<td style="text-align: center; background-color: #99CCFF; font-weight: bold; border: 1px solid #000;">Component Enginer</td>
		<td style="text-align: center; background-color: #99CCFF; font-weight: bold; border: 1px solid #000;">Originating Host(s)</td>
		<td style="text-align: center; background-color: #99CCFF; font-weight: bold; border: 1px solid #000;">Scan/Test/Type</td>
	</tr>
	<tr style="margin: 0px;">
		<td style="text-align: center; padding: 0px; margin: 0px; border: 1px solid #000;">$target</td>
		<td style="text-align: center; padding: 0px; margin: 0px; border: 1px solid #000;">$engine</td>
		<td style="text-align: center; padding: 0px; margin: 0px; border: 1px solid #000;">$source</td>
		<td style="text-align: center; padding: 0px; margin: 0px; border: 1px solid #000;">$scan_type</td>
	</tr>
	</table>

	<p>Thank you for your time.</p>

EoS

	my $message = MIME::Lite->new(
		From		=>	$from,
		To			=>	$to,
		Subject		=>	$subject,
		Data		=>	$body,
		Type		=>	"text/html",
	);

	$message->send('smtp');

}

sub send_new_host_found {
	my $to			= shift(@_);
	my $from		= shift(@_);
	my $ip_addr		= shift(@_);
	my $proto		= shift(@_);

	my $subject = "P13: Found new host!  IP: $ip_addr\n\n";

	my $body = <<EoS;

	<h3>New host found!</h3>
	<p>New host found on IP $ip_addr.  It has an open port: $proto.</p>

	<p>Thank you for your time.</p>

EoS

	my $message = MIME::Lite->new(
		From		=>	$from,
		To 			=>	$to,
		Subject		=>	$subject,
		Data		=>	$body,
		Type		=>	"text/html",
	);

	$message->send('smtp');

}

sub send_new_host_service_found {
	my $to			= shift(@_);
	my $from		= shift(@_);
	my $ip_addr		= shift(@_);
	my $proto		= shift(@_);

	my $subject = "P13: Found new service for host!  IP: $ip_addr\n\n";

	my $body = <<EoS;

	<h3>New service found on host!</h3>
	<p>New service found on IP $ip_addr.  It has an open port: $proto.</p>

	<p>Thank you for your time.</p>

EoS

	my $message = MIME::Lite->new(
		From		=>	$from,
		To 			=>	$to,
		Subject		=>	$subject,
		Data		=>	$body,
		Type		=>	"text/html",
	);

	$message->send('smtp');
}

sub send_banner_updated {
	my $to			= shift(@_);
	my $from 		= shift(@_);
	my $ip_addr		= shift(@_);
	my $old_banner	= shift(@_);
	my $new_banner	= shift(@_);

	my $subject = "P13: Banner updated for host!  IP: $ip_addr\n\n";

	my $body = <<EoS;

	<h3>Banner updated on host!</h3>
	<table border="0">
		<tr><td>Old Banner:</td><td>$old_banner</td></tr>
		<tr><td>New Banner:</td><td>$new_banner</td></tr>
	</table>

EoS

	my $message = MIME::Lite->new(
		From		=>	$from,
		To			=>	$to,
		Subject		=>	$subject,
		Data		=>	$body,
		Type		=>	"text/html",
	);

	$message->send('smtp');
}

1;

