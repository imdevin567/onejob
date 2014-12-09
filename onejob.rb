require 'sinatra'
require 'shellwords'

helpers do
  def get_jobs
    atq = `atq | sort -k 6n -k 3M -k 4n -k 5 -k 7 -k 1`
    job_array = []
    test = atq.split(/\n/)
    test.each do |job|
      arr = job.split(/\t/)
      job_info = arr[1].split(/ /).reject(&:empty?)
      hash = {:id => arr[0], :day => job_info[0], :month => job_info[1], :date => job_info[2], :time => job_info[3], :year => job_info[4]}
      job_array.push(hash)
    end
    job_array
  end

  def get_job(job_id)
    cmd = `at -c #{job_id}`
    lines = cmd.split(/\n/).reject(&:empty?)
    lines
  end

  def schedule_job(script, date, time)
    run = "echo '" + Shellwords.join(script.split(/ /)) + "'"
    `#{run} | at #{time} #{date}`
  end
end

get '/' do
  @jobs = get_jobs
  erb :index
end

get '/job/new' do
  erb :new_job
end

post '/job/create' do
  schedule_job(params['script'], params['date'], params['time'])
  redirect to('/')
end

get '/job/:id' do
  @job = get_job(params['id'])
  erb :view_job
end
