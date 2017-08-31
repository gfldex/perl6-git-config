use v6.c;

grammar Config is export {
    token TOP { ^ \s* [ <block> [ <white-lines> <block>]* ]? \s* $ }
    token block { [ <section> || <comment> ] }
    token white-lines { [ \s*? \n ]+ }
    token section { '[' <section-name> ']' [ <white-lines> <section-content> ]* }
    token section-content { [ <comment> || <section-line> ] }
    token section-name { <-[\]]>+ }
    token section-line { \s* <identifier> \s* '=' \s* <value> }
    token value { <-[\n]>+ }
    token comment { \s* '#' <-[\n]>* }
    token identifier { <+[ - \w ]>+ }
}

sub git-config(IO::Path $file? --> Hash) is export {
    my %ret;

    my @fs = $file // ($*HOME «~« </.gitconfig /.config/git/config>);
    my $cfg-handle = ([//] try (@fs».IO».open)) // warn("Can not find gitconfig at any of {('⟨' «~« @fs »~» '⟩').join(', ')}");
    my $cfg-text is default("") = try $cfg-handle.slurp;

    my $parsed = Config.parse($cfg-text) // []; # or fail 'Failed to parse „~/.gitconfig“.';
    for $parsed.hash<block>.map({ .hash<section> }) -> $section {
        next unless $section<section-name>;

        %ret{$section<section-name>.Str} = Hash.new(do for $section.hash<section-content>.map({ .hash<section-line> }).grep({ ?$_ }) {
             .hash<identifier>.Str => .hash<value>.Str
        })
    }

    my $cfg-file-path = $cfg-handle.path;

    %ret but role :: {
        method search-path { @fs }
        method path { $cfg-file-path }
    }
}
