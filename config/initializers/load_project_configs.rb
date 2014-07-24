FEDORA_CONFIG_GLOBAL = YAML.load_file(Rails.root.join('config', 'fedora.yml'))[Rails.env]
DERIVATIVE_CONFIG_GLOBAL = YAML.load_file(Rails.root.join('config', 'derivatives.yml'))[Rails.env]