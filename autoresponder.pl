#!/usr/bin/perl
use strict; use warnings;
use Data::Dumper;
use Extism ':all';
use JSON::PP qw(decode_json);
use XTP;

# load XTP configuration
my $appid = $ENV{XTP_APPID};
my $token = $ENV{XTP_TOKEN};

# parse the incoming email
my %email = parse_incoming_email(@ARGV);
my $sender = $email{sender};
my $receiver = $email{receiver};

# if the receiver is root, check if it's a guest signup email
# if so reply with an invite link
if ($receiver eq 'root@localhost') {
    my $subject = exists $email{headers}{Subject} ? $email{headers}{Subject} : '';
    if ($subject =~ m!^/hackablee?mail\s+signup!) {
        eval {
            my $client = XTP::Client->new({
                token => $token,
                appId => $appid,
            });
            my $invite = $client->inviteGuest({
                guestKey => email_to_guestKey($sender),
                deliveryMethod => 'link'
            });
            my %email = (
                headers => {
                    Subject => 'Hackable Email Invite',
                    To => $sender,
                    From => $receiver,
                },
                body => $invite->{link}
            );
            exit send_email($sender, $receiver, \%email);
        };
        if ($@) {
            exit 70; # EX_SOFTWARE
        }
    }
}

# try to get a plugin
my $plugin = eval {
    # Initialize the host functions
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

    # Initialize an XTP client
    my $client = XTP::Client->new({
        token => $token,
        appId => $appid,
        extism => {functions => [$deliver, $reply], wasi => 1}
    });

    # Finally actually try to get a plugin
    $client->getPlugin('on email', email_to_guestKey($receiver));
};
if ($@) {
    # no plugin, or initializing XTP failed, let the email pass through
    exit send_email($sender, $receiver, \%email);
}

# Call the guest's plugin
my $rc = eval {
    my $res = $plugin->call('onEmail', \%email);
    JSON::PP::->new->utf8->allow_nonref->decode($res)
};
if ($@) {
    # Bounce, the plugin crashed
    exit 70; # EX_SOFTWARE
}
# return the plugin's exit code
exit $rc;

sub email_to_guestKey {
    my ($address) = @_;
    unpack('H*', $address)
}

sub parse_incoming_email {
    my ($sender, $receiver) = @_;
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
        my ($header, $value) = $line =~ /^([^:]+):\s+(.+)$/ or die "failed to parse header line: '$line'   ";
        $email{headers}{$header} = $value;
        $prevheader = $header;
    }

    # parse body (only text supported currently)
    my $body = '';
    while(my $line = <STDIN>) {
        $body .= $line;
    }
    $email{body} = $body;
    %email
}

sub send_email {
    my ($sender, $receiver, $email) = @_;
    open(my $chld,  '|-', '/usr/sbin/sendmail', '-i', '-f', $sender, $receiver) // die "failed to open sendmail";
    while (my ($header, $value) = each(%{$email->{headers}})) {
        my $headerline = "$header: $value\n";
        print $chld $headerline;
    }
    print $chld "\n";
    print $chld $email->{body};
    close($chld);
    my $fullcode = $?;
    my $code = $fullcode >> 8;
    $code
}
