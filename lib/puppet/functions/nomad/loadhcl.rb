require 'json'
require 'tempfile'

Puppet::Functions.create_function(:'nomad::loadhcl') do
  # This function takes a absolute path to a HCL file and loads it to equivalent Hash.
  def loadhcl(hcl)
    f = Tempfile.new('nomad_loadhcl')
    begin
      f.write hcl
      f.close
      JSON.parse(`nomad run -output #{f.path}`)
    ensure
      f.close!
    end
  end
end
