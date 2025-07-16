module CrPublicationsService
  def update_cr_pub_pars(cr_pars)
    Rails.logger.info "Updating cr_pub with: '#{cr_pars}' | #{DateTime.now.to_s}"
  end
end
