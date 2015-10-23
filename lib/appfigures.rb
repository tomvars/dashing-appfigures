#Thomas Varsavsky, 09/2014
#Togethera
require 'net/https'
require 'json'
require 'date'
def export_data(options)
	product=options[:product]||"iOS"
	end_date=options[:end_date]||Date.today-2
	num_days=options[:num_days]||7
	start_date= end_date - num_days
	product_key=YOUR_PRODUCT_KEY
	client_key=YOUR_CLIENT_KEY
	if product == "iOS"
		uri = URI("https://api.appfigures.com/v2/reports/sales/?group_by=dates&client_key=#{client_key}&products=#{product_key}&start_date=#{start_date}&end_date=#{end_date}")
	elsif product =="Play" || product=="Android"
		uri = URI("https://api.appfigures.com/v2/reports/sales/?group_by=dates&client_key=#{client_key}&products=#{product_key}&start_date=#{start_date}&end_date=#{end_date}")
	end
	hash_output=Hash.new
	Net::HTTP.start(uri.host, uri.port,
	  :use_ssl => uri.scheme == 'https', 
	  :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|

	  request = Net::HTTP::Get.new uri.request_uri
	  request.basic_auth 'YOUR_USERNAME', 'YOUR_PASSWORD'
	  response = http.request request # Net::HTTPResponse object
	  
	  hash_output= JSON.parse(response.body)
	end
	return hash_output
end
def get_appfigures_points_week_to_seven_days(data)
  points=[]
  y=Hash.new
  new_hash=Hash.new
  counter=0
  running_total=0
  daily_total=0
  data.each do |key,j|
    y[Date.parse(key).strftime('%s').to_i]=j
  end
  y.each do |key,j|
  	y[key].each do |key2, j|
	  	if key2=="downloads"
	  		daily_total=j
	  		running_total+=daily_total
	  		counter+=1
	    end
	    if counter==7
	      points << {x: key, y: running_total }
	      running_total=0
	      counter=0
	    end
	end
  end
  return points
end

def get_stacked_area_series_downloads(options)
	num_weeks = options[:num_weeks] || 7
	end_date = options[:end_date] || Date.today-2
	num_days = num_weeks*7
	ios_hashtable=export_data(product:"iOS", end_date: end_date, num_days: num_days)
	play_hashtable=export_data(product:"Play", end_date: end_date, num_days: num_days)
	arrayx=get_appfigures_points_week_to_seven_days(play_hashtable)
	arrayy=get_appfigures_points_week_to_seven_days(ios_hashtable)
	final_play=[]
	final_ios=[]
	counter=0
	arrayx.each do |x|
		final_play<< {x:x[:x], y:(x[:y].to_f/(x[:y]+arrayy[counter][:y]).to_f).round(2)}
		final_ios<< {x:x[:x], y:(arrayy[counter][:y].to_f/(x[:y]+arrayy[counter][:y]).to_f).round(2)}
		counter+=1
	end
	hashx,hashy=Array.new(2) {{}}
	hashx["name"]="Android"
	hashx["data"]=final_play
	hashy["name"]="iOS"
	hashy["data"]=final_ios
	series=Array.new
	series=[hashx,hashy]
	return series
end
