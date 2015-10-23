require 'date'
root = ::File.dirname(__FILE__)
require ::File.join(root, "..", 'lib', 'appfigures')
s = Rufus::Scheduler.new
hashtable=Hash.new
# s.every '6h', :first_in => 0 do |job|
#   # ios_hashtable=export_data(product="iOS")
#   # ios_last_hashtable= export_data(product="iOS", end_date=Date.today-9)
#   ios_hashtable={"some"=>404}
#   ios_last_hashtable={"thing"=>404}
#   this_week = ios_hashtable.values[0].to_i
#   last_week = ios_last_hashtable.values[0].to_i
#   send_event 'appfigures_ios_downloads', current: this_week, last: last_week
# end
# s.every '6h', :first_in => 0 do |job|
#   # play_hashtable=export_data(product="Play")
#   # play_last_hashtable=export_data(product="Play", end_date=Date.today-9)
#   play_hashtable={"some"=>404}
#   play_last_hashtable={"thing"=>404}
#   this_week = play_hashtable.values[0].to_i
#   last_week = play_last_hashtable.values[0].to_i
#   send_event 'appfigures_android_downloads', current: this_week, last: last_week
# end
# s.every '6h', :first_in=> 0 do |job|
#   # ios_hashtable=export_data(product="iOS")
#   # play_hashtable=export_data(product="Play")
#   ios_hashtable=export_data(product:"iOS", end_date: Date.today-2, num_days: 7)
#   play_hashtable=export_data(product:"Play", end_date: Date.today-2, num_days: 7)
#   value1 = get_appfigures_points_week_to_seven_days(ios_hashtable)[0].values[1].to_i
#   value2 = get_appfigures_points_week_to_seven_days(play_hashtable)[0].values[1].to_i
#   download_data = [
#   { label: "iOS", value: value1},
#   { label: "Android", value: value2},
# ]
# send_event 'ios_play_pie_chart', { value: download_data }
# end
s.every '6h', :first_in => 0 do |job|
  ios_hashtable=export_data(product:"iOS", end_date: Date.today-2, num_days: 49)
  points=get_appfigures_points_week_to_seven_days(ios_hashtable)
  send_event('appfigures_ios_downloads', points: points)
end
s.every '6h', :first_in => 0 do |job|
  android_hashtable=export_data(product:"Play", end_date: Date.today-2, num_days: 49)
  points=get_appfigures_points_week_to_seven_days(android_hashtable)
  send_event('appfigures_android_downloads', points: points)
end
s.every '5h', :first_in => 0 do |job|
  series=get_stacked_area_series_downloads(num_weeks: 10)
  send_event('appfigures_stacked_area', series: series)
end
