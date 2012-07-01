# Google Refine API

This gem is wrote for Google Refine 2.5 and later. Since 2.5, Google Refine splited it's import process into two steps. Create an ImportingJob first and then actually create the Project. This gem help you to simulate this process programmatically.

### Install

    gem install google_refine

### Command line

    upload-to-refine filename
    upload-to-refine filename -h example.com:25000

### Programmatically

    refine = Refine.new("example.com:2500")
    puts refine.create_project("filename")
