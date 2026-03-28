# frozen_string_literal: true

# deploys to Emory servers via ssm
# defaults to Staging environment
# To set a target environment, the instance must be tagged in Gov Cloud:
#   Project=ETD Service
#   Environment=Production | Staging | QA | etc.
# Invoke the deploy command with the HOST_ENV variable specifying the desired environment, e.g.
#   HOST_ENV=Production bundle exec cap ssm deploy
# Alternatively, invoke the command with the HOST_ID variable set to a valid  EC2 instance ID, e.g.
#   HOST_ID=i-0abcdef1234567890 bundle exec cap ssm deploy

require 'net/ssh/proxy/command'
set :rails_env, 'production'
set :host_env, -> { ENV['HOST_ENV'] || 'stage' }
set :instance_id, lambda {
                    ENV['HOST_ID'] ||
                      `aws ec2 describe-instances --region us-east-2  --profile emory-etd \
                                           --filters Name=tag-key,Values=Environment Name=tag-value,Values=#{fetch(:host_env)} Name=instance-state-name,Values=running \
                                           Name=tag-key,Values=Project Name=tag-value,Values="ETD Service" \
                                           --query "Reservations[*].Instances[*].InstanceId" --output text`.chomp
}
server fetch(:instance_id), user: 'deploy', roles: [:web, :app, :db, :worker]
set :command, %(aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile emory-etd)
set :ssh_options,
  auth_methods: %w[publickey],
  forward_agent: true,
  proxy: Net::SSH::Proxy::Command.new(fetch(:command))
