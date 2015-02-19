module MMS
  require 'rubygems'  # For ruby < 1.9

  require "uri"
  require "json"
  require "cgi"
  require "net/http"
  require 'net/http/digest_auth'
  require 'terminal-table'
  require 'pathname'

  require 'mms/config'
  require 'mms/agent'
  require 'mms/client'
  require 'mms/cache'
  require 'mms/version'
  require 'mms/resource'
  require 'mms/errors'

  require 'mms/resource/group'
  require 'mms/resource/host'
  require 'mms/resource/cluster'
  require 'mms/resource/snapshot'
  require 'mms/resource/snapshot_schedule'
  require 'mms/resource/restore_job'
  require 'mms/resource/alert'

  require 'mms/cli'
end
