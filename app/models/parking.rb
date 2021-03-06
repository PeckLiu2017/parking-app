class Parking < ApplicationRecord
  belongs_to :user, :optional => true
  validates_presence_of :parking_type, :start_at
  validates_inclusion_of :parking_type, :in => ["guest", "short-term", "long-term"]

  validate :validate_end_at_with_amount

  before_validation :setup_amount

  def validate_end_at_with_amount
    if ( end_at.present? && amount.blank? )
      errors.add(:amount, "有结束时间就必须有金额")
    end

    if ( end_at.blank? && amount.present? )
      errors.add(:end_at, "有金额就必须有结束时间")
    end
  end

  # 计算停了多少分钟，两个时间直接相减得到的是秒数
  def duration
     end_at - start_at
  end

  # def calculate_amount
  def setup_amount
    if self.amount.blank? && self.start_at.present? && self.end_at.present?
      if self.user.blank?
        self.amount = calculate_guest_term_amount  # 一般费率
      elsif self.parking_type == "long-term"
          self.amount = calculate_long_term_amount # 短期费率
      elsif self.parking_type == "short-term"
        self.amount = calculate_short_term_amount  # 长期费率
      end
    end
  end

  def calculate_guest_term_amount
    if duration <= 60 * 60
      self.amount = 200
    else
      self.amount = 200 + (((duration - 60 * 60 ) / 60) / 30).to_f.ceil * 100
    end
  end

  def calculate_short_term_amount
    if duration <= 60 * 60
      self.amount = 200
    else
      self.amount = 200 + (((duration - 60 * 60 ) / 60) / 30).to_f.ceil * 50
    end
  end

  def calculate_long_term_amount
    # 这里duration是指秒数
    duration_integer = (duration / 60 / 60 / 24 ).to_s[0].to_i
    duration_decimal = (duration / 60 / 60 / 24).to_s[2,2].to_i
    if duration_decimal >= 25
      duration_decimal = 0
      duration_integer += 1
    elsif duration_decimal > 0 && duration_decimal <25
      duration_decimal = 1
    end
    self.amount = duration_integer * 1600 + duration_decimal * 1200
  end

end
