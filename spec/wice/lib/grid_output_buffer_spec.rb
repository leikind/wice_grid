# encoding: utf-8
module Wice
  describe GridOutputBuffer do
    FILTER_COMMON_CODE = 'here filter code'

    it 'should to_s' do
      grid = GridOutputBuffer.new

      expect(grid.to_s.class).to eq(ActiveSupport::SafeBuffer)
    end

    it 'should add_filter' do
      grid = GridOutputBuffer.new
      expect(grid.add_filter('key', FILTER_COMMON_CODE)).to eq(FILTER_COMMON_CODE)
    end

    it 'should filter_for' do
      grid = GridOutputBuffer.new
      grid.add_filter('key', FILTER_COMMON_CODE)

      expect(grid.filter_for('key')).to eq(FILTER_COMMON_CODE)
    end

    it 'should filter_for 2 times' do
      grid = GridOutputBuffer.new
      grid.add_filter('key', FILTER_COMMON_CODE)

      expect(grid.filter_for('key')).to eq(FILTER_COMMON_CODE)
      expect { grid.filter_for('key') }.to raise_error
    end

    it 'should filter_for without filters' do
      grid = GridOutputBuffer.new

      expect { grid.filter_for('key') }.to raise_error
    end

    it 'should filter_for return empty string' do
      grid = GridOutputBuffer.new

      expect(grid.filter_for('key', true)).to eq('')
    end
  end
end
