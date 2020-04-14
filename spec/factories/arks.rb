# frozen_string_literal: true

FactoryBot.define do
  factory :ark do
    institution_ark
    namespace_ark { '50959' }
    url_base { 'https://digitalcommonwealth.org' }
    namespace_id { 'commonwealth' }

    trait :institution_ark do
      local_original_identifier { Faker::University.name }
      model_type { 'Bplmodels::Institution' }
      local_original_identifier_type { 'Physical Location' }
    end

    trait :collection_ark do
      local_original_identifier { Faker::Artist.name }
      local_original_identifier_type { 'Institution Collection Name' }
      model_type { 'Bplmodels::Collection' }
      parent_pid { nil }
    end

    trait :object_ark do
      local_original_identifier { Faker::File.file_name(dir: '', ext: 'tif') }
      local_original_identifier_type { 'filename' }
      model_type { 'Bplmodels::PhotographicPrint' }
      parent_pid { nil }
    end
  end
end
