package Log::ger::Output::Perl;

# DATE
# VERSION

use strict;
use warnings;
use Log::ger::Util ();

sub get_hooks {
    my %conf = @_;

    my $action = delete($conf{action}) || {
        warn  => 'warn',
        error => 'warn',
        fatal => 'die',
    };
    keys %conf and die "Unknown configuration: ".join(", ", sort keys %conf);

    return {
        create_logml_routine => [
            __PACKAGE__, 50,
            sub {
                my %args = @_;

                my $logger = sub {
                    my $ctx = shift;
                    my $lvl = shift;
                    if (my $act =
                            $action->{Log::ger::Util::string_level($lvl)}) {
                        if ($act eq 'warn') {
                            warn @_;
                        } elsif ($act eq 'carp') {
                            require Carp;
                            goto &Carp::carp;
                        } elsif ($act eq 'cluck') {
                            require Carp;
                            goto &Carp::cluck;
                        } elsif ($act eq 'croak') {
                            require Carp;
                            goto &Carp::croak;
                        } elsif ($act eq 'confess') {
                            require Carp;
                            goto &Carp::confess;
                        } else {
                            # die is the default action if unknown
                            die @_;
                        }
                    }
                };
                [$logger];
            }],
    };
}

1;
# ABSTRACT: Log to Perl's standard facility (warn, die, etc)

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

 use Log::ger::Output Perl => (
     action => { # optional
         trace => '',
         debug => '',
         info  => '',
         warn  => 'warn',
         error => 'warn',
         fatal => 'die',
     },
 );


=head1 DESCRIPTION

This output passes message to Perl's standard facility of reporting error:
C<warn()>, C<die()>, or one of L<Carp>'s C<carp()>, C<cluck()>, C<croak()>, and
C<confess()>.


=head1 CONFIGURATION

=head2 action => hash

A mapping of Log::ger error level name and action. Unmentioned levels mean to
ignore log for that level. Action can be one of:

=over

=item * '' (empty string)

Ignore the log message.

=item * warn

Pass message to Perl's C<warn()>.

=item * die

Pass message to Perl's C<die()>.

=item * carp

Pass message to L<Carp>'s C<carp()>.

=item * cluck

Pass message to L<Carp>'s C<cluck()>.

=item * croak

Pass message to L<Carp>'s C<croak()>.

=item * confess

Pass message to L<Carp>'s C<confess()>.

=back


=head1 SEE ALSO

Modelled after L<Log::Dispatch::Perl>.

L<Log::Dispatch::Plugin::Perl> which actually replaces the log statements with
warn(), die(), etc.

=cut
