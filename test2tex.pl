#!/usr/bin/perl

use strict;
use warnings;

use Config::General qw(ParseConfig);
use File::Slurp qw(read_file write_file);
use Data::Dumper;

my $conf_file = shift || die 'no input file';
my %conf = ParseConfig($conf_file);

my $template_dir = './templates';
my $templates = load_templates($template_dir);

my @tex;

# header info
my @header_params = qw(graphicspath headerid title);
my $header = $templates->{header};
for my $var (@header_params) {
    $header =~ s/##$var##/$conf{header}->{$var}/;
}
push @tex, $header;

# questions
for my $hash (@{$conf{question}}) {
    push @tex, default($hash, 'default') if !$hash->{format} or $hash->{format} eq 'default';
    push @tex, image_subpart($hash) if $hash->{format} eq 'image_subpart';
    push @tex, grid($hash) if $hash->{format} eq 'grid';
    push @tex, default($hash, 'long_answers') if $hash->{format} eq 'long_answers';
    push @tex, free_response($hash) if $hash->{format} eq 'free_response';
    push @tex, free_response_image($hash) if $hash->{format} eq 'free_response_image';
    push @tex, formula($hash) if $hash->{format} eq 'formula';
    push @tex, grid_subpart($hash) if $hash->{format} eq 'grid_subpart';
}

# footer
push @tex, $templates->{footer};

# put pieces together
my $tex = join "\n\n", @tex;

# output to file
print $tex;

# formats
# free_response
# free_response_image
# image_subpart
# long_answers
# grid

exit;


sub default {
    my ($hash, $format) = @_;
    my $template = $templates->{$format};

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
    my ($hash, $format) = @_;
    my $template = $templates->{image_subpart};

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
    my ($hash, $format) = @_;
    my $template = $templates->{grid};

    for my $var ('question', 'tek', 'scale', 'image', 'solution') {
        $hash->{$var} ||= '';
        $template =~ s/##$var##/$hash->{$var}/;
    }
    return $template;
}

sub free_response {
    my ($hash, $format) = @_;
    my $template = $templates->{free_response};
    $hash->{lines} ||= 2.5;
    for my $var ('question', 'tek', 'lines') {
        $template =~ s/##$var##/$hash->{$var}/;
    }
    return $template;
}

sub free_response_image {
    my ($hash, $format) = @_;
    my $template = $templates->{free_response_image};
    $hash->{lines} ||= 2.5;
    for my $var ('question', 'tek', 'lines', 'scale', 'image') {
        $template =~ s/##$var##/$hash->{$var}/;
    }
    return $template;
}

sub formula {
    my ($hash, $format) = @_;
    my $template = $templates->{formula};

    for my $var ('question', 'tek', 'formula') {
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

sub grid_subpart {
    my ($hash, $format) = @_;
    my $template = $templates->{grid_subpart};

    for my $var ('question', 'tek', 'scale', 'image', 'subpart', 'solution', 'grid_image', 'grid_scale') {
        $hash->{$var} ||= '';
        $template =~ s/##$var##/$hash->{$var}/;
    }
    return $template;

}

sub load_templates {
    my $dir = shift;
    my @templates = (
        'header', 'default', 'grid', 'long_answers', 'image_subpart',
        'free_response', 'free_response_image', 'footer', 'formula', 'grid_subpart',
    );
    my %temps;
    for my $tmp (@templates) {
        $temps{$tmp} = read_file $dir . "/$tmp.tmp";
    }
    return \%temps;
}
