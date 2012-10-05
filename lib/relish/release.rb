require "press"
require "fog"

module Relish
  class Release
    extend Press

    def self.conf(*attrs)
      attrs.each do |attr|
        instance_eval "def #{attr}; @#{attr} ||= ENV['#{attr.upcase}'] || raise('missing conf: #{attr.upcase}') end", __FILE__, __LINE__
      end
    end

    conf :relish_aws_access_key,
         :relish_aws_secret_key,
         :relish_table_name

    def self.schema(attrs)
      attrs.each do |attr, type|
        class_eval "def #{attr}; @items['#{attr}']['#{type}'] if @items.key? '#{attr}' end", __FILE__, __LINE__
        class_eval "def #{attr}= value; @items['#{attr}'] = {'#{type}' => value} end", __FILE__, __LINE__
      end
    end

    schema entity_id:      :S,
           release_id:     :N,
           descr:          :S,
           user_id:        :N,
           slug_id:        :S,
           slug_version:   :N,
           stack:          :S,
           language_pack:  :S,
           env_json:       :S,
           pstable_json:   :S,
           addons_json:    :S

    def self.db
      @db ||= Fog::AWS::DynamoDB.new(aws_access_key_id: relish_aws_access_key, aws_secret_access_key: relish_aws_secret_key)
    end

    def self.create(entity_id, data)
      pdfm __FILE__, __method__, entity_id: entity_id
    end

    def self.read(entity_id, release_id)
      pdfm __FILE__, __method__, entity_id: entity_id, release_id: release_id
    end

    def self.readall(entity_id)
      pdfm __FILE__, __method__, entity_id: entity_id
    end

    def self.update(entity_id, release_id, data)
      pdfm __FILE__, __method__, entity_id: entity_id, release_id: release_id
    end

    def self.delete(entity_id, release_id)
      pdfm __FILE__, __method__, entity_id: entity_id, release_id: release_id
    end
  end
end
