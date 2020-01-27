require 'spec_helper'
require 'generator_spec'

RSpec.describe TwirpGenerator, type: :generator do
  destination File.expand_path('../tmp/dummy', __dir__)
  arguments %w(sample)

  before(:all) do
    prepare_destination
    FileUtils.cp_r File.expand_path('dummy', __dir__), File.expand_path('../tmp', __dir__)
    FileUtils.rm_r File.expand_path('../tmp/dummy/lib/twirp', __dir__), force: true
    FileUtils.mkdir_p File.expand_path('../tmp/dummy/lib/twirp', __dir__)
    run_generator
  end

  it 'creates a handler' do
    assert_file 'app/rpc/sample_handler.rb', /class SampleHandler/ do |handler|
      assert_instance_method :sample, handler do |method|
        assert_match(/SampleResponse\.new/, method)
      end
    end
  end

  it 'generates files from all proto files' do
    assert_file 'lib/twirp/sample_twirp.rb', /class SampleService/
    assert_file 'lib/twirp/sample_pb.rb', /add_file\("sample\.proto",\ :syntax\ =>\ :proto3\)/

    assert_file 'lib/twirp/people_twirp.rb', /class PeopleService/
    assert_file 'lib/twirp/people_pb.rb', /add_file\("people\.proto",\ :syntax\ =>\ :proto3\)/
  end

  it 'generates route' do
    assert_file 'config/routes.rb', /mount_twirp :sample/
  end
end
