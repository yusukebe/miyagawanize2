#!/usr/bin/env perl
use Mojolicious::Lite;
use Image::ObjectDetect;
use Imager;
use MIME::Base64;
use File::Temp qw/tempfile/;

my $cascade  = './haarcascade_frontalface_alt2.xml';
my $detector = Image::ObjectDetect->new($cascade);

get '/' => sub {
    my $self = shift;
    $self->render('index');
};

get 'ws' => sub {
    my $self = shift;
    $self->on(
        message => sub {
            my ( $self, $message ) = @_;
            $message =~ s/^.+?,(.+)$/$1/;
            my ( $fh, $filename ) = tempfile( SUFFIX => '.jpg' );
            my $input = decode_base64($message);
            binmode $fh;
            print $fh $input; close $fh;
            my $purple_source = Imager->new->read( file => './purple.png' ) or die Imager->errstr;
            my $image = Imager->new( file => $filename, type => 'jpeg' )
                or die Imager->errstr;
            my @faces = $detector->detect($filename);
            my $aspect = 1.5;
            for my $face (@faces) {
                my $purple = $purple_source->scale(
                    xpixels => $face->{width} / $aspect,
                    ypixels => $face->{height} / $aspect,
                );
                $image->rubthrough(
                    tx  => $face->{width} / $aspect / 2 + $face->{x},
                    ty  => $face->{height} / $aspect + $face->{y},
                    src => $purple,
                );
            }
            my $data;
            $image->write( data => \$data, type => 'jpeg' )
              or die $image->errstr;
            my $base64 = encode_base64( $data, '' );
            $self->send("data:image/jpeg;base64,$base64");
        }
    );
};

app->start;
