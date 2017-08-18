class Parking < ApplicationRecord
  belongs_to :user, :optional => true
  validates_presence_of :parking_type, :start_at
  validates_inclusion_of :parking_type, :in => ["guest", "short-term", "long-term"]

  validate :validate_end_at_with_amount

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
    puts "end_at is #{end_at}, start_at is #{start_at},duration is #{end_at - start_at} seconds, #{( end_at - start_at ) / 60} minutes"
    ( end_at - start_at ) / 60
  end

  def calculate_amount
    puts "parking_type----"
    puts self.parking_type
    puts "parking_type----"
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
    if duration <= 60
      self.amount = 200
    else
      self.amount = 200 + ((duration - 60).to_f / 30).ceil * 100
    end
  end

  def calculate_short_term_amount
    if duration <= 60
      self.amount = 200
    else
      self.amount = 200 + ((duration - 60).to_f / 30).ceil * 50
    end
  end
# 5小时，12块
# 6小时，16块
# 23小时，16块
# 25小时，16 + 12 = 28块
# 32小时，16 + 12 = 32块
# 48小时，32块
# 先算出总的，天数 <= 1 ？先加16，然后找出小数部分，小于0.25？按一天零6小时以内，+28，大于0.25？进位按两天加32，
# 先算出总的，天数 > 1 ？先加16，然后找出小数部分，小于0.25？按一天零6小时以内，+28，大于0.25？进位按两天加32，
# 都要算小数部分，最后总的计算公式为 整数部分加小数部分。

  def calculate_long_term_amount
    duration_integer = (duration.to_f / 60 / 24 ).to_s[0].to_i
    duration_decimal = (duration.to_f / 60 / 24).to_s[2,2].to_i
    if duration_decimal >= 25
      duration_decimal = 0
      duration_integer += 1
    elsif duration_decimal > 0 && duration_decimal <25
      duration_decimal = 1
    end
    self.amount = duration_integer * 1600 + duration_decimal * 1200
  end

end
