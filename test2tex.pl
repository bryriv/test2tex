#!/usr/bin/perl

use strict;
use warnings;

use Config::General qw(ParseConfig);
use File::Slurp qw(read_file write_file);
use Data::Dumper;

my $header_template = './templates/header.tmp';
my $default_template = './templates/default.tmp';

my $conf_file = './test.conf';
#my $conf_file = shift || die 'no input file';
my %conf = ParseConfig($conf_file);

# print Dumper \%conf;
# print "path: ", $conf{header}->{graphicspath}, "\n";

# header info
my @header_params = qw(graphicspath headerid title);
my $header = read_file $header_template;
for my $var (@header_params) {
    $header =~ s/##$var##/$conf{header}->{$var}/;
}
print $header, "\n";

# questions
for my $hash (@{$conf{question}}) {
    if (!$hash->{format} or $hash->{format} eq 'default') {
        my $template = read_file $default_template;
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
        print $template, "\n";
    }
}

# formats
# free_response
# free_response_image
# image_subpart
# long_answer
# grid

exit;
