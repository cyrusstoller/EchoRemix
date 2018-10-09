class Topic < ApplicationRecord
  validates_presence_of :text
  validates_uniqueness_of :text
  validates_presence_of :weight

  scope :priority, -> { order(weight: :desc, text: :asc) }

  def self.random(current_topic = nil)
    begin
      if current_topic
        res = where.not(text: current_topic)
      else
        res = all()
      end
      res.order(Arel.sql("RANDOM()")).first.text
    rescue
      "Waiting for new topics ..."
    end
  end
end
