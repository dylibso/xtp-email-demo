#!/usr/bin/perl
use strict; use warnings;
use Extism ':all';
use JSON::PP qw(decode_json);
my ($sender, $receiver) = @ARGV;
my %email = (sender => $sender, receiver => $receiver);

# parse headers
my $prevheader;
while(my $line = <STDIN>) {
    if ($line eq "\n") {
        last;
    }
    if ($line =~ /^\s/ && $prevheader) {
        chomp $line;
        $email{headers}{$prevheader} .= "\n$line";
        next;
    }
    my ($header, $value) = $line =~ /^([^:]+):(.+)$/ or die "failed to parse header line: '$line'   ";
    $email{headers}{$header} = $value;
    $prevheader = $header;
}

# parse body (only text supported currently)
my $body = '';
while(my $line = <STDIN>) {
    $body .= $line;
}
$email{body} = $body;

sub send_email {
    my ($sender, $receiver, $email) = @_;
    open(my $chld,  '|-', '/usr/sbin/sendmail', '-i', '-f', $sender, $receiver) // die "failed to open sendmail";
    open(my $log, '>', '/home/gavin/dev/xtp-email-demo/lastmail.txt');
    while (my ($header, $value) = each(%{$email->{headers}})) {
        my $headerline = "$header: $value\n";
        print $chld $headerline;
        print $log $headerline; 
    }
    print "\n";
    print $chld $email->{body};
    print $log $email->{body};
    # TODO actually return exit code
    0
}

# Host functions
my $deliver = Extism::Function->new("deliver", [Extism_String], [Extism_String], sub {
    my ($input) = @_;
    my $email = decode_json($input);
    my $rc = send_email($sender, $receiver, $email);
    return JSON::PP::->new->utf8->allow_nonref->encode($rc);
});

my $reply = Extism::Function->new("reply", [Extism_String], [Extism_String], sub {
    my ($input) = @_;
    my $email = decode_json($input);
    $email->{headers} = {
        Subject => $email->{subject} // '',
        To => $sender,
        From => $receiver,
    };
    my $rc = send_email($sender, $receiver, $email);
    return JSON::PP::->new->utf8->allow_nonref->encode($rc);
});

# load the plugin and call it
my $wasmpath = '/home/gavin/dev/xtp-email-demo/plugin/dist/plugin.wasm';
my $wasm = do { local(@ARGV, $/) = $wasmpath; <> };
my ($plugin, $errmsg) = Extism::Plugin->new($wasm, {functions => [$deliver, $reply], wasi => 1});
$plugin or die $errmsg;
my ($res, $extismrc, $error) = $plugin->call('onEmail', \%email);
$res // die "$error rc $extismrc";
my $rc = JSON::PP::->new->utf8->allow_nonref->decode($res);
exit $rc;

#my %response = ( headers => {
#    To => $sender,
#    From => $receiver,
#    Subject => 'subject',
#}, body => 'back atcha');
#reply(\%response);

# Deliver to inbox
#send_email($sender, $receiver, \%email);

#exec('/usr/sbin/sendmail', '-i', '-f', $ARGV[0], $ARGV[1]);
