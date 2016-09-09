class Widget < ActiveRecord::Base
  def self.not_delivered
    where.not(delivered_on: nil)
  end

  def self.produced_before(produced_before_date)
    where('produced_on < ?', produced_before_date)
  end
end
