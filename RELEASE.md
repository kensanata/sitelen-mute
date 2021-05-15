# What to do for a release?

Run `make README.md`.

Update `Changes` with user-visible changes.

Increase the version in `lib/App/sitelenmute.pm`.

Use n.nn_nn for developer releases:

```
make distdir
mv App-sitelenmute-3 App-sitelenmute-3.00_00
tar czf App-sitelenmute-3.00_00.tar.gz App-sitelenmute-3.00_00
```

Double check the `MANIFEST`. Did we add new files that should be in
here?

Commit any changes and tag the release.

Based on [How to upload a script to
CPAN](https://www.perl.com/article/how-to-upload-a-script-to-cpan/) by
David Farrell (2016):

```
perl Makefile.PL && make && make dist
cpan-upload -u SCHROEDER App-sitelenmute-3.tar.gz
```

How to Prepare a New Release
============================

1. Update `$VERSION` in `sitelen-mute`.

1. Make sure there is something appropriate in [NEWS](NEWS.md).

2. Commit this change.

3. Tag this commit using `sitelen-mute-$VERSION`.

4. Push and include the tag.
