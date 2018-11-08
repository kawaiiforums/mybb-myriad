unit package Myriad::Controller::Statistics;
use Cro::HTTP::Router;

my $start-time = DateTime.now;
my $total-requests = 0;
my $successful-requests = 0;

sub statistics() is export {
    route {
        get -> 'statistics' {
            my %statistics = :$total-requests, :$successful-requests;
            %statistics<uptime> = (DateTime.now - $start-time).Int;
            content 'application/json', %statistics;
        }
    }
}

sub log-request is export { $total-requests++ }
sub log-successful-request is export { $successful-requests++ }
