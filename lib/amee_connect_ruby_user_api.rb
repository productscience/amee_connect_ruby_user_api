require 'greenletters'
# require 'pry'

require "amee_connect_ruby_user_api/version"

module AMEE

  module Connect

    class UserCreator
      # A wrapper for calling the java classes needed to
      # generate user ids and passwords for the AMEE connect platform

      attr_accessor :hash_password_cli_command
      attr_accessor :make_uid_cli_command
      attr_accessor :asked

      # values to retrieve from calling the java app
      attr_accessor :hashed_password
      attr_accessor :uid
      attr_accessor :principal_uid

      attr_accessor :name, :username

      def initialize(cli_params)
        @name = ENV['AMEE_CONNECT_NAME'] || cli_params[:name]
        @username = ENV['AMEE_CONNECT_USERNAME'] || cli_params[:username]
        @password = ENV['AMEE_CONNECT_PASSWORD'] = cli_params[:password]

        # these typically won't change between users
        @hash_password_cli_command = ENV['AMEE_CONNECT_HASH_PASSWORD_CLI_COMMAND'] || cli_params[:hash_password_cli_command]
        @make_uid_cli_command = make_uid_cli_command = ENV['AMEE_CONNECT_MAKE_UID_CLI_COMMAND'] || cli_params[:make_uid_cli_command]
      end

      # fetches a password from the java application
      def hash_password
        begin
          adv = Greenletters::Process.new(@hash_password_cli_command, :transcript => $stdout)

          adv.start!

          adv.on(:output, /Please type a plain-text password/i) do |process, match_data|
            @asked = true
            adv << "#{@password}\n"
          end

          adv.on(:output, /.+/i) do |process, match_data|
            @hashed_password = set_hashed_password(match_data)
          end

          adv.wait_for(:exit)

        rescue NotImplementedError
          puts "Finished"
        end
      end

      def fetch_uid
        begin
          adv = Greenletters::Process.new(@make_uid_cli_command, :transcript => $stdout)

          adv.start!

          adv.on(:output, /How many?/i) do |process, match_data|
            @asked = true
            adv << "1\n"
          end

          adv.on(:output, /.+/i) do |process, match_data|
            set_uid(match_data)
          end

          adv.wait_for(:exit)

        rescue NotImplementedError
          puts "Finished"
        end
      end

      def print_create_user_sql

        timestamp = Time.now.getutc.to_s.sub('UTC','').strip

        return <<-SQL

        INSERT INTO `user`
          (`id`, `created`, `modified`, `uid`, `status`, `email`, `locale`, `name`, `password`, `time_zone`, `user_type`, `username`, `api_version_id`)
        VALUES
          (INCREMENT_USER_NO, '#{timestamp}', '#{timestamp}', '#{@uid}', 1, 'ADD_EMAIL_HERE', NULL, '#{@name}', '#{@hashed_password}', NULL, 0, '#{@username}', 1);

        INSERT INTO `group_principal`
          (`id`, `created`, `modified`, `uid`, `status`, `principal_id`, `principal_type`, `principal_uid`, `group_id`)
        VALUES
          ('INCREMENT_GROUP_NO', '#{timestamp}', '#{timestamp}', 'NEW_UID_HERE', 1, INCREMENT_USER_NO, 'USR', 'NEW_PRINCIPAL_UID_HERE', 5);

        SQL

      end


      private

      def set_hashed_password(match_data)
        # we don't know the algorithm, but we know our password
        # is 64 characters long.
        # TODO: use the correct algo
        if ((match_data.matched.length == 65) && asked)
          @hashed_password = match_data.matched.chomp
        end
      end

      def set_uid(match_data)
        if ((match_data.matched.length == 13) && asked)
          @uid = match_data.matched.chomp
        end
      end
    end
  end

end
