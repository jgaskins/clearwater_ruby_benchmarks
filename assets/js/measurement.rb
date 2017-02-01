class Measurement
  attr_reader :message

  def self.defaults
    hash = {
      a: 1,
      1 => 2,
    }
    hash2 = {b: 2}

    string = 'Hello, world!'

    array = [1, 2, 3]
    array_strings = %w(a b c)

    deep_subclass = Class.new(Class.new(Class.new(Class.new)))
    sub_object = deep_subclass.new

    string_sub_object = Class.new(Class.new(Class.new(String))).new

    [
      # # Hash
      # Measurement.new('Hash hit, symbol key')  { hash[:a] },
      # Measurement.new('Hash hit, object key')  { hash[1] },
      # Measurement.new('Hash miss, symbol key') { hash[:nope] },
      # Measurement.new('Hash miss, object key') { hash[-10] },
      # Measurement.new('Hash merge')            { hash.merge(hash2) },
      # Measurement.new('Hash merge!')           { hash.merge!(hash) },

      # # String
      # Measurement.new('String concat')     { string + string },
      # Measurement.new('String gsub')       { string.gsub 'world', '' },
      # Measurement.new('String gsub regex') { string.gsub /regex/, '' },

      # # Array
      # Measurement.new('Array insert') { array.dup << 1 },
      # Measurement.new('Array delete') { array.dup.delete 1 },
      # Measurement.new('Array of strings insert') { array_strings.dup << 'd' },
      # Measurement.new('Array of strings delete') { array_strings.dup.delete 'c' },
      # Measurement.new('Array +') { array + array },
      # Measurement.new('Array -') { array - array },
      # Measurement.new('Array &') { array & array },
      # Measurement.new('Array |') { array | array },
      Measurement.new('Array.new, no size') { Array.new },
      Measurement.new('Array.new, with size 10') { Array.new(10) },
      Measurement.new('Array#-, empty arg') { array - [] },

      # # Method
      # Measurement.new('Method#to_proc', &method(:noop)),

      # # Method calls
      # Measurement.new('Method call with positional args') {
      #   positional_method(1, 'two', Object.new)
      # },

      # Measurement.new('Method call with keyword args') {
      #   keyword_method(foo: 1, bar: 'two', baz: Object.new)
      # },

      # Measurement.new('String#$$is_string') { `#{string}.$$is_string` },
      # Measurement.new('StringSubclass#$$is_string') { `#{string_sub_object}.$$is_string` },
      # Measurement.new('Object#is_a? hit') { string.is_a? String },
      # Measurement.new('Object#is_a? superclass hit') { string.is_a? Object },
      # Measurement.new('Object#is_a? deep superclass hit') { sub_object.is_a? Object },
      # Measurement.new('Object#is_a? miss') { string.is_a? Hash },
      # Measurement.new('Class#=== hit') { String === string },
      # Measurement.new('Class#=== superclass hit') { Object === string },
      # Measurement.new('Class#=== deep superclass hit') { Object === sub_object },
      # Measurement.new('Class#=== miss') { Hash === string },
    ]
  end

  def self.noop
  end

  def initialize message, &block
    @message = message
    @block = block
    @iterations = 0
    @total_duration = 0

    if RUBY_ENGINE == 'opal'
      @performance = `performance`
    end
  end

  def rate
    return nil if @total_duration.zero?

    @iterations / @total_duration
  end

  def warmup
    run_duration 0.5, dry_run: true
  end

  def run_iterations iterations
    count = 0

    while count < iterations
      run
      count += 1
    end
  end

  def run_duration duration, dry_run: false
    runtime = 0

    while runtime < duration
      t = run(dry_run: dry_run)
      runtime += t
    end

    runtime
  end

  def run dry_run: false
    start = now
    @block.call
    finish = now
    duration = finish - start

    unless dry_run
      @iterations += 1
      @total_duration += duration
    end

    duration
  end

  def now
    if RUBY_ENGINE == 'opal'
      `#@performance.now() / 1000`
    else
      Time.now
    end
  end

  private # Yes, I know this does nothing in Opal.

  def self.keyword_method(foo:, bar:, baz:)
  end

  def self.positional_method(foo, bar, baz)
  end
end
