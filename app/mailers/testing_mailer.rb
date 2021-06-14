class TestingMailer < ActionMailer::Base
  def test
    mail(
      from: "test@movri.ca",
      subject: 'movri test',
      to: "test@yopmail.com"
    )
  end
end