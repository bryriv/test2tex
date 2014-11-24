#!/usr/bin/perl

use strict;
use warnings;

use Config::General qw(ParseConfig);
use File::Slurp qw(read_file write_file);
use Data::Dumper;

my $template_dir = './templates';

my $conf_file = './test.conf';
#my $conf_file = shift || die 'no input file';
my %conf = ParseConfig($conf_file);

# print Dumper \%conf;
# print "path: ", $conf{header}->{graphicspath}, "\n";
my @tex;

# header info
my @header_params = qw(graphicspath headerid title);
my $header = read_file $template_dir . '/header.tmp';
for my $var (@header_params) {
    $header =~ s/##$var##/$conf{header}->{$var}/;
}

push @tex, $header;

# questions
for my $hash (@{$conf{question}}) {
    push @tex, default($hash) if !$hash->{format} or $hash->{format} eq 'default';
    push @tex, image_subpart($hash) if $hash->{format} eq 'image_subpart';
    push @tex, grid($hash) if $hash->{format} eq 'grid';
}

# footer
push @tex, read_file $template_dir . '/footer.tmp';;

# put pieces together
my $tex = join "\n", @tex;
# output to file
print $tex;

# formats
# free_response
# free_response_image
# image_subpart
# long_answer
# grid

exit;


sub default {
    my $format = '/default.tmp';
    my $hash = shift;
    my $template = read_file $template_dir . $format;
    for my $var ('question', 'tek') {
        $template =~ s/##$var##/$hash->{$var}/;
    }
    my @choices;
    for my $choice (@{$hash->{choice}}) {
        my $tex_cmd = $choice->{correct} ? '\CorrectChoice' : '\choice';
        push @choices, join ' ', ($tex_cmd, $choice->{val});
    }
    my $choices = join "\n", @choices;
    $template =~ s/##choices##/$choices/;
    return $template;
}

sub image_subpart {
    my $format = '/image_subpart.tmp';
    my $hash = shift;
    my $template = read_file $template_dir . $format;
    for my $var ('question', 'tek', 'scale', 'image', 'subpart') {
        $template =~ s/##$var##/$hash->{$var}/;
    }
    my @choices;
    for my $choice (@{$hash->{choice}}) {
        my $tex_cmd = $choice->{correct} ? '\CorrectChoice' : '\choice';
        push @choices, join ' ', ($tex_cmd, $choice->{val});
    }
    my $choices = join "\n", @choices;
    $template =~ s/##choices##/$choices/;
    return $template;
}

sub grid {
    my $format = '/grid.tmp';
    my $hash = shift;
    my $template = read_file $template_dir . $format;
    for my $var ('question', 'tek', 'scale', 'image', 'solution') {
        $template =~ s/##$var##/$hash->{$var}/;
    }
    return $template;

}
