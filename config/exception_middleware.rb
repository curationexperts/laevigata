# frozen_string_literal: true

class ExceptionMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue Blacklight::Exceptions::RecordNotFound, ActiveFedora::ObjectNotFoundError
    # Redirect to non-existant location, which goes to the 404 page
    [301, { 'Location' => '/error_404', 'Content-Type' => 'text/html' }, ['Moved Permanently']]
  end
end
