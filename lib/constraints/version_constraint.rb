# frozen_string_literal: true

class VersionConstraint
  ARK_VERSION = 'v2'

  def self.matches?(request)
    version = request.params[:version]
    ARK_VERSION.match?(version)
  end
end
