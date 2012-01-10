require_relative "../lib/google_refine_api"

refine = Refine.new("http://10.0.2.12:2500")
puts refine.create_project("test/sample_data")
