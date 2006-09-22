package FFmpeg::Command;

use warnings;
use strict;
our $VERSION = '0.05';

use base qw( Class::Accessor::Fast Class::ErrorHandler );
__PACKAGE__->mk_accessors( qw( input_file output_file ffmpeg options ) );

use IPC::Run qw( start );
use Carp qw( carp );

our %option = (
    format              => '-f',
    video_codec         => '-vcodec',
    bitrate             => '-b',
    frame_rate          => '-r',
    frame_size          => '-s',
    audio_codec         => '-acodec',
    audio_sampling_rate => '-ar',
    audio_bit_rate      => '-ab',
    title               => '-title',
    author              => '-author',
    comment             => '-comment',
    size                => '-s',
);

sub new {
    my $class = shift;
    my $self = {
        ffmpeg      => shift || 'ffmpeg',
        options     => [],
        input_file  => '',
        output_file => '',
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
    my $device = delete $args->{device} || 'ipod';

    my %device_option = (
        ipod => {
            format              => 'mp4',
            video_codec         => 'mpeg4',
            bitrate             => 600,
            frame_size          => '320x240',
            audio_codec         => 'aac',
            audio_sampling_rate => 48000,
            audio_bit_rate      => 64,
        },
        psp => {
            format              => 'psp',
            video_codec         => 'mpeg4',
            bitrate             => 600,
            frame_size          => '320x240',
            audio_codec         => 'aac',
            audio_sampling_rate => 48000,
            audio_bit_rate      => 64,
        },
    );

    my %output_option = (
        %{ $device_option{$device} },
        %$args,
    );

    for ( keys %output_option ){
        if( defined $option{$_} and defined $output_option{$_} ){
            push @{ $self->options }, $option{$_}, $output_option{$_};
        }
        else {
            carp "$_ is not defined and ignored.";
        }
    }

    return;
}

sub execute {
    my $self = shift;

    my ( $in, $out, $err );
    my $h = eval {
        start [ $self->ffmpeg, '-y', '-i', $self->input_file, @{ $self->options }, $self->output_file ],
            \$in, \$out, \$err;
    };

    if( $@ ){
        $self->error($@);
        return;
    }
    else {
        finish $h or do {
            $self->error($err);
            return;
        };
    }

    return 1;
}

*exec = \&execute;

1;
__END__

=head1 NAME

FFmpeg::Command - A wrapper class for ffmpeg command line utility.

=head1 DESCRIPTION

A simple interface for using ffmpeg command line utility.

=head1 SYNOPSIS

    use FFmpeg::Command;

    my $ffmpeg = FFmpeg::Command->new('/usr/local/bin/ffmpeg');

    $ffmpeg->input_options({
        file => $input_file,
    });

    # Convert a video file into iPod playable format.
    $ffmpeg->output_options({
        file  => $output_file,
        device => 'ipod',
    });

    my $result = $ffmpeg->exec();

    croak $ffmpeg->errstr unless $result;

    # This is same as above.
    $ffmpeg->output_options({
        file                => $output_file,
        format              => 'mp4',
        video_codec         => 'mpeg4',
        bitrate             => 600,
        frame_size          => '320x240',
        audio_codec         => 'aac',
        audio_sampling_rate => 48000,
        audio_bit_rate      => 64,
    });

    $ffmpeg->exec();


    # Convert a video file into PSP playable format.
    $ffmpeg->output_options({
        file  => $output_file,
        device => 'psp',
    });

    $ffmpeg->exec();

    # This is same as above.
    $ffmpeg->output_options({
        file                => $output_file,
        format              => 'psp',
        video_codec         => 'mpeg4',
        bitrate             => 600,
        frame_size          => '320x240',
        audio_codec         => 'aac',
        audio_sampling_rate => 48000,
        audio_bit_rate      => 64,
    });

    $ffmpeg->exec();

    # Execute ffmpeg with any options you like.
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

=head2 new('/usr/bin/ffmpeg')

Contructs FFmpeg::Command object.It takes a path of ffmpeg command.
You can omit this argument and this module searches ffmpeg command within PATH environment variable.


=head2 input_options({ %options })

Specify input file name and input options.(Now no options are available.)

=over

=item file

a file name of input file.

=back

=head2 output_options({ %options })

Specify output file name and output options.

Avaiable options are:

=over

=item file

a file name of output file.

=item format

Output video format.

=item video_codec

Output video codec.

=item bitrate

Output video bitrate.

=item frame_size

Output video screen size.

=item audio_codec

Output audio code.

=item audio_sampling_rate

Output audio sampling rate.

=item audio_bit_rate

Output audio bit rate.

=item title

Set the title.

=item author

Set the author.

=item comment

Set the comment.

=back

=head2 input_file('/path/to/inpuf_file')

Specify input file name using with options() method.

=head2 output_file('/path/to/output_file')

Specify output file name using with options() method.

=head2 options( @options )

Specify ffmpeg command options directly.

=head2 execute()

Executes ffmpeg comman with specified options.

=head2 exec()

An alias of execute()


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
