require 'test_helper'

class VerifyCrossrefWorkerJobTest < ActiveSupport::TestCase

  test "job is enqueued successfully" do
    Sidekiq::Testing.inline!
    cr_worker = VerifyCrossrefWorkerJob.new
    assert_nothing_raised do
      cr_worker.perform()
    end
  end
end
