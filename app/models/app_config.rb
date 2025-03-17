class AppConfig < ApplicationRecord
  has_one_attached :navbar_image
  has_one_attached :favicon_image
end
