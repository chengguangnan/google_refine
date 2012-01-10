require "rest_client"
require "json"

class Project
  def initialize(refine, id)
    @refine = refine
    @id = id
  end

  def to_s 
    "#{@refine.uri}/project?project=#{@id}"
  end
end

class Job

  def initialize(refine, id)
    @refine = refine
    @id = id
  end

  def load_raw_data(upload)
    RestClient.post("#{@refine.uri}/command/core/importing-controller?controller=core%2Fdefault-importing-controller&jobID=#{@id}&subCommand=load-raw-data", :upload => File.new(upload, "rb"))

    while true
      sleep 2
      status = RestClient.post("#{@refine.uri}/command/core/get-importing-job-status?jobID=#{@id}", nil)
      warn status
      break if JSON[status]["job"]["config"]["state"] == "ready"
    end
  end

  def create_project(options)
    RestClient.post("#{@refine.uri}/command/core/importing-controller?controller=core%2Fdefault-importing-controller&jobID=#{@id}&subCommand=create-project",
      :format => "text/line-based/*sv",
      :options => options.to_json)

    project_id = nil
    while project_id.nil?
      sleep 2
      response = RestClient.post("#{@refine.uri}/command/core/get-importing-job-status?jobID=#{@id}", nil)
      project_id = JSON[response]["job"]["config"]["projectID"]
    end

    Project.new(@refine, project_id)
  end

  def cancel
    warn RestClient.post("#{@refine.uri}/command/core/cancel-importing-job?jobID=#{@id}", nil)
  end

end

class Refine
  attr_accessor :uri

  def initialize (uri)
    @uri = uri
  end

  def create_importing_job
    response = RestClient.post("#{@uri}/command/core/create-importing-job", nil)
    job_id = JSON[response]["jobID"]
    warn response
    Job.new(self, job_id)
  end

  def create_project (upload, param = {})

    default_options = {
      :"encoding" => "",
      :"separator" => "\\t",
      :"ignoreLines" => -1,
      :"headerLines" => 1,
      :"skipDataLines" => 0,
      :"limit" => -1,
      :"storeBlankRows" => true,
      :"guessCellValueTypes" => true,
      :"processQuotes" => false,
      :"storeBlankCellsAsNulls" => true,
      :"includeFileSources" => false,
      :"projectName" => "Uploaded by gem google_refine_api" 
    }

    format = param[:format]

    param[:options] ||= {}

    options = default_options.update(param[:options])

    job = create_importing_job
    job.load_raw_data(upload)
    project = job.create_project(options)
    project
    ensure
      job.cancel if job
  end

end
