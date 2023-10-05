# frozen_string_literal: true

def format_datetime(datetime)
  datetime.strftime('%Y-%m-%d %H:%M:%S')
end

def unix_to_datetime(unix)
  Time.at(unix / 1000)
end
