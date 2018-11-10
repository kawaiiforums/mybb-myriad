use DBIish;
use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Myriad::Controller::Users;
use Myriad::Controller::Statistics;

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

my $application = route {
    include users(%defaults, $dbh);

    if %defaults<debug-mode> {
        include statistics;
    }
}

my Cro::Service $service = Cro::HTTP::Server.new:
    :host<localhost>, :port<10000>, :$application;

$service.start;

react whenever signal(SIGINT) {
    $service.stop;
    exit;
}
