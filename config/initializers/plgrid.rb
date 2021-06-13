Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect,
    name: :plgrid,
    scope: [:openid],
    response_type: :code,
    issuer: "https://#{Rails.application.credentials.plgrid.dig(:sso, :host)}/auth/realms/PLGRID",
    discovery: true,
    client_options: {
      port: nil,
      scheme: "https",
      host: Rails.application.credentials.plgrid.dig(:sso, :host),
      identifier: Rails.application.credentials.plgrid.dig(:sso, :identifier),
      secret: Rails.application.credentials.plgrid.dig(:sso, :secret),
      redirect_uri: "http://localhost:3000/auth/plgrid/callback"
    }
end
