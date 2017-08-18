class Car
  attr_accessor :name,:modal,:year

  def age
    # self.year = year
    Time.now.year - self.year
  end

  def info
    puts "#{name}-#{modal}-#{year}"
  end
end

# car = Car.new("特斯拉","m3",2017) #这种用法要结合initialize方法使用
car = Car.new
car.name = "特斯拉"
car.modal = "m3"
car.year = 2017


puts car.age
puts car.info
