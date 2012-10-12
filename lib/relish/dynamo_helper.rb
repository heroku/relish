require "fog"

class Relish
  class DynamoHelper

    def initialize(aws_access_key, aws_secret_key, table_name)
      @aws_access_key = aws_access_key
      @aws_secret_key = aws_secret_key
      @table_name = table_name
    end

    def db
      @db ||= Fog::AWS::DynamoDB.new(:aws_access_key_id => @aws_access_key, :aws_secret_access_key => @aws_secret_key)
    end

    def query_current_version(id, *attrs)
      opts = set_attrs_on_opts(attrs, :ConsistentRead => true, :Limit => 1, :ScanIndexForward => false)
      response = db.query(@table_name, {:S => id}, opts)
      if response.body['Count'] == 1
        response.body['Items'].first
      end
    end

    def put_current_version(item)
      db.put_item(@table_name, item, {:Expected => {:id => {:Exists => false}, :version => {:Exists => false}}})
    end

    def get_version(id, version, *attrs)
      opts = set_attrs_on_opts(attrs)
      response = db.get_item(@table_name, {:HashKeyElement => {:S => id}, :RangeKeyElement => {:N => version}}, opts)
      response.body['Item']
    end

    def put_version(id, version, item)
      db.put_item(@table_name, item, {:Expected => {:id => {:Value => {:S => id}}, :version => {:Value => {:N => version}}}})
    end

    def put(item)
      db.put_item(@table_name, item)
    end

    def query(id, consistent, limit)
      response = db.query(@table_name, {:S => id}, :ConsistentRead => consistent, :Limit => limit, :ScanIndexForward => false)
      response.body['Items']
    end

    private

    def set_attrs_on_opts(attrs, opts = {})
      attrs = Array(attrs)
      opts[:AttributesToGet] = attrs unless attrs.empty?
      opts
    end
  end
end
