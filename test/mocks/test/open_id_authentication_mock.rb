module OpenIdAuthentication 
  protected
    def authenticate_with_open_id(identity_url = params[:openid_url], fields = {}) #:doc:
      if params[:open_id_complete].nil?
        redirect_to '/'
      else
        identity_url = normalize_url(identity_url)
        extension_response_fields = {}
        if $mockuser
          extension_response_fields['nickname'] = $mockuser[:loginname]
          extension_response_fields['email'] = $mockuser[:email]
          extension_response_fields['gender'] = $mockuser[:gender]
          extension_response_fields['dob'] = $mockuser[:dob]
          extension_response_fields['timezone'] = $mockuser[:timezone]
        end

        if identity_url.include?('failed')
          yield Result[:failed], identity_url, nil
        elsif identity_url.include?('missing')
          yield Result[:missing], identity_url, nil
        elsif identity_url.include?('cancelled')
          yield Result[:canceled], identity_url, nil
        else
          yield Result[:successful], identity_url, extension_response_fields
        end
      end
    end

  private
    def add_simple_registration_fields(open_id_response, fields)
      open_id_response.add_extension_arg('sreg', 'required', [ fields[:required] ].flatten * ',') if fields[:required]
      open_id_response.add_extension_arg('sreg', 'optional', [ fields[:optional] ].flatten * ',') if fields[:optional]
    end
end
