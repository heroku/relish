class Relish
  class Release

    attr_accessor :item

    def self.schema(attrs)
      attrs.each do |attr, type|
        class_eval "def #{attr}; @item['#{attr}']['#{type}'] if @item.key? '#{attr}' end", __FILE__, __LINE__
        class_eval "def #{attr}= value; @item['#{attr}'] = {'#{type}' => value} end", __FILE__, __LINE__
      end
    end

    schema :id                   => :S,
           :version              => :N,
           :name                 => :S,
           :descr                => :S,
           :user_id              => :N,
           :route_id             => :S,
           :slug_uuid            => :S,
           :slug_id              => :S,
           :slug_version         => :N,
           :stack                => :S,
           :language_pack        => :S,
           :commit               => :S,
           :heroku_log_input_url => :S,
           :log_input_url        => :S,
           :heroku_log_token     => :S,
           :log_token            => :S,
           :env                  => :S,
           :pstable              => :S,
           :addons               => :S,
           :uuid                 => :S,
           :app_uuid             => :S,
           :app_name             => :S,
           :format               => :S
  end
end
