unit package Myriad::Controller::Users;
use Myriad::Controller::Statistics;
use Cro::HTTP::Router;

sub users(%defaults, $dbh) is export {
    route {
        get -> 'u', $expression is copy {
        log-request;
        $expression = $expression.lc().trim();
        my $sth = $dbh.prepare(qq:to/STATEMENT/);
           SELECT uid AS uid, username AS username
             FROM %defaults<database-table-prefix>_users
            WHERE username ILIKE ?
         ORDER BY postnum DESC, lastactive DESC, username
            LIMIT 15
        STATEMENT
        my $result = $sth.execute("%$expression%");
        my @rows = $sth.allrows(:array-of-hash);
        log-successful-request if $result > 0;
        content 'application/json', @rows;
        }
    }
}

