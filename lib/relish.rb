require "fog"

class Relish

  attr_accessor :items

  def self.conf(*attrs)
    attrs.each do |attr|
      instance_eval "def #{attr}; @#{attr} end", __FILE__, __LINE__
      instance_eval "def #{attr}= value; @#{attr} = value end", __FILE__, __LINE__
    end
  end

  conf :aws_access_key, :aws_secret_key, :table_name

  def self.schema(attrs)
    attrs.each do |attr, type|
      class_eval "def #{attr}; @items['#{attr}']['#{type}'] if @items.key? '#{attr}' end", __FILE__, __LINE__
      class_eval "def #{attr}= value; @items['#{attr}'] = {'#{type}' => value} end", __FILE__, __LINE__
    end
  end

  schema :id             => :S,
         :version        => :N,
         :descr          => :S,
         :user_id        => :N,
         :slug_id        => :S,
         :slug_version   => :N,
         :stack          => :S,
         :language_pack  => :S,
         :env_json       => :S,
         :pstable_json   => :S,
         :addons_json    => :S

  def self.db
    @db ||= Fog::AWS::DynamoDB.new(:aws_access_key_id => aws_access_key, :aws_secret_access_key => aws_secret_key)
  end

  def self.db_query_current_version(id)
    response = db.query(table_name, {:S => id}, :ConsistentRead => true, :Limit => 1, :ScanIndexForward => false)
    if response.status != 200
      raise('status: #{response.status}')
    end
    if response.body['Count'] == 1
      response.body['Items'].first
    end
  end

  def self.db_put_current_version(items)
    response = db.put_item(table_name, items, {:Expected => {:id => {:Exists => false}, :version => {:Exists => false}}})
    if response.status != 200
      raise('status: #{response.status}')
    end
  end

  def self.db_get_version(id, version)
    response = db.get_item(table_name, {:HashKeyElement => {:S => id}, :RangeKeyElement => {:N => version}})
    if response.status != 200
      raise('status: #{response.status}')
    end
    response.body['Item']
  end

  def self.db_put_version(id, version, items)
    response = db.put_item(table_name, items, {:Expected => {:id => {:Value => {:S => id}}, :version => {:Value => {:N => version}}}})
    if response.status != 200
      raise('status: #{response.status}')
    end
  end

  def self.db_put(items)
    response = db.put_item(table_name, items)
    if response.status != 200
      raise('status: #{response.status}')
    end
  end

  def self.copy(id, version, data)
    release = new
    release.items = {}
    release.id = id
    release.version = version
    data.each do |k, v|
      release.send("#{k}=", v.to_s) unless v.nil?
    end
    db_put(release.items)
    release
  end

  def self.create(id, data)
    items = db_query_current_version(id)
    release = new
    if items.nil?
      release.items = {}
      release.id = id
      release.version = "1"
    else
      release.items = items
      release.version = (release.version.to_i + 1).to_s
    end
    data.each do |k, v|
      release.send("#{k}=", v.to_s) unless v.nil?
    end
    db_put_current_version(release.items)
    release
  end

  def self.current(id)
    items = db_query_current_version(id)
    unless items.nil?
      release = new
      release.items = items
      release
    end
  end

  def self.read(id, version)
    items = db_get_version(id, version)
    unless items.nil?
      release = new
      release.items = items
      release
    end
  end

  def self.dump(id)
  end

  def self.update(id, version, data)
    items = db_get_version(id, version)
    unless items.nil?
      release = new
      release.items = items
      data.each do |k, v|
        release.send("#{k}=", v.to_s) unless v.nil?
      end
      db_put_version(id, version, release.items)
      release
    end
  end
end
