SOLR_CONFIG = YAML.load_file(Rails.root.join('config', 'solr.yml'))[Rails.env].with_indifferent_access.freeze
IIIF_SERVER = YAML.load_file(Rails.root.join('config', 'iiif_server.yml'))[Rails.env].with_indifferent_access.freeze
