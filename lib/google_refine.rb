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

  def create_project(filename, param = {})

    options = {}
    options[:format]                 = param[:format]
    options[:projectName]            = param[:name]                      || "File \"#{filename}\" uploaded on #{Time.now}"
    options[:encoding]               = param[:encoding]                  || ""
    options[:separator]              = param[:separator]                 || "\\t"
    options[:ignoreLines]            = param[:ignoreLines]               || -1
    options[:headerLines]            = param[:headerLines]               || 0
    options[:skipDataLines]          = param[:skipDataLines]             || 0
    options[:limit]                  = param[:limit]                     || 1_000_000
    options[:storeBlankRows]         = param[:storeBlankRows]            || true
    options[:guessCellValueTypes]    = param[:guessCellValueTypes]       || true
    options[:processQuotes]          = param[:processQuotes]             || false
    options[:storeBlankCellsAsNulls] = param[:storeBlankCellsAsNulls]    || true
    options[:includeFileSources]     = param[:includeFileSources]        || false
    
    job = create_importing_job
    job.load_raw_data(filename)
    project = job.create_project(options)
    project
    ensure
      job.cancel if job
  end

end
