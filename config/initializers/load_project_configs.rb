FEDORA_CONFIG_GLOBAL = YAML.load_file(Rails.root.join('config', 'fedora.yml'))[Rails.env]
DERIVATIVE_CONFIG_GLOBAL = YAML.load_file(Rails.root.join('config', 'derivatives.yml'))[Rails.env]
IIIF_SERVER = YAML.load_file(Rails.root.join('config', 'iiif_server.yml'))[Rails.env]