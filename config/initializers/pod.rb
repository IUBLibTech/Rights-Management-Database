POD = YAML.load(ERB.new(File.read(File.join(Rails.root, "config", "pod.yml"))).result)[Rails.env.to_s]