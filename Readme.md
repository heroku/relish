# Relish

A release manager.

# Usage

```
> Relish.table_name="releases"
> Relish.aws_access_key="ABC"
> Relish.aws_secret_key="xyz"
```

### Copy a Release

Copies release data for id `abc` to version `123`:

```
> rel = Relish.copy("abc", "123", slug_id: "slug-123", slug_version: "1")
file=relish fn=copy id=abc version=123
=> #<Relish: @items={"id"=>{"S"=>"abc"}, "version"=>{"N"=>"123"}, "slug_id"=>{"S"=>"slug-123"}, "slug_version"=>{"N"=>"1"}}>
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
> rel = Relish.create("abc", slug_id: "slug-456", slug_version: "2")
file=relish fn=create id=abc
=> #<Relish: @items={"id"=>{"S"=>"abc"}, "version"=>{"N"=>"124"}, "slug_version"=>{"N"=>"2"}, "slug_id"=>{"S"=>"slug-456"}}>
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
> rel = Relish.current("abc")
file=relish fn=current id=abc
=> #<Relish: @items={"id"=>{"S"=>"abc"}, "version"=>{"N"=>"124"}, "slug_version"=>{"N"=>"2"}, "slug_id"=>{"S"=>"slug-456"}}>
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
> rel = Relish.read("abc", "123")
file=relish fn=read id=abc version=123
=> #<Relish: @items={"id"=>{"S"=>"abc"}, "version"=>{"N"=>"123"}, "slug_version"=>{"N"=>"1"}, "slug_id"=>{"S"=>"slug-123"}}>
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

Update release data for verion `123` for id `abc`:

```
> rel = Relish.update("abc", "123", slug_id: "slug-789")
file=relish fn=update id=abc version=123
=> #<Relish: @items={"id"=>{"S"=>"abc"}, "version"=>{"N"=>"123"}, "slug_version"=>{"N"=>"1"}, "slug_id"=>{"S"=>"slug-789"}}>
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
