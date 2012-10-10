class Relish
  class Release

    attr_accessor :item

    def self.schema(attrs)
      attrs.each do |attr, type|
        class_eval "def #{attr}; @item['#{attr}']['#{type}'] if @item.key? '#{attr}' end", __FILE__, __LINE__
        class_eval "def #{attr}= value; @item['#{attr}'] = {'#{type}' => value} end", __FILE__, __LINE__
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
           :env            => :S,
           :pstable        => :S,
           :addons         => :S
  end
end
