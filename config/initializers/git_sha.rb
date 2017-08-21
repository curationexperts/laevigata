GIT_SHA =
  if Rails.env.production? && File.exist?('/opt/laevigata/revisions.log')
    `tail -1 /opt/laevigata/revisions.log`.chomp.split(" ")[3]
  elsif Rails.env.development? || Rails.env.test?
    `git rev-parse HEAD`.chomp
  else
    "Unknown SHA"
  end

BRANCH =
  if Rails.env.production? && File.exist?('/opt/laevigata/revisions.log')
    `tail -1 /opt/laevigata/revisions.log`.chomp.split(" ")[1]
  elsif Rails.env.development? || Rails.env.test?
    `git rev-parse HEAD`.chomp
  else
    "Unknown branch"
  end

LAST_DEPLOYED =
  if Rails.env.production? && File.exist?('/opt/laevigata/revisions.log')
    deployed = `tail -1 /opt/laevigata/revisions.log`.chomp.split(" ")[7]
    Date.parse(deployed).strftime("%d %B %Y")
  else
    "Not in deployed environment"
  end
