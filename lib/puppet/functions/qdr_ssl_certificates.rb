# This custom function modifies ssl related config values in format of certificate/key content to cert/key file path.
# The appropriate cert/key files is created in the process.
#
# Given:
#   ssl_profiles = [{"name": "test", "caCertFile": "cert content", "certFile": "cert content", "privateKeyFile": "key content", ...}, ...]
#   cert_dir = "/etc/pki/tls/certs/"
#   key_dir = "/etc/pki/tls/private/"
# Returns:
#   ssl_profiles = [
#     {"name": "test",
#      "caCertFile": <path to cert file>,
#      "certFile": <path to cert file>,
#      "privateKeyFile": <path to key file>,
#      ... },
#     ...
#   ]
Puppet::Functions.create_function(:qdr_ssl_certificates) do
  dispatch :qdr_ssl_certificates do
    param 'Array', :ssl_profiles
    param 'String', :cert_dir
    param 'String', :key_dir
    return_type 'Array'
  end

  def qdr_ssl_certificates(ssl_profiles, cert_dir, key_dir)
    require 'fileutils'
    # alternative: system 'mkdir', '-m', '0700', '-p', path
    FileUtils.mkdir_p(cert_dir, mode: 0700)
    FileUtils.mkdir_p(key_dir, mode: 0700)

    processed_profiles = Array.new

    ssl_profiles.each do |profile|
      processed = Hash.new
      profile.each do |key, value|
        if key == "caCertFile" || key == "certFile"
          path = File.join(cert_dir, "#{key}_#{profile["name"]}.pem")
          File.open(path, 'w') { |file| file.write(value) }
          processed[key] = path
        elsif key == "privateKeyFile"
          path = File.join(key_dir, "#{key}_#{profile["name"]}.key")
          File.open(path, 'w') { |file| file.write(value) }
          processed[key] = path
        else
          processed[key] = value
        end
      end
      processed_profiles.append(processed)
    end

    return processed_profiles
  end
end
