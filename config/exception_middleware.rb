# frozen_string_literal: true

class ExceptionMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue Blacklight::Exceptions::RecordNotFound
    # Redirect to non-existant location, which goes to the 404 page
    [301, { 'Location' => '/not-found', 'Content-Type' => 'text/html' }, ['Moved Permanently']]
  end
end
