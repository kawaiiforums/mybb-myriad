unit package Myriad::Controller::Threads;
use Myriad::Controller::Statistics;
use Cro::HTTP::Router;

sub threads(%defaults, $dbh) is export {
    route {
        get -> 't', $expression is copy {
        log-request;
        $expression = $expression.lc().trim();
        my $sth = $dbh.prepare(qq:to/STATEMENT/);
        SELECT t.tid AS u,
               t.subject AS n,
               p.message AS c
          FROM %defaults<database-table-prefix>_threads t
          JOIN %defaults<database-table-prefix>_posts p 
            ON p.pid = t.firstpost
         WHERE t.subject ILIKE ?
      ORDER BY t.dateline DESC, t.lastpost DESC, t.subject
         LIMIT 15
     STATEMENT
        my $result = $sth.execute("$expression%");
        my @rows = $sth.allrows(:array-of-hash);
        log-successful-request if $result > 0;
        content 'application/json', @rows;
        }
    }
}

