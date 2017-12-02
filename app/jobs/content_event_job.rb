# We keep getting errors in our background jobs saying
# "undefined method `log_profile_event' for nil:NilClass". It seems that the depositor
# is not being passed to this job as expected. Until we can track that down properly,
# I am overriding the job here and reporting the error to Honeybadger. However, I don't want
# the job itself to fail because it can't log.
#
# A generic job for sending events about repository objects to a user and their followers.
#
# @attr [String] repo_object the object event is specified for
#
require 'honeybadger'

class ContentEventJob < EventJob
  attr_reader :repo_object
  def perform(repo_object, depositor)
    @repo_object = repo_object
    super(depositor)
    log_event(repo_object)
  end

  # Log the event to the object's stream
  def log_event(repo_object)
    repo_object.log_event(event)
  rescue => exception
    Honeybadger.notify(exception)
  end

  # log the event to the users profile stream
  def log_user_event(depositor)
    depositor.log_profile_event(event)
  rescue => exception
    Honeybadger.notify(exception)
  end
end
