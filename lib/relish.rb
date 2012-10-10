require "relish/dynamo_helper"
require "relish/encryption_helper"
require "relish/release"

class Relish

  def initialize(*args)
    @db = DynamoHelper.new(*args)
  end

  def copy(id, version, data)
    release = Release.new
    release.item = {}
    release.id = id
    release.version = version
    data.each do |k, v|
      release.send("#{k}=", v.to_s) unless v.nil?
    end
    @db.put(release.item)
    release
  end

  def create(id, data)
    item = @db.query_current_version(id)
    release = Release.new
    if item.nil?
      release.item = {}
      release.id = id
      release.version = "1"
    else
      release.item = item
      release.version = (release.version.to_i + 1).to_s
    end
    data.each do |k, v|
      release.send("#{k}=", v.to_s) unless v.nil?
    end
    @db.put_current_version(release.item)
    release
  end

  def current(id)
    item = @db.query_current_version(id)
    unless item.nil?
      release = Release.new
      release.item = item
      release
    end
  end

  def read(id, version)
    item = @db.get_version(id, version)
    unless item.nil?
      release = Release.new
      release.item = item
      release
    end
  end

  def dump(id, limit=nil)
    items = @db.query(id, limit)
    items.map do |item|
      release = Release.new
      release.item = item
      release
    end
  end

  def update(id, version, data)
    item = @db.get_version(id, version)
    unless item.nil?
      release = Release.new
      release.item = item
      data.each do |k, v|
        release.send("#{k}=", v.to_s) unless v.nil?
      end
      @db.put_version(id, version, release.item)
      release
    end
  end
end
