class UserIsAdmin
  def self.matches?(request)
    warden = request.env['warden']
    user = warden.authenticate
    user&.admin?
  end
end
