# Google Refine API

Since version 2.5, Google Refine splited it's import process into two steps. Create an ImportingJob first and then actually create the Project. This gem help you to simulate this process programmatically.

### Install
    gem install google_refine_api

### Example

    refine = Refine.new("10.0.2.12:2500")
    puts refine.create_project("test/sample_data")
