require "fog"

class Relish
  class DynamoHelper

    def initialize(*args)
      if (args.length == 1 && args[0].is_a?(Hash))
        # This enables support for dynamodb local by supporting
        # host, port, and scheme options. It also needs to be
        # supported by the application calling relish.
        @connection_opts = args[0]
        @table_name = @connection_opts.delete(:table_name)
      else
        aws_access_key, aws_secret_key, table_name, region = *args
        region ||= 'us-east-1'

        @table_name     = table_name
        @connection_opts = {
          :aws_access_key_id => aws_access_key,
          :aws_secret_access_key => aws_secret_key,
          :region => region
        }
      end
    end

    def db
      @db ||= Fog::AWS::DynamoDB.new(@connection_opts)
    end

    def query_current_version(id, *attrs)
      response = db.query(@table_name, {:S => id}, :ConsistentRead => true, :Limit => 1, :ScanIndexForward => false)
      if response.body['Count'] == 1
        response.body['Items'].first
      end
    end

    def put_current_version(item)
      db.put_item(@table_name, item, {:Expected => {:id => {:Exists => false}, :version => {:Exists => false}}})
    end

    def get_version(id, version, *attrs)
      response = db.get_item(@table_name, {:HashKeyElement => {:S => id}, :RangeKeyElement => {:N => version}}, :ConsistentRead => true)
      response.body['Item']
    end

    def delete_version(id, version)
      db.delete_item(@table_name, {:HashKeyElement => {:S => id}, :RangeKeyElement => {:N => version}})
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

    def inspect
      "#<Relish::DynamoHelper>"
    end

    alias to_s inspect
  end
end
