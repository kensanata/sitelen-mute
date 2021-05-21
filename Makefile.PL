use 5.008004;
use ExtUtils::MakeMaker;
use File::ShareDir::Install;

install_share 'share';

# os_unsupported if $^O eq 'MSWin32';

WriteMakefile(
  NAME             => 'App::sitelenmute',
  VERSION_FROM     => 'lib/App/sitelenmute.pm',
  ABSTRACT_FROM    => 'lib/App/sitelenmute.pm',
  AUTHOR           => 'Alex Schroeder',
  LICENSE          => 'gpl_3',
  MIN_PERL_VERSION => '5.26.0', # Modern::Perl '2018'
  EXE_FILES        => [
    'script/sitelen-mute',
    'script/fcaption',
  ],
  PREREQ_PM => {
    'Modern::Perl' => 1.20180701, # for '2018'
    'Encode::Locale' => 0,
    'File::Copy::Recursive' => 0,
    'File::Slurper' => 0,
    'File::ShareDir' => 0,
    'File::Symlink::Relative' => 0,
    'Image::ExifTool' => 0,
    'JSON::Tiny' => 0,
    'Time::Progress' => 0,
  },
  CONFIGURE_REQUIRES => {
    'ExtUtils::MakeMaker' => '6.52',
    'File::ShareDir::Install' => 0,
  },
  TEST_REQUIRES => {
    'File::SearchPath' => 0,
    'Mojo::DOM58' => 0,
  },
  META_MERGE => {
    'meta-spec' => { version => 2 },
    resources => {
      repository => {
	type => 'git',
	url  => 'https://alexschroeder.ch/cgit/',
	web  => 'https://alexschroeder.ch/cgit/sitelen-mute/about/',
      },
    },
  },
  clean => {
    FILES => "t/gallery t/album2",
  },
);

package MY;
use File::ShareDir::Install;

sub postamble {
  my $self = shift;
  my @ret = File::ShareDir::Install::postamble($self);
  push @ret, <<'EOT';
README.md: script/sitelen-mute
	pod2markdown $< $@
EOT
  return join "\n", @ret;
}
