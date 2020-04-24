# frozen_string_literal: true

class IdOrPidConstraint
  ID_REGEX = /\d+/.freeze
  PID_REGEX = /\A[a-z]+.*[a-z]*:{1}[a-z0-9]{9}\z/.freeze

  attr_reader :pattern

  def initialize
    @pattern = Regexp.union(ID_REGEX, PID_REGEX).freeze
  end

  def matches?(request)
    identifier = request.params[:id].to_s
    pattern.match?(identifier)
  end
end
