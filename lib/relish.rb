require "press"
require "relish/release"

module Relish
  extend Press

  def self.create(id, data)
    pdfm __FILE__, __method__, id: id
    Release.create(id, data)
  end

  def self.read(id, version)
    pdfm __FILE__, __method__, id: id, version: version
    Release.read(id, version)
  end

  def self.readall(id)
    pdfm __FILE__, __method__, id: id
    Release.readall(id)
  end

  def self.update(id, version, data)
    pdfm __FILE__, __method__, id: id, version: version
    Release.update(id, version, data)
  end
end
