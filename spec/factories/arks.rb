# frozen_string_literal: true

FactoryBot.define do
  factory :ark do
    institution_ark
    namespace_ark { '50959' }
    url_base { 'https://search-dc3dev.bpl.org' }
    namespace_id { 'bpl-dev' }

    trait :invalid_ark do
      local_original_identifier { nil }
      local_original_identifier_type { nil }
      model_type { nil }
    end

    trait :institution_ark do
      local_original_identifier { Faker::University.name }
      model_type { 'Curator::Institution' }
      local_original_identifier_type { 'physical_location' }
    end

    trait :collection_ark do
      local_original_identifier { Faker::Artist.name }
      local_original_identifier_type { 'institution_collection_name' }
      model_type { 'Curator::Collection' }
      parent_pid { nil }
    end

    trait :object_ark do
      local_original_identifier { Faker::File.file_name(dir: '', ext: 'tif') }
      local_original_identifier_type { 'filename' }
      model_type { 'Curator::DigitalObject' }
      parent_pid { nil }
    end

    trait :filestream_image_ark do
      local_original_identifier { Faker::File.file_name(dir: '', ext: 'tif') }
      local_original_identifier_type { 'filename' }
      model_type { 'Curator::Filestreams::Image' }
      parent_pid { nil }
    end

    trait :filestream_text_ark do
      local_original_identifier { Faker::File.file_name(dir: '', ext: 'txt') }
      local_original_identifier_type { 'filename' }
      model_type { 'Curator::Filestreams::Text' }
      parent_pid { nil }
    end
  end
end
