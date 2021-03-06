module Fauna
  # Example observer that can be used for debugging
  module ClientLogger
    ##
    # Lambda that can be the +observer+ for a Client.
    # Will call the passed block on a string representation of each RequestResult.
    #
    # Example:
    #
    #   logger = ClientLogger.logger do |str|
    #     puts str
    #   end
    #   Client.new observer: logger, ...
    def self.logger
      lambda do |request_result|
        yield show_request_result(request_result)
      end
    end

    # Translates a RequestResult to a string suitable for logging.
    def self.show_request_result(request_result)
      rr = request_result
      logged = ''

      logged << "Fauna #{rr.method.to_s.upcase} /#{rr.path}#{query_string_for_logging(rr.query)}\n"
      logged << "  Credentials: #{rr.auth}\n"
      if rr.request_content
        logged << "  Request JSON: #{indent(FaunaJson.to_json_pretty(rr.request_content))}\n"
      end
      logged << "  Response headers: #{indent(FaunaJson.to_json_pretty(rr.response_headers))}\n"
      logged << "  Response JSON: #{indent(FaunaJson.to_json_pretty(rr.response_content))}\n"
      logged << "  Response (#{rr.status_code}): Network latency #{(rr.time_taken * 1000).to_i}ms"

      logged
    end

    def self.indent(str) # :nodoc:
      indent_str = '  '
      str.split("\n").join("\n" + indent_str)
    end

    def self.query_string_for_logging(query) # :nodoc:
      return unless query && !query.empty?

      '?' + query.collect do |k, v|
        "#{k}=#{v}"
      end.join('&')
    end

    private_class_method :indent, :query_string_for_logging
  end
end
