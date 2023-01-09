# What to do for a release?

Run `make README.md`.

Update `Changes` with user-visible changes.

Double check the `MANIFEST`. Did we add new files that should be in
here?

Increase the version in `lib/App/sitelenmute.pm`.

Use n.nn_nn for developer releases:

```
make distdir
rel=3.01_04
mv App-sitelenmute-${rel%_*} App-sitelenmute-$rel
tar czf App-sitelenmute-$rel.tar.gz App-sitelenmute-$rel
cpan-upload -u SCHROEDER App-sitelenmute-$rel.tar.gz
```

Commit any changes and tag the release.

Based on [How to upload a script to
CPAN](https://www.perl.com/article/how-to-upload-a-script-to-cpan/) by
David Farrell (2016):

```
trash App-sitelenmute-*.*_??
perl Makefile.PL && make && make dist
cpan-upload -u SCHROEDER App-sitelenmute-3.02.tar.gz
```

How to Prepare a New Release
============================

1. Update `$VERSION` in `sitelen-mute`.

1. Make sure there is something appropriate in [NEWS](NEWS.md).

2. Commit this change.

3. Tag this commit using `sitelen-mute-$VERSION`.

4. Push and include the tag.
