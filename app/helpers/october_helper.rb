module OctoberHelper
  def last_october
    start_year = Time.zone.now.year

    # if current month is before October
    start_year -= 1 if Time.zone.now.month < 10

    Time.zone.local(start_year, 10, 1)
  end
end
