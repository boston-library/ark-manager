class ArkSerializer < ActiveModel::Serializer
  attributes :id, :namespace_ark, :url_base, :noid, :namespace_id, :model_type, :local_original_identifier, :local_original_identifier_type, :parent_pid, :secondary_parent_pids, :pid, :created_at, :updated_at
end
