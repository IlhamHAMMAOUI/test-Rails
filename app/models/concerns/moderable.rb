# app/models/concerns/moderable.rb
require 'rest-client'

module Moderable
  extend ActiveSupport::Concern

  included do
    before_save :moderate_content
  end

  def moderate_content
    api_key = 'ARl4eMxm-6DC6z_eDSpOt37p6nKpTwSzOcpYiyFeXtA' 
    moderation_url = 'https://moderation.logora.fr/predict'
    language_code = 'fr-FR'

    
    response = RestClient.post(
      moderation_url,
      { text: content_to_moderate, language: language_code },
      headers: { Authorization: "Bearer #{api_key}" }
    )

    result = JSON.parse(response.body)

    self.is_accepted = result['prediction']['0'] > 0.5
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error("Erreur lors de la requête à l'API de modération: #{e.message}")
  end
end
