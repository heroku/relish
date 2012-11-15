require "relish/dynamo_helper"
require "relish/s3_helper"
require "relish/encryption_helper"
require "relish/release"

class Relish

  def initialize(*args)
    @db = DynamoHelper.new(*args)
  end

  def copy(id, version, data)
    Release.new.tap do |release|
      release.item = {}
      release.id = id
      release.version = version
      data.each do |k, v|
        release.send("#{k}=", v.to_s) unless v.nil?
      end
      @db.put(release.item)
    end
  end

  def create(id, data)
    item = @db.query_current_version(id)
    Release.new.tap do |release|
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
    end
  end

  def current(id, *attrs)
    item = @db.query_current_version(id, *attrs)
    unless item.nil?
      Release.new.tap do |release|
        release.item = item
      end
    end
  end

  def read(id, version, *attrs)
    item = @db.get_version(id, version, *attrs)
    unless item.nil?
      Release.new.tap do |release|
        release.item = item
      end
    end
  end

  def dump(id, consistent=nil, limit=nil)
    items = @db.query(id, consistent, limit)
    items.map do |item|
      Release.new.tap do |release|
        release.item = item
      end
    end
  end

  def update(id, version, data)
    item = @db.get_version(id, version)
    unless item.nil?
      Release.new.tap do |release|
        release.item = item
        data.each do |k, v|
          release.send("#{k}=", v.to_s) unless v.nil?
        end
        @db.put_version(id, version, release.item)
      end
    end
  end
end
