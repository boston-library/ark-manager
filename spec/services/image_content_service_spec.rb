# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/service_class'

RSpec.describe ImageContentService, type: :service do
  let(:described_service_class) { described_class }

  specify { expect(described_service_class).to be_const_defined('ApplicationService') }
  specify { expect(described_service_class).to respond_to(:call).with(4).arguments }

  # it_behaves_like 'service_class' do
  #   let(:described_service_class_instance) { described_service_class.new }
  # end
end
