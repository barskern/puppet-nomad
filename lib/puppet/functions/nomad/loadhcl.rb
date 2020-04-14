require 'json'

Puppet::Functions.create_function(:'nomad::loadhcl') do
  # This function takes a absolute path to a HCL file and loads it to equivalent Hash.
  def loadhcl(path)
    JSON.parse(`nomad run -output #{path}`)
  end
end
