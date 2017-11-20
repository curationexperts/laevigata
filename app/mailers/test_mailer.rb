# This is a convenience to test whether mail is set up correctly on a given server.
# To use it, change the email address to your own, launch a rails console and run
# `TestMailer.test_email.deliver`

class TestMailer < ApplicationMailer
  def test_email
    mail(
      from: "bess@curationexperts.com",
      to: "bess@curationexperts.com",
      subject: "Test mail",
      body: "Test mail body"
    )
  end
end
