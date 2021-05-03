class Storage
  FILE_PATH = 'accounts.yml'.freeze

  def self.save(data)
    File.open(FILE_PATH, 'w') { |f| f.write data.to_yaml }
  end

  def self.load_accounts
    File.exist?(FILE_PATH) ? YAML.load_file(FILE_PATH) : []
  end
end
