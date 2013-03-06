module Rmega
  class FolderNode < Node
    def self.create session, parent_node, folder_name
      key = Crypto.random_key
      encrypted_attributes = Utils.a32_to_base64 Crypto.encrypt_attributes(key[0..3], {n: folder_name.strip})
      encrypted_key = Utils.a32_to_base64 Crypto.encrypt_key(session.master_key, key)
      n = [{h: 'xxxxxxxx', t: 1, a: encrypted_attributes, k: encrypted_key}]
      data = session.request a: 'p', t: parent_node.handle, n: n
      new session, data['f'][0]
    end

    def children
      storage.nodes.select { |node| node.parent_handle == handle }
    end

    def download path
      children.each do |node|
        if node.type == :file
          node.download path
        elsif node.type == :folder
          subfolder = File.expand_path File.join(path, node.name)
          Dir.mkdir(subfolder) unless Dir.exists?(subfolder)
          node.download subfolder
        end
      end
      nil
    end
  end
end