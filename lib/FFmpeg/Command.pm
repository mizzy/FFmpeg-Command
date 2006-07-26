package FFmpeg::Command;

use warnings;
use strict;
our $VERSION = '0.01';

use base qw/Class::Accessor::Fast/;
__PACKAGE__->mk_accessors( qw(input_file output_file ffmpeg options) );

my %option = (
    format              => '-f',
    video_codec         => '-vcodec',
    bitrate             => '-b',
    size                => '-s',
    audio_codec         => '-acodec',
    audio_sampling_rate => '-ar',
    audio_bit_rate      => '-ab',
);

sub new {
    my $class = shift;
    my $self = {
        ffmpeg  => shift || '/usr/bin/ffmpeg',
        options => [],
    };
    bless $self, $class;
}

sub input_options {
    my ( $self, $args ) = @_;
    $self->input_file($args->{file});
    return;
}

sub output_options {
    my ( $self, $args ) = @_;
    $self->output_file(delete $args->{file});


    for ( keys %$args ){
        push @{ $self->options }, $option{$_}, $args->{$_};
    }

    return;
}

sub execute {
    my $self = shift;
    warn join ' ', @{ $self->options };
    exec $self->ffmpeg, '-i', $self->input_file, @{ $self->options }, $self->output_file;
}

*exec = \&execute;

1;
__END__

=head1 NAME

FFmpeg::Command - A wrapper class for ffmpeg command line utility.

=head1 DESCRIPTION



=head1 SYNOPSIS

    use FFmpeg::Command;

    my $ffmpeg = FFmpeg::Command->new('/usr/local/bin/ffmpeg');

    # Converting a video file into another video format.
    $ffmpeg->input_options({
        file => $input_file,
    });

    $ffmpeg->output_options({
        file                => $output_file,
        format              => 'mp4',
        video_codec         => 'h264',
        bitrate             => '640',
        size                => '320x240',
        audio_codec         => 'aac',
        audio_sampling_rate => '44100',
        audio_bit_rate      => '128',
    });

    $ffmpeg->exec();

    # Executing ffmpeg with any options you like.
    # This sample code takes a screnn shot.
    $ffmpeg->input_file($input_file);
    $ffmpeg->output_file($output_file);

    $ffmpeg->options(
        '-y',
        '-f'       => 'image2',
        '-pix_fmt' => 'jpg',
        '-vframes' => 1,
        '-ss'      => 30,
        '-s'       => '320x240',
        '-an',
    );

    $ffmeg->exec();

=head1 METHODS

=head2 new

=head2 input_file

=head2 output_file

=head2 options

=head2 input_options

=head2 output_options

=head2 execute

=head2 exec


=head1 AUTHOR

Gosuke Miyashita, C<< <gosukenator at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-ffmpeg-command at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FFmpeg-Command>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FFmpeg::Command

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/FFmpeg-Command>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/FFmpeg-Command>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=FFmpeg-Command>

=item * Search CPAN

L<http://search.cpan.org/dist/FFmpeg-Command>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Gosuke Miyashita, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
