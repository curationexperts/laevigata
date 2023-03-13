class GitShaPresenter
  def self.sha
    @sha ||=
      if Rails.env.production? && File.exist?('/opt/laevigata/revisions.log')
        `tail -1 /opt/laevigata/revisions.log`.chomp.split(" ")[3].gsub(/\)$/, '')
      elsif Rails.env.development? || Rails.env.test?
        `git rev-parse HEAD`.chomp
      else
        "Unknown SHA"
      end
  end

  def self.branch
    @branch ||=
      if Rails.env.production? && File.exist?('/opt/laevigata/revisions.log')
        `tail -1 /opt/laevigata/revisions.log`.chomp.split(" ")[1]
      elsif Rails.env.development? || Rails.env.test?
        `git rev-parse --abbrev-ref HEAD`.chomp
      else
        "Unknown branch"
      end
  end

  def self.last_deployed
    @last_deployed ||=
      if Rails.env.production? && File.exist?('/opt/laevigata/revisions.log')
        deployed = `tail -1 /opt/laevigata/revisions.log`.chomp.split(" ")[7]
        Date.parse(deployed).strftime("%d %B %Y")
      else
        "Not in deployed environment"
      end
  end
end
