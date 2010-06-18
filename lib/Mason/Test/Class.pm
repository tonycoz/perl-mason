package Mason::Test::Class;
use File::Basename;
use File::Path;
use File::Slurp;
use File::Temp qw(tempdir);
use Mason::Interp;
use Test::More;
use strict;
use warnings;
use base qw(Test::Class);

__PACKAGE__->SKIP_CLASS("abstract base class");

sub _startup : Test(startup) {
    my $self = shift;
    $self->{temp_dir}   = tempdir( 'mason-test-XXXX', TMPDIR => 1, CLEANUP => 1 );
    $self->{comp_root} = $self->{temp_dir} . "/comps";
    $self->{data_dir}  = $self->{temp_dir} . "/data";
    mkpath( [ $self->{comp_root}, $self->{data_dir} ], 0, 0775 );
}

sub test_comp {
    my ($self, %params) = @_;

    my $caller      = ( caller(1) )[3];
    my $path        = $params{path} || "/$caller";
    my $desc        = $params{desc} || $caller;
    my $source_file = join( "/", $self->{comp_root}, $path );
    my $source      = $params{component} || die "must pass component";
    my $expect      = $params{expect} || die "must pass expect";
    my $output;
    my $interp = Mason::Interp->new(
        comp_root  => $self->{comp_root},
        data_dir   => $self->{data_dir},
        out_method => \$output
    );

    mkpath_and_write_file( $source_file, $source );
    $interp->run($path);

    is( $output, $expect, $desc );
}

sub mkpath_and_write_file {
    my ( $source_file, $source ) = @_;

    mkpath( dirname($source_file), 0, 0775 );
    write_file( $source_file, $source );
}

1;
