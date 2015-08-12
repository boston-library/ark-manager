class Ark < ActiveRecord::Base
  #attr_accessible :namespace_ark, :namespace_id, :noid, :pid, :url_base, :view_object, :view_thumbnail, :model_type, :local_original_identifier, :local_original_identifier_type, :parent_pid
  serialize :secondary_parent_pids, Array
end
