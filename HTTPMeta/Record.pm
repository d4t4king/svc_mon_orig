#!/usr/bin/perl -w

package HTTPMeta::Record;

use strict;
use warnings;

use DBI;

sub new {

	my $class = shift;

	my $id		= shift(@_);
	my $ip_addr	= shift(@_);
	my $dbfile	= shift(@_) || '/opt/service_monitor/stores.db';

	my $self = {};

	bless $self, $class;
	
	$self->{'id'} 			= $id;
	$self->{'ip_addr'}		= $ip_addr;
	$self->{'dbfile'}		= $dbfile;
	$self->{'exists'}		= &__record_exists__($dbfile, $id);
	#if ($self->{'exists'}) {
	#	my ($t,$tff,$tlu,$s,$sff,$slu) = &__pop_obj_from_db($id);
	#	$self->{'html_title'}			= $t;
	#	$self->{'title_first_found'}	= $tff;
	#	$self->{'title_last_update'}	= $tlu;
	#	$self->{'server'}				= $s;
	#	$self->{'server_first_found'}	= $sff;
	#	$self->{'server_last_update'}	= $slu;
	#}

	return $self;
}

sub __pop_obj_from_db {
	my $self = shift(@_);

	my $sql = "SELECT server_header,header_first_found,header_last_updated,html_title,title_first_found,title_last_updated FROM html_meta WHERE id='$self->{'id'}';";
}

sub __record_exists__ {
	
	#my $self		= shift(@_);
	my $db = shift(@_);
	my $id = shift(@_);
	my $rec_exists	= 0;					# (false)
	
	$rec_exists = &sql_get_bool($db, "SELECT DISTINCT id FROM http_meta WHERE id='$id'");

	return $rec_exists;
}

sub sql_get_string {
	#my $self	= shift(@_);
	my $dbfile	= shift(@_);
	my $sql 	= shift(@_);

	my $str	= '';
	my $db	= DBI->connect("dbi:SQLite:dbname=$dbfile", "", "") or die $DBI::errstr;
	my $st	= $db->prepare($sql) or die $DBI::errstr;
	my $rtv	= $st->execute() or die $DBI::errstr;
	while (my @row = $st->fetchrow_array()) {
		if ((defined($row[0])) and ($row[0] ne "")) { $str = $row[0]; }
	}
	$st->finish() or die $DBI::errstr;
	$db->disconnect() or die $DBI::errstr;
	
	return $str;
}

sub sql_get_bool {
	#my $self	= shift(@_);
	my $dbfile	= shift(@_);
	my $sql		= shift(@_);

	my $bool	= 0;
	my $db		= DBI->connect("dbi:SQLite:dbname=$dbfile", "", "") or die $DBI::errstr;
	my $st		= $db->prepare($sql) or die $DBI::errstr;
	my $rtv		= $st->execute() or die $DBI::errstr;
	while (my @row = $st->fetchrow_array()) {
		if ((defined($row[0])) and ($row[0] ne "")) { $bool = 1; }
	}
	$st->finish() or die $DBI::errstr;
	$db->disconnect() or die $DBI::errstr;
	
	return $bool;
}

1;

