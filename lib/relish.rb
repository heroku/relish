require "relish/dynamo_helper"
require "relish/s3_helper"
require "relish/encryption_helper"
require "relish/release"

class Relish

  def initialize(*args)
    @db    = DynamoHelper.new(*args)
    @tries = 3
  end

  def copy(id, version, data)
    rescue_dynamodb_error do
      Release.new.tap do |release|
        release.item = {}
        release.id = id
        release.version = version.to_s
        data.each do |k, v|
          release.send("#{k}=", v.to_s) unless v.nil?
        end
        @db.put(release.item)
      end
    end
  end

  def create(id, data)
    rescue_dynamodb_error do
      item = @db.query_latest_version(id)
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
  end

  def current(id, *attrs)
    rescue_dynamodb_error do
      item = @db.query_current_version(id, *attrs)
      unless item.nil?
        Release.new.tap do |release|
          release.item = item
        end
      end
    end
  end

  def read(id, version, *attrs)
    rescue_dynamodb_error do
      item = @db.get_version(id, version, *attrs)
      unless item.nil?
        Release.new.tap do |release|
          release.item = item
        end
      end
    end
  end

  def dump(id, consistent=nil, limit=nil)
    rescue_dynamodb_error do
      items = @db.query(id, consistent, limit)
      items.map do |item|
        Release.new.tap do |release|
          release.item = item
        end
      end
    end
  end

  def update(id, version, data)
    rescue_dynamodb_error do
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

  def delete(id, version)
    rescue_dynamodb_error do
      @db.delete_version(id, version)
    end
  end

  def set_error_handler(&blk)
    @error_handler = blk
  end

  def rescue_dynamodb_error
    tries = @tries
    begin
      yield
    rescue => e
      retries = ((tries -= 1) > 0)

      unless @error_handler.nil?
        @error_handler.call(e, retries)
      end

      if retries
        retry
      else
        raise
      end

    end
  end
end
