require 'aws'

module OpsWorks
  module CLI
    module Subcommands
      module Update
        # rubocop:disable MethodLength
        # rubocop:disable CyclomaticComplexity
        def self.included(thor)
          thor.class_eval do
            include Helpers::Keychain
            include Helpers::Options

            desc 'update [--stack STACK]', 'Update OpsWorks custom cookbooks'
            option :stack, type: :array
            def update
              fetch_keychain_credentials unless env_credentials?
              stacks = parse_stacks(options)
              deployments = stacks.map do |stack|
                say "Updating #{stack.name}..."
                stack.update_custom_cookbooks
              end
              Deployment.wait(deployments)
              unless deployments.all?(&:success?)
                failures = []
                deployments.each_with_index do |deployment, i|
                  failures << stacks[i].name if deployment.failed?
                end
                fail "Update failed on #{failures.join(', ')}"
              end
            end
          end
        end
        # rubocop:enable CyclomaticComplexity
        # rubocop:enable MethodLength
      end
    end
  end
end
