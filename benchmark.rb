$: << 'assets/js'

require 'measurement'

benchmarks = Measurement.defaults
width = benchmarks.max_by { |bm| bm.message.length }.message.length

benchmarks.each do |bm|
  print "#{bm.message} warming up..."
  bm.warmup
  print "\r#{bm.message} running      " + (8.chr * 6)
  bm.run_duration 1
  puts "\r%#{width}s: %s iterations per second" % [
    bm.message,
    # Insert a comma for a thousands separator
    bm.rate
      .to_i
      .to_s
      .chars
      .reverse
      .each_slice(3)
      .to_a
      .map(&:join)
      .join(',')
      .reverse
    ]
end
