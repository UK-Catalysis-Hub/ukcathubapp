module CrPublicationsHelper
  def get_pending
    CrPublication.where("status=0")
  end
  def get_added
    CrPublication.where("status=1")
  end
    def get_rejected
    CrPublication.where("status=2")
  end
end
