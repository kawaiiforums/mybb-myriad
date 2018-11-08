use DBIish;
use Cro::HTTP::Router;
use Cro::HTTP::Server;

my %defaults = database-hostname => %*ENV<MYRIAD_DATABASE_HOST> || 'localhost',
               database-port => %*ENV<MYRIAD_DATABASE_PORT> || 5432,
               database-name => %*ENV<MYRIAD_DATABASE_NAME> || 'mybb',
               database-table-prefix => %*ENV<MYRIAD_DATABASE_TABLE_PREFIX> || 'mybb',
               database-user => %*ENV<MYRIAD_DATABASE_USER> || 'mybb',
               database-password => %*ENV<MYRIAD_DATABASE_PASSWORD> || 'password',
               debug-mode => %*ENV<MYRIAD_DEBUG> || 0,
;

my $dbh = DBIish.connect(
    'Pg', :host(%defaults<database-hostname>),
    :port(%defaults<database-port>),
    :database(%defaults<database-name>),
    :user(%defaults<database-user>),
    :password(%defaults<database-password>),
    :RaiseError,
);

my $start-time = DateTime.now;
my $total-requests = 0;
my $successful-requests = 0;

my $application = route {
    get -> 'u', $expression is copy {
        $total-requests++;
        $expression = $expression.lc().trim();
        my $sth = $dbh.prepare(qq:to/STATEMENT/);
            SELECT uid AS u, username AS n FROM %defaults<database-table-prefix>_users
            WHERE username ILIKE ?
            ORDER BY postnum DESC, lastactive DESC, username LIMIT 15
            STATEMENT
        my $result = $sth.execute("$expression%");
        my @rows = $sth.allrows(:array-of-hash);
        $successful-requests++ if $result > 0;
        content 'application/json', @rows;
    }

    if %defaults<debug-mode> {
        get -> 'statistics' {
            my %statistics = :$total-requests, :$successful-requests;
            %statistics<uptime> = (DateTime.now - $start-time).Int;
            content 'application/json', %statistics;
        }
    }
}

my Cro::Service $service = Cro::HTTP::Server.new:
    :host<localhost>, :port<10000>, :$application;

$service.start;

react whenever signal(SIGINT) {
    $service.stop;
    exit;
}
