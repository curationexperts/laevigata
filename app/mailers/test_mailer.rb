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
