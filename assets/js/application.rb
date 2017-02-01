require 'opal'
require 'clearwater'
require 'measurement'

class Layout
  include Clearwater::Component

  attr_reader :benchmarks

  def initialize
    @benchmarks = Measurement.defaults
  end

  def render
    div([
      h1('Benchmarks'),
      p(<<-EOP),
        All iteration rates exclude the overhead of re-rendering. This can cause
        a one-second benchmark to run longer than one second.
      EOP
      input(
        autofocus: true,
        type: :search,
        oninput: method(:filter),
      ),
      button({ onclick: method(:run_all) }, 'Run all'),
      table(
        tbody(filtered_benchmarks.map { |bm|
          tr([
            td(bm.message),
            td(bm.rate.to_i.to_s.chars.reverse.each_slice(3).to_a.map(&:join).join(',').reverse),
            td(button({ onclick: proc { warmup bm } }, 'Warm up')),
            td(button({ onclick: proc { run_duration bm } }, 'Run')),
          ])
        }),
      ),
    ])
  end

  def filter event
    @filter = event.target.value
    call
  end

  def filtered_benchmarks
    benchmarks.select { |bm|
      bm.message =~ Regexp.new(Regexp.escape(@filter.to_s), 'i')
    }
  end

  def run_all
    filtered_benchmarks.each { |bm| run_duration bm }
  end

  def warmup bm
    bm.warmup
  end

  def run_duration bm
    duration = 0
    run = proc do
      duration += bm.run_duration(1/200)
      router.application.render

      if duration < 1
        Bowser.window.animation_frame &run
      end
    end

    run.call
  end

  def run_iterations bm
    iterations = 0
    iterations_per_run = 100_000 / 100

    run = proc do
      bm.run_iterations iterations_per_run
      iterations += iterations_per_run
      router.application.render

      if iterations < 100_000
        Bowser.window.animation_frame &run
      end
    end

    run.call
  end
end


app = Clearwater::Application.new(component: Layout.new)
app.call
