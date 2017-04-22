use v6.c;

grammar Config is export {
    token TOP { ^ <section>+ $ }
    token section { [ '[' <section-name> ']' \n [ <section-line>+ | <empty-line>+ ] ] | <empty-line>+ }
    token section-name { <-[\]]>+ }
    token section-line { \s* <identifier> \s* '=' \s* <value> \n }
    token empty-line { \n }
    token value { <-[\n]>+ }
    token identifier { \w+ }
}

sub git-config(IO::Path $file? --> Hash) is export {
    my %ret;

    my @fs = $file.Str // ($*HOME «~« </.gitconfig /.config/git/config>);
    my $cfg-text = ([//] try (@fs».IO».open)).slurp // warn("Can not find gitconfig at any of {('⟨' «~« @fs »~» '⟩').join(', ')}");

    my $parsed = Config.parse($cfg-text) or fail 'Failed to parse „~/.gitconfig“.';

    for $parsed.Hash<section>.list -> $section {
        next unless $section<section-name>;

        %ret{$section<section-name>.Str} = Hash.new(do for $section.hash<section-line> {
             .hash<identifier>.Str => .hash<value>.Str
        })
    }
    
    %ret
}
