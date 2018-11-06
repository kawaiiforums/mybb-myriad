use DBIish;
use Cro::HTTP::Router;
use Cro::HTTP::Server;

my $dbh = DBIish.connect(
    'Pg', :host(%*ENV<MYRIAD_DATABASE_HOST>),
    :port(%*ENV<MYRIAD_DATABASE_PORT>),
    :database(%*ENV<MYRIAD_DATABASE_NAME>),
    :user(%*ENV<MYRIAD_DATABASE_USER>),
    :password(%*ENV<MYRIAD_DATABASE_PASSWORD>),
    :RaiseError
);

my $total-requests = 0;
my $successful-requests = 0;

my $application = route {
    get -> 'u', $expression {
        $total-requests++;
        my $sth = $dbh.prepare(q:to/STATEMENT/);
            SELECT uid AS u, username AS n FROM mybb_users
            WHERE username LIKE ?
            ORDER BY postnum DESC, lastactive DESC, username LIMIT 15
            STATEMENT
        my $result = $sth.execute("$expression%");
        my @rows = $sth.allrows(:array-of-hash);
        $successful-requests++ if $result > 0;
        content 'application/json', @rows;
    }

    get -> 'statistics' {
        my %statistics = :$total-requests, :$successful-requests;
        content 'application/json', %statistics;
    }
}

my Cro::Service $service = Cro::HTTP::Server.new:
    :host<localhost>, :port<10000>, :$application;

$service.start;

react whenever signal(SIGINT) {
    $service.stop;
    exit;
}
