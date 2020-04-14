# frozen_string_literal: true

require 'oj'

Oj.optimize_rails
Oj.default_options =
{
  mode: :rails,
  time_format: :ruby,
  omit_nil: true
}
