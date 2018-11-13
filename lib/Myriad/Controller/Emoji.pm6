unit package Myriad::Controller::Emoji;
use Myriad::Controller::Statistics;
use Cro::HTTP::Router;

sub emoji(%defaults, $dbh) is export {
    route {
        get -> 'e', $expression is copy {
        log-request;
        $expression = $expression.lc().trim();
        my $sth = $dbh.prepare(qq:to/STATEMENT/);
           SELECT name AS name,
                  find AS code,
                  image AS image
             FROM %defaults<database-table-prefix>_smilies
            WHERE name ILIKE ?
         ORDER BY disporder DESC
            LIMIT 15
        STATEMENT
        my $result = $sth.execute("$expression%");
        my @rows = $sth.allrows(:array-of-hash);
        log-successful-request if $result > 0;
        content 'application/json', @rows;
        }
    }
}

