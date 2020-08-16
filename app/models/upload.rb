class Upload < ApplicationRecord
      has_one_attached :clip
      encrypts_attached :clip
end
