require 'rest_client'
require 'json'

class Project

  attr_accessor :id
  attr_accessor :refine

  def initialize(refine, id)
    self.refine = refine
    self.id = id
  end

  def to_s
    "#{self.refine.url}/project?project=#{self.id}"
  end
end

class Job

  attr_accessor :id
  attr_accessor :refine

  def initialize(refine, id)
    self.refine = refine
    self.id = id
  end

  def load_raw_data(filename)
    RestClient.post("#{self.refine.url}/command/core/importing-controller?controller=core%2Fdefault-importing-controller&jobID=#{self.id}&subCommand=load-raw-data", :upload => File.new(filename, "rb"))

    while true
      sleep 2
      status = RestClient.post("#{self.refine.url}/command/core/get-importing-job-status?jobID=#{self.id}", nil)
      break if JSON[status]["job"]["config"]["state"] == "ready"
    end
  end

  def create_project(options)
    RestClient.post("#{self.refine.url}/command/core/importing-controller?controller=core%2Fdefault-importing-controller&jobID=#{self.id}&subCommand=create-project",
      :format => "text/line-based/*sv",
      :options => options.to_json)

    project_id = nil
    while project_id.nil?
      sleep 2
      response = RestClient.post("#{self.refine.url}/command/core/get-importing-job-status?jobID=#{self.id}", nil)
      project_id = JSON[response]["job"]["config"]["projectID"]
    end

    Project.new(self.refine, project_id)
  end

  def cancel
    RestClient.post("#{self.refine.url}/command/core/cancel-importing-job?jobID=#{self.id}", nil)
  end

end

class Refine

  attr_accessor :url

  def initialize(url)
    self.url = url
  end

  def url=(url)
    if url !~ /^http/
      url = "http://#{url}"
    end
    @url = url
  end

  def create_importing_job
    response = RestClient.post("#{self.url}/command/core/create-importing-job", nil)
    job_id = JSON[response]["jobID"]
    Job.new(self, job_id)
  end

  def version
    response = RestClient.get("#{self.url}/command/core/get-version")
    JSON[response]['version']
  end


  def create_project(filename, param = {})

    param[:project_name] ||= File.basename(filename)

    if self.version >= "2.5"
      begin
        options = {}
        options[:projectName]            = param[:project_name]
        options[:encoding]               = param[:encoding]                  || "UTF-8"
        options[:separator]              = param[:separator]                 || "\t"
        options[:headerLines]            = param[:header_lines]              || 1
        options[:limit]                  = param[:limit]
        options[:guessCellValueTypes]    = param[:guess_value_type]          || false
        options[:processQuotes]          = param[:process_quotes]            || false

        warn options

        job = create_importing_job
        job.load_raw_data(filename)
        project = job.create_project(options)
        project
      ensure
        job.cancel if job
      end
    elsif [ "2.0", "2.1" ].include?(self.version)
      begin
        RestClient.post("#{self.url}/command/core/create-project-from-upload",
          Hash[
           {  project_name:      param[:project_name],
              header_lines:      param[:header_lines],
              limit:             param[:limit],
              guess_value_type:  param[:guess_value_type],
              ignore_quotes:     ! param[:process_quotes],
              project_file:  File.new(filename, "rb")
            }.map { |key, value| [ key.to_s.gsub('_', '-'), value ] }
          ]
        )
      rescue RestClient::Found
        project_id = $!.response.headers[:location].match(/project=(\d+)/)[1]
        Project.new(self, project_id)
      end
    end

  end

end
