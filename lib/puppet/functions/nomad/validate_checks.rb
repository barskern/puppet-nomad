# This is an autogenerated function, ported from the original legacy version.
# It /should work/ as is, but will not have all the benefits of the modern
# function API. You should see the function docs to learn how to add function
# signatures for type safety and to document this function using puppet-strings.
#
# https://puppet.com/docs/puppet/latest/custom_functions_ruby.html
#
#
# @summary
#   This function validates the contents of an array of checks
#
#*Examples:*
#
#    nomad_validate_checks({'key'=>'value'})
#    nomad_validate_checks([
#      {'key'=>'value'},
#      {'key'=>'value'}
#    ])
#
#Would return: true if valid, and raise exception otherwise
#
#
Puppet::Functions.create_function(:'nomad::validate_checks') do
  # @param arguments
  #   The original array of arguments. Port this to individually managed params
  #   to get the full benefit of the modern function API.
  #
  # @return [Data type]
  #   Describe what the function returns here
  #
  dispatch :default_impl do
    # Call the method named 'default_impl' when this is matched
    # Port this to match individual params for better type safety
    repeated_param 'Any', :arguments
  end


  def default_impl(*arguments)
    raise(Puppet::ParseError, "validate_checks(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size != 1
    return validate_checks(arguments[0])
  end

  def validate_checks(obj)
    case obj
      when Array
        obj.each do |c|
          validate_checks(c)
        end
      when Hash
          if ( (obj.key?("http") || obj.key?("script") || obj.key?("tcp")) && (! obj.key?("interval")) )
            raise Puppet::ParseError.new('interval must be defined for tcp, http, and script checks')
          end

          if obj.key?("ttl")
            if (obj.key?("http") || obj.key?("script") || obj.key?("tcp") || obj.key?("interval"))
              raise Puppet::ParseError.new('script, http, tcp, and interval must not be defined for ttl checks')
            end
          elsif obj.key?("http")
            if (obj.key?("script") || obj.key?("tcp"))
              raise Puppet::ParseError.new('script and tcp must not be defined for http checks')
            end
          elsif obj.key?("tcp")
            if (obj.key?("http") || obj.key?("script"))
              raise Puppet::ParseError.new('script and http must not be defined for tcp checks')
            end
          elsif obj.key?("script")
            if (obj.key?("http") || obj.key?("tcp"))
              raise Puppet::ParseError.new('http and tcp must not be defined for script checks')
            end
          else
            raise Puppet::ParseError.new('One of ttl, script, tcp, or http must be defined.')
          end
      else
        raise Puppet::ParseError.new("Unable to handle object of type <%s>" % obj.class.to_s)
    end
  end
end
