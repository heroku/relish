# Relish

A release manager.

# Usage

```
> r = Relish.new("aws-access-key", "aws-secret-key", "table-name")
```

### Copy a Release

Copies release data for id `abc` to version `123`:

```
> rel = r.copy("abc", "123", slug_id: "slug-123", slug_version: "1")
file=relish fn=copy id=abc version=123
=> #<Relish::Release: @item={"id"=>{"S"=>"abc"}, "version"=>{"N"=>"123"}, "slug_id"=>{"S"=>"slug-123"}, "slug_version"=>{"N"=>"1"}}>
> rel.id
=> "abc"
> rel.version
=> "123"
> rel.slug_id
=> "slug-123"
> rel.slug_version
=> "1"
>
```

### Create a Release

Creates release with data for id `abc` - version will be `1` or current version + 1:

```
> rel = r.create("abc", slug_id: "slug-456", slug_version: "2")
file=relish fn=create id=abc
=> #<Relish::Release: @item={"id"=>{"S"=>"abc"}, "version"=>{"N"=>"124"}, "slug_version"=>{"N"=>"2"}, "slug_id"=>{"S"=>"slug-456"}}>
> rel.id
=> "abc"
> rel.version
=> "124"
> rel.slug_id
=> "slug-456"
> rel.slug_version
=> "2"
>
```

### Current Release

Returns the current release for id `abc`:

```
> rel = r.current("abc")
file=relish fn=current id=abc
=> #<Relish::Release: @item={"id"=>{"S"=>"abc"}, "version"=>{"N"=>"124"}, "slug_version"=>{"N"=>"2"}, "slug_id"=>{"S"=>"slug-456"}}>
> rel.id
=> "abc"
> rel.version
=> "124"
> rel.slug_id
=> "slug-456"
> rel.slug_version
=> "2"
>
```

### Read Release

Returns version `123` for id `abc`:

```
> rel = r.read("abc", "123")
file=relish fn=read id=abc version=123
=> #<Relish::Release: @item={"id"=>{"S"=>"abc"}, "version"=>{"N"=>"123"}, "slug_version"=>{"N"=>"1"}, "slug_id"=>{"S"=>"slug-123"}}>
> rel.id
=> "abc"
> rel.version
=> "123"
> rel.slug_id
=> "slug-123"
> rel.slug_version
=> "1"
>
```

### Update Release

Update release data for version `123` for id `abc`:

```
> rel = r.update("abc", "123", slug_id: "slug-789")
file=relish fn=update id=abc version=123
=> #<Relish::Release: @item={"id"=>{"S"=>"abc"}, "version"=>{"N"=>"123"}, "slug_version"=>{"N"=>"1"}, "slug_id"=>{"S"=>"slug-789"}}>
> rel.id
=> "abc"
> rel.version
=> "123"
> rel.slug_id
=> "slug-789"
> rel.slug_version
=> "1"
>
```

### Dump Releases

Dump release data for id `abc`:

```
> rels = r.dump("abc", 2)
=> [#<Relish: @item={"id"=>{"S"=>"abc"}, "version"=>{"N"=>"124"}, "slug_version"=>{"N"=>"2"}, "slug_id"=>{"S"=>"slug-456"}}>, #<Relish: @item={"id"=>{"S"=>"abc"}, "version"=>{"N"=>"123"}, "slug_version"=>{"N"=>"1"}, "slug_id"=>{"S"=>"slug-789"}}>]
> rels[0].id
=> "abc"
> rels[0].version
=> "124"
> rels[0].slug_id
=> "slug-456"
> rels[0].slug_version
=> "2"
> rels[1].id
=> "abc"
> rels[1].version
=> "123"
> rels[1].slug_id
=> "slug-789"
> rels[1].slug_version
=> "1"
>

## Releasing new versions of the gem

The `relish` gem is hosted on a private RubyGems server via [packagecloud][packagecloud] and releases are generated with
[the Release Gem action](.github/workflows/release-gem.yml).

When you are ready to release a new version

1. Update the gem version in [lib/gateway/authentication/version.rb](lib/gateway/authentication/version.rb).
2. Merge [lib/gateway/authentication/version.rb](lib/gateway/authentication/version.rb) to main.
3. Make sure you are on main and have the latest version of the code
   1. `git checkout main`
   2. `git fetch -p origin`
   3. `git merge --ff-only origin/main`
4. Tag the version
   1. `git tag -a vX.Y.Z` (where `X.Y.Z` is the version number on the version file)
   2. `git push origin vX.Y.Z`

And that's it, the release gem action will build the updated version of the gem and upload the new gem package to packagecloud.

[packagecloud]: https://packagecloud.io
