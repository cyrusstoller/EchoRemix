class Topic < ApplicationRecord
  validates_presence_of :text
  validates_uniqueness_of :text
  validates_presence_of :weight

  scope :priority, -> { order(weight: :desc, text: :asc) }

  def self.random
    order("RANDOM()").first.text rescue "Waiting for new topics ..."
  end
end
