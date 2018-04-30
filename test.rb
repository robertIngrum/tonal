require 'wavefile'

OUTPUT_FILENAME     = 'test.wav'
SAMPLE_RATE         = 44100
SECONDS_TO_GENERATE = 1
TWO_PI              = 2 * Math::PI
RANDOM              = Random.new
SAMPLES             = []

def main(wave_type, frequency, max_amplitude)
  SAMPLES << generate(wave_type, SAMPLE_RATE * SECONDS_TO_GENERATE, frequency, max_amplitude)
end

def write
  buffer = WaveFile::Buffer.new(SAMPLES, WaveFile::Format.new(:mono, :float, SAMPLE_RATE))

  WaveFile::Writer.new(OUTPUT_FILENAME, WaveFile::Format.new(:mono, :pcm_16, SAMPLE_RATE)) do |writer|
    writer.write(buffer)
  end
end

def generate(wave_type, num_samples, frequency, max_amplitude)
  position_in_period       = 0.0
  position_in_period_delta = frequency / SAMPLE_RATE
  samples                  = num_samples.times.map { 0.0 }

  num_samples.times do |i|
    samples[i] = case wave_type
		 when :sine
   		   Math::sin(position_in_period * TWO_PI) * max_amplitude
   		 when :square
		   (position_in_period >= 0.5) ? max_amplitude : -max_amplitude
		 when :saw
		   ((position_in_period * 2.0) - 1.0) * max_amplitude
		 when :triangle
		   max_amplitude - (((position_in_period * 2.0) - 1.0) * max_amplitude * 2.0).abs
		 when :noise
		   RANDOM.rand(-max_amplitude..max_amplitude)
  		 else
    		   raise RuntimeError.new('Invalid wave_type')
  		 end

    position_in_period += position_in_period_delta

    position_in_period -= 1.0 while (position_in_period >= 1.0)
  end

  samples
end

main :sine, 440.0, 1.0
main :square, 440.0, 1.0
main :saw, 440.0, 1.0
main :triangle, 440.0, 1.0
main :noise, 440.0, 1.0

write
