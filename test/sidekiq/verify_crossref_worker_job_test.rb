require 'test_helper'

class VerifyCrossrefWorkerJobTest < ActiveSupport::TestCase

  test "job is enqueued successfully" do
    Sidekiq::Testing.inline!
    worker = VerifyCrossrefWorkerJob.new
    assert_nothing_raised do
      worker.perform()
    end
  end
end
