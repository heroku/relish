require "press"

module Relish
  extend Press

  def self.create(entity_id, data)
    pdfm __FILE__, __method__, entity_id: entity_id
    Release.create(entity_id, data)
  end

  def self.read(entity_id, release_id)
    pdfm __FILE__, __method__, entity_id: entity_id, release_id: release_id
    Release.read(entity_id, release_id)
  end

  def self.readall(entity_id)
    pdfm __FILE__, __method__, entity_id: entity_id
    Release.readall(entity_id)
  end

  def self.update(entity_id, release_id, data)
    pdfm __FILE__, __method__, entity_id: entity_id, release_id: release_id
    Release.update(entity_id, release_id, data)
  end

  def self.delete(entity_id, release_id)
    pdfm __FILE__, __method__, entity_id: entity_id, release_id: release_id
    Release.delete(entity_id, release_id)
  end
end
